-- The high voltage solar array is an assembly of medium voltage arrays.
-- Solar arrays are not able to store large amounts of energy.

minetest.register_craft({
	output = 'technic:hv_solar_array 1',
	recipe = {
		{'technic:lv_solar_array',     'technic:lv_solar_array', 'technic:lv_solar_array'},
		{'technic:lv_solar_array',     'technic:hv_transformer', 'technic:lv_solar_array'},
		{'',                           'technic:hv_cable',       ''},
	}
})

technic.register_solar_array("technic:hv_solar_array", {
	tier="HV",
	power=100
})

minetest.register_alias("technic:solar_array_hv", "technic:hv_solar_array")
