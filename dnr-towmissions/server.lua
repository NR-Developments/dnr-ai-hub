RegisterNetEvent("dnr-towmissions:server:payout", function()
    local src = source
    local amount = math.random(Config.Missions.Reward.min, Config.Missions.Reward.max)
    -- In a real framework you would add money here. 
    -- Since this is standalone, we just print or use a generic notification.
    print("Player " .. GetPlayerName(src) .. " received $" .. amount .. " for a tow mission.")
    TriggerClientEvent("ox_lib:notify", src, {description = "You earned $" .. amount, type = "success"})
end)
