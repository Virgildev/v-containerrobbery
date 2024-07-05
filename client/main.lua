local QBCore = exports['qb-core']:GetCoreObject()

local spawnedObjects = {}
local containerShell = nil
local lastRobberyTime = -Config.cooldownTime 
local entryPoint = nil  

RegisterNetEvent('container-robbery:enter')
AddEventHandler('container-robbery:enter', function(data)
    local playerPed = PlayerPedId()
    local currentTime = GetGameTimer()

    if not data or not data.parameters or not data.parameters.locationIndex or type(data.parameters.locationIndex) ~= "number" then
        if Config.Notify == 'qb' then
            QBCore.Functions.Notify('Invalid robbery location!', 'error')
        elseif Config.Notify == 'ox' then
            lib.notify({
                title = 'Container Robbery',
                description = 'Invalid robbery location!',
                type = 'error'
            })
        end
        return
    end

    local locationIndex = data.parameters.locationIndex

    if currentTime - lastRobberyTime < Config.cooldownTime then
        if Config.Notify == 'qb' then
            QBCore.Functions.Notify('You can only rob one container every 30 minutes!', 'error')
        elseif Config.Notify == 'ox' then
            lib.notify({
                title = 'Container Robbery',
                description = 'You can only rob one container every 30 minutes!',
                type = 'error'
            })
        end
        return
    end

    local hasCrowbar = QBCore.Functions.HasItem(Config.Required)

    if hasCrowbar then
        local success = false

        if Config.SkillCheckSystem == 'ox' then
            success = skillCheckEnter_ox()
        elseif Config.SkillCheckSystem == 'ps' then
            skillCheckEnter_ps(function(result)
                success = result
                if success then
                    proceedWithRobbery(locationIndex)
                else
                    if Config.Notify == 'qb' then
                        QBCore.Functions.Notify('Failed skill check to enter!', 'error')
                    elseif Config.Notify == 'ox' then
                        lib.notify({
                            title = 'Container Robbery',
                            description = 'Failed skill check to enter!',
                            type = 'error'
                        })
                    end
                end
            end)
        end

        if Config.SkillCheckSystem == 'ox' and success then
            proceedWithRobbery(locationIndex)
        end
    else
        if Config.Notify == 'qb' then
            QBCore.Functions.Notify('You need a crowbar to enter!', 'error')
        elseif Config.Notify == 'ox' then
            lib.notify({
                title = 'Container Robbery',
                description = 'You need a crowbar to enter!',
                type = 'error'
            })
        end
    end
end)

function proceedWithRobbery(locationIndex)
    local playerPed = PlayerPedId()
    local currentTime = GetGameTimer()

    lastRobberyTime = currentTime

    local coords = GetEntityCoords(playerPed)
    entryPoint = coords  

    if locationIndex < 1 or locationIndex > #Config.robberyStartLocations then
        if Config.Notify == 'qb' then
            QBCore.Functions.Notify('Invalid robbery location!', 'error')
        elseif Config.Notify == 'ox' then
            lib.notify({
                title = 'Container Robbery',
                description = 'Invalid robbery location!',
                type = 'error'
            })
        end
        return
    end

    local location = Config.robberyStartLocations[locationIndex]
    local spawn = location.entry
    containerShell = CreateContainerShell(spawn)

    Citizen.Wait(1000)
    ContainerRobberyAlert()
    local interiorCoords = vector3(spawn.x, spawn.y, spawn.z - 48.5)
    TeleportToInterior(interiorCoords.x, interiorCoords.y, interiorCoords.z, 0.0)  
    Citizen.Wait(1000)

    for category, locations in pairs(Config.searchLocations) do
        for i, loc in ipairs(locations) do
            local searchCoords = vector3(interiorCoords.x + loc.x, interiorCoords.y + loc.y, interiorCoords.z + loc.z)
            local box = CreateObject(loc.prop, searchCoords.x, searchCoords.y, searchCoords.z, false, false, false)
            FreezeEntityPosition(box, true)
            table.insert(spawnedObjects, box)

            exports['qb-target']:AddBoxZone("containerSearch" .. category .. i, searchCoords, 5.0, 5.0, {
                name = "containerSearch" .. category .. i,
                heading = 0,
                debugPoly = false,
                minZ = searchCoords.z - 1.0,
                maxZ = searchCoords.z + 1.0
            }, {
                options = {
                    {
                        icon = 'fa-solid fa-box',
                        label = "Search",
                        action = function()
                            progressBar()
                            if Config.Progress == 'qb' then
                                Citizen.Wait(Config.SearchProgress)
                            end
                            giveRandomItem(loc.loot)  
                            DeleteObject(box)
                            exports['qb-target']:RemoveZone("containerSearch" .. category .. i)
                        end
                    }
                },
                distance = 2.0
            })            
        end
    end

    local exitCoords = vector3(interiorCoords.x, interiorCoords.y - 6.0, interiorCoords.z)
    exports['qb-target']:AddBoxZone("containerExit", exitCoords, 2.0, 2.0, {
        name = "containerExit",
        heading = 0,
        debugPoly = false,
        minZ = exitCoords.z - 1.0,
        maxZ = exitCoords.z + 1.0
    }, {
        options = {
            {
                icon = 'fa-solid fa-box',
                label = "Exit",
                action = function()
                    LeaveContainer(entryPoint) 
                end
            }
        },
        distance = 2.0
    })
end

function ContainerRobberyAlert(x, y, z, h)
    exports['ps-dispatch']:ContainerRobberyAlert()
end

function TeleportToInterior(x, y, z, h)
    DoScreenFadeOut(2500)
    Citizen.Wait(3000)
    SetEntityCoords(PlayerPedId(), x, y - 6.0, z + 1.0, 0, 0, 0, false)
    SetEntityHeading(PlayerPedId(), h)
    Citizen.Wait(3000)
    DoScreenFadeIn(2500)
end

function getRotation(input)
    return 360 / (10 * input)
end

function CreateContainerShell(spawn)
    local objects = {}
    local POIOffsets = {}
    POIOffsets.exit = json.decode('{"z":2.5,"y":-15.901171875,"x":4.251012802124,"h":2.2633972168}')

    local shell = CreateObject(`container_shell`, spawn.x, spawn.y, spawn.z - 50, false, false, false)
    FreezeEntityPosition(shell, true)
    table.insert(objects, shell)

    return { objects = objects, POIOffsets = POIOffsets }
end

function LeaveContainer(entryPoint)
    local playerPed = PlayerPedId()
    local exitCoords = entryPoint  
    local exitTime = GetGameTimer() + 10000  

    if not IsScreenFadedOut() then
        DoScreenFadeOut(3500)
    end

    if Config.Progress == 'ox' then
        lib.progressBar({
            duration = 5000,
            label = 'Leaving Container...',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true,
                combat = true,
                sprint = true
            },
        })
    elseif Config.Progress == 'qb' then
        QBCore.Functions.Progressbar("search_container", "Leaving Container...", 5000, false, true, {
            disableMovement = false,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() end) 

        Citizen.Wait(5000)
    end

    TeleportToInterior(exitCoords.x, exitCoords.y + 6.0, exitCoords.z, 0.0)

    if not IsScreenFadedIn() then
        DoScreenFadeIn(2500)
    end

    if containerShell and containerShell.objects then
        for _, obj in ipairs(containerShell.objects) do
            if DoesEntityExist(obj) then
                DeleteObject(obj)
            end
        end
        containerShell = nil
    end

    for _, box in ipairs(spawnedObjects) do
        if DoesEntityExist(box) then
            DeleteObject(box)
        end
    end
    spawnedObjects = {}

    -- Failsafe:
    while GetGameTimer() < exitTime do
        Citizen.Wait(1000) 
        local playerCoords = GetEntityCoords(playerPed)
        if playerCoords.x == exitCoords.x and playerCoords.y == exitCoords.y and playerCoords.z == exitCoords.z then
            return  
        end
    end

    -- Failsafe
    TeleportToInterior(exitCoords.x, exitCoords.y + 6.0, exitCoords.z, 0.0)
    if not IsScreenFadedIn() then
        DoScreenFadeIn(2500)
    end
end

function giveRandomItem(lootTable)
    local totalWeight = 0

    for _, item in ipairs(lootTable) do
        totalWeight = totalWeight + item.chance
    end
    if totalWeight > 0 then
        if math.random() <= (Config.itemChance * 2) / 100 then 
            local randomNumber = math.random(1, totalWeight)
            local accumulatedWeight = 0

            for _, item in ipairs(lootTable) do
                accumulatedWeight = accumulatedWeight + item.chance

                if randomNumber <= accumulatedWeight then
                    TriggerServerEvent('QBCore:Server:AddItem', item.item, item.amount)
                    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[item.item], 'add', item.amount)
                    if Config.Notify == 'qb' then
                        QBCore.Functions.Notify('Found: ' .. item.item, 'success')
                    elseif Config.Notify == 'ox' then
                        lib.notify({
                            title = 'Container Robbery',
                            description = 'Found: ' .. item.item,
                            type = 'success'
                        })
                    end
                    return
                end
            end
        else
            if Config.Notify == 'qb' then
                QBCore.Functions.Notify('You found nothing this time.', 'error')
            elseif Config.Notify == 'ox' then
                lib.notify({
                    title = 'Container Robbery',
                    description = 'You found nothing this time.',
                    type = 'error'
                })
            end
        end
    else
        if Config.Notify == 'qb' then
            QBCore.Functions.Notify('Loot table is empty or invalid!', 'error')
        elseif Config.Notify == 'ox' then
            lib.notify({
                title = 'Container Robbery',
                description = 'Loot table is empty or invalid!',
                type = 'error'
            })
        end
    end
end

function progressBar()
    if Config.Progress == 'ox' then
        lib.progressBar({
            duration = Config.SearchProgress,
            label = 'Searching Crate...',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true,
                combat = true,
                sprint = true
            },
            anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_ped',
            },
        })
    elseif Config.Progress == 'qb' then
        QBCore.Functions.Progressbar("search_container", "Searching...", Config.SearchProgress, false, true, {
            disableMovement = false,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@repair",
            anim = "fixing_a_ped",
            flags = 1,
        }, {}, {}, function() 
            ClearPedTasks(PlayerPedId())
        end, function() 
            ClearPedTasks(PlayerPedId())
        end)
    end
end

function skillCheckEnter_ox()
    Citizen.Wait(200)
    local success = lib.skillCheck(Config.OxSkill)
    return success
end

function skillCheckEnter_ps(callback)
    Citizen.Wait(200)
    exports['ps-ui']:Circle(function(success)
        callback(success)
    end, Config.PsSkill)
end

function skillCheckSearch_ox()
    local success = lib.skillCheck(Config.OxSkill)
    return success
end

function skillCheckSearch_ps(callback)
    exports['ps-ui']:Circle(function(success)
        if success then
            callback(true)
        else
            callback(false)
        end
    end, Config.PsSkill) 
end

function giveRandomItem(lootTable)
    local totalWeight = 0

    for _, item in ipairs(lootTable) do
        totalWeight = totalWeight + item.chance
    end

    if totalWeight > 0 then
        local randomNumber = math.random(1, totalWeight)
        local accumulatedWeight = 0

        for _, item in ipairs(lootTable) do
            accumulatedWeight = accumulatedWeight + item.chance

            if randomNumber <= accumulatedWeight then
                if item.item ~= "nothing" then
                    local amount = math.random(item.amount.min, item.amount.max)
                    TriggerServerEvent('container-robbery:giveItem', item.item, amount)
                else
                    if Config.Notify == 'qb' then
                        QBCore.Functions.Notify('Nothing found!', 'error')
                    elseif Config.Notify == 'ox' then
                        lib.notify({
                            title = 'Container Robbery',
                            description = 'Nothing found!',
                            type = 'error'
                        })
                    end
                end
                return
            end
        end
    else
        if Config.Notify == 'qb' then
            QBCore.Functions.Notify('Nothing found!', 'error')
        elseif Config.Notify == 'ox' then
            lib.notify({
                title = 'Container Robbery',
                description = 'Nothing found!',
                type = 'error'
            })
        end
    end
end

for index, location in ipairs(Config.robberyStartLocations) do
    exports['qb-target']:AddBoxZone("containerRobbery" .. index, location.entry, 1.0, 1.0, {
        name = "containerRobbery" .. index,
        heading = 0,
        debugPoly = false,
        minZ = location.entry.z - 1.0,
        maxZ = location.entry.z + 1.0
    }, {
        options = {
            {
                icon = 'fa-solid fa-box',
                label = "Enter Container",
                action = function()
                    TriggerEvent('container-robbery:enter', { parameters = { locationIndex = index } })
                end
            }
        },
        distance = 2.0
    })
end
