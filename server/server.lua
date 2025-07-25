local VorpCore = {}
CreateThread(function()
    TriggerEvent("getCore", function(core)
        VorpCore = core;
    end)
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)

VorpInv = exports.vorp_inventory:vorp_inventoryApi()

local characters = {}


local dbQuery = function(query, params)
    local query_promise = promise.new()

    params = params or {}

    local on_result = function(result)
        query_promise:resolve(result)
    end

    MySQL.query(query, params, on_result)

    return Citizen.Await(query_promise)
end


-------- THREADS




-------- EVENTS

RegisterNetEvent("rainbow_addiction:TickWithdrawalsIncrement", function()
    local _source = source
    local UserCharacter = VorpCore.getUser(_source).getUsedCharacter
    local CharacterStatuses = characters[UserCharacter.identifier]

    if Config.ShameyDebug then print("rainbow_addiction:TickWithdrawalsIncrement") end

    local addictions = CharacterStatuses.addictions
    for k,v in pairs(addictions.dependencies) do
        local viceWithdrawals = addictions.withdrawals[k]
        if tonumber(v) >= tonumber(Config.Vices[k].dependencyThreshold) then

            local newWithdrawal = tonumber(viceWithdrawals) + tonumber(Config.Vices[k].withdrawalIncrement)
            if newWithdrawal > 100 then
                newWithdrawal = 100
            end
            addictions.withdrawals[k] = newWithdrawal

            updateAddictions(UserCharacter.identifier, addictions)

            TriggerClientEvent("rainbow_addiction:UpdateCharacterStatuses", _source, characters[UserCharacter.identifier])
        end
    end
end)

RegisterNetEvent("rainbow_addiction:TickWithdrawalsHealthHit", function()
    local _source = source
    local UserCharacter = VorpCore.getUser(_source).getUsedCharacter
    local CharacterStatuses = characters[UserCharacter.identifier]

    if Config.ShameyDebug then print("rainbow_addiction:TickWithdrawalsHealthHit") end

    local hasHighAddiction = false
    local addictions = CharacterStatuses.addictions
    for k,v in pairs(addictions.dependencies) do
        local viceWithdrawals = addictions.withdrawals[k]
        if tonumber(viceWithdrawals) >= tonumber(Config.WithdrawalHealthHitThreshold) then

            TriggerClientEvent("rainbow_addiction:ReduceHealthOuter", _source, Config.WithdrawalHealthHitAmountOuter)
            TriggerClientEvent("rainbow_addiction:ReduceHealthInner", _source, Config.WithdrawalHealthHitAmountInner)

            -- TODO: Screen effect (MP_HealthDrop) and sound
            TriggerClientEvent("vorp:Tip", _source, "You can feel your withdrawals affecting your health.", 6 * 1000)

            -- updateAddictions(UserCharacter.identifier, addictions)

            -- TriggerClientEvent("rainbow_addiction:UpdateCharacterStatuses", _source, characters[UserCharacter.identifier])
        end
    end
end)

RegisterNetEvent("rainbow_addiction:TickDependencyDecrement", function()
    local _source = source
    local UserCharacter = VorpCore.getUser(_source).getUsedCharacter
    local CharacterStatuses = characters[UserCharacter.identifier]

    if Config.ShameyDebug then print("rainbow_addiction:TickDependencyDecrement") end

    local addictions = CharacterStatuses.addictions
    for k,v in pairs(addictions.dependencies) do
        if tonumber(v) > 0 then

            local newDependency = tonumber(v) - tonumber(Config.DependencyDecrementAmount)
            if newDependency < 0 then
                newDependency = 0
            end
            addictions.dependencies[k] = newDependency

            updateAddictions(UserCharacter.identifier, addictions)

            TriggerClientEvent("rainbow_addiction:UpdateCharacterStatuses", _source, characters[UserCharacter.identifier])
        end
    end
end)


-- Catch item uses
RegisterNetEvent("vorpmetabolism:ItemUsed", function(itemName)
    local _source = source
    local UserCharacter = VorpCore.getUser(_source).getUsedCharacter
    local CharacterStatuses = characters[UserCharacter.identifier]
    
    if Config.ShameyDebug then print("vorpmetabolism:ItemUsed", itemName) end

    local isItemNameAVice = isItemNameAVice(itemName)
    if isItemNameAVice ~= false then
        local vice = isItemNameAVice
        -- if Config.ShameyDebug then print("vorpmetabolism:ItemUsed - vice:", vice) end

        local addictions = CharacterStatuses.addictions

        -- Increase the dependency on this vice
        if addictions.dependencies[vice.id] then
            if addictions.dependencies[vice.id] >= 0 and addictions.dependencies[vice.id] < 10 then
                addictions.dependencies[vice.id] = addictions.dependencies[vice.id] + 1
            end
        else
            addictions.dependencies[vice.id] = 1
        end

        -- Decrease the withdrawals on this vice
        if addictions.withdrawals[vice.id] then
            if addictions.withdrawals[vice.id] > 0 then
                addictions.withdrawals[vice.id] = 0
            end
        else
            addictions.withdrawals[vice.id] = 0
        end

        -- Update
        updateAddictions(UserCharacter.identifier, addictions)

        TriggerClientEvent("rainbow_addiction:UpdateCharacterStatuses", _source, characters[UserCharacter.identifier])
    end
end)


RegisterNetEvent("rainbow_addiction:SaveLastStatus", function()
    local _source = source
    local UserCharacter = VorpCore.getUser(_source).getUsedCharacter
    local CharacterStatuses = characters[UserCharacter.identifier]

    -- if Config.ShameyDebug then print("rainbow_addiction:SaveLastStatus", _source, characters[UserCharacter.identifier]) end
    if Config.ShameyDebug then print("rainbow_addiction:SaveLastStatus", _source) end

    if CharacterStatuses then
        CharacterStatuses.SaveCharacterStatusesInDb()
    end
    
end)

RegisterNetEvent("rainbow_addiction:GetStatus", function()
    local _source = source
    local UserCharacter = VorpCore.getUser(_source).getUsedCharacter

    if Config.ShameyDebug then print("rainbow_addiction:GetStatus", _source) end

    loadCharacterStatus(_source)

    local CharacterStatuses = characters[UserCharacter.identifier]

    TriggerClientEvent("rainbow_addiction:StartFunctions", _source, CharacterStatuses)
end)


-------- FUNCTIONS

function loadCharacterStatus(_source)

    if Config.ShameyDebug then print("loadCharacterStatus()", _source) end

    local UserCharacter = VorpCore.getUser(_source).getUsedCharacter

    -- local query = "SELECT * FROM character_statuses WHERE identifier = @identifier AND charidentifier = @charidentifier;"
    -- local params = { ['@identifier'] = UserCharacter.identifier, ['@charidentifier'] = UserCharacter.charidentifier }
    -- local result = dbQuery(query, params)

    local result_promise = promise.new()
    MySQL.single("SELECT * FROM character_statuses WHERE `identifier` = @identifier AND charidentifier = @charidentifier", 
        { ['@identifier'] = UserCharacter.identifier, ['@charidentifier'] = UserCharacter.charIdentifier }, 
        function(result)
            if result then
                characters[UserCharacter.identifier] = CharacterStatuses(_source, UserCharacter.identifier, UserCharacter.charIdentifier, json.decode(result.addictions))
            else
                characters[UserCharacter.identifier] = CharacterStatuses(_source, UserCharacter.identifier, UserCharacter.charIdentifier, {["dependencies"] = {}, ["withdrawals"] = {}})
                characters[UserCharacter.identifier].SaveNewCharacterStatusesInDb(function() end)
            end
            if Config.ShameyDebug then print("loadCharacterStatus() - CharacterStatuses", characters[UserCharacter.identifier]) end
            result_promise:resolve()
    end)
    return Citizen.Await(result_promise)
end

function isItemNameAVice(itemName)
    for k,v in pairs(Config.Vices) do
        for k2,v2 in pairs(v.itemNames) do
            -- print(itemName, v2)
            if v2 == itemName then
                return v
            end
        end
    end
    return false
end

function updateAddictions(identifier, addictions)
    -- if Config.ShameyDebug then print("updateAddictions", identifier, addictions) end
    characters[identifier].Addictions(addictions)
end

