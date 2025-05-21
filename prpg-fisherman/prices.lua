peds = {
    [1] = {
        fishes = {"Tunczyk", "Dorsz", "Okon", "Pstrag", "Wegorz", "Karp", "Miecznik", "Makrela", "Lin", "Sum", "Jesiotr", "Rekin", "Jesiotr"},
        prices = {},
    },
    [2] = {
        fishingRods = {
            {"Shimano", 100000},
            {"Mikado", 100000},
            {"Daiwa", 100000},
            {"Szczur_morski", 100000},
            {"Kapitan", 100000},
            {"Zaginiona", 100000},
            {"Majtek", 100000},
        }
    }
}

prices = {
    fishes = {
        ["Tunczyk"] = {0, 1000},
        ["Pstrag"] = {0, 1000},
        ["Wegorz"] = {0, 1000},
        ["Szczupak"] = {0, 1000},
        ["Dorsz"] = {0, 1000},
        ["Sum"] = {0, 1000},
        ["Sandacz"] = {0, 1000},
        ["Rekin"] = {0, 1000},
        ["Jesiotr"] = {0, 1000},
        ["Okon"] = {0, 1000},
        ["Lin"] = {0, 1000},
        ["Karp"] = {0, 1000},
        ["Miecznik"] = {0, 1000},
        ["Makrela"] = {0, 1000},
    }
}

fixCost = {
    ["Shimano"] = {
        standard = 100000,
        perLevel = 10000,
    },
    ["Mikado"] = {
        standard = 100000,
        perLevel = 10000,
    },
    ["Daiwa"] = {
        standard = 100000,
        perLevel = 10000,
    },
    ["Kapitan"] = {
        standard = 350000,
        perLevel = 50000,
    },
    ["Szczur_morski"] = {
        standard = 350000,
        perLevel = 50000,
    },
    ["Zaginiona"] = {
        standard = 150000,
        perLevel = 20000,
    },
    ["Majtek"] = {
        standard = 10000,
        perLevel = 1000,
    },
}

fishingRodsFishPerks = {
    ["Zaginiona"] = {
        list = {{"Dorsz", 3}, "Sandacz", "Szczupak", "Karp", "Makrela", "Okon", "Tunczyk", "Miecznik", "Jesiotr", "Rekin", "Wegorz", "Lin", "Sum", "Pstrag"},
        cost = {standard = 100000, perLevel = 10000},
    }
}

fishingRodUpgradeCost = {
    ["Zaginiona"] = {
       standard = 100000, 
       perLevel = 10000,
    }
}

------------------------------------------------------

createFishPrice = function(fish, priceA, priceB)
    if priceA and priceB then
        return math.random(priceA, priceB)
    end
    return math.random(prices.fishes[fish][1], prices.fishes[fish][2])
end

setFishPrices = function()
    for _, p in ipairs(peds) do
        if p.fishes then
            for _, f in ipairs(p.fishes) do
                local price = createFishPrice(f)
                p.prices[f] = price
            end
        end
    end
end
setFishPrices()
setTimer(setFishPrices, 60 * 1000, 0)

addEvent("fish->getFishPrices", true)
addEventHandler("fish->getFishPrices", resourceRoot, function(index)
    triggerClientEvent(client, "fish->getFishPrices", resourceRoot, peds[index].fishes, peds[index].prices)
end)

addEvent("fish->getFixCost", true)
addEventHandler("fish->getFixCost", resourceRoot, function(name, level, condition)
    triggerClientEvent(client, "fish->getFixCost", resourceRoot, math.floor((fixCost[name].standard) * (100 - condition) + ((level-1) * fixCost[name].perLevel)))
end)

addEvent("fish->getFishingRodPrices", true)
addEventHandler("fish->getFishingRodPrices", resourceRoot, function(index)
    triggerClientEvent(client, "fish->getFishingRodPrices", resourceRoot, peds[index].fishingRods)
end)

addEvent("fish->getRanking", true)
addEventHandler("fish->getRanking", resourceRoot, function()
    local sid = getElementData(client, "player:sid")
    if not sid then return end

    local result = exports["mysql"]:query("Select * from prpg_fishes_ranking where sid=? LIMIT 1;", sid)
    if result[1] then result = fromJSON(result[1].list) else result = {} end
    
    triggerClientEvent(client, "fish->getRanking", resourceRoot, result)
end)

addEvent("fish->sellFish", true)
addEventHandler("fish->sellFish", root, function(index, slot)
    local info = exports["prpg-equipment"]:getSlotInfo(client, slot)
    if not info then return end
    if exports["prpg-equipment"]:removeItem(client, slot) then
        local money = math.floor(info.weight * peds[index].prices[info.name])
        exports["prpg-notifications"]:newNotification("success", "Sprzedano " .. info.name .. " za " .. money .. " PLN.", client)
        givePlayerMoney(client, money)
    end
end)

addEvent("fish->buyFishingRod", true)
addEventHandler("fish->buyFishingRod", resourceRoot, function(pedIndex, index)
    if not pedIndex or not index then return end
    local info = peds[pedIndex].fishingRods[index]
    if getPlayerMoney(client) < info[2] then return exports["prpg-notifications"]:newNotification("error", "Nie posiadasz tyle gotówki przy sobie") end
    if exports["prpg-equipment"]:addItem(client, {name = info[1], condition = 100}) then
        takePlayerMoney(client, info[2])
        exports["prpg-notifications"]:newNotification("success", "Pomyślnie zakupiono wędke " .. info[1] .. ".", client)
    else
        exports["prpg-notifications"]:newNotification("error", "Nie masz miejsca w ekwipunku.", client)
    end
end)

addEvent("fish->fixFishingRod", true)
addEventHandler("fish->fixFishingRod", resourceRoot, function(slot)
    local sid = getElementData(client, "player:sid")
    if not sid then return end
    
    local info = exports["prpg-equipment"]:getSlotInfo(client, slot)
    if not info then return end

    if not info.used then return end

    local name = info.name
    local level = info.level or 1
    local condition = info.condition or 100

    local cost = math.floor((fixCost[name].standard) * (100 - condition) + ((level-1) * fixCost[name].perLevel))

    if cost > getPlayerMoney(client) then return exports["prpg-notifications"]:newNotification("error", "Nie posiadasz tyle gotówki przy sobie.", client) end

    takePlayerMoney(client, cost)
    exports["prpg-equipment"]:updateItemValue(client, slot, "condition", 100)
    exports["prpg-notifications"]:newNotification("success", "Pomyślnie naprawiono wędke.", client)

end)

addEvent("fish->getFishingRodPerksCost", true)
addEventHandler("fish->getFishingRodPerksCost", resourceRoot, function(info)
    if not info then return end

    local level = (info.level or 1) - 1

    local cost1 = (fishingRodsFishPerks[info.name].cost.standard or 0) + (fishingRodsFishPerks[info.name].cost.perLevel or 0) * level
    local cost2 = (fishingRodUpgradeCost[info.name].standard or 0) + (fishingRodUpgradeCost[info.name].perLevel or 0) * level

    triggerClientEvent(client, "fish->getFishingRodPerksCost", resourceRoot, cost1, cost2)
end)

addEvent("fish->setUpgrades", true)
addEventHandler("fish->setUpgrades", resourceRoot, function(slot)
    local sid = getElementData(client, "player:sid")
    if not sid then return end
    
    local info = exports["prpg-equipment"]:getSlotInfo(client, slot)
    if not info then return end

    if not info.used then return end

    local cost = (fishingRodsFishPerks[info.name].cost.standard or 0) + (fishingRodsFishPerks[info.name].cost.perLevel or 0) * ((info.level or 1)-1)
    if cost > getPlayerMoney(client) then return exports["prpg-notifications"]:newNotification("error", "Nie posiadasz tyle gotówki przy sobie.", client) end

    takePlayerMoney(client, cost)

    local level = (info.level or 1)

    if level == 1 then return exports["prpg-notifications"]:newNotification("error", "Aby dodać perki do wędki, jej level musi być większy od 1.", client) end 

    local upgrades = {}
    local fishes = fishingRodsFishPerks[info.name].list or {} --{"Dorsz", "Sandacz", "Szczupak", "Karp", "Makrela", "Okon", "Tunczyk", "Miecznik", "Jesiotr", "Rekin", "Wegorz", "Lin", "Sum", "Pstrag"}

    for i=1, level - 1 do
        local fishUpgrade = fishes[math.random(#fishes)]
        if type(fishUpgrade) == "table" then
            local upgrade = math.random(1, fishUpgrade[2] > level and level or fishUpgrade[2])
            upgrades[fishUpgrade[1]] = upgrade
        else
            local upgrade = math.random(1, level)
            upgrades[fishUpgrade] = upgrade
        end
    end
    
    exports["prpg-equipment"]:updateItemValue(client, slot, "perks", upgrades)
    triggerClientEvent(client, "fish->setFishingRodInfo", resourceRoot)

    exports["prpg-notifications"]:newNotification("success", "Wylosowano nowe boosty.", client)
end)

addEvent("fish->upgradeLevel", true)
addEventHandler("fish->upgradeLevel", resourceRoot, function(slot)
    local sid = getElementData(client, "player:sid")
    if not sid then return end
    
    local info = exports["prpg-equipment"]:getSlotInfo(client, slot)
    if not info then return end

    if not info.used then return end

    local level = (info.level or 1)

    local cost = (fishingRodUpgradeCost[info.name].standard or 0) + (fishingRodUpgradeCost[info.name].perLevel or 0) * level

    if cost > getPlayerMoney(client) then return exports["prpg-notifications"]:newNotification("error", "Nie posiadasz tyle gotówki przy sobie.", client) end

    if level >= 9 then return exports["prpg-notifications"]:newNotification("error", "Osiągnięto największy lvl wędki (9).", client) end

    exports["prpg-equipment"]:updateItemValue(client, slot, "level", level + 1)
    triggerClientEvent(client, "fish->setFishingRodInfo", resourceRoot)

    exports["prpg-notifications"]:newNotification("success", "Pomyślnie ulepszono wędke.", client)
    takePlayerMoney(client, cost)

end)