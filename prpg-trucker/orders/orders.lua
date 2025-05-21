local sw, sh = guiGetScreenSize()
local zoom = 1920/sw

local textures = {
	bg = dxCreateTexture("/images/bg.png", "argb", true, "clamp"),
	map = dxCreateTexture("/images/map.png", "argb", true, "clamp"),
	button2 = dxCreateTexture("/images/button2.png", "argb", true, "clamp"),
	button1 = dxCreateTexture("/images/button.png", "argb", true, "clamp"),
	panel = dxCreateTexture("/images/panel.png", "argb", true, "clamp"),
	pin = dxCreateTexture("/images/pin.png", "argb", true, "clamp"),
	delete = dxCreateTexture("/images/delete.png", "argb", true, "clamp"),
}

local gui_positions = {
    bg = {x = sw/2-425/zoom, y = sh/2-225/zoom, w = 850/zoom, h = 450/zoom},
    map = {x = sw/2-223/zoom, y = sh/2-200/zoom, w = 648/zoom, h = 400/zoom},
    button = {x = sw/2-415/zoom, y = sh/2-215/zoom, w = 180/zoom, h = 35/zoom, offsetY = 40/zoom},
    delete = {x = sw/2-262/zoom, y = sh/2-210/zoom, w = 24/zoom, h = 24/zoom},
    pin = {w = 32/zoom, h = 32/zoom},
    findText = {x = sw/2-425/zoom, y = sh/2+190/zoom, w = 200/zoom, h = 20/zoom},
    buttonAccept = {x = sw/2-380/zoom, y = sh/2+155/zoom, w = 110/zoom, h = 20/zoom},
}


local settings = {
    w = 3000,
    h = 3000,
    img_w = 550/zoom,
    img_h = 400/zoom,
    lastCursorPos = {},
    move = Vector2(0, 0),
    timer = nil,
    polygon = nil,
    trailer = nil,
    renderFunction = nil,
    canRemove = false,
}

local fonts = {
    roboto = dxCreateFont("Roboto.ttf", 9/zoom),
    roboto_m = dxCreateFont("Roboto.ttf", 10/zoom),
    roboto_b = dxCreateFont("Roboto.ttf", 11/zoom),
}

local orders = {}

renderOrderGui = function()
    dxDrawImage(gui_positions.bg.x, gui_positions.bg.y, gui_positions.bg.w, gui_positions.bg.h, textures.panel)
    dxDrawImageSection(gui_positions.map.x, gui_positions.map.y, gui_positions.map.w, gui_positions.map.h, settings.move.x, settings.move.y, gui_positions.map.w, gui_positions.map.h, textures.map)
    n = 0
    for i, v in ipairs(orders) do
        n = n + 1
        local offsetY = (gui_positions.button.offsetY) * (n-1)
        local zone = getZoneName(v.position.x, v.position.y, v.position.z, true) .. ", " .. getZoneName(v.position.x, v.position.y, v.position.z)

        local hover = settings.clicked == i and 175 or isMouseInPosition(gui_positions.button.x, gui_positions.button.y + offsetY, gui_positions.button.w, gui_positions.button.h) and 175 or 255
        dxDrawImage(gui_positions.button.x, gui_positions.button.y + offsetY, gui_positions.button.w, gui_positions.button.h, textures.button2, 0, 0, 0, tocolor(255, 255, 255, hover))
        
        dxDrawText(zone .. "\n#00bb00" .. formatNumber(v.payment, ",") .. " PLN", gui_positions.button.x + 5/zoom, gui_positions.button.y + offsetY, gui_positions.button.w + gui_positions.button.x - 5/zoom, gui_positions.button.h + gui_positions.button.y + offsetY, white, 1.00/zoom, fonts.roboto, "left", "center", true, _, _, true)
        
        local pos = findScreenLocation(v.position.x, v.position.y)
        if isLocationVisible((pos[1] - gui_positions.pin.w/2), (pos[2] - gui_positions.pin.h/2), gui_positions.pin.w, gui_positions.pin.h, gui_positions.map.x, gui_positions.map.y, gui_positions.map.w, gui_positions.map.h) then
            local hover = settings.clicked == i and 175 or isMouseInPosition((pos[1] - gui_positions.pin.w/2), (pos[2] - gui_positions.pin.h/2), gui_positions.pin.w, gui_positions.pin.h) and 200 or 255
            dxDrawImage((pos[1] - gui_positions.pin.w/2), (pos[2] - gui_positions.pin.h/2), gui_positions.pin.w, gui_positions.pin.h, textures.pin, 0, 0, 0, tocolor(33, 84, 229, hover))
        end

        local hover = isMouseInPosition(gui_positions.button.x, gui_positions.button.y + offsetY, gui_positions.button.w, gui_positions.button.h)

        if settings.canRemove and hover then
            local hover = isMouseInPosition(gui_positions.delete.x, gui_positions.delete.y + offsetY, gui_positions.delete.w, gui_positions.delete.h)
            dxDrawImage(gui_positions.delete.x, gui_positions.delete.y + offsetY, gui_positions.delete.w, gui_positions.delete.h, textures.delete, 0, 0, 0, tocolor(255, 255, 255, hover and 175 or 255))
        end
    end

    local hover = isMouseInPosition(gui_positions.findText.x, gui_positions.findText.y, gui_positions.findText.w, gui_positions.findText.h) and 175 or 255
    local text = "Kliknij tutaj,\naby wyszukać nowe zlecenie."
    if settings.timer and isTimer(settings.timer) then
        local time = getTimerDetails(settings.timer)
        if time then
            time = time/1000
            local minutes, seconds = math.floor(time/60), string.format("%02d", time%60)
            text = "Trwa szukanie...\nPozostały czas: " .. minutes .. ":" .. seconds
        end
    end
    dxDrawText(text, gui_positions.findText.x, gui_positions.findText.y, gui_positions.findText.w + gui_positions.findText.x, gui_positions.findText.h + gui_positions.findText.y, tocolor(255,255,255,hover), 1.00/zoom, fonts.roboto, "center", "center")

    local hover = isMouseInPosition(gui_positions.buttonAccept.x, gui_positions.buttonAccept.y, gui_positions.buttonAccept.w, gui_positions.buttonAccept.h) and 175 or 255
    dxDrawImage(gui_positions.buttonAccept.x, gui_positions.buttonAccept.y, gui_positions.buttonAccept.w, gui_positions.buttonAccept.h, textures.button1, 0, 0, 0, tocolor(33, 84, 229, hover))
    dxDrawText("Rozpocznij", gui_positions.buttonAccept.x, gui_positions.buttonAccept.y, gui_positions.buttonAccept.w + gui_positions.buttonAccept.x, gui_positions.buttonAccept.h + gui_positions.buttonAccept.y, white, 1.00/zoom, fonts.roboto, "center", "center")

end

mapClickKey = function(b, s)

    if b == "mouse1" and s == true then
        if not isMouseInPosition(gui_positions.map.x, gui_positions.map.y, gui_positions.map.w, gui_positions.map.h) then return end
        local cursorPos = {getCursorPosition()}
        settings.lastCursorPos = {cursorPos[1] * sw + settings.move.x, cursorPos[2] * sh + settings.move.y}
        addEventHandler("onClientCursorMove", root, cursorMove)
    elseif b == "mouse1" and s == false then
        removeEventHandler("onClientCursorMove", root, cursorMove)
    end

end

cursorMove = function(_, _, nX, nY)
    local temp = {nX - settings.lastCursorPos[1], nY - settings.lastCursorPos[2]}
    settings.move.x = -temp[1]
    settings.move.x = settings.move.x > settings.w - gui_positions.map.w and settings.w - gui_positions.map.w or settings.move.x
    settings.move.x = settings.move.x < 0 and 0 or settings.move.x

    settings.move.y = -temp[2]
    settings.move.y = settings.move.y > settings.h - gui_positions.map.h and settings.h - gui_positions.map.h or settings.move.y
    settings.move.y = settings.move.y < 0 and 0 or settings.move.y
end

findScreenLocation = function(x, y)

    local center = {gui_positions.map.x + settings.w/2 - settings.move.x, gui_positions.map.y + settings.h/2 - settings.move.y} -- pos(0, 0)
    local new_x = center[1] + settings.w/2 * x / 3000
    local new_y = center[2] + settings.h/2 * y / -3000

    return {new_x, new_y}

end

moveTo = function(x, y)

    local center = {settings.w/2 - gui_positions.map.w/2, settings.h/2 - gui_positions.map.h/2}
    local new_x = center[1] + settings.w/2 * x / 3000
    local new_y = center[2]  + settings.h/2 * y / -3000

    new_x = new_x > settings.w - gui_positions.map.w and settings.w - gui_positions.map.w or new_x
    new_x = new_x < 0 and 0 or new_x

    new_y = new_y > settings.h - gui_positions.map.h and settings.h - gui_positions.map.h or new_y
    new_y = new_y < 0 and 0 or new_y

    animate(settings.move.x, new_x, 2, 500, function(x)
        settings.move.x = x
    end)
    
    animate(settings.move.y, new_y, 2, 500, function(y)
        settings.move.y = y
    end)

end

moveToButtonClick = function(b, s)

    if b == "left" and s == "down" then

        n = 0
        for i, v in ipairs(orders) do
            n = n + 1
            local offsetY = (gui_positions.button.offsetY) * (n-1)

            if settings.canRemove and isMouseInPosition(gui_positions.delete.x, gui_positions.delete.y + offsetY, gui_positions.delete.w, gui_positions.delete.h) then
                triggerServerEvent("trucker->removeOrder", resourceRoot, i)
                table.remove(orders, i)
                return
            end

            if isMouseInPosition(gui_positions.button.x, gui_positions.button.y + offsetY, gui_positions.button.w, gui_positions.button.h) then
                settings.clicked = i
                moveTo(v.position.x, v.position.y)
            end

            local pos = findScreenLocation(v.position.x, v.position.y)
            if isLocationVisible((pos[1] - gui_positions.pin.w/2), (pos[2] - gui_positions.pin.h/2), gui_positions.pin.w, gui_positions.pin.h, gui_positions.map.x, gui_positions.map.y, gui_positions.map.w, gui_positions.map.h) then
                if isMouseInPosition(gui_positions.map.x, gui_positions.map.y, gui_positions.map.w, gui_positions.map.h) and isMouseInPosition((pos[1] - gui_positions.pin.w/2), (pos[2] - gui_positions.pin.h/2), gui_positions.pin.w, gui_positions.pin.h) then
                    settings.clicked = i
                    moveTo(v.position.x, v.position.y)
                end
            end

        end
        
    end

end


function pointInPolygon( x, y, ...)
    local vertices = {...}
    local points= {}
      
    for i=1, #vertices-1, 2 do
      points[#points+1] = { x=vertices[i], y=vertices[i+1] }
    end
    local i, j = #points, #points
    local inside = false
  
    for i=1, #points do
      if ((points[i].y < y and points[j].y>=y or points[j].y< y and points[i].y>=y) and (points[i].x<=x or points[j].x<=x)) then
        if (points[i].x+(y-points[i].y)/(points[j].y-points[i].y)*(points[j].x-points[i].x)<x) then
          inside = not inside
        end
      end
      j = i
    end
  
    return inside
end

createPolygon = function(order, trailer, moveForward)
    local angle = math.rad(order.rotation.z) 
            
    local matrix = trailer.matrix
    local newPosition = matrix:transformPosition(Vector3(0, moveForward or 0, 0))
    
    local x, y
    x = newPosition.x
    y = newPosition.y

    local points = {
        Vector2(x, y), 
        Vector2(x + 2, y),
        Vector2(x, y + 2), 
        Vector2(x - 2, y), 
        Vector2(x, y - 2),
    }

    local t = {}

    for i, point in ipairs(points) do
        local px, py = point.x, point.y
        local rotatedX = math.cos(angle) * (px - x) - math.sin(angle) * (py - y) + x
        local rotatedY = math.sin(angle) * (px - x) + math.cos(angle) * (py - y) + y
        
        table.insert(t, rotatedX)
        table.insert(t, rotatedY)
    end

    local polygon = createColPolygon(unpack(t))
    
    return {polygon = polygon, points = t}
end

startButtonClick = function(b, s)
    if b == "left" and s == "down" then
        if isMouseInPosition(gui_positions.buttonAccept.x, gui_positions.buttonAccept.y, gui_positions.buttonAccept.w, gui_positions.buttonAccept.h) then
            if not settings.clicked then return end
            local order = orders[settings.clicked]
            local trailer = createVehicle(435, order.position.x, order.position.y, order.position.z, order.rotation.x, order.rotation.y, order.rotation.z)
            local blip = createBlipAttachedTo(trailer, 12, 2, 255, 255, 255, 255, _, 99999)
            exports["prpg-work-settings"]:setText("Udaj się do #eb34bdC #ffffffoznaczonego na mapie, aby odebrać naczepe.\nPrzy odbieraniu uważaj, aby naczepa się nie odczepiła.")
            triggerServerEvent("trucker->startOrder", resourceRoot, order.id)

            setElementFrozen(trailer, true)
            setElementAlpha(trailer, 150)
            local polygon = createPolygon(order, trailer, 3.5)
            
            settings.trailer = trailer
            settings.polygon = polygon.polygon

            renderPolygonChecking = function()
                local element = Vector3(getPositionFromElementOffset(getPedOccupiedVehicle(localPlayer), 0, -5, 0))
                if pointInPolygon(element.x, element.y, unpack(polygon.points)) then
                    destroyElement(trailer)
                    destroyElement(polygon.polygon)
                    triggerServerEvent("trucker->createTrailer", resourceRoot, order.id)
                    triggerServerEvent("trucker->createDevotionPoint", resourceRoot)
                    removeEventHandler("onClientRender", root, renderPolygonChecking)
                end
            end
            addEventHandler("onClientRender", root, renderPolygonChecking)
            settings.renderFunction = renderPolygonChecking
        end
    end
end

createDevotionPoint = function(point, playerTrailer)
    local trailer = createVehicle(435, point.position.x, point.position.y, point.position.z, point.rotation.x, point.rotation.y, point.rotation.z)
    local blip = createBlipAttachedTo(trailer, 12, 2, 255, 255, 255, 255, _, 99999)
    exports["prpg-work-settings"]:setText("Udaj się do #eb34bdC #ffffffoznaczonego na mapie, aby odstawić naczepe.")

    setElementFrozen(trailer, true)
    setElementAlpha(trailer, 150)
    setElementCollisionsEnabled(trailer, false)

    local polygon = createPolygon(point, trailer)

    settings.trailer = trailer
    settings.polygon = polygon.polygon

    renderPolygonChecking = function()
        if not isElement(playerTrailer) then
            exports["prpg-work-settings"]:setText("Wjedź ciężarówką do żółtego punktu z walizką.")
            destroyElement(trailer)
            destroyElement(polygon.polygon)
            removeEventHandler("onClientRender", root, renderPolygonChecking)
        end
        local element = Vector3(getPositionFromElementOffset(playerTrailer, 0, 0, 0))
        if pointInPolygon(element.x, element.y, unpack(polygon.points)) then
            exports["prpg-work-settings"]:setText("Wjedź ciężarówką do żółtego punktu z walizką.")
            triggerServerEvent("trucker->destroyTrailer", resourceRoot)
            triggerServerEvent("trucker->trailerDelivered", resourceRoot)
            destroyElement(trailer)
            destroyElement(polygon.polygon)
            removeEventHandler("onClientRender", root, renderPolygonChecking)
        end
    end
    addEventHandler("onClientRender", root, renderPolygonChecking)
    settings.renderFunction = renderPolygonChecking
end
addEvent("trucker->createDevotionPoint", true)
addEventHandler("trucker->createDevotionPoint", resourceRoot, createDevotionPoint)

isLocationVisible = function(lX, lY, lW, lH, x, y, w, h)
	return ((lX >= x and lX <= x + w) and (lY >= y and lY <= y + h) and (lX + lW >= x and lX + lW <= x + w) and (lY + lH >= y and lY + lH <= y + h))
end

findNewOrderButtonClick = function(b, s)
    if b == "left" and s == "down" then
        if isMouseInPosition(gui_positions.findText.x, gui_positions.findText.y, gui_positions.findText.w, gui_positions.findText.h) then
            triggerServerEvent("trucker->findNewOrder", resourceRoot)
        end
    end
end

createTimer = function(time)
    settings.timer = setTimer(function()
        settings.timer = nil
    end, time, 1)
end
addEvent("trucker->createTimer", true)
addEventHandler("trucker->createTimer", resourceRoot, createTimer)

addOrder = function(list)
    table.insert(orders, list)
end
addEvent("trucker->addOrder", true)
addEventHandler("trucker->addOrder", resourceRoot, addOrder)

getMyOrders = function(list)
    orders = list
end
addEvent("trucker->getMyOrders", true)
addEventHandler("trucker->getMyOrders", resourceRoot, getMyOrders)

destroyTrailersAndPolygons = function()
    if settings.polygon and isElement(settings.polygon) then
        destroyElement(settings.polygon)
        settings.polygon = nil
    end
    if settings.trailer and isElement(settings.trailer) then
        destroyElement(settings.trailer)
        settings.trailer = nil
    end
    if settings.renderFunction then
        removeEventHandler("onClientRender", root, settings.renderFunction)
        settings.renderFunction = nil
    end
end
addEvent("trucker->destroyTrailersAndPolygons", true)
addEventHandler("trucker->destroyTrailersAndPolygons", resourceRoot, destroyTrailersAndPolygons)

canRemoveOrders = function(bool)
    settings.canRemove = bool
end
addEvent("trucker->canRemoveOrders", true)
addEventHandler("trucker->canRemoveOrders", resourceRoot, canRemoveOrders)

showOrderGui = function(bool)
    if bool == true then
        addEventHandler("onClientRender", root, renderOrderGui)
        addEventHandler("onClientKey", root, mapClickKey)
        addEventHandler("onClientClick", root, moveToButtonClick)
        addEventHandler("onClientClick", root, findNewOrderButtonClick)
        addEventHandler("onClientClick", root, startButtonClick)
        triggerServerEvent("trucker->getMyOrders", resourceRoot)
        triggerServerEvent("trucker->getMyWorkInfo", resourceRoot)
    elseif bool == false then
        removeEventHandler("onClientRender", root, renderOrderGui)
        removeEventHandler("onClientKey", root, mapClickKey)
        removeEventHandler("onClientClick", root, moveToButtonClick)
        removeEventHandler("onClientClick", root, findNewOrderButtonClick)
        removeEventHandler("onClientClick", root, startButtonClick)
        orders = {}
        settings.clicked = nil
        settings.canRemove = false
    end
end
addEvent("trucker->showOrderGui", true)
addEventHandler("trucker->showOrderGui", resourceRoot, showOrderGui)