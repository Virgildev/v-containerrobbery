local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('container-robbery:giveItem')
AddEventHandler('container-robbery:giveItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem(item, amount)
        local lootLabel = GetItemLabel(item) 

        if Config.Notify == 'qb' then
            TriggerClientEvent('QBCore:Notify', src, 'You received ' .. amount .. ' ' .. lootLabel .. '(s)', 'success')
        elseif Config.Notify == 'ox' then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Container Robbery',
                description = 'You received ' .. amount .. ' ' .. lootLabel .. '(s)',
                type = 'success'
            })
        end
    end
end)

function GetItemLabel(itemName)
    for _, category in pairs(Config.searchLocations) do
        for _, location in ipairs(category) do
            for _, loot in ipairs(location.loot) do
                if loot.item == itemName then
                    return loot.label
                end
            end
        end
    end
    return itemName
end
