local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)


NUIEvents = {}

NUIEvents.UpdateHUD = function(addictions)

	if Config.ShameyDebug then print("NUIEvents.UpdateHUD", addictions) end

	if not addictions or tablelength(addictions) < 2 then return end

	local percentageAddiction = calculateAddictionPercentageFromObject(addictions)
	SendNUIMessage({
        addiction = percentageAddiction,
    })
end

NUIEvents.ShowHUD = function(show)
	-- if Config.ShameyDebug then print("NUIEvents.ShowHUD", show) end
    SendNUIMessage({
        showhud = show
    })
end

function calculateAddictionPercentageFromObject(addictions)
	-- if Config.ShameyDebug then print("calculateAddictionPercentageFromObject", addictions) end
	local addictionAmount = 0
	for k,v in pairs(addictions.withdrawals) do
		addictionAmount = addictionAmount + v
	end
	
	return addictionAmount
end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end