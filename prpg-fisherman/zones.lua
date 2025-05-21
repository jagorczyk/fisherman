zones = {
    {
        pos = {431.44, -2524.88, 300, 300},
        fishes = { -- name, percent
            ["Szczupak"] = {15, percentage = {
                {70, weight = {1, 3}, speed = {2, 4}},
                {25, weight = {3, 5}, speed = {2, 4}},
                {4, weight = {5, 10}, speed = {2, 4}},
                {1, weight = {10, 20}, speed = {2, 4}},
            }},
            ["Okon"] = {30, percentage = {
                {70, weight = {0.5,  1}, speed = {2, 4}},
                {25, weight = {1, 1.5}, speed = {2, 4}},
                {4, weight = {1.5, 2}, speed = {2, 4}},
                {1, weight = {2, 2.7}, speed = {2, 4}},
            }},
            ["Pstrag"] = {10, percentage = {
                {70, weight = {0.5, 3}, speed = {2, 4}},
                {25, weight = {3, 5.5}, speed = {2, 4}},
                {4, weight = {5.5, 8}, speed = {2, 4}},
                {1, weight = {8, 10}, speed = {2, 4}},
            }},
            ["Sandacz"] = {10, percentage = {
                {70, weight = {1, 4}, speed = {2, 4}},
                {25, weight = {4, 7}, speed = {2, 4}},
                {4, weight = {7, 10}, speed = {2, 4}},
                {1, weight = {10, 20}, speed = {2, 4}},
            }},
            ["Jesiotr"] = {5, percentage = {
                {70, weight = {1, 10}, speed = {3, 4}},
                {25, weight = {10, 50}, speed = {3, 4}},
                {4, weight = {50, 150}, speed = {3, 4}},
                {1, weight = {150, 600}, speed = {3, 4}},
            }},
            ["Karp"] = {30, percentage = {
                {70, weight = {2, 7.5}, speed = {3, 4}},
                {25, weight = {7.5, 12.5}, speed = {3, 4}},
                {4, weight = {12.5, 20}, speed = {3, 4}},
                {1, weight = {20, 37}, speed = {3, 4}},
            }},
            ["Wegorz"] = {10, percentage = {
                {70, weight = {0.5, 2}, speed = {2, 4}},
                {25, weight = {2, 3.5}, speed = {2, 4}},
                {4, weight = {3.5, 5}, speed = {2, 4}},
                {1, weight = {5, 7}, speed = {2, 4}},
            }, time = {21, 6}},
        },
        respawnPercentage = 20,
        water = dxCreateTexture("/images/water2.png", "argb", true, "clamp"),
        type = "water2",
        uniqueFishingRod = {name = "Szczur_morski", chance = {50, 100}} -- {1, 100} == 1/100
    },
    {
        pos = {-856.60, -1850.38, 400, 300},
        fishes = { -- name, percent, percentage
            ["Lin"] = {15, percentage = {
                {70, weight = {1, 2}, speed = {3, 4}},
                {25, weight = {2, 3}, speed = {3, 4}},
                {4, weight = {3, 4}, speed = {3, 4}},
                {1, weight = {4, 5}, speed = {3, 4}},
            }},
            ["Sum"] = {5, percentage = {
                {70, weight = {10, 30}, speed = {3, 4}},
                {25, weight = {30, 70}, speed = {3, 4}},
                {4, weight = {70, 100}, speed = {3, 4}},
                {1, weight = {100, 140}, speed = {3, 4}},
            }},
            ["Okon"] = {30, percentage = {
                {70, weight = {0.5,  1}, speed = {2, 4}},
                {25, weight = {1, 1.5}, speed = {2, 4}},
                {4, weight = {1.5, 2}, speed = {2, 4}},
                {1, weight = {2, 2.7}, speed = {2, 4}},
            }},
            ["Szczupak"] = {15, percentage = {
                {70, weight = {1, 3}, speed = {2, 4}},
                {25, weight = {3, 5}, speed = {2, 4}},
                {4, weight = {5, 10}, speed = {2, 4}},
                {1, weight = {10, 20}, speed = {2, 4}},
            }},
            ["Wegorz"] = {10, percentage = {
                {70, weight = {0.5, 2}, speed = {2, 4}},
                {25, weight = {2, 3.5}, speed = {2, 4}},
                {4, weight = {3.5, 5}, speed = {2, 4}},
                {1, weight = {5, 7}, speed = {2, 4}},
            }, time = {21, 6}},
        },
        respawnPercentage = 20,
        water = dxCreateTexture("/images/water3.png", "argb", true, "clamp"),
        type = "water3",
    },
    {
        pos = {118.67, -2413.77, 500, 500},
        respawnPercentage = 20,
        water = dxCreateTexture("/images/water3.png", "argb", true, "clamp"),
        type = "water3",
    },
}

local notZoneArea = {
    fishes = {
        ["Dorsz"] = {35, percentage = {
            {70, weight = {1, 5}, speed = {3, 4}},
            {25, weight = {5, 10}, speed = {3, 4}},
            {4, weight = {10, 15}, speed = {3, 4}},
            {1, weight = {15, 40}, speed = {3, 4}},
        }},
        ["Tunczyk"] = {5, percentage = {
            {70, weight = {50, 100}, speed = {3, 4}},
            {25, weight = {100, 250}, speed = {3, 4}},
            {4, weight = {250, 450}, speed = {3, 4}},
            {1, weight = {450, 650}, speed = {3, 4}},
        }},
        ["Rekin"] = {5, percentage = {
            {70, weight = {400, 600}, speed = {3, 4}},
            {25, weight = {600, 750}, speed = {3, 4}},
            {4, weight = {750, 900}, speed = {3, 4}},
            {1, weight = {900, 1100}, speed = {3, 4}},
        }},
        ["Miecznik"] = {10, percentage = {
            {70, weight = {100, 200}, speed = {3, 4}},
            {25, weight = {200, 300}, speed = {3, 4}},
            {4, weight = {300, 400}, speed = {3, 4}},
            {1, weight = {400, 500}, speed = {3, 4}},
        }},
        ["Makrela"] = {45, percentage = {
            {70, weight = {0.25, 0.5}, speed = {3, 4}},
            {25, weight = {0.5, 0.75}, speed = {3, 4}},
            {4, weight = {0.75, 1}, speed = {3, 4}},
            {1, weight = {1, 1.25}, speed = {3, 4}},
        }},
    },
    respawnPercentage = 20,
    water = dxCreateTexture("/images/water1.png", "argb", true, "clamp"),
}

for i, zone in ipairs(zones) do
    local z = createColRectangle(zone.pos[1], zone.pos[2] - zone.pos[4], zone.pos[3], zone.pos[4])
	createRadarArea(zone.pos[1], zone.pos[2] - zone.pos[4], zone.pos[3], zone.pos[4], 33, 84, 229, 140)
    setElementData(z, "zone:info", zone)
end

getPlayerZone = function()

    for i, v in ipairs(getElementsByType("colshape", resourceRoot)) do
        if isElementWithinColShape(localPlayer, v) then
            return getElementData(v, "zone:info")
        end
    end

    return notZoneArea

end

getTypeColor = function(t, alpha)

    if t == "water1" then
        return tocolor(33, 84, 229, alpha)
    elseif t == "water2" then
        return tocolor(0, 189, 16, alpha)
    elseif t == "water3" then
        return tocolor(150, 75, 0, alpha)
    end

end