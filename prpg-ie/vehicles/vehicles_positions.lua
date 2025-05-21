positions = {
    {2730.29, -1777.76, 667.03, 0.0, 360.0, 307.3},
    {2729.45, -1767.85, 667.03, 0.0, 0.0, 268.8},
    {2729.06, -1759.14, 667.03, 0.0, 0.0, 227.8},
    {2739.76, -1760.62, 667.03, 0.0, 360.0, 135.1},
    {2738.93, -1769.40, 667.03, 0.0, 360.0, 68.1},
}

playerVehicles = {}

destroyVehiclesInGarage = function(player)

    if playerVehicles[player] then

        for i,v in ipairs(playerVehicles[player]) do
            if isElement(v) then destroyElement(v) end
        end

    end

    playerVehicles[player] = nil

end

createVehiclesInGarage = function(player, sid, vehicleList)

    if not player or not vehicleList then return end

    if playerVehicles[player] then

        for i,v in ipairs(playerVehicles[player]) do
            destroyElement(v)
        end

    end

    local listOfVehicles = {}

    for i,v in ipairs(vehicleList) do

        if positions[i] then
            local veh = createVehicle(v.model, positions[i][1], positions[i][2], positions[i][3], positions[i][4], positions[i][5], positions[i][6])
            setElementData(veh, "ie:vehicle:info", {
                model = v.model
            })
            addEventHandler("onVehicleStartEnter", veh, function() cancelEvent() end)
            setElementFrozen(veh, true)
            setElementDimension(veh, sid)
            table.insert(listOfVehicles, veh)
        end

    end

    playerVehicles[player] = listOfVehicles

end