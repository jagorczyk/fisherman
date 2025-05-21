local sw, sh = guiGetScreenSize()
local zoom = 1920/sw

local textures = {
    bg = dxCreateTexture("/images/bg_sell.png", "argb", true, "clamp"),
    scrollpane = dxCreateTexture("/images/scrollpane.png", "argb", true, "clamp"),
}

local gui_positions = {
    bg = {x = sw-400/zoom, y = sh/2-210/zoom, w = 350/zoom, h = 420/zoom},
    title = {x = sw-400/zoom, y = sh/2-210/zoom, w = 350/zoom, h = 50/zoom},
    item = {x = sw-370/zoom, y = sh/2-150/zoom, w = 64/zoom, h = 64/zoom},
    itemText = {x = sw-370/zoom, y = sh/2-110/zoom, w = 64/zoom, h = 64/zoom},
    offsetX = 110/zoom,
    offsetY = 95/zoom,
    sellText = {x = sw-400/zoom, y = sh/2+140/zoom, w = 350/zoom, h = 50/zoom},
    scrollpane = {x = sw-65/zoom, y = sh/2-130/zoom, w = 4/zoom, h = 260/zoom},
}

local fonts = {
    roboto = dxCreateFont("roboto.ttf", 10),
    roboto_s = dxCreateFont("roboto.ttf", 8),
}

local settings = {
    list = {},
    prices = {},
    slotsInLine = 3,
    site = 1,
    column = 3,
    move = 0,
}

renderSelling = function()
    dxDrawImage(gui_positions.bg.x, gui_positions.bg.y, gui_positions.bg.w, gui_positions.bg.h, textures.bg)
    dxDrawText(settings.name, gui_positions.title.x, gui_positions.title.y, gui_positions.title.w + gui_positions.title.x, gui_positions.title.h + gui_positions.title.y, white, 1.00, fonts.roboto, "center", "center")
    
    n = 0

    for i=1, math.ceil(#settings.list / settings.slotsInLine) do
        if i >= settings.site and i <= settings.column then
            n = n + 1
            local offsetY = (gui_positions.offsetY) * (n - 1)
            local index = (i - 1) * settings.slotsInLine + 1
            a = 0
            for j=index, index+settings.slotsInLine-1 do
                a = a + 1
                local offsetX = (gui_positions.offsetX) * (a - 1)
                if settings.list[j] then
                    dxDrawImage(gui_positions.item.x + offsetX, gui_positions.item.y + offsetY, gui_positions.item.w, gui_positions.item.h, textures[settings.list[j]])
                    dxDrawText(settings.list[j] .. "\n#00bb00" .. formatNumber(settings.prices[settings.list[j]], ",") .. " PLN #ffffff/ kg", gui_positions.itemText.x + offsetX, gui_positions.itemText.y + offsetY, gui_positions.itemText.w + gui_positions.itemText.x + offsetX, gui_positions.itemText.h + gui_positions.itemText.y + offsetY, white, 1.00, fonts.roboto_s, "center", "center", _, _, _, true) 
                end
            end
        end
    end

    dxDrawText("aby sprzedać rybe,\n użyj opcji 'Sprzedaj' w ekwipunku", gui_positions.sellText.x, gui_positions.sellText.y, gui_positions.sellText.w + gui_positions.sellText.x, gui_positions.sellText.h + gui_positions.sellText.y, white, 1.00, fonts.roboto_s, "center", "center")
    if #settings.list > 9 then
        local list = math.ceil(#settings.list / settings.slotsInLine)
        dxDrawImage(gui_positions.scrollpane.x, gui_positions.scrollpane.y, gui_positions.scrollpane.w, gui_positions.scrollpane.h, textures.scrollpane, 0, 0, 0, tocolor(50, 50, 50))
        dxDrawImage(gui_positions.scrollpane.x, gui_positions.scrollpane.y + (settings.move), gui_positions.scrollpane.w, gui_positions.scrollpane.h * 3/list, textures.scrollpane, 0, 0, 0, tocolor(33, 84, 229))
    end
end

setTextures = function(list)
    for _, v in ipairs(list) do
        textures[v] = getTexture(v)
    end
end

addOptions = function(list)
    if not list then return end
    local equipment = exports["prpg-equipment"]
    for i,v in ipairs(list) do
        equipment:addOption(v, "Sprzedaj")
    end
end

removeOptions = function(list)
    if not list then return end
    local equipment = exports["prpg-equipment"]
    for i,v in ipairs(list) do
        equipment:removeOption(v, "Sprzedaj")
    end
end


local scrollPane = function(key)
    local list = math.ceil(#settings.list / settings.slotsInLine)
    if key == "mouse_wheel_up" then
        if settings.site ~= 1 then
            settings.site = settings.site-1
            settings.column = settings.column-1
            settings.move = settings.move - (gui_positions.scrollpane.h - (gui_positions.scrollpane.h * 3/list)) / (list - 3)
        end
    elseif key == "mouse_wheel_down" then
        if settings.column < list  then
            settings.site = settings.site+1
            settings.column = settings.column+1
            settings.move = settings.move + (gui_positions.scrollpane.h - (gui_positions.scrollpane.h * 3/list)) / (list - 3)
        end
    end
end

getFishPrices = function(list, prices)
    settings.list = list
    settings.prices = prices
    setTextures(list)
    addOptions(list)
end
addEvent("fish->getFishPrices", true)
addEventHandler("fish->getFishPrices", resourceRoot, getFishPrices)

getIndex = function()
    return settings.index or false
end

showSelling = function(bool, index, name)
    if bool == true then
        settings.index = index
        settings.list = {}
        settings.prices = {}
        settings.name = name
        triggerServerEvent("fish->getFishPrices", resourceRoot, index)
        addEventHandler("onClientRender", root, renderSelling)
        addEventHandler("onClientKey", root, scrollPane)
    elseif bool == false then
        removeOptions(exports["prpg-equipment"]:getAllFishes())
        removeEventHandler("onClientRender", root, renderSelling)
        removeEventHandler("onClientKey", root, scrollPane)
    end
end