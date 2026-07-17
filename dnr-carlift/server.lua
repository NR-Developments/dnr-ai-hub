RegisterNetEvent("dnr-carlift:server:updateLift", function(liftId, state)
    TriggerClientEvent("dnr-carlift:client:syncLift", -1, liftId, state)
end)

RegisterNetEvent("dnr-carlift:server:deleteLift", function(liftId)
    TriggerClientEvent("dnr-carlift:client:deleteLift", -1, liftId)
end)
