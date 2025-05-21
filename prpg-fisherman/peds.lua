cancelPedDamage = function()
    cancelEvent()
    setElementHealth(source, 1000)
end

peds = {
    [1] = {
        pos = {378.38, -1987.05, 7.84},
        rotation = 90,  
        skin = 1,
        type = "sell",
        name = "Kupiec Zbych"
    },
    [2] = {
        pos = {400.82, -2067.24, 10.75},
        rotation = -90,  
        skin = 3,
        type = "buy",
        name = "Sprzedawca",
    }
}

for index, p in ipairs(peds) do

    local ped = createPed(p.skin, p.pos[1], p.pos[2], p.pos[3], p.rotation)
    local marker = createMarker(p.pos[1], p.pos[2], p.pos[3], "cylinder", 1, 255, 255, 255, 0)
    setElementFrozen(ped, true)
    addEventHandler("onClientPedDamage", ped, cancelPedDamage)
    setElementData(ped, "ped:customName", p.name)

    addEventHandler("onClientMarkerHit", marker, function(el, md)
        if el ~= localPlayer or not md then return end
        if getPedOccupiedVehicle(el) then return end
        if p.type == "sell" then showSelling(true, index, p.name) return end
        if p.type == "buy" then showBuying(true, index) return end
    end)

    addEventHandler("onClientMarkerLeave", marker, function(el, md)
        if el ~= localPlayer or not md then return end
        if p.type == "sell" then showSelling(false) return end
        if p.type == "buy" then showBuying(false) return end
    end)

end