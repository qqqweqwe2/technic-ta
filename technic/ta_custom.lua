local S = technic.getter

minetest.register_alias("basic_materials:aluminum_bar", "elements:aluminum_ingot")
minetest.register_alias("basic_materials:aluminum_strip", "elements:aluminum_ingot")
minetest.register_alias("basic_materials:aluminum_wire", "elements:aluminum_ingot")
minetest.register_alias("basic_materials:brass_block", "technic:brass_block") -- needs registered again in technic
minetest.register_alias("basic_materials:brass_ingot", "technic:brass_ingot") -- needs registered again in technic
minetest.register_alias("basic_materials:carbon_steel_bar", "technic:carbon_steel_ingot") 
minetest.register_alias("basic_materials:cement_block", "technic:concrete") -- needs registered again in technic
minetest.register_alias("basic_materials:chain_brass", "morelights_vintage:chain_b")
minetest.register_alias("basic_materials:chainlink_brass", "morelights_vintage:chain_b")
minetest.register_alias("basic_materials:chainlink_steel", "morelights:chain_l")
minetest.register_alias("basic_materials:chain_steel", "morelights:chain_l")
minetest.register_alias("basic_materials:concrete_block", "technic:concrete") -- needs registered again in technic
minetest.register_alias("basic_materials:copper_strip", "technic:fine_copper_wire") -- needs registered again in technic
minetest.register_alias("basic_materials:copper_wire", "technic:fine_copper_wire")
minetest.register_alias("basic_materials:empty_spool", "") -- ?? weird conflicts might happen, have to investigate
minetest.register_alias("basic_materials:energy_crystal_simple", "technic:red_energy_crystal")
minetest.register_alias("basic_materials:gear_steel", "technic:carbon_steel_ingot")
minetest.register_alias("basic_materials:gold_strip", "technic:fine_gold_wire")
minetest.register_alias("basic_materials:gold_wire", "technic:fine_gold_wire")
minetest.register_alias("basic_materials:heating_element", "technic:fine_copper_wire") -- just my idea
minetest.register_alias("basic_materials:ic", "technic:control_logic_unit") -- also my idea
minetest.register_alias("basic_materials:lead_strip", "technic:lead_ingot")
minetest.register_alias("basic_materials:motor", "technic:motor") -- needs registered again in technic
--minetest.register_alias("basic_materials:oil_extract", "") -- no alias needed here
minetest.register_alias("basic_materials:padlock", "keys:skeleton_key")
--minetest.register_alias("basic_materials:paraffin", "") -- no alias needed here
--minetest.register_alias("basic_materials:plastic_sheet", "") -- no alias needed here
minetest.register_alias("basic_materials:plastic_strip", "basic_materials:plastic_sheet")
minetest.register_alias("basic_materials:silicon", "technic:silicon_wafer")
minetest.register_alias("basic_materials:silver_wire", "technic:fine_silver_wire") -- needs registered again in technic
minetest.register_alias("basic_materials:stainless_steel_bar", "technic:stainless_steel_ingot")
minetest.register_alias("basic_materials:stainless_steel_strip", "technic:stainless_steel_ingot")
minetest.register_alias("basic_materials:stainless_steel_wire", "technic:stainless_steel_ingot")
minetest.register_alias("basic_materials:steel_bar", "default:steel_ingot")
minetest.register_alias("basic_materials:steel_strip", "default:steel_ingot")
minetest.register_alias("basic_materials:steel_wire", "default:steel_ingot")
minetest.register_alias("basic_materials:terracotta_base", "bakedclay:grey")
minetest.register_alias("basic_materials:wet_cement", "technic:concrete") -- needs registered again in technic

minetest.register_craftitem("technic:fine_copper_wire", {
	description = S("Fine Copper Wire"),
	inventory_image = "technic_fine_copper_wire.png",
})

minetest.register_craftitem("technic:fine_gold_wire", {
	description = S("Fine Gold Wire"),
	inventory_image = "technic_fine_gold_wire.png",
})

minetest.register_craftitem("technic:fine_silver_wire", {
	description = S("Fine Silver Wire"),
	inventory_image = "technic_fine_silver_wire.png",
})

minetest.register_craftitem("technic:motor", {
	description = S("Electric Motor"),
	inventory_image = "technic_motor.png",
})

minetest.clear_craft({
    output = "technic:fine_copper_wire"
})

minetest.clear_craft({
    output = "technic:fine_gold_wire"
})

minetest.clear_craft({
    output = "technic:fine_silver_wire"
})

minetest.register_craft({
	output = 'technic:fine_copper_wire 2',
	recipe = {
		{'', 'default:copper_ingot', ''},
		{'', 'default:copper_ingot', ''},
		{'', 'default:copper_ingot', ''},
	}
})

minetest.register_craft({
	output = 'technic:fine_gold_wire 2',
	recipe = {
		{'', 'default:gold_ingot', ''},
		{'', 'default:gold_ingot', ''},
		{'', 'default:gold_ingot', ''},
	}
})

minetest.register_craft({
	output = 'technic:fine_silver_wire 2',
	recipe = {
		{'', 'moreores:silver_ingot', ''},
		{'', 'moreores:silver_ingot', ''},
		{'', 'moreores:silver_ingot', ''},
	}
})

minetest.register_craft({
	output = 'technic:motor',
	recipe = {
		{'technic:carbon_steel_ingot', 'technic:copper_coil', 'technic:carbon_steel_ingot'},
		{'technic:carbon_steel_ingot', 'technic:copper_coil', 'technic:carbon_steel_ingot'},
		{'technic:carbon_steel_ingot', 'default:copper_ingot', 'technic:carbon_steel_ingot'},
	}
})
