local QBCore = exports['qb-core']:GetCoreObject()
local spawnedNPC = nil
local uiOpen = false

-- Define UI handling functions at the top of the file
local function CloseUI()
    if uiOpen then
        print("CloseUI function called")
        
        -- Update state
        uiOpen = false
        
        -- Disable focus
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        
        -- Unfreeze player and show radar
        FreezeEntityPosition(PlayerPedId(), false)
        DisplayRadar(true)
        
        -- Send close message to NUI
        SendNUIMessage({
            action = 'closeUI'
        })
        
        -- Additional safety measures
        SetCursorLocation(0.5, 0.5)
        
        print("UI closed successfully")
    end
end

local function OpenUI()
    if not uiOpen then
        print("OpenUI function called")
        
        -- Update state
        uiOpen = true
        
        -- Enable focus
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
        
        -- Send open message with data to NUI
        SendNUIMessage({
            action = 'openUI',
            items = Config.Items,
            weapons = Config.Weapons
        })
        
        print("UI opened successfully")
    end
end

local function SpawnNPC()
    local model = GetHashKey(Config.NPC.model)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    spawnedNPC = CreatePed(4, model, Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z, Config.NPC.coords.w, true, true)

    SetEntityHeading(spawnedNPC, Config.NPC.coords.w)
    FreezeEntityPosition(spawnedNPC, Config.NPC.freeze)
    SetEntityInvincible(spawnedNPC, Config.NPC.invincible)
    SetBlockingOfNonTemporaryEvents(spawnedNPC, Config.NPC.blockevents)
    SetPedDiesWhenInjured(spawnedNPC, false)
    SetPedCanPlayAmbientAnims(spawnedNPC, true)
    SetPedCanRagdollFromPlayerImpact(spawnedNPC, false)
    SetEntityCanBeDamaged(spawnedNPC, false)

    TaskStartScenarioInPlace(spawnedNPC, Config.NPC.scenario, 0, true)

    exports['qb-target']:AddTargetEntity(spawnedNPC, {
        options = {
            {
                icon = Config.Target.icon,
                label = Config.Target.label,
                action = function()
                    TriggerEvent('alpha-blackmarket:client:talkToDealer')
                end
            }
        },
        distance = Config.Target.distance
    })

    SetModelAsNoLongerNeeded(model)
end

local function DeleteNPC()
    if spawnedNPC and DoesEntityExist(spawnedNPC) then
        exports['qb-target']:RemoveTargetEntity(spawnedNPC)
        DeleteEntity(spawnedNPC)
        spawnedNPC = nil
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SpawnNPC()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DeleteNPC()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    SpawnNPC()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    DeleteNPC()
end)

RegisterNetEvent('alpha-blackmarket:client:talkToDealer', function()
    TriggerServerEvent('alpha-blackmarket:server:checkPermissions')
end)

RegisterNetEvent('alpha-blackmarket:client:openUI', function(hasPermission)
    if hasPermission then
        -- Use our new OpenUI function
        OpenUI()
    else
        QBCore.Functions.Notify('Access denied. You need special clearance.', 'error', 3000)
    end
end)

RegisterNUICallback('closeUI', function(data, cb)
    print('closeUI callback received')
    CloseUI()
    cb({status = 'ok'})
end)

RegisterNUICallback('buyItem', function(data, cb)
    print('buyItem callback received:', json.encode(data))
    
    if data and data.item and data.price then
        print('Triggering server event to buy item:', data.item, 'for price:', data.price)
        TriggerServerEvent('alpha-blackmarket:server:buyItem', data.item, data.price)
        QBCore.Functions.Notify('Processing purchase...', 'primary', 2000)
        cb({status = 'ok'})
    else
        print('Error: Invalid data received in buyItem callback:', json.encode(data))
        QBCore.Functions.Notify('Error processing purchase', 'error', 3000)
        cb({status = 'error', message = 'Invalid data'})
    end
end)

RegisterNUICallback('buyWeapon', function(data, cb)
    print('buyWeapon callback received:', json.encode(data))
    
    if data and data.weapon and data.price then
        print('Triggering server event to buy weapon:', data.weapon, 'for price:', data.price)
        TriggerServerEvent('alpha-blackmarket:server:buyWeapon', data.weapon, data.price)
        QBCore.Functions.Notify('Processing weapon purchase...', 'primary', 2000)
        cb({status = 'ok'})
    else
        print('Error: Invalid data received in buyWeapon callback:', json.encode(data))
        QBCore.Functions.Notify('Error processing weapon purchase', 'error', 3000)
        cb({status = 'error', message = 'Invalid data'})
    end
end)

RegisterNUICallback('escapePressed', function(data, cb)
    print('escapePressed callback received')
    CloseUI()
    cb({status = 'ok'})
end)

-- Thread to handle ESC key press
CreateThread(function()
    while true do
        Wait(0)
        if uiOpen then
            -- Check for ESC key (322) or Backspace key (177)
            if IsControlJustPressed(0, 322) or IsControlJustPressed(0, 177) then
                print("ESC or Backspace pressed, closing UI")
                CloseUI()
            end
        else
            Wait(500) -- Use longer wait when UI is closed to save resources
        end
    end
end)

-- Additional thread to ensure UI state is consistent
CreateThread(function()
    while true do
        Wait(1000)
        if uiOpen then
            -- Make sure focus is set correctly when UI is open
            SetNuiFocus(true, true)
        end
    end
end)