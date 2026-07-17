local towing = {inUse = false, truck = nil, vehicle = nil}
local activeMission = nil
local missionBlip = nil
local dropoffBlip = nil
local missionVehicle = nil

---Returns whether the vehicle is a valid tow truck or not
local function IsVehicleTowTruck(towtruck)
	if not DoesEntityExist(towtruck) or not IsEntityAVehicle(towtruck) then return false end
	for model, data in pairs(Config.FlatbedTowing.Trucks) do
		if GetHashKey(model) == GetEntityModel(towtruck) then return true end
	end
	return false
end
exports("IsVehicleTowTruck", IsVehicleTowTruck)

local function GetTowTruckData(towtruck)
	for model, data in pairs(Config.FlatbedTowing.Trucks) do
		if GetHashKey(model) == GetEntityModel(towtruck) then return data end
	end
end

local function VehicleIsBlacklistedForTowing(vehicle)
	for _, model in pairs(Config.FlatbedTowing.Blacklisted) do
		if GetHashKey(model) == GetEntityModel(vehicle) then return true end
	end
	return false
end

local function GetClosestTowTruck(dist)
	local ped = PlayerPedId()
	local towtruck = GetVehiclePedIsIn(ped, false)
	if not towtruck or towtruck == 0 then
		towtruck = lib.getClosestVehicle(GetEntityCoords(ped), dist or 4.0, false)
	end
	if not IsVehicleTowTruck(towtruck) then return end
	return towtruck
end

function AttachVehicle(attachCoords)
	if not towing.truck or not IsVehicleTowTruck(towing.truck) then return end
	if towing.vehicle then return end
	
	local vehicle = lib.getClosestVehicle(attachCoords, 2.0, false)
	if not vehicle or not DoesEntityExist(vehicle) then 
        lib.notify({description = "No vehicle nearby to attach", type = "error"})
        return 
    end

	if VehicleIsBlacklistedForTowing(vehicle) then
        lib.notify({description = "This vehicle cannot be towed", type = "error"})
        return 
    end

	local truckData = GetTowTruckData(towing.truck)
	local boneIndex = GetEntityBoneIndexByName(towing.truck, truckData.boneName)
	
	AttachEntityToEntity(vehicle, towing.truck, boneIndex, truckData.offset.x, truckData.offset.y, truckData.offset.z, 0, 0, 0, 1, 1, 0, 1, 0, 1)
	return vehicle
end

function TowVehicle()
	local towtruck = GetClosestTowTruck(4.0)
	if not towtruck then
        lib.notify({description = "No tow truck nearby", type = "error"})
		return
	end

	towing.truck = towtruck
	towing.model = GetEntityModel(towtruck)
	towing.inUse = true

    lib.notify({description = "Head to the back of the truck to manage towing", type = "inform"})

	while towing.inUse do
		Wait(1)
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		local min, max = GetModelDimensions(towing.model)
		local attachCoords = GetOffsetFromEntityInWorldCoords(towtruck, 0.0, (min.y - 3.0), 0.0)
		local truckCoords = GetOffsetFromEntityInWorldCoords(towtruck, (min.x-0.05), (min.y + 1.0), 0.0)
		local truckDist = #(coords - truckCoords)

		if truckDist < 10.0 then
			if not towing.vehicle then
				if truckDist < 1.5 then
					lib.showTextUI("[G] Attach Vehicle")
					if IsControlJustPressed(0, Config.FlatbedTowing.Keybind) then
						towing.vehicle = AttachVehicle(attachCoords)
						if towing.vehicle then 
                            lib.hideTextUI()
                            towing.inUse = false 
                        end
					end
				else
                    lib.hideTextUI()
                end
			else
				if truckDist < 1.5 then
					lib.showTextUI("[G] Detach Vehicle")
					if IsControlJustPressed(0, Config.FlatbedTowing.Keybind) then
						DetachEntity(towing.vehicle)
						SetEntityCoords(towing.vehicle, attachCoords.x, attachCoords.y, attachCoords.z, 1, 0, 0, 1)
						SetVehicleOnGroundProperly(towing.vehicle)
						towing.vehicle = nil
						towing.inUse = false
                        lib.hideTextUI()
					end
				else
                    lib.hideTextUI()
                end
			end
		end

		if truckDist > 20.0 then
			towing.inUse = false
            lib.hideTextUI()
		end
	end
end

RegisterCommand(Config.FlatbedTowing.Command, function()
    if not towing.inUse then TowVehicle() else towing.inUse = false end
end, false)

--- Mission Logic
local function CancelMission()
    if not activeMission then return end
    if DoesEntityExist(missionVehicle) then DeleteVehicle(missionVehicle) end
    if DoesBlipExist(missionBlip) then RemoveBlip(missionBlip) end
    if DoesBlipExist(dropoffBlip) then RemoveBlip(dropoffBlip) end
    activeMission = nil
    missionVehicle = nil
    lib.notify({description = "Mission cancelled", type = "inform"})
end

local function StartTowMission()
    if activeMission then return lib.notify({description = "You already have an active mission", type = "error"}) end
    
    local missionId = math.random(1, #Missions["breakdown"])
    local data = Missions["breakdown"][missionId]
    
    activeMission = data
    missionBlip = AddBlipForCoord(data.pos.x, data.pos.y, data.pos.z)
    SetBlipSprite(missionBlip, 1)
    SetBlipColour(missionBlip, 5)
    SetBlipRoute(missionBlip, true)
    
    lib.notify({description = "A vehicle has broken down. Go to the location and tow it to the dropoff.", type = "inform"})
    
    CreateThread(function()
        local vehicleModel = Config.Missions.RandomVehicles[math.random(1, #Config.Missions.RandomVehicles)]
        lib.requestModel(vehicleModel)
        missionVehicle = CreateVehicle(vehicleModel, data.pos.x, data.pos.y, data.pos.z, data.pos.w, true, false)
        
        while activeMission do
            local wait = 1000
            local pedCoords = GetEntityCoords(PlayerPedId())
            if #(pedCoords - vector3(data.pos.x, data.pos.y, data.pos.z)) < 20.0 then
                if DoesBlipExist(missionBlip) then RemoveBlip(missionBlip) end
                dropoffBlip = AddBlipForCoord(data.dropoff.x, data.dropoff.y, data.dropoff.z)
                SetBlipSprite(dropoffBlip, 1)
                SetBlipColour(dropoffBlip, 2)
                SetBlipRoute(dropoffBlip, true)
                
                while activeMission do
                    Wait(1000)
                    if not DoesEntityExist(missionVehicle) then
                        CancelMission()
                        return
                    end
                    local vehCoords = GetEntityCoords(missionVehicle)
                    if #(vehCoords - data.dropoff) < 10.0 and not IsEntityAttached(missionVehicle) then
                        lib.notify({description = "Mission complete!", type = "success"})
                        TriggerServerEvent("dnr-towmissions:server:payout")
                        if DoesBlipExist(dropoffBlip) then RemoveBlip(dropoffBlip) end
                        activeMission = nil
                        Wait(5000)
                        if DoesEntityExist(missionVehicle) then DeleteVehicle(missionVehicle) end
                        missionVehicle = nil
                        return
                    end
                end
            end
            Wait(wait)
        end
    end)
end

local function OpenTowMenu()
    lib.registerContext({
        id = 'tow_mission_menu',
        title = 'Tow Trucker Missions',
        options = {
            {
                title = 'Request Job',
                description = 'Receive a new breakdown callout',
                icon = 'truck-pickup',
                disabled = activeMission ~= nil,
                onSelect = function()
                    StartTowMission()
                end
            },
            {
                title = 'Cancel Job',
                description = 'Abandon your current mission',
                icon = 'ban',
                disabled = activeMission == nil,
                onSelect = function()
                    CancelMission()
                end
            }
        }
    })
    lib.showContext('tow_mission_menu')
end

RegisterCommand("towmenu", function()
    OpenTowMenu()
end, false)

RegisterCommand("starttow", function()
    StartTowMission()
end, false)
