--Class for characters statuses
function CharacterStatuses(source, identifier, charIdentifier, addictions)
    local self = {}

    self.identifier = identifier
    self.charIdentifier = charIdentifier
    self.addictions = addictions
    self.source = source

    
    self.Identifier = function()
        return self.identifier
    end

    self.CharIdentifier = function(value)
        if value ~= nil then
            self.charIdentifier = value
        end
        return self.charIdentifier
    end

    self.Addictions = function(value)
        if value ~= nil then self.addictions = value end
        return self.addictions
    end

    self.Source = function(value)
        if value ~= nil then
            self.source = value
        end
        return self.source
    end

    self.SaveNewCharacterStatusesInDb = function(cb)
        if Config.ShameyDebug then print("self.SaveNewCharacterStatusesInDb") end
        MySQL.query("INSERT INTO character_statuses(`identifier`,`charidentifier`,`addictions`) VALUES (?,?,?)"
            ,
            { self.identifier, self.charIdentifier, json.encode(self.addictions) },
            function(character)
                cb(character.insertId)
            end)
    end

    self.SaveCharacterStatusesInDb = function()
        if Config.ShameyDebug then print("self.SaveCharacterStatusesInDb") end
        MySQL.update("UPDATE character_statuses SET `addictions` = @addictions WHERE `identifier` = @identifier AND `charidentifier` = @charidentifier"
            ,
            { ["addictions"] = json.encode(self.addictions), ["identifier"] = tostring(self.identifier), ["charidentifier"] = self.charIdentifier }
        )
    end

    return self
end