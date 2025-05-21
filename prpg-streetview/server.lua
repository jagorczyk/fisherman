local blip = createBlip(-2505.87, 1204.19, 37.44, 46, 2, 0, 0, 0, 0, 0, 275)

local respawnPosition = {-2501.66, 1205.78, 37.54, 360.0, 0.0, 0.2}
local workList = {}
local markers = {}
local blips = {}

local additionalMoneyPercent = {}

stopWorking = function(player, vehicle)
    
    if workList[player] then
        workList[player] = nil
    end

    if isElement(vehicle) then
        destroyElement(vehicle)
    end

    if isElement(markers[player]) then
        destroyElement(markers[player])
    end

    if isElement(blips[player]) then
        destroyElement(blips[player])
    end

    if isElement(player) then
        exports["prpg-notifications"]:newNotification("info", "Zakończono prace street-view.", player)
        exports["prpg-work-settings"]:showWorkingGui(player, false)
    end

end

addPlayerPoint = function(client)
    if not client or not isElement(client) then return end
    
    local sid = getElementData(client, "player:sid")
    if not sid then return end

    local result = exports["mysql"]:query("Select * from prpg_streetview_upgrades where sid=? LIMIT 1;", sid)
    if result[1] then
        exports["mysql"]:exec("Update prpg_streetview_upgrades set ppoints=ppoints+1 where sid=? limit 1;", sid)
    else
        exports["mysql"]:exec("Insert into prpg_streetview_upgrades (sid, ppoints) VALUES (?, 1)", sid)
    end
end

createPath = function(player, path, next_id, actuallMarker, actuallBlip, vehicle)
    if isElement(actuallMarker) then
        destroyElement(actuallMarker)
    end

    if isElement(actuallBlip) then
        destroyElement(actuallBlip)
    end

    local p = paths[path]
    if not p then return end

    if next_id <= #p then
        markers[player] = createMarker(p[next_id][1], p[next_id][2], p[next_id][3], "checkpoint", 2, 33, 84, 229, 255, player)
        blips[player] = createBlipAttachedTo(markers[player], 41, 1, 255, 255, 255, 255, 0, 250, player)
        
        local marker = markers[player]
        local blip = blips[player]

        if p[next_id + 1] then setMarkerTarget(marker, p[next_id + 1][1], p[next_id + 1][2], p[next_id + 1][3]) else setMarkerIcon(marker, "finish") end

        addEventHandler("onMarkerHit", marker, function(el, md)
            if getElementType(el) == "vehicle" and md then
                if getVehicleController(el) ~= player then return end
                createPath(player, path, next_id + 1, marker, blip, vehicle)
                if workList[player] then
                    workList[player] = workList[player] + (math.random(80, 280))
                    exports["prpg-work-settings"]:setMoney(player, workList[player])
                end
            end
        end)
    else
        local additionalPercent = additionalMoneyPercent[player] or 0
        local text = additionalPercent > 0 and "(+" .. additionalPercent .. "%)" or ""
        local money = math.floor(workList[player] + (additionalPercent/100) * workList[player])
        givePlayerMoney(player, money)
        addPlayerPoint(player)
        exports["prpg-notifications"]:newNotification("success", "Otrzymujesz zarobione " .. money .. " PLN. " .. text, player)
        stopWorking(player, vehicle)
    end

end

addUpgradesToVehicle = function(upgrades, vehicle)
    for _, u in ipairs(upgrades) do
        if u == "Szybsze auto" then
            setVehicleHandling(vehicle, "maxVelocity", 200)
            setVehicleHandling(vehicle, "engineAcceleration", 12)
        end
    end
end

addUpgradesToPlayer = function(upgrades, player)
    for _, u in ipairs(upgrades) do
        if u == "Większy zarobek" then
            additionalMoneyPercent[player] = 5
        end
    end
end

addEvent("streetview->startWork", true)
addEventHandler("streetview->startWork", resourceRoot, function()
    local sid = getElementData(client, "player:sid")
    if not sid then return end

    if getElementData(client, "player:srp") < 150 then return exports["prpg-notifications"]:newNotification("error", "Nie spełniasz określonych wymagań.", client) end
    if getElementData(client, "player:srp") < 150 then return exports["prpg-notifications"]:newNotification("error", "Nie spełniasz określonych wymagań.", client) end
    if workList[client] then return end

    local vehicle = createVehicle(getVehicleModelFromName("Landstalker"), unpack(respawnPosition))
    warpPedIntoVehicle(client, vehicle)

    workList[client] = 0
    additionalMoneyPercent[client] = 0
    exports["prpg-notifications"]:newNotification("info", "Rozpoczęto prace street-view.", client)
    createPath(client, math.random(#paths), 1, nil, nil, vehicle)

    local upgrades = exports["mysql"]:query("Select * from prpg_streetview_upgrades where sid=? LIMIT 1;", sid)
    if upgrades[1] then
        upgrades = fromJSON(upgrades[1].upgrades)
        addUpgradesToVehicle(upgrades, vehicle)
        addUpgradesToPlayer(upgrades, client)
    end

    exports["prpg-work-settings"]:showWorkingGui(client, true)
    exports["prpg-work-settings"]:setTitle(client, "Praca Street-view")
    exports["prpg-work-settings"]:setText(client, "Jeździj po punktach w celu zarobienia pieniędzy.")
end)

addEventHandler("onVehicleExit", resourceRoot, function(ped)
    stopWorking(ped, source)
end)

addEventHandler("onPlayerQuit", root, function()
    local veh = getPedOccupiedVehicle(source)
    stopWorking(source, veh)
end)