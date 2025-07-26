ESX = exports["es_extended"]:getSharedObject()


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
        MySQL.single('SELECT armor FROM users WHERE identifier = ?', {
            xPlayer.identifier
        }, function(result)
            if result and result.armor then
                TriggerClientEvent('hud:client:UpdateArmor', src, result.armor)
            end
        end)
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