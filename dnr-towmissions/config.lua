Config = {}

Config.Debug = false

--- Flatbed Towing
Config.FlatbedTowing = {
	Enable = true,
	Command = "tow",
	Trucks = {
		["flatbed"] = {offset = vector3(0.0, -2.0, 0.8), boneName = "bodyshell"},
	},
	Blacklisted = {"flatbed", "towtruck", "cargobob"},
	Marker = {type = 20, scale = {x = 0.50, y = 0.50, z = 0.50}, color = {r = 240, g = 52, b = 52, a = 100}},
	Keybind = 47, -- default G
}

Config.Missions = {
    Enable = true,
    Reward = {min = 250, max = 500},
    RandomVehicles = {"sultan", "blista", "glendale", "exemplar"},
    RandomPeds = {"s_m_y_dealer_01", "a_m_m_indian_01", "a_m_m_polynesian_01"},
}
