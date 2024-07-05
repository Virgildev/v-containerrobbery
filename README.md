# v-containerrobbery
A QBCore/OX container robbery script for FiveM servers.

Preview: [Watch Video](https://streamable.com/sckhgl)

Unlock the thrill of heists with our Container Robbery script designed for FiveM servers. This robust Lua script integrates seamlessly with your server, offering immersive gameplay features that elevate the crime simulation experience. Players can engage in daring container robberies, complete with dynamic entry points, skill checks, and randomized loot rewards.

## Key Features:

- Customizable config:
  - Able to add as many robbery locations as you wish.
  - Able to add or remove a certain number of searchable locations.
  - Dispatch integration, which can be modified by editing `client.lua` on line 170.
  - Cooldown system.
  - Unlimited robbery locations.

- PS Dispatch Integration:
  - **Add to `client.lua`**:
    ```lua
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
    exports('ContainerRobberyAlert', ContainerRobberyAlert);
    ```

  - **Add to `shared/config.lua`**:
    ```lua
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
    ```

## Requirements:
- ox_target/qb-target
- ox_inventory/qb-inventory
- ox_lib/qb-progress
