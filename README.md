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

## Config

```
Config = {

    -- ox_target, and qb-target work without any adjustments
    -- ox_inventory and qb-inventory work without any adjustments

    Progress = 'ox', -- 'ox' or 'qb'
    Notify = 'qb', -- 'ox' or 'qb'
    SkillCheckSystem = 'ps', -- 'ox' or 'ps'
   
    --Only have to adjust the one you wish to use
    OxSkill = {'easy', 'easy', 'medium'}, -- ox skillcheck difficulty
    PsSkill = 2, 6, -- ps skillcheck difficulty

    SearchProgress = 10000, -- Searching boxes inside progress length

    Required = 'weapon_crowbar', -- Required item to enter the container
    
    -- Container locations, add as many or as little as you wish
    robberyStartLocations = {
        { entry = vector3(896.39, -3079.50, 5.90) },
        { entry = vector3(896.40, -3090.78, 5.90) },
        { entry = vector3(587.52, -2829.06, 5.42) },
        { entry = vector3(-153.31, -2419.78, 6.93) },
        { entry = vector3(54.16, -1633.60, 28.60) },
        { entry = vector3(680.01, 1284.26, 359.57) },
        { entry = vector3(208.01, 2743.93, 42.72) },
    },

    -- Chance to recieve an item from each box
    itemChance = 100,

    -- Add as many as you want
    searchLocations = {
        Weapons = {
            { x = 0.0, y = 5.0, z = -1.5, prop = "prop_lev_crate_01", loot = {
                { item = "weapon_pistol", label = 'Pistol', chance = 60, amount = { min = 1, max = 3 } },
                { item = "weapon_knife", label = 'Knife', chance = 50, amount = { min = 1, max = 1 } },
                { item = "weapon_smg", label = 'SMG', chance = 50, amount = { min = 1, max = 1 } },
            }},
        },
        Ammo = {
            { x = 0.0, y = 2.5, z = -1.5, prop = "prop_box_ammo03a", loot = {
                { item = "ammo-9", label = '9mm Ammo', chance = 50, amount = { min = 10, max = 30 } },
                { item = "ammo-45", label = '45mm Ammo', chance = 50, amount = { min = 5, max = 20 } },
                { item = "ammo-rifle", label = 'Rifle Ammo', chance = 50, amount = { min = 20, max = 50 } },
            }},
        },
        Loot = {
            { x = 0.0, y = -0.5, z = -1.5, prop = "prop_boxpile_03a", loot = {
                { item = "rolex", label = 'Rolex Watch', chance = 50, amount = { min = 1, max = 3 } },
                { item = "water", label = 'Water Bottle', chance = 50, amount = { min = 1, max = 5 } },
                { item = "burger", label = 'Burger', chance = 50, amount = { min = 1, max = 2 } },
            }},
        },
    },

    cooldownTime = 30 * 6000, -- Cooldown time, just change first number, and it will be x number of minutes. Currently 30 minutes.
}

```

## PS Dispatch Integration:
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
