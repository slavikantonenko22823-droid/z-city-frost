if not SERVER then return end

AddCSLuaFile("autorun/client/cl_zcity_frost_cold.lua")

ZCFrost = ZCFrost or {}
local ZCF = ZCFrost

local SUPPORTED_MAPS = {
    ["gm_zcity_frost"] = true,
    ["gm_zcity_frost_v4_1"] = true,
    ["gm_zcity_frost_v4"] = true,
    ["gm_zcity_frost_v3"] = true,
    ["gm_zcity_frost_v2"] = true,
}

local cvOutdoorTime = CreateConVar(
    "zc_frost_cold_outdoor_time",
    "480",
    bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY),
    "Seconds for an unprotected player to fill the cold meter outdoors.",
    60,
    3600
)

local cvIndoorTime = CreateConVar(
    "zc_frost_cold_indoor_time",
    "1500",
    bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY),
    "Seconds for an unprotected player to fill the cold meter indoors.",
    120,
    7200
)

local cvGraceTime = CreateConVar(
    "zc_frost_cold_grace_time",
    "120",
    bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY),
    "Seconds the player remains functional after the cold meter reaches 100.",
    10,
    600
)

local cvSleepTime = CreateConVar(
    "zc_frost_cold_sleep_time",
    "12",
    bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY),
    "Seconds of the final falling-asleep phase before death.",
    3,
    60
)

local cvHeatRecovery = CreateConVar(
    "zc_frost_cold_heat_recovery",
    "1.75",
    bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY),
    "Cold-meter points removed per second at heat power 1.",
    0.1,
    10
)

local cvHeatRadius = CreateConVar(
    "zc_frost_cold_heat_radius",
    "300",
    bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY),
    "Base heat-source radius.",
    64,
    1000
)

local cvCheckpointTime = CreateConVar(
    "zc_frost_cold_checkpoint_time",
    "12",
    bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY),
    "Seconds near a valid fire before it becomes the respawn checkpoint.",
    2,
    120
)

local function IsSupportedMap()
    return SUPPORTED_MAPS[game.GetMap()] == true
end

local function Notify(ply, msg)
    if not IsValid(ply) then return end
    ply:ChatPrint("[Frost] " .. msg)
end

local function GetCharacterPos(ply)
    if hg and hg.GetCurrentCharacter then
        local ent = hg.GetCurrentCharacter(ply)
        if IsValid(ent) then
            return ent:GetPos()
        end
    end
    return ply:GetPos()
end

local function IsOutdoors(ply)
    if ply:InVehicle() then return false end

    local pos = GetCharacterPos(ply)
    local tr = util.TraceLine({
        start = pos + Vector(0, 0, 24),
        endpos = pos + Vector(0, 0, 32000),
        filter = ply,
        mask = MASK_SOLID_BRUSHONLY
    })

    return tr.HitSky == true
end

local function GetInsulation(ply)
    local total = 0
    local clothes = ply.GetNetVar and ply:GetNetVar("zc_clothes", {}) or {}

    if istable(clothes) then
        for _, entIndex in ipairs(clothes) do
            local cloth = Entity(entIndex)
            if IsValid(cloth) and isnumber(cloth.WarmSave) then
                total = total + math.max(cloth.WarmSave, 0)
            end
        end
    end

    return math.Clamp(total * 0.55, 0, 0.80)
end

function ZCF.RegisterHeatSource(ent, power, owner, checkpointEligible)
    if not IsValid(ent) then return end
    ent.ZCFrostHeat = math.max(tonumber(power) or 1, 0)
    ent.ZCFrostFireOwner = IsValid(owner) and owner or nil
    ent.ZCFrostCheckpointEligible = checkpointEligible ~= false
end

local function GetHeatPower(ply)
    local pos = GetCharacterPos(ply)
    local baseRadius = cvHeatRadius:GetFloat()

    local totalPower = 0
    local bestEnt = nil
    local bestContribution = 0
    local bestCheckpointEligible = false

    for _, ent in ipairs(ents.FindInSphere(pos, baseRadius)) do
        if not IsValid(ent) then continue end

        local class = ent:GetClass()
        local power = 0
        local checkpointEligible = false

        if isnumber(ent.ZCFrostHeat) then
            power = math.max(ent.ZCFrostHeat, 0)
            checkpointEligible = ent.ZCFrostCheckpointEligible ~= false
        elseif class == "env_fire" then
            power = 1
            checkpointEligible = true
        elseif class == "vfire" then
            if ent.GetFireState then
                power = math.Clamp(tonumber(ent:GetFireState()) or 0, 0, 1.5)
            else
                power = 0.8
            end
            checkpointEligible = true
        elseif ent:IsOnFire() then
            power = 0.35
            checkpointEligible = false
        end

        if power > 0 then
            local distance = pos:Distance(ent:GetPos())
            local falloff = math.Clamp(1 - distance / baseRadius, 0, 1)
            local contribution = power * falloff

            totalPower = totalPower + contribution

            if contribution > bestContribution then
                bestContribution = contribution
                bestEnt = ent
                bestCheckpointEligible = checkpointEligible
            end
        end
    end

    return math.Clamp(totalPower, 0, 2.5), bestEnt, bestCheckpointEligible
end

local function FindSafePosition(ply, pos)
    local down = util.TraceLine({
        start = pos + Vector(0, 0, 64),
        endpos = pos - Vector(0, 0, 256),
        filter = ply,
        mask = MASK_SOLID
    })

    local base = down.Hit and (down.HitPos + Vector(0, 0, 4)) or pos

    local offsets = {
        Vector(0, 0, 0),
        Vector(48, 0, 0),
        Vector(-48, 0, 0),
        Vector(0, 48, 0),
        Vector(0, -48, 0),
        Vector(48, 48, 0),
        Vector(-48, 48, 0),
        Vector(48, -48, 0),
        Vector(-48, -48, 0),
    }

    for _, off in ipairs(offsets) do
        local candidate = base + off
        local hull = util.TraceHull({
            start = candidate,
            endpos = candidate,
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 72),
            filter = ply,
            mask = MASK_PLAYERSOLID
        })

        if not hull.Hit then
            return candidate
        end
    end

    return nil
end

function ZCF.SetCheckpoint(ply, pos, ang, source)
    if not IsValid(ply) or not ply:IsPlayer() then return false end

    local safe = FindSafePosition(ply, pos or ply:GetPos())
    if not safe then return false end

    ply.ZCFrostCheckpoint = safe
    ply.ZCFrostCheckpointAng = ang or Angle(0, ply:EyeAngles().y, 0)
    ply.ZCFrostCheckpointSource = IsValid(source) and source or nil

    Notify(ply, "Огонь запомнен как последняя точка обогрева.")
    return true
end

local function SetPhase(ply, phase)
    ply.ZCFrostPhase = phase
    ply:SetNWInt("ZCFrostPhase", phase)
end

local function SetCold(ply, value)
    value = math.Clamp(value, 0, 100)
    ply.ZCFrostCold = value
    ply:SetNWFloat("ZCFrostCold", value)
end

local function CancelCritical(ply)
    SetPhase(ply, 0)
    ply.ZCFrostCriticalEnd = nil
    ply:SetNWFloat("ZCFrostCriticalEnd", 0)
end

local function StartCritical(ply)
    if ply.ZCFrostPhase and ply.ZCFrostPhase > 0 then return end

    SetPhase(ply, 1)
    ply.ZCFrostCriticalEnd = CurTime() + cvGraceTime:GetFloat()
    ply:SetNWFloat("ZCFrostCriticalEnd", ply.ZCFrostCriticalEnd)

    Notify(ply, "Шкала холода заполнена. У тебя ещё 2 минуты, чтобы найти тепло.")
end

local function StartSleep(ply)
    if not IsValid(ply) or not ply:Alive() then return end

    SetPhase(ply, 2)
    ply.ZCFrostSleepEnd = CurTime() + cvSleepTime:GetFloat()
    ply:SetNWFloat("ZCFrostSleepEnd", ply.ZCFrostSleepEnd)
    ply:SetNWFloat("ZCFrostSleepDuration", cvSleepTime:GetFloat())

    ply:Freeze(true)
    Notify(ply, "Ты больше не можешь сопротивляться холоду...")
end

local function KillFromCold(ply)
    if not IsValid(ply) or not ply:Alive() then return end

    ply.ZCFrostColdDeath = true
    ply.ZCFrostRespawnPending = ply.ZCFrostCheckpoint ~= nil

    ply:Freeze(false)
    ply:Kill()
end

local function UpdateBodyTemperature(ply, cold)
    if not ply.organism then return end

    local target = 36.7 - (cold / 100) * 1.5

    if (ply.ZCFrostPhase or 0) == 2 then
        target = 34.5
    end

    ply.organism.temperature = math.Clamp(target, 34.5, 36.7)
end

local function UpdateCheckpoint(ply, dt, heatPower, heatEnt, checkpointEligible)
    if heatPower < 0.20 or not checkpointEligible or not IsValid(heatEnt) then
        ply.ZCFrostCheckpointWarmTime = 0
        ply.ZCFrostCheckpointCandidate = nil
        return
    end

    if ply.ZCFrostCheckpointCandidate ~= heatEnt then
        ply.ZCFrostCheckpointCandidate = heatEnt
        ply.ZCFrostCheckpointWarmTime = 0
    end

    ply.ZCFrostCheckpointWarmTime = (ply.ZCFrostCheckpointWarmTime or 0) + dt

    if ply.ZCFrostCheckpointWarmTime >= cvCheckpointTime:GetFloat() then
        if ply.ZCFrostCheckpointSource ~= heatEnt then
            ZCF.SetCheckpoint(ply, ply:GetPos(), Angle(0, ply:EyeAngles().y, 0), heatEnt)
        end

        ply.ZCFrostCheckpointWarmTime = -999999
    end
end

local function UpdatePlayer(ply, dt)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    ply:SetNWBool("ZCFrostEnabled", true)

    if not ply:Alive() then return end

    local phase = ply.ZCFrostPhase or 0
    local cold = ply.ZCFrostCold or 0
    local outdoors = IsOutdoors(ply)
    local insulation = GetInsulation(ply)
    local heatPower, heatEnt, checkpointEligible = GetHeatPower(ply)

    ply:SetNWBool("ZCFrostOutdoors", outdoors)
    ply:SetNWFloat("ZCFrostInsulation", insulation)
    ply:SetNWFloat("ZCFrostHeatPower", heatPower)

    UpdateCheckpoint(ply, dt, heatPower, heatEnt, checkpointEligible)

    if phase ~= 2 then
        if heatPower > 0.05 then
            cold = cold - cvHeatRecovery:GetFloat() * heatPower * dt
        else
            local secondsToFull = outdoors and cvOutdoorTime:GetFloat() or cvIndoorTime:GetFloat()
            local rate = 100 / math.max(secondsToFull, 1)

            if ply:InVehicle() then
                rate = rate * 0.65
            end

            if ply:GetVelocity():Length2D() > 125 then
                rate = rate * 0.85
            end

            rate = rate * (1 - insulation)
            cold = cold + rate * dt
        end

        SetCold(ply, cold)
    end

    cold = ply.ZCFrostCold or 0

    if phase == 0 then
        if cold >= 100 then
            StartCritical(ply)
        end
    elseif phase == 1 then
        if cold <= 94 then
            CancelCritical(ply)
            Notify(ply, "Ты успел согреться. Критическое переохлаждение отступает.")
        elseif CurTime() >= (ply.ZCFrostCriticalEnd or math.huge) then
            StartSleep(ply)
        end
    elseif phase == 2 then
        if CurTime() >= (ply.ZCFrostSleepEnd or math.huge) then
            KillFromCold(ply)
        end
    end

    UpdateBodyTemperature(ply, cold)
end

timer.Create("ZCFrostCold_Update", 0.5, 0, function()
    if not IsSupportedMap() then return end

    for _, ply in ipairs(player.GetAll()) do
        UpdatePlayer(ply, 0.5)
    end
end)

hook.Add("PlayerInitialSpawn", "ZCFrostCold_InitPlayer", function(ply)
    if not IsSupportedMap() then return end

    SetCold(ply, 0)
    SetPhase(ply, 0)
    ply:SetNWBool("ZCFrostEnabled", true)
end)

hook.Add("PlayerSpawn", "ZCFrostCold_Respawn", function(ply)
    if not IsSupportedMap() then return end

    ply:Freeze(false)
    SetPhase(ply, 0)
    ply:SetNWFloat("ZCFrostCriticalEnd", 0)
    ply:SetNWFloat("ZCFrostSleepEnd", 0)

    local wasColdDeath = ply.ZCFrostColdDeath == true
    local shouldReturn = wasColdDeath and ply.ZCFrostRespawnPending and ply.ZCFrostCheckpoint ~= nil

    ply.ZCFrostColdDeath = nil
    ply.ZCFrostRespawnPending = nil

    if wasColdDeath then
        SetCold(ply, shouldReturn and 15 or 0)
    else
        SetCold(ply, 0)
    end

    if not shouldReturn then return end

    timer.Simple(0.25, function()
        if not IsValid(ply) or not ply:Alive() then return end
        if not ply.ZCFrostCheckpoint then return end

        local safe = FindSafePosition(ply, ply.ZCFrostCheckpoint)
        if not safe then return end

        ply:SetPos(safe)
        if ply.ZCFrostCheckpointAng then
            ply:SetEyeAngles(ply.ZCFrostCheckpointAng)
        end

        Notify(ply, "Ты очнулся возле последнего места, где грелся у огня.")
    end)
end)

hook.Add("PlayerDisconnected", "ZCFrostCold_Cleanup", function(ply)
    ply.ZCFrostCheckpoint = nil
    ply.ZCFrostCheckpointSource = nil
end)

concommand.Add("zc_frost_cold_set", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then return end

    local target = IsValid(ply) and ply or player.GetAll()[1]
    if not IsValid(target) then return end

    local value = math.Clamp(tonumber(args[1]) or 0, 0, 100)
    SetCold(target, value)

    if value < 100 then
        CancelCritical(target)
    end
end)

concommand.Add("zc_frost_checkpoint_here", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    ZCF.SetCheckpoint(ply, ply:GetPos(), Angle(0, ply:EyeAngles().y, 0))
end)

print("[ZC Frost Cold] Loaded for " .. game.GetMap())
