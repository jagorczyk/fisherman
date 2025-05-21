local sw, sh = guiGetScreenSize()
local zoom = 1920/sw

local textures = {
	bg = dxCreateTexture("/images/bg.png", "argb", true, "clamp"),
	button = dxCreateTexture("/images/button.png", "argb", true, "clamp"),
	img = dxCreateTexture("/images/work_img.png", "argb", true, "clamp"),
	slot = dxCreateTexture("/images/slot.png", "argb", true, "clamp"),
	fastcar = dxCreateTexture("/images/fastcar.png", "argb", true, "clamp"),
	buy = dxCreateTexture("/images/buy.png", "argb", true, "clamp"),
    circle = dxCreateTexture("/images/circle.png", "argb", true, "clamp"),
    noavatar = dxCreateTexture("/images/noavatar.png", "argb", true, "clamp"),
    avatarTextures = {},
    shaderTextures = {},
}

local gui_positions = {
    bg = {x = sw/2-325/zoom, y = sh/2-225/zoom, w = 650/zoom, h = 450/zoom},
    button = {x = sw/2-305/zoom, y = sh/2-205/zoom, w = 110/zoom, h = 20/zoom, offsetX = 120/zoom},
    
    glowna = {
        img = {x = sw/2-162/zoom, y = sh/2-120/zoom, w = 325/zoom, h = 183/zoom},
        text = {x = sw/2-55/zoom, y = sh/2+78/zoom, w = 100/zoom, h = 20/zoom},
        button = {x = sw/2-55/zoom, y = sh/2+110/zoom, w = 110/zoom, h = 20/zoom},
    },
    upgrades = {
        slot = {x = sw/2-303/zoom, y = sh/2-160/zoom, w = 600/zoom, h = 40/zoom, offsetY = 48/zoom},
        item = {x = sw/2-292/zoom, y = sh/2-156/zoom, w = 32/zoom, h = 32/zoom},
        title = {x = sw/2-245/zoom, y = sh/2-164/zoom, w = 32/zoom, h = 32/zoom},
        text = {x = sw/2-245/zoom, y = sh/2-147/zoom, w = 32/zoom, h = 32/zoom},
        has = {x = sw/2+260/zoom, y = sh/2-156/zoom, w = 32/zoom, h = 32/zoom},
        scroll = {x = sw/2+305/zoom, y = sh/2-157/zoom, w = 4/zoom, h = 327/zoom},
        myPoints = {x = sw/2-303/zoom, y = sh/2-195/zoom, w = 600/zoom, h = 40/zoom},
    },
    ranking = {
        top1 = {
            circle = {x = sw/2-48/zoom, y = sh/2-125/zoom, w = 96/zoom, h = 96/zoom},
            text = {x = sw/2-50/zoom, y = sh/2-150/zoom, w = 100/zoom, h = 20/zoom},
            info = {x = sw/2-50/zoom, y = sh/2-22/zoom, w = 100/zoom, h = 20/zoom},
        },
        top2 = {
            circle = {x = sw/2-230/zoom, y = sh/2-45/zoom, w = 96/zoom, h = 96/zoom},
            text = {x = sw/2-232/zoom, y = sh/2-70/zoom, w = 100/zoom, h = 20/zoom},
            info = {x = sw/2-232/zoom, y = sh/2+58/zoom, w = 100/zoom, h = 20/zoom},
        },
        top3 = {
            circle = {x = sw/2+134/zoom, y = sh/2-45/zoom, w = 96/zoom, h = 96/zoom},
            text = {x = sw/2+136/zoom, y = sh/2-70/zoom, w = 100/zoom, h = 20/zoom},
            info = {x = sw/2+136/zoom, y = sh/2+58/zoom, w = 100/zoom, h = 20/zoom},
        },
    }
}

local settings = {
    selected = "Strona główna",
    site = 1,
    column = 7,
    move = 0,
    ppoints = 0,
    clickTick = getTickCount(),
}

local fonts = {
    roboto = dxCreateFont("Roboto.ttf", 9/zoom),
    roboto_m = dxCreateFont("Roboto.ttf", 10/zoom),
    roboto_b = dxCreateFont("Roboto.ttf", 11/zoom),
}

local options = {
    "Strona główna",
    "Ulepszenia",
    "Ranking"
}

local upgrades = {}
local playerUpgrades = {}

local rankingColors = {
    [1] = tocolor(252, 235, 3),
    [2] = tocolor(224, 224, 224),
    [3] = tocolor(205, 127, 50)
}

local rankingOfPlayers = {}

renderGui = function()
    dxDrawImage(gui_positions.bg.x, gui_positions.bg.y, gui_positions.bg.w, gui_positions.bg.h, textures.bg)
    for i, v in ipairs(options) do
        local offsetX = (gui_positions.button.offsetX) * (i-1)
        local hover = isMouseInPosition(gui_positions.button.x + offsetX, gui_positions.button.y, gui_positions.button.w, gui_positions.button.h) and 200 or 255
        dxDrawImage(gui_positions.button.x + offsetX, gui_positions.button.y, gui_positions.button.w, gui_positions.button.h, textures.button, 0, 0, 0, tocolor(30, 30, 30, hover))
        dxDrawText(v, gui_positions.button.x + offsetX, gui_positions.button.y, gui_positions.button.w + gui_positions.button.x + offsetX, gui_positions.button.h + gui_positions.button.y, white, 1.00, fonts.roboto, "center", "center")
    end

    if settings.selected == "Strona główna" then
        local gui_positions = gui_positions.glowna
        dxDrawImage(gui_positions.img.x, gui_positions.img.y, gui_positions.img.w, gui_positions.img.h, textures.img)
        dxDrawText("Wymagania: 150 SRP, prawo jazdy kat. B", gui_positions.text.x, gui_positions.text.y, gui_positions.text.w + gui_positions.text.x, gui_positions.text.h + gui_positions.text.y, white, 1.00, fonts.roboto, "center", "center")
        
        local hover = isMouseInPosition(gui_positions.button.x, gui_positions.button.y, gui_positions.button.w, gui_positions.button.h) and 200 or 255
        dxDrawImage(gui_positions.button.x, gui_positions.button.y, gui_positions.button.w, gui_positions.button.h, textures.button, 0, 0, 0, tocolor(33, 84, 229, hover))
        dxDrawText("Rozpocznij", gui_positions.button.x, gui_positions.button.y, gui_positions.button.w + gui_positions.button.x, gui_positions.button.h + gui_positions.button.y, white, 1.00, fonts.roboto, "center", "center")
    end

    n = 0

    if settings.selected == "Ulepszenia" then
        local gui_positions = gui_positions.upgrades
        dxDrawText("Twoje punkty: #a0a0a0" .. settings.ppoints or 0, gui_positions.myPoints.x, gui_positions.myPoints.y, gui_positions.myPoints.w + gui_positions.myPoints.x, gui_positions.myPoints.h + gui_positions.myPoints.y, white, 1.00, fonts.roboto, "right", "center", _, _, _, true)
        for i, v in ipairs(upgrades) do
            if i >= settings.site and i <= settings.column then
                n = n + 1
                local offsetY = (gui_positions.slot.offsetY) * (n-1)
                dxDrawImage(gui_positions.slot.x, gui_positions.slot.y + offsetY, gui_positions.slot.w, gui_positions.slot.h, textures.slot)
                dxDrawImage(gui_positions.item.x, gui_positions.item.y + offsetY, gui_positions.item.w, gui_positions.item.h, v.texture)
                dxDrawText(v.title .. " - #a0a0a0" .. v.cost .. " punktów pracy " .. (hasUpgrade(v.title) and "#00bb00(posiadane)" or ""), gui_positions.title.x, gui_positions.title.y + offsetY, gui_positions.title.w + gui_positions.title.x, gui_positions.title.h + gui_positions.title.y + offsetY, white, 1.00, fonts.roboto, "left", "center", _, _, _, true)
                dxDrawText(v.text, gui_positions.text.x, gui_positions.text.y + offsetY, gui_positions.text.w + gui_positions.text.x, gui_positions.text.h + gui_positions.text.y + offsetY, white, 1.00, fonts.roboto, "left", "center")
                local hover = isMouseInPosition(gui_positions.has.x, gui_positions.has.y + offsetY, gui_positions.has.w, gui_positions.has.h) and 150 or 255
                if not hasUpgrade(v.title) then
                    dxDrawImage(gui_positions.has.x, gui_positions.has.y + offsetY, gui_positions.has.w, gui_positions.has.h, textures.buy, 0, 0, 0, tocolor(255, 255, 255, hover))
                end
            end
        end
        if #upgrades > 8 then 
            dxDrawRectangle(gui_positions.scroll.x, gui_positions.scroll.y, gui_positions.scroll.w, gui_positions.scroll.h, tocolor(30, 30, 30))
            dxDrawRectangle(gui_positions.scroll.x, gui_positions.scroll.y + settings.move, gui_positions.scroll.w, gui_positions.scroll.h * 7/#upgrades, tocolor(33, 84, 229))
        end
    end

    if settings.selected == "Ranking" then
        local gui_positions = gui_positions.ranking
        for i=1, 3 do
            dxDrawText("TOP " .. i, gui_positions["top"..i].text.x, gui_positions["top"..i].text.y, gui_positions["top"..i].text.w + gui_positions["top"..i].text.x, gui_positions["top"..i].text.h + gui_positions["top"..i].text.y, rankingColors[i], 1.00, fonts.roboto_b, "center", "center")
            local player = rankingOfPlayers[i]
            if player then
                dxDrawText(player.nick .. " - #a0a0a0" .. player.points .. " pkt", gui_positions["top"..i].info.x, gui_positions["top"..i].info.y, gui_positions["top"..i].info.w + gui_positions["top"..i].info.x, gui_positions["top"..i].info.h + gui_positions["top"..i].info.y, white, 1.00, fonts.roboto_m, "center", "center", _, _, _, true)
            else
                dxDrawText("brak", gui_positions["top"..i].info.x, gui_positions["top"..i].info.y, gui_positions["top"..i].info.w + gui_positions["top"..i].info.x, gui_positions["top"..i].info.h + gui_positions["top"..i].info.y, white, 1.00, fonts.roboto_m, "center", "center", _, _, _, true)
            end
            dxDrawImage(gui_positions["top"..i].circle.x, gui_positions["top"..i].circle.y, gui_positions["top"..i].circle.w, gui_positions["top"..i].circle.h, player and textures.shaderTextures[player.sid] or textures.noavatar)
        end
    end

end

scrollPane = function(key)
    if settings.selected ~= "Ulepszenia" then return end
    local list = upgrades
    local gui_positions = gui_positions.upgrades
    if key == "mouse_wheel_up" then
        if settings.site ~= 1 then
            settings.site = settings.site-1
            settings.column = settings.column-1
            settings.move = settings.move - (gui_positions.scroll.h - (gui_positions.scroll.h * 7/#list)) / (#list - 7)
        end
    elseif key == "mouse_wheel_down" then
        if settings.column < #list then
            settings.site = settings.site+1
            settings.column = settings.column+1
            settings.move = settings.move + (gui_positions.scroll.h - (gui_positions.scroll.h * 7/#list)) / (#list - 7)
        end
    end
end

hasUpgrade = function(upgrade)
    for _, u in ipairs(playerUpgrades) do
        if u == upgrade then
            return true
        end
    end
    return false
end

changePageButtonClick = function(b, s)
    if b == "left" and s == "up" then
        for i, v in ipairs(options) do
            local offsetX = (gui_positions.button.offsetX) * (i-1)
            if isMouseInPosition(gui_positions.button.x + offsetX, gui_positions.button.y, gui_positions.button.w, gui_positions.button.h) then
                if settings.selected == v then return end
                settings.selected = v
            end
        end
    end
end

startWorkButtonClick = function(b, s)
    if b == "left" and s == "up" then
        if settings.selected ~= "Strona główna" then return end
        local gui_positions = gui_positions.glowna
        if isMouseInPosition(gui_positions.button.x, gui_positions.button.y, gui_positions.button.w, gui_positions.button.h) then
            triggerServerEvent("streetview->startWork", resourceRoot)
        end
    end
end

buyUpgradeButtonClick = function(b, s)
    if b == "left" and s == "up" then
        if settings.selected ~= "Ulepszenia" then return end
        local gui_positions = gui_positions.upgrades
        n = 0
        for i, v in ipairs(upgrades) do
            if i >= settings.site and i <= settings.column then
                n = n + 1
                local offsetY = (gui_positions.slot.offsetY) * (n-1)
                if settings.clickTick + 1000 > getTickCount() then return end
                if isMouseInPosition(gui_positions.has.x, gui_positions.has.y + offsetY, gui_positions.has.w, gui_positions.has.h) then
                    triggerServerEvent("streetview->buyWorkUpgrade", resourceRoot, i)
                    settings.clickTick = getTickCount()
                end
            end
        end
    end
end

getWorkUpgrades = function(list)
    upgrades = {}
    for _, u in ipairs(list) do
        table.insert(upgrades, {
            title = u.title,
            text = u.text,
            cost = u.cost,
            texture = dxCreateTexture(u.texture, "argb", true, "clamp"),
        })
    end
end
addEvent("streetview->getWorkUpgrades", true)
addEventHandler("streetview->getWorkUpgrades", resourceRoot, getWorkUpgrades)

getMyWorkInfo = function(list, points)
    playerUpgrades = list
    settings.ppoints = points
end
addEvent("streetview->getMyWorkInfo", true)
addEventHandler("streetview->getMyWorkInfo", resourceRoot, getMyWorkInfo)

addAvatar = function(index)
	local texture = exports["prpg-avatars"]:getAvatar(index)

    if not texture then return end
	if textures.avatarTextures[index] == texture then return end

    local avatar = dxCreateTexture("/images/circle.png", "argb", true, "clamp")
    textures.avatarTextures[index] = nil
	textures.shaderTextures[index] = nil

	textures.avatarTextures[index] = texture
	textures.shaderTextures[index] = dxCreateShader("/include/hud_mask.fx")

	dxSetShaderValue(textures.shaderTextures[index], "sPicTexture", textures.avatarTextures[index]) 
	dxSetShaderValue(textures.shaderTextures[index], "sMaskTexture", avatar)
end

getWorkRanking = function(list)
    rankingOfPlayers = {}
    for i, r in ipairs(list) do
        table.insert(rankingOfPlayers, {
            nick = r.login,
            points = r.ppoints,
            sid = r.id,
        })
        addAvatar(r.id)
    end
end
addEvent("streetview->getWorkRanking", true)
addEventHandler("streetview->getWorkRanking", resourceRoot, getWorkRanking)

showGui = function(bool)
    if bool == true then
        addEventHandler("onClientRender", root, renderGui)
        addEventHandler("onClientClick", root, startWorkButtonClick)
        addEventHandler("onClientClick", root, changePageButtonClick)
        addEventHandler("onClientClick", root, buyUpgradeButtonClick)
        addEventHandler("onClientKey", root, scrollPane)
        triggerServerEvent("streetview->getWorkUpgrades", resourceRoot)
        triggerServerEvent("streetview->getMyWorkInfo", resourceRoot)
        triggerServerEvent("streetview->getWorkRanking", resourceRoot)
        settings.selected = "Strona główna"
    elseif bool == false then
        removeEventHandler("onClientRender", root, renderGui)
        removeEventHandler("onClientClick", root, startWorkButtonClick)
        removeEventHandler("onClientClick", root, changePageButtonClick)
        removeEventHandler("onClientClick", root, buyUpgradeButtonClick)
        removeEventHandler("onClientKey", root, scrollPane)
    end
end