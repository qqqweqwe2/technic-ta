-- HV extractor

minetest.register_craft({
	output = 'technic:hv_extractor',
	recipe = {
		{'technic:lv_extractor', 'technic:lv_extractor',   'technic:lv_extractor'},
		{'pipeworks:tube_1',              'technic:hv_transformer', 'pipeworks:tube_1'},
		{'technic:motor', 'technic:hv_cable',       'technic:chromium_block'},
	}
})

technic.register_extractor({tier = "HV", demand = {400, 300, 200}, speed = 4, upgrade = 1, tube = 1})
