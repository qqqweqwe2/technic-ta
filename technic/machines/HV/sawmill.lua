
minetest.register_craft({
	output = 'technic:hv_sawmill',
	recipe = {
		{'default:diamond', 'default:diamond', 'default:diamond'},
		{'technic:water_jumbo_can', 'technic:lv_sawmill', 'technic:motor'},
		{'technic:carbon_steel_ingot', 'technic:hv_cable', 'technic:carbon_steel_ingot'},
	},
})

technic.register_sawmill({
	tier = "HV",
	demand = {1500, 1125, 750},
	speed = 5,
	node_box = {
		type = "fixed",
		fixed = {
			{-3/32, 14/32, -1/32, 3/32, 15/32, 1/32},
			{-6/32, 13/32, -1/32, 6/32, 14/32, 1/32},
			{-8/32, 12/32, -1/32, 8/32, 13/32, 1/32},
			{-9/32, 11/32, -1/32, 9/32, 12/32, 1/32},
			{-10/32, 10/32, -1/32, 10/32, 11/32, 1/32},
			{-11/32, 9/32, -1/32, 11/32, 10/32, 1/32},
			{-12/32, 7/32, -1/32, 12/32, 9/32, 1/32},
			{-1/2, -1/2, -1/2, 1/2, 7/32, 1/2},
		},
	},
	tiles = {nil,nil,nil,nil,"_back",nil},
	upgrade = 1,
	tube = 1,
	tube_sides = {nil, true, true, true, true}
})

minetest.after(0.1, function()
minetest.override_item("technic:hv_sawmill", {
    drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-3/32, 14/32, -1/32, 3/32, 15/32, 1/32},
			{-6/32, 13/32, -1/32, 6/32, 14/32, 1/32},
			{-8/32, 12/32, -1/32, 8/32, 13/32, 1/32},
			{-9/32, 11/32, -1/32, 9/32, 12/32, 1/32},
			{-10/32, 10/32, -1/32, 10/32, 11/32, 1/32},
			{-11/32, 9/32, -1/32, 11/32, 10/32, 1/32},
			{-12/32, 7/32, -1/32, 12/32, 9/32, 1/32},
			{-1/2, -1/2, -1/2, 1/2, 7/32, 1/2},
		},
	},
    tiles = {"technic_hv_sawmill_top.png","technic_hv_sawmill_bottom.png","technic_hv_sawmill_side.png","technic_hv_sawmill_side.png","technic_hv_sawmill_back.png","technic_hv_sawmill_front.png"},
})
end)
