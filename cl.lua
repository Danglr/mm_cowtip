-- RedM Script to ragdoll a cow when colliding with it

-- Constants
local COW_MODEL = "a_c_cow"
local DETECT_DISTANCE = 1.5 -- Distance to detect the cow
local RAGDOLL_TIME = 5000 -- Duration of the ragdoll effect in milliseconds

-- Function to check if the player is close to a cow
function IsNearCow()
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    
    -- Get a list of all nearby entities
    local entities = GetGamePool("CPed")
    
    for _, entity in ipairs(entities) do
        if IsPedAPlayer(entity) then
            -- Skip if the entity is a player
            goto continue
        end
        
        local entityPos = GetEntityCoords(entity)
        local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, entityPos.x, entityPos.y, entityPos.z)
        
        if distance < DETECT_DISTANCE and GetEntityModel(entity) == GetHashKey(COW_MODEL) then
            return entity
        end
        
        ::continue::
    end
    
    return nil
end

-- Function to apply ragdoll effect to the cow
function RagdollCow()
    local cow = IsNearCow()
    
    if cow then
        -- Set the cow to ragdoll
        SetPedToRagdoll(cow, RAGDOLL_TIME, RAGDOLL_TIME, 0, false, false, false)
    end
end

-- Main thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Check if the player is colliding with a cow
        local cow = IsNearCow()
        if cow then
            -- Get the player's velocity
            local playerPed = PlayerPedId()
            local playerVelocity = GetEntityVelocity(playerPed)
            
            -- If the player is moving fast enough, ragdoll the cow
            if Vmag(playerVelocity) > 5.0 then -- Adjust the speed threshold as needed
                RagdollCow()
            end
        end
    end
end)
