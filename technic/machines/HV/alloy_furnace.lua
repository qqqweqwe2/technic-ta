-- HV alloy furnace
local S = technic.getter
local mat = technic.materials

minetest.register_craft({
	output = 'technic:hv_alloy_furnace',
	recipe = {
		{'technic:lv_alloy_furnace', 'technic:lv_alloy_furnace', 'technic:lv_alloy_furnace'},
		{'pipeworks:tube_1',              'technic:hv_transformer',   'pipeworks:tube_1'},
		{'technic:stainless_steel_ingot', 'technic:hv_cable',         'technic:stainless_steel_ingot'},
	}
})

technic.register_base_machine("technic:hv_alloy_furnace", {
	typename = "alloy",
	description = S("@1 Alloy Furnace", S("HV")),
	insert_object = technic.insert_object_unique_stack,
	can_insert = technic.can_insert_unique_stack,
	tier = "HV",
	speed = 3,
	demand = {2000}
})

