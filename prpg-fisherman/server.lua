addEvent("fish->addItem", true)
addEventHandler("fish->addItem", resourceRoot, function(tab, uniqueFishingRod)
    local added = exports["prpg-equipment"]:addItem(client, tab)
    if not added then
        exports["prpg-notifications"]:newNotification("error", "Nie masz miejsca w ekwipunku.", client)
    end
    if uniqueFishingRod then

        local drawAdding = function(p1, p2)
            local choices = {}
            
            for i=1, p1 do
                table.insert(choices, true)
            end
        
            for i=1, p2 - p1 do
                table.insert(choices, false)
            end
        
            local randomTable = function(tab)
                local newTable = {}
                for i=1, #tab do
                    local index = math.random(#tab)
                    table.insert(newTable, tab[index])
                    table.remove(tab, index)
                end
                return newTable
            end

            choices = randomTable(choices)
        
            return choices[math.random(#choices)]
        
        end

        if drawAdding(uniqueFishingRod.chance[1], uniqueFishingRod.chance[2]) then
            local added = exports["prpg-equipment"]:addItem(client, {name = uniqueFishingRod.name, condition = 100})
            if added then
                exports["prpg-notifications"]:newNotification("success", "Udało Ci się znaleźć unikatową wędkę w wodzie! Znajduje się ona w twoim ekwipunku.", client)
            else
                exports["prpg-notifications"]:newNotification("error", "Niestety nie masz miejsca w ekwipunku. Szansa na unikatową wędkę przepadla.", client)
            end
        end

    end
end)

addEvent("fish->setCondition", true)
addEventHandler("fish->setCondition", resourceRoot, function(slot, value)
    
    local sid = getElementData(client, "player:sid")
    if not sid then return end
    
    local info = exports["prpg-equipment"]:getSlotInfo(client, slot)
    if not info then return end

    exports["prpg-equipment"]:updateItemValue(client, slot, "condition", value)

end)

addEvent("fish->setFishList", true)
addEventHandler("fish->setFishList", resourceRoot, function(slot, fish, weight)
    local sid = getElementData(client, "player:sid")
    if not sid then return end
    
    local info = exports["prpg-equipment"]:getSlotInfo(client, slot)
    if not info then return end

    local result = exports["mysql"]:query("Select * from prpg_fishes_ranking where sid=? LIMIT 1;", sid)
    local fishList = {}

    if result[1] then fishList = fromJSON(result[1].list) end

    local weight = tonumber(weight)

    if not fishList[fish] then
        fishList[fish] = {count = 1, maxWeight = weight}
    else
        local count = tonumber(fishList[fish].count or 0)
        local fishWeight = tonumber(fishList[fish].maxWeight or 0)

        fishList[fish].count = fishList[fish].count + 1

        if weight > fishWeight then
            fishList[fish].maxWeight = weight
        end
    end

    local fishingRodMaxWeight = info.maxWeight or 0

    if result[1] then
        exports["mysql"]:exec("Update prpg_fishes_ranking set list=? where sid=? LIMIT 1;", toJSON(fishList), sid)
    else
        exports["mysql"]:exec("Insert into prpg_fishes_ranking (list sid) VALUES (?, ?)", toJSON(fishList), sid)
    end

    if weight > fishingRodMaxWeight then
        exports["prpg-equipment"]:updateItemValue(client, slot, "maxWeight", tonumber(string.format("%0.2f", weight)))
    end

end)

addEvent("fish->animation", true)
addEventHandler("fish->animation", resourceRoot, function(state)

    if state then
        setPedAnimation(client, "SWORD", "sword_block", -1, false, false, true, true)
    else
        setPedAnimation(client)
    end

end)