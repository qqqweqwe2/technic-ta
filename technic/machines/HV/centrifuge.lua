local S = technic.getter
minetest.register_craft({
	output = "technic:hv_centrifuge",
	recipe = {
		{"technic:motor",          "technic:copper_plate",   "technic:diamond_drill_head"},
		{"default:diamondblock",   "technic:machine_casing", "default:diamondblock"      },
		{"pipeworks:one_way_tube", "technic:hv_cable",       "pipeworks:mese_filter"     },
	}
})

technic.register_base_machine("technic:hv_centrifuge", {
	typename = "separating",
	description = S("@1 Centrifuge", S("HV")),
	tier = "HV",
	demand = { 6000, 5500, 5000 },
	speed = 4,
	upgrade = 1,
	tube = 1
})
