local upgrades = {
    {
        title = "Szybsze auto",
        text = "Ulepszenie zmienia handling pojazdu na lepszy.",
        cost = 300,
        texture = "/images/fastcar.png",
    },
    {
        title = "Większy zarobek",
        text = "Dodatkowe 5% do zarobków.",
        cost = 2000,
        texture = "/images/money.png",
    },
}

findUpgradeInTable = function(upgradeToFind, listOfUpgrades)
    for _, u in ipairs(listOfUpgrades) do
        if u == upgradeToFind then
            return true
        end
    end
    return false
end

addEvent("trucker->getWorkUpgrades", true)
addEventHandler("trucker->getWorkUpgrades", resourceRoot, function()
    triggerClientEvent(client, "trucker->getWorkUpgrades", resourceRoot, upgrades)
end)

addEvent("trucker->getMyWorkInfo", true)
addEventHandler("trucker->getMyWorkInfo", resourceRoot, function()
    local sid = getElementData(client, "player:sid")
    if not sid then return end

    local result = exports["mysql"]:query("Select * from prpg_trucker_upgrades where sid=? LIMIT 1;", sid)
    if not result[1] then return end

    triggerClientEvent(client, "trucker->getMyWorkInfo", resourceRoot, fromJSON(result[1].upgrades), result[1].ppoints)

    for i,v in ipairs(fromJSON(result[1].upgrades)) do
        if v == "Usuwanie zleceń" then
            triggerClientEvent(client, "trucker->canRemoveOrders", resourceRoot, true)
        end
    end
end)

addEvent("trucker->buyWorkUpgrade", true)
addEventHandler("trucker->buyWorkUpgrade", resourceRoot, function(index)
    if not index then return end

    local sid = getElementData(client, "player:sid")
    if not sid then return end

    local result = exports["mysql"]:query("Select * from prpg_trucker_upgrades where sid=? LIMIT 1;", sid)
    local upgradeToBuy = upgrades[index]

    if result[1] then
        local myUpgrades = fromJSON(result[1].upgrades)
        if findUpgradeInTable(upgradeToBuy.title, myUpgrades) then return end --exports["prpg-notifications"]:newNotification("error", "Te ulepszenie jest już aktywowane.", client) end
        if result[1].ppoints < upgradeToBuy.cost then return exports["prpg-notifications"]:newNotification("error", "Nie stać Cie na te ulepszenie.", client) end
        
        table.insert(myUpgrades, upgradeToBuy.title)
        local exec = exports["mysql"]:exec("Update prpg_trucker_upgrades set upgrades = ?, ppoints = ppoints - ? where sid = ? LIMIT 1;", toJSON(myUpgrades), upgradeToBuy.cost, sid)
        if exec then
            exports["prpg-notifications"]:newNotification("success", "Pomyślnie aktywowano ulepszenie " .. upgradeToBuy.title .. ".", client)
            triggerClientEvent(client, "trucker->getMyWorkInfo", resourceRoot, myUpgrades, result[1].ppoints - upgradeToBuy.cost)
        end
    else
        return exports["prpg-notifications"]:newNotification("error", "Nie stać Cie na te ulepszenie.", client)
    end

end)

addEvent("trucker->getWorkRanking", true)
addEventHandler("trucker->getWorkRanking", resourceRoot, function()
    local sid = getElementData(client, "player:sid")
    if not sid then return end

    local result = exports["mysql"]:query("Select X.login, X.id, Y.ppoints from prpg_users X, prpg_trucker_upgrades Y where X.id = Y.sid order by ppoints desc LIMIT 3;");
    triggerClientEvent(client, "trucker->getWorkRanking", resourceRoot, result)
end)