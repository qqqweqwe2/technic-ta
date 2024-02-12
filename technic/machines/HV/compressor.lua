-- HV compressor
local S = technic.getter

minetest.register_craft({
	output = 'technic:hv_compressor',
	recipe = {
		{'technic:carbon_plate',          'technic:lv_compressor',   'technic:composite_plate'},
		{'technic:lv_compressor',              'technic:hv_transformer', 'technic:lv_compressor'},
		{'technic:stainless_steel_ingot', 'technic:hv_cable',       'technic:stainless_steel_ingot'},
	}
})

technic.register_base_machine("technic:hv_compressor", {
	typename = "compressing",
	description = S("@1 Compressor", S("HV")),
	tier = "HV",
	demand = {1500, 1000, 750},
	speed = 5,
	upgrade = 1,
	tube = 1
})
