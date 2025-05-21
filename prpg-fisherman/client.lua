local sw, sh = guiGetScreenSize()
local zoom = 1920/sw

local textures = {
    bg = dxCreateTexture("/images/bg.png", "argb", true, "clamp"),
    gradient = dxCreateTexture("/images/gradient.png", "argb", true, "clamp"),
    hook = dxCreateTexture("/images/hook.png", "argb", true, "clamp"),
    ["Tunczyk"] = dxCreateTexture("/images/fishes/Tunczyk.png", "argb", true, "clamp"),
    ["Pstrag"] = dxCreateTexture("/images/fishes/Pstrag.png", "argb", true, "clamp"),
    ["Wegorz"] = dxCreateTexture("/images/fishes/Wegorz.png", "argb", true, "clamp"),
    ["Szczupak"] = dxCreateTexture("/images/fishes/Szczupak.png", "argb", true, "clamp"),
    ["Dorsz"] = dxCreateTexture("/images/fishes/Dorsz.png", "argb", true, "clamp"),
    ["Sum"] = dxCreateTexture("/images/fishes/Sum.png", "argb", true, "clamp"),
    ["Sandacz"] = dxCreateTexture("/images/fishes/Sandacz.png", "argb", true, "clamp"),
    ["Rekin"] = dxCreateTexture("/images/fishes/Rekin.png", "argb", true, "clamp"),
    ["Jesiotr"] = dxCreateTexture("/images/fishes/Jesiotr.png", "argb", true, "clamp"),
    ["Okon"] = dxCreateTexture("/images/fishes/Okon.png", "argb", true, "clamp"),
    ["Lin"] = dxCreateTexture("/images/fishes/Lin.png", "argb", true, "clamp"),
    ["Karp"] = dxCreateTexture("/images/fishes/Karp.png", "argb", true, "clamp"),
    ["Miecznik"] = dxCreateTexture("/images/fishes/Miecznik.png", "argb", true, "clamp"),
    ["Makrela"] = dxCreateTexture("/images/fishes/Makrela.png", "argb", true, "clamp"),
}

local gui_positions = {
    bgTarget = {x = 0, y = 0, w = 510, h = 225},
    fish = {x = 0, y = 0, w = 64, h = 64},
    bg = {x = sw/2-255/zoom, y = sh/2+250/zoom, w = 510/zoom, h = 225/zoom},
    bg_pull = {x = sw/2-255/zoom, y = sh/2+200/zoom, w = 510/zoom, h = 41/zoom},
    text = {x = sw/2-255/zoom, y = sh/2+160/zoom, w = 510/zoom, h = 41/zoom},
    space_text = {x = sw/2-255/zoom, y = sh/2+245/zoom, w = 510/zoom, h = 41/zoom},
    line = {x = sw/2/zoom, y = sh/2+250/zoom},
    hook = {w = 32/zoom, h = 32/zoom},
    upgrades = {x = sw/2+300/zoom, y = sh-275/zoom, w = 100/zoom, h = 50/zoom},
}

local settings = {
    fishing = false,
    renderTarget = dxCreateRenderTarget(510/zoom, 225/zoom, true),
    respawnTimer = nil,
    startFishingTimer = nil,
}

local fonts = {
    roboto = dxCreateFont("roboto.ttf", 8),
    roboto_b = dxCreateFont("roboto.ttf", 12),
    roboto_m = dxCreateFont("roboto.ttf", 10),
}

local fishingRodUpgrades = {}
local fishes = {}

addEventHandler("onClientKey", root, function(k, s)
    if k == "mouse1" and s then

        if isCursorShowing() or isConsoleActive() then return end
        if getPedWeapon(localPlayer) ~= 15 then return end
        if isElementInWater(localPlayer) then return end
        if settings.fishing then return end

        local px, py, pz = getElementPosition(localPlayer)
        local cuboid = createColSphere(px + 10, py, pz, 1)
        exports["prpg-bone_attach"]:attachElementToBone(cuboid, localPlayer, 1, 0, 3)

        setTimer(function()
            local cx, cy, cz = unpack(exports["prpg-bone_attach"]:getAttachedPosition(cuboid))
            local ground = getGroundPosition(cx, cy, cz)
            if testLineAgainstWater(cx, cy, cz, cx, cy, ground) then
                if getElementSpeed(localPlayer, "km/h") > 1 then return end
                getFishingRodUpgrades()
                setTimer(startFishing, 10, 1, true)
            end
            destroyElement(cuboid)
        end, 100, 1)

    end
end)

fishingRenderTarget = function()
    local zone = getPlayerZone()
    dxSetRenderTarget(settings.renderTarget, true)
        dxDrawImage(gui_positions.bgTarget.x, gui_positions.bgTarget.y, gui_positions.bgTarget.w, gui_positions.bgTarget.h, zone.water)
        for _, fish in ipairs(fishes) do
            local rotation = fish.fromX > 0 and -1 or 1
            local positionX = fish.fromX > 0 and fish.x + gui_positions.fish.w or fish.x
            dxDrawImage(positionX, fish.y, rotation * gui_positions.fish.w, gui_positions.fish.h, fish.texture)
        end
    dxSetRenderTarget()
end

renderFishing = function()
    fishingRenderTarget()
    dxDrawImage(gui_positions.bg.x, gui_positions.bg.y, gui_positions.bg.w, gui_positions.bg.h, settings.renderTarget)
    for i, fish in ipairs(fishes) do
        if not fish.pullingOut then
            fish.x = interpolateBetween(fish.fromX, 0, 0, fish.toX, 0, 0, (getTickCount()-fish.tick)/fish.speedX, "Linear")
            fish.y = interpolateBetween(fish.fromY, 0, 0, fish.toY, 0, 0, (getTickCount()-fish.tick)/fish.speedY, "SineCurve")
            if (getTickCount() > fish.tick + fish.speedX + 100) then
                table.remove(fishes, i)
            end
        else
            dxDrawLine(fish.x + gui_positions.bg.x + 32/zoom, fish.y + gui_positions.bg.y + 32/zoom, gui_positions.line.x, gui_positions.line.y, tocolor(150, 75, 0), 3, true)
            dxDrawImage(fish.x + gui_positions.bg.x + 26/zoom, fish.y + gui_positions.bg.y + 30/zoom, gui_positions.hook.w, gui_positions.hook.h, textures.hook)
        end
    end

    if (getTableLength(fishingRodUpgrades.perks) > 0) then
        dxDrawText("Aktywne boosty:", gui_positions.upgrades.x + 1, gui_positions.upgrades.y + 1, gui_positions.upgrades.w + gui_positions.upgrades.x + 1, gui_positions.upgrades.h + gui_positions.upgrades.y + 1, tocolor(0, 0, 0), 1.00, fonts.roboto_m, "center", "center")
        dxDrawText("Aktywne boosty:", gui_positions.upgrades.x, gui_positions.upgrades.y, gui_positions.upgrades.w + gui_positions.upgrades.x, gui_positions.upgrades.h + gui_positions.upgrades.y, white, 1.00, fonts.roboto_m, "center", "center")
        
        i = 0
        for k, upgrade in pairs(fishingRodUpgrades.perks) do
            i = i + 1
            local offsetY = (20/zoom) * (i)
            dxDrawText("+" .. upgrade .. "% na złowienie " .. k, gui_positions.upgrades.x + 1, gui_positions.upgrades.y + offsetY + 1, gui_positions.upgrades.w + gui_positions.upgrades.x + 1, gui_positions.upgrades.h + gui_positions.upgrades.y + offsetY + 1, tocolor(0, 0, 0), 1.00, fonts.roboto_m, "center", "center")
            dxDrawText("#a0a0a0+" .. upgrade .. "% #ffffffna złowienie #a0a0a0" .. k, gui_positions.upgrades.x, gui_positions.upgrades.y + offsetY, gui_positions.upgrades.w + gui_positions.upgrades.x, gui_positions.upgrades.h + gui_positions.upgrades.y + offsetY, white, 1.00, fonts.roboto_m, "center", "center", _, _, _, true)
        end
    end

end

---------------------------------------------------------------

renderPullingOut = function()
    dxDrawImage(gui_positions.bg_pull.x, gui_positions.bg_pull.y, gui_positions.bg_pull.w, gui_positions.bg_pull.h, textures.bg, 0, 0, 0, tocolor(216, 175, 0))
    settings.pullingProgress = settings.pullingProgress - 0.1 * math.ceil(settings.fishInfo.weight / 200)
    dxDrawImageSection(gui_positions.bg_pull.x, gui_positions.bg_pull.y, gui_positions.bg_pull.w * (settings.pullingProgress or 0)/100, gui_positions.bg_pull.h, 0, 0, 510 * (settings.pullingProgress or 0)/100, 41, textures.gradient)
    dxDrawText(string.format("%s %0.2fkg", settings.fishInfo.fish, settings.fishInfo.weight), gui_positions.text.x + 1, gui_positions.text.y + 1, gui_positions.text.w + gui_positions.text.x + 1, gui_positions.text.h + gui_positions.text.y + 1, tocolor(0,0,0), 1.00, fonts.roboto_b, "center", "center")
    dxDrawText(string.format("%s %0.2fkg", settings.fishInfo.fish, settings.fishInfo.weight), gui_positions.text.x, gui_positions.text.y, gui_positions.text.w + gui_positions.text.x, gui_positions.text.h + gui_positions.text.y, white, 1.00, fonts.roboto_b, "center", "center")
    dxDrawText("wciskaj spacje, aby wciągnąć rybe", gui_positions.bg_pull.x, gui_positions.bg_pull.y, gui_positions.bg_pull.w + gui_positions.bg_pull.x, gui_positions.bg_pull.h + gui_positions.bg_pull.y, white, 1.00, fonts.roboto, "center", "center")
    if settings.pullingProgress <= 0 then
        startFishing(false)
        exports["prpg-notifications"]:newNotification("error", "Ryba uciekła.")
    elseif settings.pullingProgress >= 100 then
        exports["prpg-notifications"]:newNotification("success", "Udalo Ci się złowić rybe.")
        local slot, condition = getFishingRodInfo()
        local uniqueFishingRod = getPlayerZone().uniqueFishingRod or false
        triggerServerEvent("fish->addItem", resourceRoot, {name = settings.fishInfo.fish, weight = settings.fishInfo.weight}, uniqueFishingRod)
        triggerServerEvent("fish->setCondition", resourceRoot, slot, condition - tonumber(string.format("%0.2f", settings.fishInfo.weight/100)))
        triggerServerEvent("fish->setFishList", resourceRoot, slot, settings.fishInfo.fish, tonumber(string.format("%0.2f", settings.fishInfo.weight)))
        startFishing(false)
    end
end

pullOutFishClick = function(b,s)
    if b == "left" and s == "down" then
        if not isMouseInPosition(gui_positions.bg.x, gui_positions.bg.y, gui_positions.bg.w, gui_positions.bg.h) then return end
        if #fishes <= 0 then exports["prpg-notifications"]:newNotification("error", "Przynęta się urwała."); startFishing(false) return end
        
        for i, fish in ipairs(fishes) do
            if isMouseInPosition(fish.x + gui_positions.bg.x, fish.y + gui_positions.bg.y, gui_positions.fish.w, gui_positions.fish.h) then
                settings.pulling = true
                fish.pullingOut = true
                settings.pullingProgress = math.random(40, 60)
                settings.fishInfo = fish
                settings.spaceTick = getTickCount()
                addEventHandler("onClientRender", root, renderPullingOut)
                addEventHandler("onClientKey", root, spacePullOut)
                removeEventHandler("onClientClick", root, pullOutFishClick)
                return
            end
        end
        if not settings.pulling then
            exports["prpg-notifications"]:newNotification("error", "Przynęta się urwała.")
            startFishing(false)
        end
    end
end

spacePullOut = function(b, press)
    if b == "space" and press then
        settings.pullingProgress = settings.pullingProgress + math.ceil(settings.fishInfo.weight / 200) + 2
    end
end

---------------------------------------------------------------

dodajRybe = function(fish, fromX, toX, speedX, fromY, toY, speedY, weight, texture)
    table.insert(fishes, {
        fish = fish,
        fromX = fromX,
        toX = toX,
        speedX = speedX,
        fromY = fromY,
        toY = toY,
        speedY = speedY,
        x = fromX,
        y = fromY,
        tick = getTickCount(),
        weight = weight,
        texture = texture
    })
end

dR = function()
    local zone = getPlayerZone()
    local respawn = drawRespawning(zone.respawnPercentage + fishingRodUpgrades.additionalRespawnPercentage)
    
    if not respawn then return end

    local site = math.random(1, 2)
    if site == 1 then
        fromX = -200
        toX = 550
    elseif site == 2 then
        fromX = 550
        toX = -200
    end

    local fromY = math.random(100, 170)--math.random(60, 100)
    local toY = math.random(-100, 50)

    local allFishes = zone.fishes
    local fish, fishInfo = drawTheFish(allFishes)

    local speedX = math.random(fishInfo.speed[1] * 1000, fishInfo.speed[2] * 1000)
    local speedY = math.random(fishInfo.speed[1] * 1000, fishInfo.speed[2] * 1000)
    local weight = math.random(fishInfo.weight[1] * 100, fishInfo.weight[2] * 100) / 100

    dodajRybe(fish, fromX, toX, speedX, fromY, toY, speedY, weight, textures[fish])
end

drawTheFish = function(fishTable)

    local allFishes = {}
    local hour, min = getTime()
    local time = hour * 60 + min

    for k, v in pairs(fishTable) do
        local boost = fishingRodUpgrades.perks[k] or 0
        if v.time then
            if (time >= v.time[1] * 60 or time <= v.time[2] * 60) then
                for i=1, v[1] + boost do
                    table.insert(allFishes, k)
                end
            end
        else
            for i=1, v[1] + boost do
                table.insert(allFishes, k)
            end
        end
    end

    allFishes = table.randomTable(allFishes)

    local drawedFish = allFishes[math.random(#allFishes)]
    local fishPercentages = fishTable[drawedFish].percentage
    local draws = {}

    for i, v in ipairs(fishPercentages) do
        for j=1, v[1] do
            table.insert(draws, i)
        end
    end

    draws = table.randomTable(draws)
    local fishInfo = fishPercentages[draws[math.random(#draws)]]
    fishInfo = {weight = fishInfo.weight, speed = fishInfo.speed}

    return drawedFish, fishInfo

end

drawRespawning = function(p)
    local choices = {}
    
    for i=1, p do
        table.insert(choices, true)
    end

    for i=1, 100 - p do
        table.insert(choices, false)
    end

    choices = table.randomTable(choices)

    return choices[math.random(#choices)]

end

table.randomTable = function(tab)
    local newTable = {}
    for i=1, #tab do
        local index = math.random(#tab)
        table.insert(newTable, tab[index])
        table.remove(tab, index)
    end
    return newTable
end

local random = math.random

math.random = function(a, b)
    math.randomseed(getTickCount())
    if not b then return random(a) end
    return random(a, b)
end    

baitBreakTimer = function()
    startFishing(false)
    exports["prpg-notifications"]:newNotification("error", "Przynęta się zerwała.")
end

getFishingRodUpgrades = function()
    local equipment = exports["prpg-equipment"]
    local upgrade = upgrades['default']
    for k, item in pairs(equipment:getAllItems()) do
        if item.used and equipment:isItemFishingRod(item) then
            local upgrade = upgrades[item.name] or upgrade
            fishingRodUpgrades.additionalRespawnPercentage = upgrade.additionalRespawnPercentage + (item.level or 1)
            fishingRodUpgrades.baitBreakTime = math.random(upgrade.baitBreakTime[1], upgrade.baitBreakTime[2])
            fishingRodUpgrades.perks = item.perks or {}
        end
    end
end

getFishingRodInfo = function()
    local equipment = exports["prpg-equipment"]
    local slot, condition

    for k, item in pairs(equipment:getAllItems()) do
        if item.used and equipment:isItemFishingRod(item) then
            slot = k
            condition = item.condition or 100
        end
    end

    return slot, condition
end

getTexture = function(texture)
    return textures[texture]
end

isPlayerFishing = function()
    return settings.fishing or false
end

---------------------------------------------------------------

startFishing = function(bool)
    if bool == true then
        if getPedOccupiedVehicle(localPlayer) then return end
        fishes = {}
        setElementFrozen(localPlayer, true)
        addEventHandler("onClientRender", root, renderFishing)
        addEventHandler("onClientClick", root, pullOutFishClick)
        settings.fishing = true
        settings.respawnTimer = setTimer(dR, 5 * 1000, 0)
        settings.startFishingTimer = setTimer(baitBreakTimer, fishingRodUpgrades.baitBreakTime * 1000, 1)
        triggerServerEvent("fish->animation", resourceRoot, true)
    elseif bool == false then
        setElementFrozen(localPlayer, false)
        removeEventHandler("onClientRender", root, renderFishing)
        removeEventHandler("onClientRender", root, renderPullingOut)
        removeEventHandler("onClientClick", root, pullOutFishClick)
        removeEventHandler("onClientKey", root, spacePullOut)
        settings.fishing = false
        if isTimer(settings.startFishingTimer) then killTimer(settings.startFishingTimer) end
        if isTimer(settings.respawnTimer) then killTimer(settings.respawnTimer) end
        settings.respawnTimer = nil
        settings.startFishingTimer = nil
        triggerServerEvent("fish->animation", resourceRoot, false)
    end
end

