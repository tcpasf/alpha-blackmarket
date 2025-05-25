local QBCore = exports['qb-core']:GetCoreObject()

local function CheckPlayerPermission(Player)
    local mode = Config.Permissions.mode

    if mode == 'all' then
        return true
    elseif mode == 'admin' then
        return Player.PlayerData.name == Config.Permissions.admin
    elseif mode == 'gangs' then
        local playerGang = Player.PlayerData.gang.name
        for _, gang in pairs(Config.Permissions.allowedGangs) do
            if playerGang == gang then
                return true
            end
        end
        return false
    end

    return false
end

RegisterNetEvent('alpha-blackmarket:server:checkPermissions', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local hasPermission = CheckPlayerPermission(Player)

    TriggerClientEvent('alpha-blackmarket:client:openUI', src, hasPermission)
end)

RegisterNetEvent('alpha-blackmarket:server:buyItem', function(itemName, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then 
        print("Player not found for source:", src)
        return 
    end

    print("Processing item purchase for player:", Player.PlayerData.charinfo.firstname, "Item:", itemName, "Price:", price)

    if not CheckPlayerPermission(Player) then
        TriggerClientEvent('QBCore:Notify', src, 'Access denied - You do not have permission', 'error', 3000)
        return
    end

    -- Check if the item exists in the shared items
    local itemData = QBCore.Shared.Items[itemName]
    if itemData == nil then
        print("Item not found in database:", itemName)
        TriggerClientEvent('QBCore:Notify', src, 'Item does not exist in database', 'error', 3000)
        return
    end

    -- Check if player has enough money
    if Player.PlayerData.money.cash >= price then
        -- Check if player has enough space in inventory
        if Player.Functions.AddItem(itemName, 1) then
            Player.Functions.RemoveMoney('cash', price)
            print("Purchase successful for item:", itemName)
            TriggerClientEvent('QBCore:Notify', src, 'Item purchased successfully', 'success', 3000)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'add')
        else
            print("Not enough inventory space for item:", itemName)
            TriggerClientEvent('QBCore:Notify', src, 'Not enough space in inventory', 'error', 3000)
        end
    else
        print("Not enough cash. Required:", price, "Player has:", Player.PlayerData.money.cash)
        TriggerClientEvent('QBCore:Notify', src, 'Not enough cash', 'error', 3000)
    end
end)

RegisterNetEvent('alpha-blackmarket:server:buyWeapon', function(weaponName, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then 
        print("Player not found for source:", src)
        return 
    end

    print("Processing weapon purchase for player:", Player.PlayerData.charinfo.firstname, "Weapon:", weaponName, "Price:", price)

    if not CheckPlayerPermission(Player) then
        TriggerClientEvent('QBCore:Notify', src, 'Access denied - You do not have permission', 'error', 3000)
        return
    end

    -- Check if the weapon exists in the shared items
    -- Some servers might store weapons with different item names
    local weaponItem = QBCore.Shared.Items[weaponName]
    local finalWeaponName = weaponName
    
    if weaponItem == nil then
        -- Try with WEAPON_ prefix removed (some servers store them this way)
        local altWeaponName = weaponName:gsub("weapon_", "")
        weaponItem = QBCore.Shared.Items[altWeaponName]
        
        if weaponItem == nil then
            print("Weapon not found in database:", weaponName, "or as:", altWeaponName)
            TriggerClientEvent('QBCore:Notify', src, 'Weapon does not exist in database', 'error', 3000)
            return
        else
            finalWeaponName = altWeaponName -- Use the alternative name that was found
            print("Found weapon with alternative name:", finalWeaponName)
        end
    end

    -- Check if player has enough money
    if Player.PlayerData.money.cash >= price then
        -- Check if player has enough space in inventory
        if Player.Functions.AddItem(finalWeaponName, 1) then
            Player.Functions.RemoveMoney('cash', price)
            print("Purchase successful for weapon:", finalWeaponName)
            TriggerClientEvent('QBCore:Notify', src, 'Weapon purchased successfully', 'success', 3000)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[finalWeaponName], 'add')
        else
            print("Not enough inventory space for weapon:", finalWeaponName)
            TriggerClientEvent('QBCore:Notify', src, 'Not enough space in inventory', 'error', 3000)
        end
    else
        print("Not enough cash. Required:", price, "Player has:", Player.PlayerData.money.cash)
        TriggerClientEvent('QBCore:Notify', src, 'Not enough cash', 'error', 3000)
    end
end)
