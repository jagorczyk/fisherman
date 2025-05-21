local orders = {}
local timers = {}
playerTrailers = {}
actuallOrder = {}

local startPoint = Vector3(1056.66, 1293.18, 10.92)

createOrder = function()
    local index = math.random(#trailers)
    local randomOrder = trailers[index]
    local payment = getDistanceBetweenPoints2D(startPoint.x, startPoint.y, randomOrder[1], randomOrder[2])
    return {
        position = {x = randomOrder[1], y = randomOrder[2], z = randomOrder[3]},
        rotation = {x = randomOrder[4], y = randomOrder[5], z = randomOrder[6]},
        payment = math.floor(payment),
        id = index,
    }
end

createTrailer = function(player, order)
    local order = trailers[2]
    trailers[player] = createVehicle(435, order[1], order[2], order[3], order[4], order[5], order[6])
end

addEvent("trucker->getMyOrders", true)
addEventHandler("trucker->getMyOrders", resourceRoot, function()
    local sid = getElementData(client, "player:sid")
    if not sid then return end
    
    local result = exports["mysql"]:query("Select * from prpg_trucker_upgrades where sid=? LIMIT 1;", sid)
    if result[1] then
        local orders = fromJSON(result[1].orders)
        triggerClientEvent(client, "trucker->getMyOrders", resourceRoot, orders)
    end

end)

addEvent("trucker->findNewOrder", true)
addEventHandler("trucker->findNewOrder", resourceRoot, function()

    local sid = getElementData(client, "player:sid")
    if not sid then return end

    if timers[client] and isTimer(timers[client]) then return end

    local time = 1
    time = time * 1 * 1000

    local player = client

    timers[client] = setTimer(function()

        local order = createOrder()
        local orders = {}
        local result = exports["mysql"]:query("Select * from prpg_trucker_upgrades where sid=? LIMIT 1;", sid)
    
        if result[1] then
            orders = fromJSON(result[1].orders)
            if #orders >= 9 then return exports["prpg-notifications"]:newNotification("error", "Osiągnięto maksymalną ilość zleceń.", player) end
            table.insert(orders, order)
            local exec = exports["mysql"]:exec("Update prpg_trucker_upgrades set orders = ? where sid = ? LIMIT 1;", toJSON(orders), sid)
        else
            table.insert(orders, order)
            exports["mysql"]:exec("Insert into prpg_trucker_upgrades (sid, orders) VALUES (?, ?)", sid, toJSON(orders))
        end

        triggerClientEvent(player, "trucker->addOrder", resourceRoot, order)
        exports["prpg-notifications"]:newNotification("success", "Pojawiło się nowe zlecenie.", player)
    end, time, 1)

    triggerClientEvent(player, "trucker->createTimer", resourceRoot, time)

end)

addEvent("trucker->startOrder", true)
addEventHandler("trucker->startOrder", resourceRoot, function(orderID)

    local sid = getElementData(client, "player:sid")
    if not sid then return end

    local result = exports["mysql"]:query("Select * from prpg_trucker_upgrades where sid=? LIMIT 1;", sid)
    local orders = {}

    if result[1] then
        orders = fromJSON(result[1].orders)
        for i,v in ipairs(orders) do
            if v.id == orderID then
                actuallOrder[client] = v
                table.remove(orders, i)
            end
        end
    end

    exports["mysql"]:exec("Update prpg_trucker_upgrades set orders=? where sid=? limit 1;", toJSON(orders), sid)
    triggerClientEvent(client, "trucker->showOrderGui", resourceRoot, false)

end)

addEvent("trucker->removeOrder", true)
addEventHandler("trucker->removeOrder", resourceRoot, function(index)

    local sid = getElementData(client, "player:sid")
    if not sid then return end

    local result = exports["mysql"]:query("Select * from prpg_trucker_upgrades where sid=? LIMIT 1;", sid)
    local orders = {}

    if result[1] then
        orders = fromJSON(result[1].orders)
        for i,v in ipairs(orders) do
            if i == index then
                table.remove(orders, i)
            end
        end
    end

    exports["mysql"]:exec("Update prpg_trucker_upgrades set orders=? where sid=? limit 1;", toJSON(orders), sid)

end)

addEvent("trucker->createTrailer", true)
addEventHandler("trucker->createTrailer", resourceRoot, function(index)

    local order = trailers[index]
    local trailer = createVehicle(435, order[1], order[2], order[3], order[4], order[5], order[6])
    local veh = getPedOccupiedVehicle(client)

    setTimer(function()
        attachTrailerToVehicle(veh, trailer) 
    end, 100, 1)

    playerTrailers[client] = trailer

end)

addEvent("trucker->createDevotionPoint", true)
addEventHandler("trucker->createDevotionPoint", resourceRoot, function()

    local index = math.random(#devotion)
    local randomOrder = devotion[index]

    point = {
        position = {x = randomOrder[1], y = randomOrder[2], z = randomOrder[3]},
        rotation = {x = randomOrder[4], y = randomOrder[5], z = randomOrder[6]},
    }

    triggerClientEvent(client, "trucker->createDevotionPoint", resourceRoot, point, playerTrailers[client])

end)

addEvent("trucker->destroyTrailer", true)
addEventHandler("trucker->destroyTrailer", resourceRoot, function()

    if not playerTrailers[client] then return end
    destroyElement(playerTrailers[client])
    playerTrailers[client] = nil

end)

addEvent("trucker->trailerDelivered", true)
addEventHandler("trucker->trailerDelivered", resourceRoot, function()

    if not actuallOrder[client] then return end

    exports["prpg-notifications"]:newNotification("success", "Dostarczono naczepe. Na Twoje konto wpływa " .. formatNumber(actuallOrder[client].payment, ",") .. " PLN.", client)
    givePlayerMoney(client, actuallOrder[client].payment)
    exports["prpg-work-settings"]:addMoney(client, actuallOrder[client].payment)
    actuallOrder[client] = nil

end)


addEventHandler("onTrailerDetach", root, function()
    for k, v in pairs(playerTrailers) do
        if v == source then
            playerTrailers[k] = nil
            actuallOrder[k] = nil
            exports["prpg-notifications"]:newNotification("error", "Naczepa się odpięła. Praca zakończona.", k)
            triggerEvent("trucker->stopWork", k)
            destroyElement(source)
        end
    end
end)