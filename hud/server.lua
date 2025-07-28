ESX = exports["es_extended"]:getSharedObject()


CreateThread(function()
    MySQL.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS armor INT DEFAULT 0', {}, function()
    end)
end)


RegisterNetEvent('hud:server:UpdateArmor')
AddEventHandler('hud:server:UpdateArmor', function(newArmor)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        MySQL.update('UPDATE users SET armor = ? WHERE identifier = ?', {
            newArmor,
            xPlayer.identifier
        }, function(affectedRows)
            if affectedRows > 0 then
                TriggerClientEvent('hud:client:ArmorUpdated', src, newArmor)
            end
        end)
    end
end)

RegisterNetEvent('hud:server:LoadArmor')
AddEventHandler('hud:server:LoadArmor', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        MySQL.query('SHOW COLUMNS FROM users LIKE "armor"', {}, function(result)
            print('DEBUG: Column check result: ' .. tostring(result and #result or 'nil'))
            if result and #result > 0 then
                MySQL.single('SELECT armor FROM users WHERE identifier = ?', {
                    xPlayer.identifier
                }, function(armorResult)
                    if armorResult and armorResult.armor then
                        TriggerClientEvent('hud:client:UpdateArmor', src, armorResult.armor)
                    end
                end)
            else
                MySQL.query('ALTER TABLE users ADD COLUMN armor INT DEFAULT 0', {}, function()
                    MySQL.update('UPDATE users SET armor = ? WHERE identifier = ?', {
                        0,
                        xPlayer.identifier
                    }, function(affectedRows)
                        if affectedRows > 0 then
                            TriggerClientEvent('hud:client:UpdateArmor', src, 0)
                        end
                    end)
                end)
            end
        end)
    else
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local armor = GetPedArmour(GetPlayerPed(src))
        MySQL.update('UPDATE users SET armor = ? WHERE identifier = ?', {
            armor,
            xPlayer.identifier
        }, function(affectedRows)
            if affectedRows > 0 then
            end
        end)
    end
end)