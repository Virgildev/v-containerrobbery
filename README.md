# v-containerrobbery
A QBCore/OX container robbery. 

Preview: https://streamable.com/sckhgl

Unlock the thrill of heists with our Container Robbery script designed for FiveM servers. This robust Lua script integrates seamlessly with your server, offering immersive gameplay features that elevate the crime simulation experience. Players can engage in daring container robberies, complete with dynamic entry points, skill checks, and randomized loot rewards.

Key Features:

-Customizable config:

    able to add as many robbery locations as you wish
    able to add or remove to a certain number of searchable locations
    dispatch intergration, you can easily change by going to line 170 in client.lua
    cooldown system
    unlimited robbery locations

-PS Disptach Integration:

    ps-dispatch>client>alerts

    add:

                local function ContainerRobberyAlert()
                local coords = GetEntityCoords(cache.ped)
                local vehicle = GetVehicleData(cache.vehicle)

                local dispatchData = {
                    message = 'Container Robbery in Progress',
                    codeName = 'containerRobbery',
                    code = '10-90',
                    icon = 'fas fa-box',
                    priority = 2,
                    coords = coords,
                    street = GetStreetAndZone(coords),
                    heading = GetPlayerHeading(),
                    gender = GetPlayerGender(),
                    jobs = { 'leo' }
                } 
                TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
                end 
                exports('ContainerRobberyAlert', ContainerRobberyAlert)

    ps-dispatch>shared>config


    add:
                            ['containerRobbery'] = { 
                            radius = 0,
                            sprite = 119,
                            color = 1,
                            scale = 1.5,
                            length = 2,
                            sound = 'Lose_1st',
                            sound2 = 'GTAO_FM_Events_Soundset',
                            offset = false,
                            flash = false
                            },  


Requirements:
-ox_target/qb-target
-ox_inventory/qb-inventory
-ox_lib/qb-progress
