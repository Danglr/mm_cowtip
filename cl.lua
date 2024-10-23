-- RedM Script to ragdoll a cow when colliding with it

-- Constants
local COW_MODEL = `a_c_cow` -- Let's hash this right away, so we arent running GetHashKey in a loop for the model check.
local DETECT_DISTANCE = 1.5 -- Distance to detect the cow
local RAGDOLL_TIME = 5000 -- Duration of the ragdoll effect in milliseconds

-- Main thread
CreateThread(function() -- Citizen.CreateThread = CreateThread
    while true do
        -- Slow down the interval A LOT, this is a very expensive loop operation. 
        -- This should be slow enough for a huge performance boost, while still being fast enough to detect cows player is running against.
        Wait(400)

        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)

        for _, entity in ipairs(GetGamePool('CPed')) do
            -- Let's add the model check here, so we don't have to loop through all entities AND check their distance before we make sure its actually a cow.
            -- I got rid of the IsPedAPlayer check since player's can't be cows (under normal circumstances).
            if GetEntityModel(entity) ~= COW_MODEL then
                -- Skip if the entity is a player or not a cow
                goto continue
            end

            local entityPos = GetEntityCoords(entity)
            local distance = #(playerPos - entityPos) -- This distance check is much, much faster.

            if distance < DETECT_DISTANCE then -- Here we only need to check the distance, since we already know we're dealing with a cow.
                -- Get the player's velocity
                local playerSpeed = GetEntitySpeed(playerPed) -- If we get the speed, we don't need to calculate magnitude on a vector.

                -- If the player is moving fast enough, ragdoll the cow
                if playerSpeed > 5.0 then
                    -- Let's get rid of the RagdollCow function since it only had one line of code after optimization.
                    SetPedToRagdoll(entity, RAGDOLL_TIME, RAGDOLL_TIME, 0, false, false, false)
                    -- Let's introduce a timeout because we don't need to keep checking for a while immediately after ragdolling the cow.
                    Wait(2000) -- Wait 2 seconds before continuing, and then break the for loop because we found our cow.
                    break
                end
            end

            ::continue::
        end
    end
end)
