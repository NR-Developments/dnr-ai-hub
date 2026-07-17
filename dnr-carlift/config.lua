Config = {}

Config.Debug = false

Config.AceGroup = "admin" -- ACE group allowed to use /carlift command

Config.CarLift = {
    Model = {
        base = `t1ger_carlift_base`, -- model for carlift base
        arm = `t1ger_carlift_arms`, -- model for carlift arm
    },
	Command = "createlift", -- command to create a carlift
	Icons = { -- icons for target options on carlift
		["up"] = "fa-sharp fa-solid fa-arrow-up",
		["down"] = "fa-sharp fa-solid fa-arrow-down",
		["stop"] = "fa-regular fa-circle-stop",
		["delete"] = "fa-solid fa-ban"
	}
}
