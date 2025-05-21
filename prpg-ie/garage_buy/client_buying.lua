local sw, sh = guiGetScreenSize()
local zoom = 1920/sw

local fonts = {
    roboto = dxCreateFont("roboto.ttf", 10/zoom),
    roboto_s = dxCreateFont("roboto.ttf", 9/zoom),
}

local textures = {
	bg = dxCreateTexture("/images/bg_buying.png", "argb", true, "clamp"),
	button = dxCreateTexture("/images/button.png", "argb", true, "clamp"),
}

local gui_positions = {
    bg = {x = sw/2-250/zoom, y = sh/2-175/zoom, w = 500/zoom, h = 350/zoom},
    title = {x = sw/2-250/zoom, y = sh/2-175/zoom, w = 500/zoom, h = 50/zoom},
    text = {x = sw/2-250/zoom, y = sh/2-175/zoom, w = 500/zoom, h = 350/zoom},
    button = {x = sw/2-60/zoom, y = sh/2+125/zoom, w = 120/zoom, h = 25/zoom},
}

renderBuyingMenu = function()
    dxDrawImage(gui_positions.bg.x, gui_positions.bg.y, gui_positions.bg.w, gui_positions.bg.h, textures.bg)
    dxDrawText("Garaż Import-Export", gui_positions.title.x, gui_positions.title.y, gui_positions.title.w + gui_positions.title.x, gui_positions.title.h + gui_positions.title.y, white, 1.00, fonts.roboto, "center", "center")
    
    local hover = isMouseInPosition(gui_positions.button.x, gui_positions.button.y, gui_positions.button.w, gui_positions.button.h) and 200 or 255
    dxDrawImage(gui_positions.button.x, gui_positions.button.y, gui_positions.button.w, gui_positions.button.h, textures.button, 0, 0, 0, tocolor(255, 255, 255, hover))
    dxDrawText("Kup", gui_positions.button.x, gui_positions.button.y, gui_positions.button.w + gui_positions.button.x, gui_positions.button.h + gui_positions.button.y, white, 1.00, fonts.roboto, "center", "center")
    
    dxDrawText("W tym garażu możesz przechowywać nielegalnie\nsprowadzone przez siebie pojazdy.\n\nKoszt kupienia garażu to 500,000 #00bb00PLN#ffffff.", gui_positions.text.x, gui_positions.text.y, gui_positions.text.w + gui_positions.text.x, gui_positions.text.h + gui_positions.text.y, white, 1.00, fonts.roboto, "center", "center", _, _, _, true)
end

buyGarageButtonClick = function(b,s)
    if b == "left" and s == "down" then
        if isMouseInPosition(gui_positions.button.x, gui_positions.button.y, gui_positions.button.w, gui_positions.button.h) then
            triggerServerEvent("ie->buyGarage", resourceRoot)
            showBuyingMenu(false)
        end
    end
end


showBuyingMenu = function(bool)
    if bool == true then
        addEventHandler("onClientRender", root, renderBuyingMenu)
        addEventHandler("onClientClick", root, buyGarageButtonClick)
    elseif bool == false then
        removeEventHandler("onClientRender", root, renderBuyingMenu)
        removeEventHandler("onClientClick", root, buyGarageButtonClick)
    end
end
addEvent("ie->showBuyingMenu", true)
addEventHandler("ie->showBuyingMenu", resourceRoot, showBuyingMenu)