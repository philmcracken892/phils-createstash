local RSGCore = exports['rsg-core']:GetCoreObject()


local PlayerData = {}
local createdStashes = {}
local isCreatingStash = false
local CurrentStash = nil
local IsInZone = false
local MenuOpen = false
local HasLoaded = false


local StashPrompt = nil
local CreatePrompt = nil
local CancelPrompt = nil
local PromptsCreated = false


local activeBlips = {}


CreateThread(function()
    while RSGCore == nil do
        Wait(100)
    end
    
    PlayerData = RSGCore.Functions.GetPlayerData()
    
    while PlayerData.citizenid == nil do
        PlayerData = RSGCore.Functions.GetPlayerData()
        Wait(100)
    end
    
    CreatePrompts()
    Wait(2000)
    LoadStashes()
    HasLoaded = true
end)

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    PlayerData = RSGCore.Functions.GetPlayerData()
    
    if not PromptsCreated then
        CreatePrompts()
    end
    
    Wait(3000)
    LoadStashes()
    HasLoaded = true
    
    
end)

RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    HasLoaded = false
    RemoveAllBlips()
end)


function CreatePrompts()
    if PromptsCreated then return end
    
    StashPrompt = PromptRegisterBegin()
    PromptSetControlAction(StashPrompt, 0x760A9C6F)
    local str1 = CreateVarString(10, 'LITERAL_STRING', 'Open Stash')
    PromptSetText(StashPrompt, str1)
    PromptSetEnabled(StashPrompt, false)
    PromptSetVisible(StashPrompt, false)
    PromptSetHoldMode(StashPrompt, true)
    PromptSetStandardizedHoldMode(StashPrompt, true)
    PromptRegisterEnd(StashPrompt)
    
    CreatePrompt = PromptRegisterBegin()
    PromptSetControlAction(CreatePrompt, 0xC7B5340A)
    local str2 = CreateVarString(10, 'LITERAL_STRING', 'Create Stash Here')
    PromptSetText(CreatePrompt, str2)
    PromptSetEnabled(CreatePrompt, false)
    PromptSetVisible(CreatePrompt, false)
    PromptSetHoldMode(CreatePrompt, true)
    PromptSetStandardizedHoldMode(CreatePrompt, true)
    PromptRegisterEnd(CreatePrompt)
    
    CancelPrompt = PromptRegisterBegin()
    PromptSetControlAction(CancelPrompt, 0x156F7119)
    local str3 = CreateVarString(10, 'LITERAL_STRING', 'Cancel')
    PromptSetText(CancelPrompt, str3)
    PromptSetEnabled(CancelPrompt, false)
    PromptSetVisible(CancelPrompt, false)
    PromptSetHoldMode(CancelPrompt, false)
    PromptRegisterEnd(CancelPrompt)
    
    PromptsCreated = true
    
end


function LoadStashes()
   
    
    RSGCore.Functions.TriggerCallback('rsg-stashcreator:server:GetStashes', function(stashes)
        if stashes then
            createdStashes = stashes
            
            local count = 0
            local blipCount = 0
            for id, stash in pairs(stashes) do
                count = count + 1
                if stash.showBlip then
                    blipCount = blipCount + 1
                end
            end
            
           
            LoadAllBlips()
        else
            
        end
    end)
end

function TableCount(t)
    local count = 0
    if t and type(t) == "table" then
        for _ in pairs(t) do count = count + 1 end
    end
    return count
end


local function CreateBlip(blipData)
    if not blipData or not blipData.x or not blipData.y or not blipData.z then
        return nil
    end
    
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, blipData.x, blipData.y, blipData.z)
    
    if blip and type(blip) == "number" and blip ~= 0 then
        SetBlipSprite(blip, blipData.sprite or -1138864184, 1)
        SetBlipScale(blip, blipData.scale or 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, blipData.name or "Stash")
        
        if blipData.color and type(blipData.color) == "string" then
            BlipAddModifier(blip, joaat(blipData.color))
        end
        
        return blip
    end
    
    return nil
end

local function RemoveBlipSafe(blip)
    if blip and type(blip) == "number" and blip ~= 0 then
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
            return true
        end
    end
    return false
end

function LoadAllBlips()
    RemoveAllBlips()
    
    if createdStashes and type(createdStashes) == "table" then
        local created = 0
        for stashId, stash in pairs(createdStashes) do
            if stash.showBlip == true and stash.coords then
                local blipData = {
                    x = stash.coords.x,
                    y = stash.coords.y,
                    z = stash.coords.z,
                    sprite = Config.BlipSprite or -1138864184,
                    scale = Config.BlipScale or 0.2,
                    name = stash.label or "Stash",
                    color = Config.BlipColor
                }
                local newBlip = CreateBlip(blipData)
                if newBlip then
                    activeBlips[stashId] = newBlip
                    created = created + 1
                end
            end
        end
        
    end
end

function AddSingleBlip(stashId, stash)
    if not stash or not stash.coords then return end
    
    if stash.showBlip == true then
        if activeBlips[stashId] then
            RemoveBlipSafe(activeBlips[stashId])
            activeBlips[stashId] = nil
        end
        
        local blipData = {
            x = stash.coords.x,
            y = stash.coords.y,
            z = stash.coords.z,
            sprite = Config.BlipSprite or -1138864184,
            scale = Config.BlipScale or 0.2,
            name = stash.label or "Stash",
            color = Config.BlipColor
        }
        local newBlip = CreateBlip(blipData)
        if newBlip then
            activeBlips[stashId] = newBlip
        end
    end
end

function RemoveSingleBlip(stashId)
    if activeBlips[stashId] then
        RemoveBlipSafe(activeBlips[stashId])
        activeBlips[stashId] = nil
    end
end

function RemoveAllBlips()
    if activeBlips and type(activeBlips) == "table" then
        for stashId, blip in pairs(activeBlips) do
            RemoveBlipSafe(blip)
        end
    end
    activeBlips = {}
end


CreateThread(function()
    while true do
        local sleep = 1000
        
        if HasLoaded then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local closestStash = nil
            local closestDistance = math.huge
            
            if createdStashes and type(createdStashes) == "table" then
                for stashId, stash in pairs(createdStashes) do
                    if stash.coords then
                        local stashCoords = vector3(stash.coords.x, stash.coords.y, stash.coords.z)
                        local distance = #(playerCoords - stashCoords)
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            closestStash = stash
                            closestStash.id = stashId
                        end
                    end
                end
            end
            
            if closestStash and closestDistance < Config.InteractionDistance then
                sleep = 0
                IsInZone = true
                CurrentStash = closestStash
                
                if StashPrompt and not MenuOpen and not isCreatingStash then
                    local promptText = CreateVarString(10, 'LITERAL_STRING', 'Open: ' .. (closestStash.label or "Stash"))
                    PromptSetText(StashPrompt, promptText)
                    
                    PromptSetEnabled(StashPrompt, true)
                    PromptSetVisible(StashPrompt, true)
                    
                    if PromptHasHoldModeCompleted(StashPrompt) then
                        OpenStash(CurrentStash)
                    end
                end
            else
                if IsInZone then
                    IsInZone = false
                    CurrentStash = nil
                    if StashPrompt then
                        PromptSetEnabled(StashPrompt, false)
                        PromptSetVisible(StashPrompt, false)
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)


CreateThread(function()
    while true do
        local sleep = 1000
        
        if isCreatingStash then
            sleep = 0
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            
            if Config.MarkerEnabled then
                DrawMarker(
                    0x94FDAE17,
                    coords.x, coords.y, coords.z - 1.0,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    1.0, 1.0, 0.5,
                    Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                    false, false, 2, false, nil, nil, false
                )
            end
            
            if CreatePrompt and CancelPrompt then
                PromptSetEnabled(CreatePrompt, true)
                PromptSetVisible(CreatePrompt, true)
                PromptSetEnabled(CancelPrompt, true)
                PromptSetVisible(CancelPrompt, true)
                
                if PromptHasHoldModeCompleted(CreatePrompt) then
                    isCreatingStash = false
                    HidePreviewPrompts()
                    CreateNewStashMenu()
                end
                
                if PromptIsJustPressed(CancelPrompt) then
                    isCreatingStash = false
                    HidePreviewPrompts()
                    lib.notify({
                        title = 'Preview Mode',
                        description = 'Cancelled',
                        type = 'info'
                    })
                end
            end
        end
        
        Wait(sleep)
    end
end)

function HidePreviewPrompts()
    if CreatePrompt then
        PromptSetEnabled(CreatePrompt, false)
        PromptSetVisible(CreatePrompt, false)
    end
    if CancelPrompt then
        PromptSetEnabled(CancelPrompt, false)
        PromptSetVisible(CancelPrompt, false)
    end
end


function OpenStash(stash)
    if not stash then return end
    
    local Player = RSGCore.Functions.GetPlayerData()
    
    local stashName
    if stash.type == 'personal' then
        stashName = 'stash_' .. stash.id .. '_' .. Player.citizenid
    else
        stashName = 'stash_' .. stash.id
    end
    
    TriggerServerEvent('rsg-stashcreator:server:openStash', stashName, stash)
end




function OpenStashCreatorMenu()
    RSGCore.Functions.TriggerCallback('rsg-stashcreator:server:hasPermission', function(hasPermission)
        if hasPermission then
            lib.registerContext({
                id = 'stash_creator_main',
                title = '🗃️ Stash Creator',
                onExit = function()
                    MenuOpen = false
                end,
                options = {
                    {
                        title = '📦 Create New Stash',
                        description = 'Create a new stash at your location',
                        icon = 'plus',
                        onSelect = function()
                            CreateNewStashMenu()
                        end
                    },
                    {
                        title = '📋 Manage Stashes',
                        description = 'View and edit existing stashes',
                        icon = 'list',
                        onSelect = function()
                            ManageStashesMenu()
                        end
                    },
                    {
                        title = '🎯 Preview Mode',
                        description = 'Walk around and place stash',
                        icon = 'eye',
                        onSelect = function()
                            TogglePreviewMode()
                        end
                    },
                    {
                        title = '🔄 Refresh Stashes',
                        description = 'Reload all stashes from database',
                        icon = 'sync',
                        onSelect = function()
                            RemoveAllBlips()
                            LoadStashes()
                            lib.notify({
                                title = 'Stashes Reloaded',
                                type = 'success'
                            })
                        end
                    }
                }
            })
            lib.showContext('stash_creator_main')
            MenuOpen = true
        else
            lib.notify({
                title = 'Access Denied',
                description = 'You do not have permission',
                type = 'error',
                duration = 5000
            })
        end
    end)
end


function CreateNewStashMenu()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    local input = lib.inputDialog('Create New Stash', {
        {
            type = 'input',
            label = 'Stash Name',
            description = 'Enter a unique name for this stash',
            required = true,
            placeholder = 'My Stash'
        },
        {
            type = 'select',
            label = 'Stash Type',
            description = 'Select the type of stash',
            required = true,
            options = Config.StashTypes
        },
        {
            type = 'number',
            label = 'Slots',
            description = 'Number of inventory slots',
            default = Config.DefaultSlots,
            min = 1,
            max = 200
        },
        {
            type = 'number',
            label = 'Weight Capacity',
            description = 'Maximum weight in grams',
            default = Config.DefaultWeight,
            min = 1000,
            max = 1000000
        },
        {
            type = 'checkbox',
            label = 'Show Blip on Map',
            checked = false
        }
    })
    
    if not input then 
        MenuOpen = false
        return 
    end
    
    local stashData = {
        label = input[1],
        type = input[2],
        slots = input[3],
        weight = input[4],
        showBlip = input[5] == true,
        coords = {
            x = playerCoords.x,
            y = playerCoords.y,
            z = playerCoords.z,
            heading = GetEntityHeading(PlayerPedId())
        }
    }
    
    if stashData.type == 'job' then
        SelectJobMenu(stashData)
    elseif stashData.type == 'gang' then
        SelectGangMenu(stashData)
    else
        ConfirmStashCreation(stashData)
    end
end


function SelectJobMenu(stashData)
    local options = {}
    for _, job in ipairs(Config.Jobs) do
        table.insert(options, {
            title = job.label,
            icon = 'briefcase',
            onSelect = function()
                stashData.jobName = job.value
                ConfirmStashCreation(stashData)
            end
        })
    end
    
    lib.registerContext({
        id = 'stash_select_job',
        title = 'Select Job Requirement',
        menu = 'stash_creator_main',
        onExit = function()
            MenuOpen = false
        end,
        options = options
    })
    lib.showContext('stash_select_job')
end


function SelectGangMenu(stashData)
    local options = {}
    for _, gang in ipairs(Config.Gangs) do
        table.insert(options, {
            title = gang.label,
            icon = 'users',
            onSelect = function()
                stashData.gangName = gang.value
                ConfirmStashCreation(stashData)
            end
        })
    end
    
    lib.registerContext({
        id = 'stash_select_gang',
        title = 'Select Gang Requirement',
        menu = 'stash_creator_main',
        onExit = function()
            MenuOpen = false
        end,
        options = options
    })
    lib.showContext('stash_select_gang')
end


function ConfirmStashCreation(stashData)
    local alert = lib.alertDialog({
        header = 'Confirm Stash Creation',
        content = string.format([[
**Name:** %s  
**Type:** %s  
**Slots:** %d  
**Weight:** %d g  
**Show Blip:** %s
**Location:** %.2f, %.2f, %.2f
        ]], stashData.label, stashData.type, stashData.slots, stashData.weight,
            tostring(stashData.showBlip),
            stashData.coords.x, stashData.coords.y, stashData.coords.z),
        centered = true,
        cancel = true
    })
    
    if alert == 'confirm' then
        TriggerServerEvent('rsg-stashcreator:server:CreateStash', stashData)
    end
    MenuOpen = false
end


function ManageStashesMenu()
    RSGCore.Functions.TriggerCallback('rsg-stashcreator:server:GetStashes', function(stashes)
        if not stashes or next(stashes) == nil then
            lib.notify({
                title = 'No Stashes',
                description = 'No stashes have been created yet',
                type = 'info'
            })
            MenuOpen = false
            return
        end
        
        local options = {}
        for stashId, stash in pairs(stashes) do
            table.insert(options, {
                title = stash.label or "Unknown",
                description = string.format('Type: %s | Slots: %d | Blip: %s', 
                    stash.type or "stash", 
                    stash.slots or 50,
                    tostring(stash.showBlip)),
                icon = 'box',
                metadata = {
                    {label = 'ID', value = tostring(stashId)},
                    {label = 'Weight', value = (stash.weight or 100000) .. 'g'},
                },
                onSelect = function()
                    StashOptionsMenu(stashId, stash)
                end
            })
        end
        
        lib.registerContext({
            id = 'stash_manage_list',
            title = '📋 Manage Stashes',
            menu = 'stash_creator_main',
            onExit = function()
                MenuOpen = false
            end,
            options = options
        })
        lib.showContext('stash_manage_list')
    end)
end


function StashOptionsMenu(stashId, stash)
    lib.registerContext({
        id = 'stash_options_' .. stashId,
        title = '⚙️ ' .. (stash.label or "Stash"),
        menu = 'stash_manage_list',
        onExit = function()
            MenuOpen = false
        end,
        options = {
            {
                title = '📍 Teleport to Stash',
                icon = 'location-arrow',
                onSelect = function()
                    if stash.coords then
                        SetEntityCoords(PlayerPedId(), stash.coords.x, stash.coords.y, stash.coords.z, false, false, false, false)
                        lib.notify({
                            title = 'Teleported',
                            description = 'Teleported to ' .. (stash.label or "Stash"),
                            type = 'success'
                        })
                    end
                    MenuOpen = false
                end
            },
            {
                title = '✏️ Edit Stash',
                icon = 'edit',
                onSelect = function()
                    EditStashMenu(stashId, stash)
                end
            },
            {
                title = '📦 Open Stash',
                icon = 'box-open',
                onSelect = function()
                    local stashName = 'stash_' .. stashId
                    TriggerServerEvent('rsg-stashcreator:server:openStash', stashName, stash)
                    MenuOpen = false
                end
            },
            {
                title = '🔄 Move Stash Here',
                description = 'Move stash to your current location',
                icon = 'arrows-alt',
                onSelect = function()
                    local coords = GetEntityCoords(PlayerPedId())
                    local newCoords = {
                        x = coords.x,
                        y = coords.y,
                        z = coords.z,
                        heading = GetEntityHeading(PlayerPedId())
                    }
                    TriggerServerEvent('rsg-stashcreator:server:MoveStash', stashId, newCoords)
                    MenuOpen = false
                end
            },
            {
                title = '🗑️ Delete Stash',
                icon = 'trash',
                iconColor = 'red',
                onSelect = function()
                    DeleteStashConfirm(stashId, stash)
                end
            }
        }
    })
    lib.showContext('stash_options_' .. stashId)
end


function EditStashMenu(stashId, stash)
    local input = lib.inputDialog('Edit Stash: ' .. (stash.label or "Stash"), {
        {
            type = 'input',
            label = 'Stash Name',
            default = stash.label or "Stash",
            required = true
        },
        {
            type = 'number',
            label = 'Slots',
            default = stash.slots or 50,
            min = 1,
            max = 200
        },
        {
            type = 'number',
            label = 'Weight Capacity',
            default = stash.weight or 100000,
            min = 1000,
            max = 1000000
        },
        {
            type = 'checkbox',
            label = 'Show Blip on Map',
            checked = stash.showBlip == true
        }
    })
    
    if not input then 
        MenuOpen = false
        return 
    end
    
    local updatedData = {
        id = stashId,
        label = input[1],
        slots = input[2],
        weight = input[3],
        showBlip = input[4] == true
    }
    
    TriggerServerEvent('rsg-stashcreator:server:UpdateStash', updatedData)
    MenuOpen = false
end


function DeleteStashConfirm(stashId, stash)
    local alert = lib.alertDialog({
        header = '⚠️ Delete Stash',
        content = 'Are you sure you want to delete **' .. (stash.label or "this stash") .. '**?\n\nThis cannot be undone and all items will be lost!',
        centered = true,
        cancel = true
    })
    
    if alert == 'confirm' then
        TriggerServerEvent('rsg-stashcreator:server:DeleteStash', stashId)
    end
    MenuOpen = false
end


function TogglePreviewMode()
    isCreatingStash = true
    MenuOpen = false
    
    lib.notify({
        title = 'Preview Mode Enabled',
        description = 'Walk to location, hold ENTER to create',
        type = 'info',
        duration = 5000
    })
end


RegisterNetEvent('rsg-stashcreator:client:StashCreated', function(stashId, stashData)
    if stashId and stashData then
        createdStashes[stashId] = stashData
        AddSingleBlip(stashId, stashData)
        
        lib.notify({
            title = 'Stash Created',
            description = 'Created: ' .. (stashData.label or "Stash"),
            type = 'success'
        })
    end
end)

RegisterNetEvent('rsg-stashcreator:client:StashUpdated', function(stashId, stashData)
    if stashId and stashData then
        createdStashes[stashId] = stashData
        RemoveSingleBlip(stashId)
        AddSingleBlip(stashId, stashData)
        
        lib.notify({
            title = 'Stash Updated',
            description = 'Updated: ' .. (stashData.label or "Stash"),
            type = 'success'
        })
    end
end)

RegisterNetEvent('rsg-stashcreator:client:StashDeleted', function(stashId)
    if stashId then
        RemoveSingleBlip(stashId)
        createdStashes[stashId] = nil
        
        lib.notify({
            title = 'Stash Deleted',
            type = 'success'
        })
    end
end)

RegisterNetEvent('rsg-stashcreator:client:SyncStashes', function(stashes)
   
    if stashes then
        createdStashes = stashes
        LoadAllBlips()
    end
end)

-- ============================================
-- COMMANDS
-- ============================================
RegisterCommand(Config.Command, function()
    OpenStashCreatorMenu()
end, false)

RegisterCommand('sc', function()
    ExecuteCommand(Config.Command)
end, false)

-- ============================================
-- CLEANUP ON RESOURCE STOP
-- ============================================
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if StashPrompt then
            PromptDelete(StashPrompt)
        end
        if CreatePrompt then
            PromptDelete(CreatePrompt)
        end
        if CancelPrompt then
            PromptDelete(CancelPrompt)
        end
        
        RemoveAllBlips()
    end
end)