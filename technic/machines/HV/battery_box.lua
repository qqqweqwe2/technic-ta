-- HV battery box

minetest.register_craft({
	output = 'technic:hv_battery_box0',
	recipe = {
		{'technic:lv_battery_box0', 'technic:lv_battery_box0', 'technic:lv_battery_box0'},
		{'technic:lv_battery_box0', 'technic:hv_transformer',  'technic:lv_battery_box0'},
		{'',                        'technic:hv_cable',        ''},
	}
})

technic.register_battery_box("technic:hv_battery_box", {
	tier           = "HV",
	max_charge     = 200000,
	charge_rate    = 10000,
	discharge_rate = 40000,
	charge_step    = 1000,
	discharge_step = 4000,
	upgrade        = 1,
	tube           = 1,
})
