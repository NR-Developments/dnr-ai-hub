local activeLifts = {}

--- Function to create a carlift
--- @param coords vector3
--- @param heading number
--- @param dbId? number
local function createCarLift(coords, heading, dbId)
    local baseModel = Config.CarLift.Model.base
    local armModel = Config.CarLift.Model.arm

    lib.requestModel(baseModel)
    lib.requestModel(armModel)

    local baseObj = CreateObject(baseModel, coords.x, coords.y, coords.z, true, false, false)
    SetEntityHeading(baseObj, heading)
    FreezeEntityPosition(baseObj, true)

    local armObj = CreateObject(armModel, coords.x, coords.y, coords.z, true, false, false)
    SetEntityHeading(armObj, heading)
    -- Arms usually start at the base level or slightly offset
    
    local liftId = dbId or (#activeLifts + 1)
    activeLifts[liftId] = {
        base = baseObj,
        arm = armObj,
        state = "stopped",
        height = 0.0,
        dbId = dbId
    }

    -- Add target options
    exports["qb-target"]:AddTargetEntity(baseObj, {
        options = {
            {
                label = "Lift Up",
                icon = Config.CarLift.Icons["up"],
                action = function()
                    TriggerServerEvent("dnr-carlift:server:updateLift", liftId, "up")
                end
            },
            {
                label = "Lift Down",
                icon = Config.CarLift.Icons["down"],
                action = function()
                    TriggerServerEvent("dnr-carlift:server:updateLift", liftId, "down")
                end
            },
            {
                label = "Stop Lift",
                icon = Config.CarLift.Icons["stop"],
                action = function()
                    TriggerServerEvent("dnr-carlift:server:updateLift", liftId, "stop")
                end
            },
            {
                label = "Delete Lift",
                icon = Config.CarLift.Icons["delete"],
                action = function()
                    if dbId then
                        TriggerServerEvent("dnr-carlift:server:deleteLiftDB", dbId)
                    else
                        TriggerServerEvent("dnr-carlift:server:deleteLift", liftId)
                    end
                end
            }
        },
        distance = 2.5
    })
end

RegisterNetEvent("dnr-carlift:client:spawnLift", function(coords, heading, dbId)
    createCarLift(coords, heading, dbId)
end)

RegisterNetEvent("dnr-carlift:client:syncLift", function(liftId, state)
    if activeLifts[liftId] then
        activeLifts[liftId].state = state
    end
end)

RegisterNetEvent("dnr-carlift:client:deleteLift", function(liftId)
    if activeLifts[liftId] then
        DeleteObject(activeLifts[liftId].base)
        DeleteObject(activeLifts[liftId].arm)
        activeLifts[liftId] = nil
    end
end)

CreateThread(function()
    while true do
        local wait = 1000
        for id, lift in pairs(activeLifts) do
            if lift.state == "up" and lift.height < 1.5 then
                wait = 0
                lift.height = lift.height + 0.01
                local coords = GetEntityCoords(lift.base)
                SetEntityCoords(lift.arm, coords.x, coords.y, coords.z + lift.height, false, false, false, false)
            elseif lift.state == "down" and lift.height > 0.0 then
                wait = 0
                lift.height = lift.height - 0.01
                local coords = GetEntityCoords(lift.base)
                SetEntityCoords(lift.arm, coords.x, coords.y, coords.z + lift.height, false, false, false, false)
            end
        end
        Wait(wait)
    end
end)

-- Menu feature
local function openLiftMenu()
    lib.registerContext({
        id = "dnr_carlift_menu",
        title = "Car Lift Management",
        options = {
            {
                title = "Create Persistent Lift",
                description = "Spawn a car lift at your current position",
                icon = "plus",
                onSelect = function()
                    local coords = GetEntityCoords(cache.ped)
                    local heading = GetEntityHeading(cache.ped)
                    TriggerServerEvent("dnr-carlift:server:createLiftDB", coords, heading)
                end
            },
            {
                title = "Create Temporary Lift",
                description = "Spawn a car lift that disappears on restart",
                icon = "wrench",
                onSelect = function()
                    local coords = GetEntityCoords(cache.ped)
                    local heading = GetEntityHeading(cache.ped)
                    createCarLift(coords, heading)
                end
            }
        }
    })
    lib.showContext("dnr_carlift_menu")
end

RegisterNetEvent("dnr-carlift:client:openMenu", function()
    openLiftMenu()
end)

RegisterCommand("carlift", function()
    -- Admin check handled by command restriction/server-side
end, false)
