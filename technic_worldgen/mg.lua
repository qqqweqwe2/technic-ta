if technic.config:get_bool("enable_granite_generation") then
	mg.register_ore_sheet({
		name = "technic:granite",
		wherein = "default:stone",
		height_min = -31000,
		height_max = -150,
		tmin = 3,
		tmax = 6,
		threshhold = 0.4,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70}
	})
end

if technic.config:get_bool("enable_marble_generation") then
	mg.register_ore_sheet({
		name = "technic:marble",
		wherein = "default:stone",
		height_min = -31000,
		height_max = -50,
		tmin = 3,
		tmax = 6,
		threshhold = 0.4,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=23, octaves=3, persist=0.70}
	})
end
