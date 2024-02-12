minetest.register_craft({
	output = "technic:hv_thresher",
	recipe = {
		{'technic:stainless_steel_ingot', 'technic:motor',          'technic:stainless_steel_ingot'},
		{'pipeworks:tube_1',              'technic:machine_casing', 'pipeworks:tube_1'},
		{'technic:stainless_steel_ingot', 'technic:hv_cable',       'technic:stainless_steel_ingot'},
	}
})

technic.register_thresher({
	tier = "HV",
	demand = {700, 500, 350},
	speed = 4,
	upgrade = 1,
	tube = 1,
})
