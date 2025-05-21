local sw, sh = guiGetScreenSize()
local zoom = 1920/sw

local textures = {
	bg = dxCreateTexture("/images/bg.png", "argb", true, "clamp"),
	money = dxCreateTexture("/images/money.png", "argb", true, "clamp"),
	clock = dxCreateTexture("/images/time.png", "argb", true, "clamp"),
}

local gui_positions = {
    bg = {x = sw/2-225/zoom, y = 20/zoom, w = 450/zoom, h = 150/zoom},
    money = {x = sw/2-221/zoom, y = 140/zoom, w = 24/zoom, h = 24/zoom},
    moneyText = {x = sw/2-195/zoom, y = 143/zoom, w = 100/zoom, h = 20/zoom},
    clock = {x = sw/2+197/zoom, y = 140/zoom, w = 24/zoom, h = 24/zoom},
    clockText = {x = sw/2+90/zoom, y = 143/zoom, w = 100/zoom, h = 20/zoom},
    openText = {x = sw/2-225/zoom, y = 130/zoom, w = 450/zoom, h = 50/zoom},
    title = {x = sw/2-225/zoom, y = 15/zoom, w = 450/zoom, h = 50/zoom},
    text = {x = sw/2-225/zoom, y = 15/zoom, w = 450/zoom, h = 50/zoom},
}

local fonts = {
    roboto = dxCreateFont("Roboto.ttf", 10/zoom),
    roboto_s = dxCreateFont("Roboto.ttf", 9/zoom),
}

local settings = {
    money = 0,
    startTick = getTickCount(),
    title = "",
    text = "",
    showed = true,
}

renderGui = function()
    dxDrawImage(gui_positions.bg.x, gui_positions.bg.y, gui_positions.bg.w, gui_positions.bg.h, textures.bg)
    dxDrawText(settings.title, gui_positions.title.x, gui_positions.title.y, gui_positions.title.w + gui_positions.title.x, gui_positions.title.h + gui_positions.title.y, white, 1.00, fonts.roboto, "center", "center", _, _, _, true)
    dxDrawText(settings.text, gui_positions.bg.x, gui_positions.bg.y, gui_positions.bg.w + gui_positions.bg.x, gui_positions.bg.h + gui_positions.bg.y, white, 1.00, fonts.roboto, "center", "center", _, _, _, true)
    
    dxDrawImage(gui_positions.money.x, gui_positions.money.y, gui_positions.money.w, gui_positions.money.h, textures.money)
    dxDrawText(settings.money .. " PLN", gui_positions.moneyText.x, gui_positions.moneyText.y, gui_positions.moneyText.w + gui_positions.moneyText.x, gui_positions.moneyText.h + gui_positions.moneyText.y, tocolor(0, 200, 0), 1.00, fonts.roboto, "left", "center")
   
    dxDrawImage(gui_positions.clock.x, gui_positions.clock.y, gui_positions.clock.w, gui_positions.clock.h, textures.clock)
    local seconds = (getTickCount() - settings.startTick) / 1000 / 60
    local hours, minutes = math.floor(seconds/60), string.format("%02d", seconds%60)
    dxDrawText(hours .. ":" .. minutes, gui_positions.clockText.x, gui_positions.clockText.y, gui_positions.clockText.w + gui_positions.clockText.x, gui_positions.clockText.h + gui_positions.clockText.y, white, 1.00, fonts.roboto, "right", "center")
    
    dxDrawText("Naciśnij B, aby wyłączyć okno.", gui_positions.openText.x, gui_positions.openText.y, gui_positions.openText.w + gui_positions.openText.x, gui_positions.openText.h + gui_positions.openText.y, white, 1.00, fonts.roboto_s, "center", "center")
end

setText = function(text)
    settings.text = text
end
addEvent("settings->setText", true)
addEventHandler("settings->setText", resourceRoot, setText)

setMoney = function(money)
    settings.money = money
end
addEvent("settings->setMoney", true)
addEventHandler("settings->setMoney", resourceRoot, setMoney)

setTitle = function(title)
    settings.title = title
end
addEvent("settings->setTitle", true)
addEventHandler("settings->setTitle", resourceRoot, setTitle)

addMoney = function(money)
    settings.money = settings.money + money
end
addEvent("settings->addMoney", true)
addEventHandler("settings->addMoney", resourceRoot, addMoney)


bind = function(k, s)
    if settings.showed then
        removeEventHandler("onClientRender", root, renderGui)
    else
        addEventHandler("onClientRender", root, renderGui)
    end
    settings.showed = not settings.showed
end

showGui = function(bool)
    if bool == true then
        addEventHandler("onClientRender", root, renderGui)
        settings.money = 0
        settings.title = ""
        settings.text = ""
        settings.startTick = getTickCount()
        bindKey("b", "down", bind)
    elseif bool == false then
        unbindKey("b", "down", bind)
        removeEventHandler("onClientRender", root, renderGui)
    end
end
addEvent("settings->showGui", true)
addEventHandler("settings->showGui", resourceRoot, showGui)
