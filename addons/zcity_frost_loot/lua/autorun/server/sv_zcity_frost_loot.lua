-- Z-City Frost - map-specific loot for gm_zcity_frost
-- Uses Z-City's native zbox_lootbox entity and Half-Life 2 item crate models.

if not SERVER then return end

local SUPPORTED_MAPS = {
    ["gm_zcity_frost"] = true,
    ["gm_zcity_frost_last"] = true,
    ["gm_zcity_frost_v2"] = true,
    ["gm_zcity_frost_v3"] = true,
    ["gm_zcity_frost_v4"] = true,
    ["gm_zcity_frost_v4_1"] = true,
    ["gm_zcity_frost_v4_2"] = true,
    ["gm_zcity_frost_v4_2_REVORK"] = true,
}

if not SUPPORTED_MAPS[game.GetMap()] then return end

local CRATE_MODELS = {
    "models/props_junk/wood_crate002a.mdl",
    "models/props_junk/wood_crate001a_damaged.mdl",
    "models/props_junk/wood_crate001a.mdl",
    "models/props_c17/FurnitureDresser001a.mdl",
}
local RESPAWN_TIME = 20 * 60

local LOOT = {
    house = {
        {10, "weapon_smallconsumable"},
        {5,  "weapon_bigconsumable"},
        {6,  "weapon_matches"},
        {5,  "weapon_bandage_sh"},
        {3,  "weapon_bigbandage_sh"},
        {4,  "hg_flashlight"},
        {3,  "weapon_ducttape"},
        {2,  "weapon_painkillers"},
    },
    garage = {
        {8, "weapon_ducttape"},
        {6, "weapon_hammer"},
        {6, "weapon_hg_crowbar"},
        {4, "weapon_hg_shovel"},
        {3, "weapon_hg_sledgehammer"},
        {5, "hg_flashlight"},
        {3, "weapon_matches"},
        {2, "weapon_bandage_sh"},
    },
    hunter = {
        {9, "weapon_smallconsumable"},
        {5, "weapon_bigconsumable"},
        {6, "weapon_matches"},
        {5, "hg_flashlight"},
        {5, "weapon_bandage_sh"},
        {4, "weapon_pocketknife"},
        {3, "weapon_hg_axe"},
        {6, "ent_ammo_12/70gauge"},
    },
    military = {
        {8, "weapon_bandage_sh"},
        {6, "weapon_bigbandage_sh"},
        {5, "weapon_painkillers"},
        {5, "weapon_walkie_talkie"},
        {5, "hg_flashlight"},
        {8, "ent_ammo_9x18mm"},
        {8, "ent_ammo_5.45x39mm"},
        {6, "ent_ammo_7.62x39mm"},
        {5, "weapon_makarov"},
        {3, "weapon_ak74u"},
        {2, "weapon_ak74"},
        {1, "weapon_ak203"},
    },
}

local OPTIONAL_MILITARY = {
    {4, "weapon_tt"},
    {4, "weapon_tula_tokarev"},
    {2, "weapon_ak12"},
    {2, "weapon_ak_12"},
}

local POINTS = {
    {id="house_1_a", type="house", pos=Vector(3480,-5000,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_1_b", type="house", pos=Vector(3720,-4900,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_2_a", type="house", pos=Vector(4480,-5000,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_2_b", type="house", pos=Vector(4720,-4900,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_2_basement", type="house", pos=Vector(4500,-5080,40), ang=Angle(0,0,0), min=1, max=2},
    {id="house_3_a", type="house", pos=Vector(5480,-5000,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_3_b", type="house", pos=Vector(5720,-4900,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_4_a", type="house", pos=Vector(3980,-3950,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_4_b", type="house", pos=Vector(4220,-3850,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_4_basement", type="house", pos=Vector(4000,-4030,40), ang=Angle(0,0,0), min=1, max=2},
    {id="house_5_a", type="house", pos=Vector(-5720,-800,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_5_b", type="house", pos=Vector(-5480,-700,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_6_a", type="house", pos=Vector(-5720,400,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_6_b", type="house", pos=Vector(-5480,500,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_6_basement", type="house", pos=Vector(-5700,320,40), ang=Angle(0,0,0), min=1, max=2},
    {id="house_7_a", type="house", pos=Vector(-4570,-800,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_7_b", type="house", pos=Vector(-4330,-700,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_8_a", type="house", pos=Vector(-4570,400,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_8_b", type="house", pos=Vector(-4330,500,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_8_basement", type="house", pos=Vector(-4550,320,40), ang=Angle(0,0,0), min=1, max=2},
    {id="house_9_a", type="house", pos=Vector(-1620,5200,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_9_b", type="house", pos=Vector(-1380,5300,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_10_a", type="house", pos=Vector(-570,5200,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_10_b", type="house", pos=Vector(-330,5300,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_10_basement", type="house", pos=Vector(-550,5120,40), ang=Angle(0,0,0), min=1, max=2},
    {id="house_11_a", type="house", pos=Vector(530,5200,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_11_b", type="house", pos=Vector(770,5300,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_12_a", type="house", pos=Vector(1580,5200,164), ang=Angle(0,90,0), min=1, max=3},
    {id="house_12_b", type="house", pos=Vector(1820,5300,164), ang=Angle(0,0,0), min=1, max=3},
    {id="house_12_basement", type="house", pos=Vector(1600,5120,40), ang=Angle(0,0,0), min=1, max=2},
    {id="hunter_1", hut=1, type="hunter", pos=Vector(-6200,3600,36), ang=Angle(0,20,0), min=2, max=4},
    {id="hunter_2", hut=2, type="hunter", pos=Vector(-3650,6400,36), ang=Angle(0,20,0), min=2, max=4},
    {id="hunter_3", hut=3, type="hunter", pos=Vector(2750,6400,36), ang=Angle(0,20,0), min=2, max=4},
    {id="hunter_4", hut=4, type="hunter", pos=Vector(6350,1800,36), ang=Angle(0,20,0), min=2, max=4},
    {id="hunter_5", hut=5, type="hunter", pos=Vector(6400,-6100,36), ang=Angle(0,20,0), min=2, max=4},
    {id="start_garage_1", type="garage", pos=Vector(-5480,-5820,36), ang=Angle(0,15,0), min=2, max=4},
    {id="start_garage_2", type="garage", pos=Vector(-5120,-5980,36), ang=Angle(0,90,0), min=2, max=4},
    {id="service_1", type="garage", pos=Vector(2520,830,36), ang=Angle(0,15,0), min=2, max=4},
    {id="service_2", type="garage", pos=Vector(2880,670,36), ang=Angle(0,90,0), min=2, max=4},
    {id="mil_1_main", type="military", pos=Vector(4400,4200,164), ang=Angle(0,0,0), min=2, max=4},
    {id="mil_1_basement", type="military", pos=Vector(4650,4130,40), ang=Angle(0,90,0), min=2, max=4},
    {id="mil_2_main", type="military", pos=Vector(5550,4200,164), ang=Angle(0,0,0), min=2, max=4},
    {id="mil_2_basement", type="military", pos=Vector(5800,4130,40), ang=Angle(0,90,0), min=2, max=4},
    {id="mil_garage", type="military", pos=Vector(5100,5600,36), ang=Angle(0,0,0), min=2, max=4},
}

local crates = {}
local armedHut = 1

local function activePoints()
    return POINTS
end

local function classExists(class)
    if weapons.GetStored(class) then return true end
    if scripted_ents.GetStored(class) then return true end
    return false
end

local function buildWeighted(source)
    local t = {}
    for _, entry in ipairs(source or {}) do
        if classExists(entry[2]) then
            t[#t + 1] = {weight = entry[1], class = entry[2]}
        end
    end
    return t
end

local function weightedPick(tbl)
    local total = 0
    for _, v in ipairs(tbl) do total = total + v.weight end
    if total <= 0 then return nil end
    local roll = math.Rand(0, total)
    local sum = 0
    for _, v in ipairs(tbl) do
        sum = sum + v.weight
        if roll <= sum then return v.class end
    end
    return tbl[#tbl] and tbl[#tbl].class or nil
end

local function makeLoot(point)
    local source = {}
    for _, e in ipairs(LOOT[point.type] or {}) do source[#source+1] = e end

    if point.type == "military" then
        for _, e in ipairs(OPTIONAL_MILITARY) do source[#source+1] = e end
    end

    local weighted = buildWeighted(source)
    local result = {}
    local count = math.random(point.min or 1, point.max or 3)

    if point.hut and point.hut == armedHut and classExists("weapon_doublebarrel") then
        result[#result + 1] = {class = "weapon_doublebarrel"}
        if classExists("ent_ammo_12/70gauge") then
            result[#result + 1] = {class = "ent_ammo_12/70gauge"}
        end
        count = math.max(0, count - 1)
    end

    for i = 1, count do
        local class = weightedPick(weighted)
        if class then result[#result + 1] = {class = class} end
    end

    return result
end

local function removeOurCrates()
    for _, ent in pairs(crates) do
        if IsValid(ent) then ent:Remove() end
    end
    crates = {}

    for _, ent in ipairs(ents.FindByClass("zbox_lootbox")) do
        if ent.ZCityFrostLoot then ent:Remove() end
    end
end

local function findGroundPos(pos, ent)
    local tr = util.TraceEntityHull({
        start = pos + Vector(0,0,96),
        endpos = pos - Vector(0,0,256),
        filter = ent,
        mask = MASK_SOLID,
    }, ent)
    return tr.Hit and (tr.HitPos + Vector(0,0,2)) or pos
end

local function spawnPoint(point)
    if not scripted_ents.GetStored("zbox_lootbox") then
        print("[ZC Frost Loot] zbox_lootbox is missing. Is Z-City loaded?")
        return
    end

    local ent = ents.Create("zbox_lootbox")
    if not IsValid(ent) then return end

    ent.Model = point.model or table.Random(CRATE_MODELS)
    ent.CanGenerate = false
    ent.ZCityFrostLoot = true
    ent.ZCityFrostLootID = point.id
    ent:SetPos(point.pos)
    ent:SetAngles(point.ang or angle_zero)
    ent:Spawn()
    ent:SetPos(findGroundPos(point.pos, ent))
    ent:SetAngles(point.ang or angle_zero)
    ent.Loot = makeLoot(point)

    -- Keep loot containers as real movable physics props.
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetSolid(SOLID_VPHYSICS)
    ent:SetCollisionGroup(COLLISION_GROUP_NONE)

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(true)
        phys:EnableGravity(true)
        phys:EnableCollisions(true)
        phys:Wake()

        -- Make big furniture feel heavier than wooden crates.
        if ent.Model == "models/props_c17/FurnitureDresser001a.mdl" then
            phys:SetMass(math.max(phys:GetMass(), 75))
        else
            phys:SetMass(math.max(phys:GetMass(), 35))
        end
    end

    crates[point.id] = ent
    return ent
end

hook.Add("EntityTakeDamage", "ZCityFrostLoot_PhysicsDamage", function(ent, dmg)
    if not IsValid(ent) or not ent.ZCityFrostLoot then return end

    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return end

    local force = dmg:GetDamageForce()
    if force:IsZero() and IsValid(dmg:GetAttacker()) then
        force = dmg:GetAttacker():GetAimVector() * math.max(dmg:GetDamage(), 10) * 450
    end

    if not force:IsZero() then
        phys:Wake()
        phys:ApplyForceOffset(force, dmg:GetDamagePosition())
    end
end)

local function spawnAll()
    removeOurCrates()
    armedHut = math.random(1, 5)
    for _, point in ipairs(activePoints()) do
        spawnPoint(point)
    end
    print(string.format("[ZC Frost Loot] Spawned %d loot crates. Double-barrel cabin: %d", #POINTS, armedHut))
end

hook.Add("InitPostEntity", "ZCityFrostLoot_Init", function()
    timer.Simple(3, spawnAll)
end)

hook.Add("PostCleanupMap", "ZCityFrostLoot_Cleanup", function()
    timer.Simple(1, spawnAll)
end)

timer.Create("ZCityFrostLoot_Maintenance", 30, 0, function()
    for _, point in ipairs(activePoints()) do
        local ent = crates[point.id]
        if not IsValid(ent) then
            spawnPoint(point)
        elseif (not ent.Loot or #ent.Loot == 0) then
            ent.ZCityFrostEmptySince = ent.ZCityFrostEmptySince or CurTime()
            if CurTime() - ent.ZCityFrostEmptySince >= RESPAWN_TIME then
                ent.Loot = makeLoot(point)
                ent.ZCityFrostEmptySince = nil
            end
        else
            ent.ZCityFrostEmptySince = nil
        end
    end
end)

concommand.Add("zc_frost_loot_respawn", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    spawnAll()
end)
