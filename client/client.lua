local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)


local loaded = false

-- {"dependencies":{"alcohols":10},"withdrawals":{"alcohols":20}}
CharacterStatuses = {}


-----------

if Config.ShameyDebug then 

	RegisterCommand("startaddiction", function(source, args)
		TriggerServerEvent("rainbow_addiction:GetStatus")
	end)

	-- RegisterCommand("setaddiction", function(source, args)
	-- 	TriggerEvent("rainbow_addiction:UpdateAddiction", tonumber(args[1]))
	-- end)

end


-------- THREADS

function StartAddictionUpdaterThread()
	-- Withdrawals Increments
    CreateThread(function()
        while true do
            if (not loaded) then return end

			Wait(Config.WithdrawalIncrementIntervalInSeconds * 1000)
			
			TriggerServerEvent("rainbow_addiction:TickWithdrawalsIncrement")
        end
    end)

	-- Withdrawals Health Hits
	CreateThread(function()
        while true do
            if (not loaded) then return end

			Wait(Config.WithdrawalHealthHitIntervalInSeconds * 1000)
			
			TriggerServerEvent("rainbow_addiction:TickWithdrawalsHealthHit")
        end
    end)

	-- Dependency Decrements
	CreateThread(function()
        while true do
            if (not loaded) then return end

			Wait(Config.DependencyDecrementIntervalInSeconds * 1000)
			
			TriggerServerEvent("rainbow_addiction:TickDependencyDecrement")
        end
    end)
end

function StartAddictionSaveDBThread()
    CreateThread(function()
        while true do
            if (not loaded) then return end

            Wait(Config.DbUpdateIntervalInSeconds * 1000)

            TriggerServerEvent("rainbow_addiction:SaveLastStatus")
        end
    end)
end

function StartRadarControlHudThread()
    CreateThread(function()
        while true do
            if (not loaded) then return end
            Wait(1000)
            if ((IsRadarHidden()) or (IsPauseMenuActive()) or (NetworkIsInSpectatorMode()) or (IsHudHidden())) then
                NUIEvents.ShowHUD(false)
            else
                NUIEvents.ShowHUD(true)
            end
        end
    end)
end


-------- EVENTS

RegisterNetEvent("rainbow_addiction:ReduceHealthInner", function(amount)

	if Config.PrintDebug then print("rainbow_addiction:ReduceHealthInner", amount) end

	local health = GetAttributeCoreValue(PlayerPedId(), 0)
    local newhealth = health - amount

    if (newhealth < 0) then
        newhealth = 0
    end

    Citizen.InvokeNative(0xC6258F41D86676E0, PlayerPedId(), 0, newhealth) -- SetAttributeCoreValue native
end)

RegisterNetEvent("rainbow_addiction:ReduceHealthOuter", function(amount)

	if Config.PrintDebug then print("rainbow_addiction:ReduceHealthOuter", amount) end

	local health = GetEntityHealth(PlayerPedId(), 0)
	local newhealth = health - amount

	if (newhealth < 0) then
		newhealth = 0
	end
	SetEntityHealth(PlayerPedId(), newhealth, 0)
end)

RegisterNetEvent("vorp:SelectedCharacter", function(charId)
    TriggerServerEvent("rainbow_addiction:GetStatus")
end)

RegisterNetEvent("rainbow_addiction:StartFunctions", function(_CharacterStatuses)

	if Config.PrintDebug then print("rainbow_addiction:StartFunctions", _CharacterStatuses) end

	CharacterStatuses = _CharacterStatuses

	-- NUIEvents.UpdateHUD(CharacterStatuses.addictions)

	StartAddictionUpdaterThread()
	StartAddictionSaveDBThread()
	StartRadarControlHudThread()
	-- TriggerEvent("rainbow_addiction:StartAddictionThreads")

    loaded = true
end)

RegisterNetEvent("rainbow_addiction:UpdateCharacterStatuses", function(_CharacterStatuses)

	-- if Config.PrintDebug then print("rainbow_addiction:UpdateCharacterStatuses", _CharacterStatuses) end

	CharacterStatuses = _CharacterStatuses

	local addictions = CharacterStatuses.addictions
	NUIEvents.UpdateHUD(addictions)
end)

-------- FUNCTIONS

function updateAddiction(dependencies, withdrawals)
	CharacterDependencies = dependencies
	CharacterWithdrawals = withdrawals
end

