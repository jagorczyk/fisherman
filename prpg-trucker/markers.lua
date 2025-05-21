local workMarkers = {
    {1049.85, 1275.77, 10.92},
}

local jobMarkers = {
    {1044.06, 1288.53, 10.92},
    {1064.25, 1296.15, 10.82},
}

for i, v in ipairs(workMarkers) do
    local sphere = createColSphere(v[1], v[2], v[3], 1)
	local marker = createMarker(v[1], v[2], v[3]-0.6, "cylinder", 0.7, 33, 84, 255, 0)
    
	setElementData(marker, "marker:info", {
        image = ":prpg-trucker/images/truck.png",
        text = "Praca Truckera",
        size = 1,
        offset = 120,
    })

    addEventHandler("onColShapeHit", sphere, function(el, md)
        if getElementType(el) ~= "player" then return end
        if not md then return end

        local veh = getPedOccupiedVehicle(el)
        if veh then return end

        local sid = getElementData(el, "player:sid")
        if not sid then return end

        triggerClientEvent(el, "trucker->showGui", resourceRoot, true)

    end)
    
    addEventHandler("onColShapeLeave", sphere, function(el, md)
        if getElementType(el) ~= "player" then return end
        if not md then return end
    
        triggerClientEvent(el, "trucker->showGui", resourceRoot, false)
    end)
end

for i, v in ipairs(jobMarkers) do
    local sphere = createColSphere(v[1], v[2], v[3], 2)
	local marker = createMarker(v[1], v[2], v[3]-0.6, "cylinder", 2, 255, 255, 0, 0)
    
	setElementData(marker, "marker:info", {
        markerAddonImage = {
            texture = ":prpg-trucker/images/suitcase.png",
            rotation = 180,
        },
    })

    addEventHandler("onColShapeHit", sphere, function(el, md)
        if getElementType(el) ~= "player" then return end
        if not md then return end

        local veh = getPedOccupiedVehicle(el)
        if not veh then return end

        local sid = getElementData(el, "player:sid")
        if not sid then return end

        if not work[el] then return end
        if actuallOrder[el] then return end

        triggerClientEvent(el, "trucker->showOrderGui", resourceRoot, true)

    end)
    
    addEventHandler("onColShapeLeave", sphere, function(el, md)
        if getElementType(el) ~= "player" then return end
        if not md then return end
    
        triggerClientEvent(el, "trucker->showOrderGui", resourceRoot, false)
    end)

end