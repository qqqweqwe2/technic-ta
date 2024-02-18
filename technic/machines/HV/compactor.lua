local S = technic.getter
-- HV compactor

minetest.register_craft({
	output = 'technic:hv_compactor',
	recipe = {
		{'technic:carbon_plate', 'underch:ruby_block', 'technic:carbon_plate'},
		{'pipeworks:autocrafter', 'underch:saphire_block', 'technic:hv_compressor'},
		{'ethereal:crystal_ingot', 'technic:hv_cable', 'ethereal:crystal_ingot'},
	}
})

technic.register_base_machine("technic:hv_compactor", {
	typename = "compacting",
	description = S("@1 Compactor", S("HV")),
	tier = "HV",
	demand = { 1500, 1000, 750 },
	speed = 5,
	upgrade = 1,
	tube = 1
})
