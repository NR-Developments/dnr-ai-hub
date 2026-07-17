MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `dnr_carlifts` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `coords` longtext NOT NULL,
            `heading` float NOT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])
end)

local function getLifts()
    local lifts = MySQL.query.await("SELECT * FROM dnr_carlifts")
    for _, lift in ipairs(lifts) do
        local coords = json.decode(lift.coords)
        TriggerClientEvent("dnr-carlift:client:spawnLift", -1, vector3(coords.x, coords.y, coords.z), lift.heading, lift.id)
    end
end

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(1000)
    getLifts()
end)

RegisterNetEvent("dnr-carlift:server:createLiftDB", function(coords, heading)
    local src = source
    if not IsPlayerAceAllowed(src, "command.carlift") then return end
    
    local id = MySQL.insert.await("INSERT INTO dnr_carlifts (coords, heading) VALUES (?, ?)", {
        json.encode({x = coords.x, y = coords.y, z = coords.z}),
        heading
    })
    
    if id then
        TriggerClientEvent("dnr-carlift:client:spawnLift", -1, coords, heading, id)
    end
end)

RegisterNetEvent("dnr-carlift:server:deleteLiftDB", function(dbId)
    local src = source
    if not IsPlayerAceAllowed(src, "command.carlift") then return end

    MySQL.query.await("DELETE FROM dnr_carlifts WHERE id = ?", {dbId})
    TriggerClientEvent("dnr-carlift:client:deleteLift", -1, dbId)
end)

RegisterNetEvent("dnr-carlift:server:updateLift", function(liftId, state)
    TriggerClientEvent("dnr-carlift:client:syncLift", -1, liftId, state)
end)

RegisterNetEvent("dnr-carlift:server:deleteLift", function(liftId)
    TriggerClientEvent("dnr-carlift:client:deleteLift", -1, liftId)
end)

RegisterCommand("carlift", function(source, args, raw)
    if source == 0 or IsPlayerAceAllowed(source, "command.carlift") then
        TriggerClientEvent("dnr-carlift:client:openMenu", source)
    end
end, false)
