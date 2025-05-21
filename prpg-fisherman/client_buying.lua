local sw, sh = guiGetScreenSize()
local zoom = 1920/sw

local textures = {
    bg = dxCreateTexture("/images/bg_buy.png", "argb", true, "clamp"),
    button = dxCreateTexture("/images/button.png", "argb", true, "clamp"),
    radar = dxCreateTexture("/images/radar.png", "argb", true, "clamp"),
    button_buy = dxCreateTexture("/images/button_buy.png", "argb", true, "clamp"),
    scrollpane = dxCreateTexture("/images/scrollpane.png", "argb", true, "clamp"),
    itemslot = dxCreateTexture("/images/itemslot.png", "argb", true, "clamp"),
    fix = dxCreateTexture("/images/button_fix.png", "argb", true, "clamp"),
}

local settings = {
    selected = nil,
    w = 300,
    h = 300,
    slotsInLine = 6,
    site = 1,
    column = 3,
    move = 0,
    fishRanking = {},
    clickTick = getTickCount(),
    perksCost = 0,
}

local gui_positions = {
    bg = {x = sw/2-325/zoom, y = sh/2-210/zoom, w = 650/zoom, h = 420/zoom},
    title = {x = sw/2-325/zoom, y = sh/2-210/zoom, w = 650/zoom, h = 50/zoom},
    option = {x = sw/2-308/zoom, y = sh/2-165/zoom, w = 117/zoom, h = 19/zoom, offsetX = 125/zoom},
    radar = {x = sw/2-300/zoom, y = sh/2-130/zoom, w = settings.w/zoom, h = settings.h/zoom},
    text = {x = sw/2+10/zoom, y = sh/2-135/zoom, w = settings.w/zoom, h = settings.h/zoom},
    Wedki = {
        item = {x = sw/2-285/zoom, y = sh/2-130/zoom, w = 48/zoom, h = 48/zoom},
        itemText = {x = sw/2-285/zoom, y = sh/2-85/zoom, w = 48/zoom, h = 48/zoom},
        button_buy = {x = sw/2-293/zoom, y = sh/2-40/zoom, w = 64/zoom, h = 13/zoom},
        offsetX = 100/zoom,
        offsetY = 110/zoom,
        scrollpane = {x = sw/2+310/zoom, y = sh/2-145/zoom, w = 4/zoom, h = 340/zoom},
    },
    Bestiariusz = {
        item = {x = sw/2-285/zoom, y = sh/2-130/zoom, w = 48/zoom, h = 48/zoom},
        itemText = {x = sw/2-285/zoom, y = sh/2-85/zoom, w = 48/zoom, h = 48/zoom},
        button_buy = {x = sw/2-293/zoom, y = sh/2-40/zoom, w = 64/zoom, h = 13/zoom},
        offsetX = 100/zoom,
        offsetY = 110/zoom,
        scrollpane = {x = sw/2+310/zoom, y = sh/2-145/zoom, w = 4/zoom, h = 340/zoom},
        text = {x = sw/2-325/zoom, y = sh/2-210/zoom, w = 650/zoom, h = 420/zoom},
    },
    Ulepszanie = {
        itemslot = {x = sw/2-32/zoom, y = sh/2-64/zoom, w = 64/zoom, h = 64/zoom},
        item = {x = sw/2-32+8/zoom, y = sh/2-64+8/zoom, w = 48/zoom, h = 48/zoom},
        itemLevel = {x = sw/2-50/zoom, y = sh/2+7/zoom, w = 100/zoom, h = 20/zoom},
        cost = {x = sw/2-50/zoom, y = sh/2+23/zoom, w = 100/zoom, h = 20/zoom},
        perks = {x = sw/2-280/zoom, y = sh/2-100/zoom, w = 120/zoom, h = 20/zoom},
        level = {x = sw/2-60/zoom, y = sh/2+50/zoom, w = 120/zoom, h = 20/zoom},
        text = {x = sw/2-280/zoom, y = sh/2-100/zoom, w = 120/zoom, h = 20/zoom},
    },
    Naprawa = {
        itemslot = {x = sw/2-32/zoom, y = sh/2-64/zoom, w = 64/zoom, h = 64/zoom},
        item = {x = sw/2-32+8/zoom, y = sh/2-64+8/zoom, w = 48/zoom, h = 48/zoom},
        condition = {x = sw/2-50/zoom, y = sh/2+7/zoom, w = 100/zoom, h = 20/zoom},
        cost = {x = sw/2-50/zoom, y = sh/2+23/zoom, w = 100/zoom, h = 20/zoom},
        fix = {x = sw/2-60/zoom, y = sh/2+50/zoom, w = 120/zoom, h = 20/zoom},
        text = {x = sw/2-50/zoom, y = sh/2+100/zoom, w = 100/zoom, h = 20/zoom},
    },
}

local fonts = {
    roboto = dxCreateFont("roboto.ttf", 10),
    roboto_s = dxCreateFont("roboto.ttf", 9),
    roboto_ss = dxCreateFont("roboto.ttf", 8),
}

local options = {
    "Informacje",
    "Wędki",
    "Bestiariusz",
    "Ulepszanie",
    "Naprawa",
}

local text = [[
    Witaj!
    W tym miejscu możesz kupić swoją pierwszą wędkę,
    lub zobaczyć jakie ryby dotychczas złowiłeś/aś.

    Po lewej stronie znajduje się mapa łowisk. Kolor 
    zielony oznacza jezioro. Brązowy natomiast 
    oznacza bagno. Niebieski (lub brak koloru) - 
    najbardziej popularny, oznacza ocean lub jego 
    dopływy.

    Złowione ryby możesz sprzedawać u lokalnych
    sprzedawców. U każdego z nich ceny się różnią.
    Na każdym z łowisk istnieje szansa, aby zdobyć
    unikalną dla łowiska wędkę.

    Każda z wędek ma różne benefity. Różni je:

    - czas zerwania przynęty,
    - dodatkowy procent na respawn ryby,

    Level wędki dodaje 1% do dodatkowego respawnu
    ryby.
]]

renderBuying = function()
    dxDrawImage(gui_positions.bg.x, gui_positions.bg.y, gui_positions.bg.w, gui_positions.bg.h, textures.bg)
    dxDrawText("Sprzedawca", gui_positions.title.x, gui_positions.title.y, gui_positions.title.w + gui_positions.title.x, gui_positions.title.h + gui_positions.title.y, white, 1.00, fonts.roboto, "center", "center")


    for i, v in ipairs(options) do
        local offset = gui_positions.option.offsetX * (i-1)
        local hover = settings.selected == v and 200 or isMouseInPosition(gui_positions.option.x + offset, gui_positions.option.y, gui_positions.option.w, gui_positions.option.h) and 200 or 255
        dxDrawImage(gui_positions.option.x + offset, gui_positions.option.y, gui_positions.option.w, gui_positions.option.h, textures.button, 0, 0, 0, tocolor(255,255,255,hover))
        dxDrawText(v, gui_positions.option.x + offset, gui_positions.option.y, gui_positions.option.w + gui_positions.option.x + offset, gui_positions.option.h + gui_positions.option.y, white, 1.00, fonts.roboto_s, "center", "center")
    end

    if settings.selected == "Informacje" then
        dxDrawImage(gui_positions.radar.x, gui_positions.radar.y, gui_positions.radar.w, gui_positions.radar.h, textures.radar)

        for _, p in ipairs(zones) do
            local x, y = findScreenLocation(p.pos[1], p.pos[2])
            local w, h = p.pos[3] / (settings.w / 15), p.pos[3] / (settings.h / 15)
            dxDrawRectangle(x, y, w, h, p.type and getTypeColor(p.type, 150) or tocolor(33, 84, 229, 150))
        end

        dxDrawText(text, gui_positions.text.x, gui_positions.text.y, gui_positions.text.w + gui_positions.text.x, gui_positions.text.h + gui_positions.text.y, white, 1.00, fonts.roboto_s, "center", "top")
    elseif settings.selected == "Wędki" then
        local gui_positions = gui_positions.Wedki
        n = 0
        for i=1, math.ceil(#settings.fishingRods / settings.slotsInLine) do
            if i >= settings.site and i <= settings.column then
                n = n + 1
                local offsetY = (gui_positions.offsetY) * (n - 1)
                local index = (i - 1) * settings.slotsInLine + 1
                a = 0
                for j=index, index+settings.slotsInLine-1 do
                    a = a + 1
                    local offsetX = (gui_positions.offsetX) * (a - 1)
                    if settings.fishingRods[j] then
                        dxDrawImage(gui_positions.item.x + offsetX, gui_positions.item.y + offsetY, gui_positions.item.w, gui_positions.item.h, settings.eq:getTexture(settings.fishingRods[j][1]))
                        dxDrawText(settings.fishingRods[j][1] .. "\n#00bb00" .. formatNumber(settings.fishingRods[j][2], ",") .. " PLN", gui_positions.itemText.x + offsetX, gui_positions.itemText.y + offsetY, gui_positions.itemText.w + gui_positions.itemText.x + offsetX, gui_positions.itemText.h + gui_positions.itemText.y + offsetY, white, 1.00, fonts.roboto_s, "center", "center", _, _, _, true) 
                        
                        local hover = isMouseInPosition(gui_positions.button_buy.x + offsetX, gui_positions.button_buy.y + offsetY, gui_positions.button_buy.w, gui_positions.button_buy.h) and 200 or 255
                        dxDrawImage(gui_positions.button_buy.x + offsetX, gui_positions.button_buy.y + offsetY, gui_positions.button_buy.w, gui_positions.button_buy.h, textures.button_buy, 0, 0, 0, tocolor(255,255,255,hover))
                        dxDrawText("Zakup", gui_positions.button_buy.x + offsetX, gui_positions.button_buy.y + offsetY, gui_positions.button_buy.w + gui_positions.button_buy.x + offsetX, gui_positions.button_buy.h + gui_positions.button_buy.y + offsetY, white, 1.00, fonts.roboto_ss, "center", "center", _, _, _, true) 
                    end
                end
            end
        end

        if #settings.fishingRods > settings.slotsInLine * 3 then
            local list = math.ceil(#settings.fishingRods / settings.slotsInLine)
            dxDrawImage(gui_positions.scrollpane.x, gui_positions.scrollpane.y, gui_positions.scrollpane.w, gui_positions.scrollpane.h, textures.scrollpane, 0, 0, 0, tocolor(50, 50, 50))
            dxDrawImage(gui_positions.scrollpane.x, gui_positions.scrollpane.y + (settings.move), gui_positions.scrollpane.w, gui_positions.scrollpane.h * 3/list, textures.scrollpane, 0, 0, 0, tocolor(33, 84, 229))
        end
    elseif settings.selected == "Bestiariusz" then

        local gui_positions = gui_positions.Bestiariusz
        local list = settings.fishRanking or {}

        n = 0
        for i=1, math.ceil(#settings.fishes / settings.slotsInLine) do
            if i >= settings.site and i <= settings.column then
                n = n + 1
                local offsetY = (gui_positions.offsetY) * (n - 1)
                local index = (i - 1) * settings.slotsInLine + 1
                a = 0
                for j=index, index+settings.slotsInLine-1 do
                    a = a + 1
                    local offsetX = (gui_positions.offsetX) * (a - 1)
                    local texture = getTexture(settings.fishes[j])
                    
                    if texture then
                        dxDrawImage(gui_positions.item.x + offsetX, gui_positions.item.y + offsetY, gui_positions.item.w, gui_positions.item.h, texture)
                        local info = list[settings.fishes[j]] or {count = 0, maxWeight = 0}
                        local text = string.format("#a0a0a0%d #ffffffzłowionych\nMax. waga:\n #a0a0a0%0.2fkg", info.count, info.maxWeight)
                        dxDrawText(text, gui_positions.itemText.x + offsetX, gui_positions.itemText.y + offsetY, gui_positions.itemText.w + gui_positions.itemText.x + offsetX, gui_positions.itemText.h + gui_positions.itemText.y + offsetY, white, 1.00, fonts.roboto_s, "center", "top", _, _, _, true) 
                    end
                end
            end
        end

        if #settings.fishRanking > settings.slotsInLine * 3 then
            local list = math.ceil(#settings.fishRanking / settings.slotsInLine)
            dxDrawImage(gui_positions.scrollpane.x, gui_positions.scrollpane.y, gui_positions.scrollpane.w, gui_positions.scrollpane.h, textures.scrollpane, 0, 0, 0, tocolor(50, 50, 50))
            dxDrawImage(gui_positions.scrollpane.x, gui_positions.scrollpane.y + (settings.move), gui_positions.scrollpane.w, gui_positions.scrollpane.h * 3/list, textures.scrollpane, 0, 0, 0, tocolor(33, 84, 229))
        end

    elseif settings.selected == "Naprawa" then

        if not settings.fishingRod then return end

        local gui_positions = gui_positions.Naprawa

        dxDrawText("Koszt naprawy wędki zależy od jej stanU,\noraz poziomu ulepszenia.", gui_positions.text.x, gui_positions.text.y, gui_positions.text.w + gui_positions.text.x, gui_positions.text.h + gui_positions.text.y, white, 1.00, fonts.roboto, "center", "center")
        
        dxDrawImage(gui_positions.itemslot.x, gui_positions.itemslot.y, gui_positions.itemslot.w, gui_positions.itemslot.h, textures.itemslot)
        dxDrawImage(gui_positions.item.x, gui_positions.item.y, gui_positions.item.w, gui_positions.item.h, settings.eq:getTexture(settings.fishingRod.name))
        dxDrawText(string.format("Stan: #a0a0a0%0.2f", settings.fishingRod.condition) .. "%", gui_positions.condition.x , gui_positions.condition.y , gui_positions.condition.w + gui_positions.condition.x , gui_positions.condition.h + gui_positions.condition.y, white, 1.00, fonts.roboto_s, "center", "top", _, _, _, true) 
        dxDrawText("Koszt naprawy: #00bb00" .. formatNumber(tonumber(settings.fixCost or 0), ",") .. " PLN", gui_positions.cost.x , gui_positions.cost.y , gui_positions.cost.w + gui_positions.cost.x , gui_positions.cost.h + gui_positions.cost.y, white, 1.00, fonts.roboto_s, "center", "top", _, _, _, true) 
        
        local hover = isMouseInPosition(gui_positions.fix.x, gui_positions.fix.y, gui_positions.fix.w, gui_positions.fix.h) and 200 or 255
        dxDrawImage(gui_positions.fix.x, gui_positions.fix.y, gui_positions.fix.w, gui_positions.fix.h, textures.fix, 0, 0, 0, tocolor(255,255,255,hover))
        dxDrawText("Napraw", gui_positions.fix.x, gui_positions.fix.y, gui_positions.fix.w + gui_positions.fix.x, gui_positions.fix.h + gui_positions.fix.y, white, 1.00, fonts.roboto_s, "center", "center", _, _, _, true)

    elseif settings.selected == "Ulepszanie" then

        if not settings.fishingRod then return end

        local gui_positions = gui_positions.Ulepszanie
        
        dxDrawImage(gui_positions.itemslot.x, gui_positions.itemslot.y, gui_positions.itemslot.w, gui_positions.itemslot.h, textures.itemslot)
        dxDrawImage(gui_positions.item.x, gui_positions.item.y, gui_positions.item.w, gui_positions.item.h, settings.eq:getTexture(settings.fishingRod.name))
        
        dxDrawText(string.format("Aktualny level: #a0a0a0+%d", settings.fishingRod.level or 1), gui_positions.itemLevel.x , gui_positions.itemLevel.y , gui_positions.itemLevel.w + gui_positions.itemLevel.x , gui_positions.itemLevel.h + gui_positions.itemLevel.y, white, 1.00, fonts.roboto_s, "center", "top", _, _, _, true) 
        dxDrawText("Koszt ulepszenia: #00bb00" .. formatNumber(tonumber(settings.upgradeCost or 0), ",") .. " PLN", gui_positions.cost.x , gui_positions.cost.y , gui_positions.cost.w + gui_positions.cost.x , gui_positions.cost.h + gui_positions.cost.y, white, 1.00, fonts.roboto_s, "center", "top", _, _, _, true) 

        local hover = isMouseInPosition(gui_positions.level.x, gui_positions.level.y, gui_positions.level.w, gui_positions.level.h) and 200 or 255
        dxDrawImage(gui_positions.level.x, gui_positions.level.y, gui_positions.level.w, gui_positions.level.h, textures.fix, 0, 0, 0, tocolor(255,255,255,hover))
        dxDrawText("Ulepsz", gui_positions.level.x, gui_positions.level.y, gui_positions.level.w + gui_positions.level.x, gui_positions.level.h + gui_positions.level.y, white, 1.00, fonts.roboto_s, "center", "center", _, _, _, true)

        dxDrawText("Aktualne boosty:", gui_positions.text.x, gui_positions.text.y, gui_positions.text.w + gui_positions.text.x, gui_positions.text.h + gui_positions.text.y, white, 1.00, fonts.roboto_s, "center", "center", _, _, _, true) 
        
        local perksTable = settings.fishingRod.perks or {}

        i = 0
        for k, upgrade in pairs(perksTable) do
            i = i + 1
            local offsetY = (20/zoom) * (i)
            dxDrawText("#a0a0a0+" .. upgrade .. "% #ffffffna złowienie #a0a0a0" .. k, gui_positions.text.x, gui_positions.text.y + offsetY, gui_positions.text.w + gui_positions.text.x, gui_positions.text.h + gui_positions.text.y + offsetY, white, 1.00, fonts.roboto_s, "center", "center", _, _, _, true) 
        end

        local offset = (getTableLength(perksTable) + 1) * (20/zoom) + 7/zoom

        local hover = isMouseInPosition(gui_positions.perks.x, gui_positions.perks.y + offset, gui_positions.perks.w, gui_positions.perks.h) and 200 or 255
        dxDrawImage(gui_positions.perks.x, gui_positions.perks.y + offset, gui_positions.perks.w, gui_positions.perks.h, textures.fix, 0, 0, 0, tocolor(255,255,255,hover))
        dxDrawText("Losuj boosty", gui_positions.perks.x, gui_positions.perks.y + offset, gui_positions.perks.w + gui_positions.perks.x, gui_positions.perks.h + gui_positions.perks.y + offset, white, 1.00, fonts.roboto_s, "center", "center", _, _, _, true)
        dxDrawText("Cena losowania: #00bb00" .. formatNumber(settings.perksCost, ",") .. " PLN", gui_positions.perks.x, gui_positions.perks.y + offset + 25/zoom, gui_positions.perks.w + gui_positions.perks.x, gui_positions.perks.h + gui_positions.perks.y + offset + 25/zoom, white, 1.00, fonts.roboto_s, "center", "center", _, _, _, true)

    end

end

findScreenLocation = function(x, y)

    local x = x / (3000 / settings.w)
    local y = y / (3000 / settings.h)

    local center = {gui_positions.radar.x + gui_positions.radar.w/2, gui_positions.radar.y + gui_positions.radar.h/2} -- pos(0, 0)

    local new_x = center[1] + gui_positions.radar.w/2 * x / settings.w
    local new_y = center[2] + gui_positions.radar.h/2 * y / -settings.h

    return new_x, new_y

end

local scrollPane = function(key)
    local list = settings.selected == "Wędki" and (settings.fishingRods or {}) or (settings.fishRanking or {})
    list = math.ceil(#list / settings.slotsInLine)
    local gui_positions = settings.selected == "Wędki" and gui_positions.Wedki or gui_positions.Bestiariusz
    if key == "mouse_wheel_up" then
        if settings.site ~= 1 then
            settings.site = settings.site-1
            settings.column = settings.column-1
            settings.move = settings.move - (gui_positions.scrollpane.h - (gui_positions.scrollpane.h * settings.slotsInLine/list)) / (list - settings.slotsInLine)
        end
    elseif key == "mouse_wheel_down" then
        if settings.column < list  then
            settings.site = settings.site+1
            settings.column = settings.column+1
            settings.move = settings.move + (gui_positions.scrollpane.h - (gui_positions.scrollpane.h * settings.slotsInLine/list)) / (list - settings.slotsInLine)
        end
    end
end

getFishingRodPrices = function(list)
    settings.fishingRods = list
end
addEvent("fish->getFishingRodPrices", true)
addEventHandler("fish->getFishingRodPrices", resourceRoot, getFishingRodPrices)

getRanking = function(list)
    settings.fishRanking = list
end
addEvent("fish->getRanking", true)
addEventHandler("fish->getRanking", resourceRoot, getRanking)

getFixCost = function(cost)
    settings.fixCost = math.floor(cost)
end
addEvent("fish->getFixCost", true)
addEventHandler("fish->getFixCost", resourceRoot, getFixCost)

setFishingRodInfo = function()
    settings.fishingRod = getFishingRod()
end
addEvent("fish->setFishingRodInfo", true)
addEventHandler("fish->setFishingRodInfo", resourceRoot, setFishingRodInfo)

getFishingRodPerksCost = function(cost1, cost2)
    settings.perksCost = math.floor(cost1)
    settings.upgradeCost = math.floor(cost2)
end
addEvent("fish->getFishingRodPerksCost", true)
addEventHandler("fish->getFishingRodPerksCost", resourceRoot, getFishingRodPerksCost)

changeSiteButtonClick = function(b, s)
    if b == "left" and s == "down" then
        for i, v in ipairs(options) do
            local offset = gui_positions.option.offsetX * (i-1)
            if isMouseInPosition(gui_positions.option.x + offset, gui_positions.option.y, gui_positions.option.w, gui_positions.option.h) then
                if v == settings.selected then return end
                if v == "Naprawa" then
                    local fishingRod = getFishingRod()
                    if not fishingRod then return exports["prpg-notifications"]:newNotification("error", "Najpierw wyjmij wędke.") end
                    settings.fishingRod = fishingRod
                    triggerServerEvent("fish->getFixCost", resourceRoot, fishingRod.name, fishingRod.level or 1, fishingRod.condition)
                end
                if v == "Ulepszanie" then
                    local fishingRod = getFishingRod()
                    if not fishingRod then return exports["prpg-notifications"]:newNotification("error", "Najpierw wyjmij wędke.") end
                    settings.fishingRod = fishingRod
                    triggerServerEvent("fish->getFixCost", resourceRoot, fishingRod.name, fishingRod.level or 1, fishingRod.condition)
                    triggerServerEvent("fish->getFishingRodPerksCost", resourceRoot, fishingRod)
                end
                settings.selected = v
                settings.site = 1
                settings.column = 3
                settings.move = 0
            end
        end
    end
end

buyButtonClick = function(b, s)
    if b == "left" and s == "down" then
        if settings.selected ~= "Wędki" then return end
        local gui_positions = gui_positions.Wedki
        n = 0
        for i=1, math.ceil(#settings.fishingRods / settings.slotsInLine) do
            if i >= settings.site and i <= settings.column then
                n = n + 1
                local offsetY = (gui_positions.offsetY) * (n - 1)
                local index = (i - 1) * settings.slotsInLine + 1
                a = 0
                for j=index, index+settings.slotsInLine-1 do
                    a = a + 1
                    local offsetX = (gui_positions.offsetX) * (a - 1)
                    if settings.fishingRods[j] then
                        if isMouseInPosition(gui_positions.button_buy.x + offsetX, gui_positions.button_buy.y + offsetY, gui_positions.button_buy.w, gui_positions.button_buy.h) then
                            if not checkIfCanClick() then return end
                            triggerServerEvent("fish->buyFishingRod", resourceRoot, settings.index, j)
                        end
                    end
                end
            end
        end
    end
end

fixButtonClick  = function(b, s)
    if b == "left" and s == "down" then
        if settings.selected ~= "Naprawa" then return end
        local gui_positions = gui_positions.Naprawa
        if isMouseInPosition(gui_positions.fix.x, gui_positions.fix.y, gui_positions.fix.w, gui_positions.fix.h) then
            if not checkIfCanClick() then return end
            if settings.fishingRod.condition == 100 then return exports["prpg-notifications"]:newNotification("error", "Twoja wędka jest już naprawiona.") end
            local slot = getSlot()
            local fishingRod = getFishingRod()
            if not fishingRod or not slot then return exports["prpg-notifications"]:newNotification("error", "Najpierw wyjmij wędke.") end
            if slot then
                settings.fishingRod = fishingRod
                triggerServerEvent("fish->fixFishingRod", resourceRoot, slot)
                showBuying(false)
            end
        end
    end
end

perksButtonClick  = function(b, s)
    if b == "left" and s == "down" then
        if settings.selected ~= "Ulepszanie" then return end
        local gui_positions = gui_positions.Ulepszanie
        local perksTable = settings.fishingRod.perks or {}
        local offset = (getTableLength(perksTable) + 1) * (20/zoom) + 5/zoom
        if isMouseInPosition(gui_positions.perks.x, gui_positions.perks.y + offset, gui_positions.perks.w, gui_positions.perks.h) then
            if not checkIfCanClick() then return end
            local slot = getSlot()
            if not slot then return exports["prpg-notifications"]:newNotification("error", "Najpierw wyjmij wędke.") end
            if slot then
                triggerServerEvent("fish->setUpgrades", resourceRoot, slot)
                triggerServerEvent("fish->getFishingRodPerksCost", resourceRoot, fishingRod)
            end
        end
    end
end

levelButtonClick  = function(b, s)
    if b == "left" and s == "down" then
        if settings.selected ~= "Ulepszanie" then return end
        local gui_positions = gui_positions.Ulepszanie
        if isMouseInPosition(gui_positions.level.x, gui_positions.level.y, gui_positions.level.w, gui_positions.level.h) then
            if not checkIfCanClick() then return end
            local slot = getSlot()
            if not slot then return exports["prpg-notifications"]:newNotification("error", "Najpierw wyjmij wędke.") end
            if slot then
                triggerServerEvent("fish->upgradeLevel", resourceRoot, slot)
                triggerServerEvent("fish->getFishingRodPerksCost", resourceRoot, fishingRod)
            end
        end
    end
end

getFishingRod = function()

    for k, item in pairs(settings.eq:getAllItems()) do
        if item.used and settings.eq:isItemFishingRod(item) then
            return item
        end
    end

    return false

end

getSlot = function()

    for k, item in pairs(settings.eq:getAllItems()) do
        if item.used and settings.eq:isItemFishingRod(item) then
            return k
        end
    end

    return false

end

checkIfCanClick = function()
    if getTickCount() > settings.clickTick + 2000 then
        settings.clickTick = getTickCount()
        return true
    else
        exports["prpg-notifications"]:newNotification("error", "Odczekaj chwile przed kolejnym kliknieciem.")
        return false
    end
end

getTableLength = function(table)
    local i = 0
    for k, v in pairs(table) do
        i = i + 1
    end
    return i
end

showBuying = function(bool, index)
    if bool == true then
        settings.selected = "Informacje"
        settings.fishingRods = {}
        settings.fishRanking = {}
        settings.index = index
        settings.eq = exports["prpg-equipment"]
        settings.fishes = exports["prpg-equipment"]:getAllFishes()
        settings.site = 1
        settings.column = 3
        settings.move = 0
        triggerServerEvent("fish->getFishingRodPrices", resourceRoot, index)
        triggerServerEvent("fish->getRanking", resourceRoot)
        addEventHandler("onClientRender", root, renderBuying)
        addEventHandler("onClientClick", root, changeSiteButtonClick)
        addEventHandler("onClientClick", root, buyButtonClick)
        addEventHandler("onClientClick", root, fixButtonClick)
        addEventHandler("onClientClick", root, perksButtonClick)
        addEventHandler("onClientClick", root, levelButtonClick)
        addEventHandler("onClientKey", root, scrollPane)
    elseif bool == false then
        removeEventHandler("onClientRender", root, renderBuying)
        removeEventHandler("onClientClick", root, changeSiteButtonClick)
        removeEventHandler("onClientClick", root, buyButtonClick)
        removeEventHandler("onClientClick", root, fixButtonClick)
        removeEventHandler("onClientClick", root, perksButtonClick)
        removeEventHandler("onClientClick", root, levelButtonClick)
        removeEventHandler("onClientKey", root, scrollPane)
    end
end