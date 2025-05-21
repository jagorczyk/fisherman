local enterMarker = createMarker(1612.90, -1559.63, 14.17 - 0.5, "cylinder", 0.9, 33, 84, 229, 0)

setElementData(enterMarker, "marker:info", {
    image = ":prpg-tuner/images/wrench.png",
    text = "Garaż Import/Export",
    size = 1.2,
    offset = 80,
})

local markersExit = {}

createExitMarker = function(sid)

    if markersExit[sid] then
        destroyElement(markersExit[sid])
    end

    markersExit[sid] = createMarker(2734.06, -1780.55, 667.30 - 0.5, "cylinder", 0.9, 33, 84, 229, 0)
    setElementDimension(markersExit[sid], sid)

    setElementData(markersExit[sid], "marker:info", {
        image = ":prpg-tuner/images/wrench.png",
        text = "Wyjście z garażu",
        size = 1.2,
        offset = 80,
    })

    addEventHandler("onMarkerHit", markersExit[sid], function(el, md)
        if getElementType(el) ~= "player" then return end
        if not md then return end

        if getPedOccupiedVehicle(el) then return end

        local s = getElementData(el, "player:sid")
        if not s then return end

        if sid ~= s then return end

        local player = el
        fadeCamera(player, false, 1)
    
        setTimer(function()
            fadeCamera(player, true, 1) 
            setElementDimension(player, 0)
            setElementPosition(player, 1612.86, -1557.85, 14.15)
        end, 1000, 1)

        destroyVehiclesInGarage(player)
        destroyElement(source)
        markersExit[sid] = nil
    end)

end

addEventHandler("onMarkerHit", enterMarker, function(el, md)
    if getElementType(el) ~= "player" then return end
    if not md then return end

    if getPedOccupiedVehicle(el) then return end

    local sid = getElementData(el, "player:sid")
    if not sid then return end

    local query = exports["mysql"]:query("Select * from prpg_ie where sid=? LIMIT 1;", sid)
    if query[1] then
        
        local player = el
        fadeCamera(player, false, 1)

        setTimer(function()
            fadeCamera(player, true, 1) 
            setElementDimension(player, sid)
            setElementPosition(player, 2734.02, -1777.67, 667.30)
        end, 1000, 1)

        createVehiclesInGarage(player, sid, fromJSON(query[1].vehicles))
        createExitMarker(sid)
    else
        triggerClientEvent(el, "ie->showBuyingMenu", resourceRoot, true)
    end

end)

addEventHandler("onMarkerLeave", enterMarker, function(el, md)
    if getElementType(el) ~= "player" then return end
    if not md then return end

    triggerClientEvent(el, "ie->showBuyingMenu", resourceRoot, false)
end)

local price = 500000

addEvent("ie->buyGarage", true)
addEventHandler("ie->buyGarage", resourceRoot, function()

    local sid = getElementData(client, "player:sid")
    if not sid then return end

    if getPlayerMoney(client) < price then exports["prpg-notifications"]:newNotification("error", "Nie posiadasz przy sobie tyle gotówki.", client) return end
    
    local exec = exports["mysql"]:exec("INSERT INTO prpg_ie (sid) VALUES (?)", sid)
    if exec then
        exports["prpg-notifications"]:newNotification("success", "Pomyślnie zakupiono garaż i/e.", client)
        takePlayerMoney(client, price)
    end

end)