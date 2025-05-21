local positions = {
    {-2513.95, 1200.95, 37.44}
}

for _, v in ipairs(positions) do
	local marker = createMarker(v[1], v[2], v[3]-0.6, "cylinder", 0.7, 33, 84, 255, 0)
    
	setElementData(marker, "marker:info", {
        image = ":prpg-streetview/images/street-view.png",
        text = "Praca Street-View",
        size = 1,
        offset = 120,
    })

	addEventHandler("onClientMarkerHit", marker, function(el, md)
	
		if el == localPlayer and md then
            if getPedOccupiedVehicle(el) then return end
            showGui(true)
        end

	end)

	addEventHandler("onClientMarkerLeave", marker, function(el, md)
	
		if el == localPlayer and md then
            showGui(false)
        end

	end)

end