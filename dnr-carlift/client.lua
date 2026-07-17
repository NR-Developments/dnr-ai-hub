local activeLifts = {}

--- Function to create a carlift
--- @param coords vector3
--- @param heading number
local function createCarLift(coords, heading)
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
    
    local liftId = #activeLifts + 1
    activeLifts[liftId] = {
        base = baseObj,
        arm = armObj,
        state = "stopped",
        height = 0.0
    }

    -- Add target options
    exports['qb-target']:AddTargetEntity(baseObj, {
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
                    TriggerServerEvent("dnr-carlift:server:deleteLift", liftId)
                end
            }
        },
        distance = 2.5
    })
end

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

RegisterCommand(Config.CarLift.Command, function()
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    createCarLift(coords, heading)
end, false)
