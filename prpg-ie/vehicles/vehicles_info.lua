local fonts = {
    roboto = dxCreateFont("roboto.ttf", 12),
}

rt = {}

addEventHandler("onClientRestore", root, function()
    rt = {}
end)

addEventHandler("onClientPreRender", root, function()
    for k,v in pairs(rt) do
        if not isElement(k) then
            destroyElement(rt[k])
            rt[k] = nil
        end
    end

    local x, y, z = getElementPosition(localPlayer)
    local vehicles = getElementsWithinRange(x, y, z, 10, "vehicle")

    if #vehicles > 0 then
        renderCarsInfo(vehicles)
    end
end)

renderCarsInfo = function(table)

    for _, veh in ipairs(table) do
        if getElementData(veh, "ie:vehicle:info") then
            if isElementStreamedIn(veh) then
                if rt[veh] then
                    destroyElement(rt[veh])
                    rt[veh] = nil
                end
                createVehicleRenderTarget(veh)
                local _, _, _, _, by, bz = getElementBoundingBox(veh)
                local x, y, z = getPositionFromElementOffset(veh, 0, by/2, bz)
                local lx, ly, lz = getPositionFromElementOffset(veh, 0, 5, 0)
                dxDrawMaterialLine3D(x, y, z + 0.45, x, y, z-0.65, rt[veh], 1.5, white, false)--, lx, ly, lz)
            end
        end
    end

end

createVehicleRenderTarget = function(vehicle)
    rt[vehicle] = dxCreateRenderTarget(500, 300, true)
    local x, y, z = getElementPosition(vehicle)
    local prX,prY,prZ = getElementRotation(localPlayer)

    local data = getElementData(vehicle, "ie:vehicle:info")

    dxSetRenderTarget(rt[vehicle], true)

        dxDrawImage(50, 0, 400, 130, "/images/bg_info.png")
        dxDrawText("Infernus", 0, -40, 500, 130, tocolor(255, 255, 255, 255), 1, fonts.roboto, "center", "center")
        dxDrawText("Kwota: 12,561,333 #00bb00PLN", 0, 0, 500, 130, tocolor(255, 255, 255, 255), 1, fonts.roboto, "center", "center", _, _, _, true)
        dxDrawText("W garażu od: 26.05.2024 21:02", 0, 40, 500, 130, tocolor(255, 255, 255, 255), 1, fonts.roboto, "center", "center", _, _, _, true)
        -- dxDrawText("Silnik: " .. string.format("%.01f", data.engine / 100) .. " V" .. data.cylindres .. " " .. data.engineType, 0, -30, 500, 130, tocolor(255, 255, 255, 255), 1, fonts.roboto, "center", "center", _, _, _, true)
        -- dxDrawText("Cena: #00bb00" .. formatNumber(data.cost, ",") .. " PLN", 0, 0, 500, 130, tocolor(255, 255, 255, 255), 1, fonts.roboto, "center", "center", _, _, _, true)
        -- dxDrawText("Dostępne sztuki: " .. data.count, 0, 30, 500, 130, tocolor(255, 255, 255, 255), 1, fonts.roboto, "center", "center", _, _, _, true)
        -- dxDrawText("Podejdź do pojazdu, aby poznać więcej szczegółów.", 0, 90, 500, 130, tocolor(255, 255, 255, 255), 1, fonts.roboto, "center", "center", _, _, _, true)
        
    dxSetRenderTarget()
end