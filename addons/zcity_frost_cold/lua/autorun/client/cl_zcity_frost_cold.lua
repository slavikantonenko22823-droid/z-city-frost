if not CLIENT then return end

surface.CreateFont("ZCFrostColdLabel", {
    font = "Roboto",
    size = 18,
    weight = 700,
    antialias = true
})

surface.CreateFont("ZCFrostColdSmall", {
    font = "Roboto",
    size = 15,
    weight = 600,
    antialias = true
})

surface.CreateFont("ZCFrostColdCritical", {
    font = "Roboto",
    size = 24,
    weight = 900,
    antialias = true
})

local lerpedCold = 0

local function FormatTime(seconds)
    seconds = math.max(math.ceil(seconds), 0)
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%d:%02d", m, s)
end

hook.Add("HUDPaint", "ZCFrostCold_HUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:GetNWBool("ZCFrostEnabled", false) then return end

    local cold = ply:GetNWFloat("ZCFrostCold", 0)
    local phase = ply:GetNWInt("ZCFrostPhase", 0)
    local heat = ply:GetNWFloat("ZCFrostHeatPower", 0)
    local insulation = ply:GetNWFloat("ZCFrostInsulation", 0)
    local outdoors = ply:GetNWBool("ZCFrostOutdoors", false)

    lerpedCold = Lerp(FrameTime() * 6, lerpedCold, cold)

    local sw, sh = ScrW(), ScrH()
    local w = math.Clamp(sw * 0.18, 250, 360)
    local h = 18
    local x = sw * 0.035
    local y = sh * 0.79

    draw.SimpleText("ХОЛОД", "ZCFrostColdLabel", x, y - 24, Color(225, 235, 245), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(math.floor(lerpedCold + 0.5) .. "%", "ZCFrostColdSmall", x + w, y - 21, Color(205, 220, 235), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    draw.RoundedBox(3, x, y, w, h, Color(12, 16, 20, 210))

    local fill = math.Clamp(lerpedCold / 100, 0, 1)
    local fillW = math.floor((w - 4) * fill)

    if fillW > 0 then
        draw.RoundedBox(2, x + 2, y + 2, fillW, h - 4, Color(80, 145, 205, 230))
    end

    surface.SetDrawColor(145, 185, 220, 180)
    surface.DrawOutlinedRect(x, y, w, h, 1)

    local stateText
    if heat > 0.10 then
        stateText = "У ОГНЯ"
    elseif outdoors then
        stateText = "НА УЛИЦЕ"
    else
        stateText = "В УКРЫТИИ"
    end

    draw.SimpleText(
        stateText .. "   •   УТЕПЛЕНИЕ " .. math.floor(insulation * 100 + 0.5) .. "%",
        "ZCFrostColdSmall",
        x,
        y + h + 6,
        heat > 0.10 and Color(235, 190, 115) or Color(175, 195, 210),
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_TOP
    )

    if phase == 1 then
        local remaining = ply:GetNWFloat("ZCFrostCriticalEnd", 0) - CurTime()

        draw.SimpleText(
            "КРИТИЧЕСКОЕ ПЕРЕОХЛАЖДЕНИЕ",
            "ZCFrostColdCritical",
            sw / 2,
            sh * 0.18,
            Color(210, 225, 240),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )

        draw.SimpleText(
            "Найди тепло: " .. FormatTime(remaining),
            "ZCFrostColdLabel",
            sw / 2,
            sh * 0.18 + 31,
            Color(160, 195, 225),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    elseif phase == 2 then
        local sleepEnd = ply:GetNWFloat("ZCFrostSleepEnd", CurTime())
        local total = math.max(sleepEnd - CurTime(), 0)
        local duration = math.max(ply:GetNWFloat("ZCFrostSleepDuration", 12), 1)
        local progress = 1 - math.Clamp(total / duration, 0, 1)
        local alpha = math.floor(80 + progress * 165)

        surface.SetDrawColor(0, 0, 0, alpha)
        surface.DrawRect(0, 0, sw, sh)

        draw.SimpleText(
            "ТЫ ЗАСЫПАЕШЬ...",
            "ZCFrostColdCritical",
            sw / 2,
            sh * 0.48,
            Color(200, 215, 230, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end
end)
