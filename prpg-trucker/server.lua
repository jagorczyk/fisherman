work = {}
local trucksList = {
    [403] = true, --Linerunner,
    [515] = true, --Roadtrain,
    [514] = true, --Roadtrain,
}

addEvent("trucker->startWork", true)
addEventHandler("trucker->startWork", resourceRoot, function()

    local sid = getElementData(client, "player:sid")
    if not sid then return end

    if work[client] then return end

    work[client] = true
    exports["prpg-notifications"]:newNotification("info", "Rozpoczynasz prace kierowcy ciężarówki.", client)

    exports["prpg-work-settings"]:showWorkingGui(client, true)
    exports["prpg-work-settings"]:setTitle(client, "Praca Kierowcy Ciężarówki")
    exports["prpg-work-settings"]:setMoney(client, 0)

    triggerClientEvent(client, "trucker->checkPlayerVehicle", resourceRoot, trucksList)

    exports["prpg-work-settings"]:setText(client, "Wjedź ciężarówką do żółtego punktu z walizką.")

end)

addEvent("trucker->stopWork", true)
addEventHandler("trucker->stopWork", resourceRoot, function()
    local sid = getElementData(client, "player:sid")
    if not sid then return end

    if not work[client] then return end
    work[client] = nil
    exports["prpg-work-settings"]:showWorkingGui(client, false)


    if actuallOrder[client] then
        actuallOrder[client] = nil
    end

    if playerTrailers[client] then
        destroyElement(playerTrailers[client])
        playerTrailers[client] = nil
    end

    triggerClientEvent(client, "trucker->destroyTrailersAndPolygons", resourceRoot)

end)

addEvent("trucker->isPlayerWorking", true)
addEventHandler("trucker->isPlayerWorking", resourceRoot, function()

    if work[client] then
        triggerClientEvent(client, "trucker->isPlayerWorking", resourceRoot, true)
    else
        triggerClientEvent(client, "trucker->isPlayerWorking", resourceRoot, false)
    end

end)

addEventHandler("onPlayerQuit", root, function()
    if work[source] then
        work[source] = nil
    end

    if actuallOrder[source] then
        actuallOrder[source] = nil
    end

    if playerTrailers[source] then
        destroyElement(playerTrailers[source])
        playerTrailers[source] = nil
    end
end)

addEventHandler("onVehicleExit", root, function(player)
    if work[player] then
        work[player] = nil
        exports["prpg-work-settings"]:showWorkingGui(player, false)
        exports["prpg-notifications"]:newNotification("info", "Praca zakończona.", player)
    end

    if actuallOrder[player] then
        actuallOrder[player] = nil
    end

    if playerTrailers[player] then
        destroyElement(playerTrailers[player])
        playerTrailers[player] = nil
    end

    triggerClientEvent(player, "trucker->destroyTrailersAndPolygons", resourceRoot)
end)