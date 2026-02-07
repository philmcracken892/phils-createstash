local RSGCore = exports['rsg-core']:GetCoreObject()
local stashCache = {}


function IsPlayerAdmin(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local playerData = Player.PlayerData
    
    if RSGCore.Functions.HasPermission then
        if RSGCore.Functions.HasPermission(source, 'admin') then
            return true
        end
        if RSGCore.Functions.HasPermission(source, 'god') then
            return true
        end
    end
    
    if playerData.group then
        for _, group in ipairs(Config.AdminGroups) do
            if string.lower(tostring(playerData.group)) == string.lower(group) then
                return true
            end
        end
    end
    
    
    
    return false
end


RSGCore.Functions.CreateCallback('rsg-stashcreator:server:hasPermission', function(source, cb)
    cb(IsPlayerAdmin(source))
end)

RSGCore.Functions.CreateCallback('rsg-stashcreator:server:GetStashes', function(source, cb)
   
    cb(stashCache)
end)


function LoadStashesFromDB()
    stashCache = {} 
    
    local result = MySQL.query.await('SELECT * FROM custom_stashes')
    
    if result and #result > 0 then
        for _, row in ipairs(result) do
            local coords = json.decode(row.coords)
            
            
            local showBlip = false
            if row.show_blip == 1 or row.show_blip == true or row.show_blip == '1' then
                showBlip = true
            end
            
            stashCache[row.id] = {
                id = row.id,
                label = row.label,
                type = row.type or 'stash',
                slots = row.slots or 50,
                weight = row.weight or 100000,
                showBlip = showBlip,
                jobName = row.job_name,
                gangName = row.gang_name,
                coords = coords
            }
            
           
        end
        
    else
        
    end
end


CreateThread(function()
    Wait(1000)
    LoadStashesFromDB()
end)


RegisterNetEvent('rsg-stashcreator:server:openStash', function(stashName, stashData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local canAccess = true
    
    if stashData.type == 'job' then
        if Player.PlayerData.job.name ~= stashData.jobName then
            canAccess = false
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Access Denied',
                description = 'You do not have the required job',
                type = 'error'
            })
        end
    elseif stashData.type == 'gang' then
        if Player.PlayerData.gang.name ~= stashData.gangName then
            canAccess = false
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Access Denied',
                description = 'You are not in the required gang',
                type = 'error'
            })
        end
    end
    
    if canAccess then
        exports['rsg-inventory']:OpenInventory(src, stashName, {
            maxweight = stashData.weight or 100000,
            slots = stashData.slots or 50
        })
        
        
    end
end)


RegisterNetEvent('rsg-stashcreator:server:CreateStash', function(stashData)
    local src = source
    
    if not IsPlayerAdmin(src) then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'Access Denied',
            description = 'You are not authorized',
            type = 'error'
        })
    end
    
    local coordsJson = json.encode(stashData.coords)
    local showBlipInt = stashData.showBlip and 1 or 0
    
    MySQL.insert('INSERT INTO custom_stashes (label, type, slots, weight, show_blip, job_name, gang_name, coords) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        stashData.label,
        stashData.type,
        stashData.slots,
        stashData.weight,
        showBlipInt,
        stashData.jobName or nil,
        stashData.gangName or nil,
        coordsJson
    }, function(id)
        if id then
            stashData.id = id
            stashData.showBlip = stashData.showBlip == true -- Ensure boolean
            stashCache[id] = stashData
            
           
            TriggerClientEvent('rsg-stashcreator:client:StashCreated', src, id, stashData)
            
           
            TriggerClientEvent('rsg-stashcreator:client:SyncStashes', -1, stashCache)
            
           
        end
    end)
end)


RegisterNetEvent('rsg-stashcreator:server:UpdateStash', function(updatedData)
    local src = source
    
    if not IsPlayerAdmin(src) then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'Access Denied',
            description = 'You are not authorized',
            type = 'error'
        })
    end
    
    local stashId = updatedData.id
    local showBlipInt = updatedData.showBlip and 1 or 0
    
    MySQL.update('UPDATE custom_stashes SET label = ?, slots = ?, weight = ?, show_blip = ? WHERE id = ?', {
        updatedData.label,
        updatedData.slots,
        updatedData.weight,
        showBlipInt,
        stashId
    }, function(affectedRows)
        if affectedRows > 0 then
           
            if stashCache[stashId] then
                stashCache[stashId].label = updatedData.label
                stashCache[stashId].slots = updatedData.slots
                stashCache[stashId].weight = updatedData.weight
                stashCache[stashId].showBlip = updatedData.showBlip == true
            end
            
           
            TriggerClientEvent('rsg-stashcreator:client:StashUpdated', src, stashId, stashCache[stashId])
            
           
            TriggerClientEvent('rsg-stashcreator:client:SyncStashes', -1, stashCache)
            
            
        end
    end)
end)


RegisterNetEvent('rsg-stashcreator:server:DeleteStash', function(stashId)
    local src = source
    
    if not IsPlayerAdmin(src) then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'Access Denied',
            description = 'You are not authorized',
            type = 'error'
        })
    end
    
    local stashLabel = stashCache[stashId] and stashCache[stashId].label or 'Unknown'
    
    MySQL.query('DELETE FROM custom_stashes WHERE id = ?', {stashId}, function(result)
        if result then
            stashCache[stashId] = nil
            
            MySQL.query('DELETE FROM stashitems WHERE stash LIKE ?', {'stash_' .. stashId .. '%'})
            
           
            TriggerClientEvent('rsg-stashcreator:client:StashDeleted', src, stashId)
            
            
            TriggerClientEvent('rsg-stashcreator:client:SyncStashes', -1, stashCache)
            
           
        end
    end)
end)


RegisterNetEvent('rsg-stashcreator:server:MoveStash', function(stashId, newCoords)
    local src = source
    
    if not IsPlayerAdmin(src) then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'Access Denied',
            description = 'You are not authorized',
            type = 'error'
        })
    end
    
    local coordsJson = json.encode(newCoords)
    
    MySQL.update('UPDATE custom_stashes SET coords = ? WHERE id = ?', {
        coordsJson,
        stashId
    }, function(affectedRows)
        if affectedRows > 0 then
            if stashCache[stashId] then
                stashCache[stashId].coords = newCoords
            end
            
            
            TriggerClientEvent('rsg-stashcreator:client:SyncStashes', -1, stashCache)
            
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Stash Moved',
                description = 'Location updated successfully',
                type = 'success'
            })
        end
    end)
end)


RegisterNetEvent('RSGCore:Server:OnPlayerLoaded', function()
    local src = source
    Wait(2000) 
    TriggerClientEvent('rsg-stashcreator:client:SyncStashes', src, stashCache)
    
end)


exports('GetStashes', function()
    return stashCache
end)

exports('GetStashById', function(stashId)
    return stashCache[stashId]
end)

exports('ReloadStashes', function()
    LoadStashesFromDB()
    TriggerClientEvent('rsg-stashcreator:client:SyncStashes', -1, stashCache)
end)