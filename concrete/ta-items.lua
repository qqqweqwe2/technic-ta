local technic = rawget(_G, "technic") or {}
technic.concrete_posts = {}

-- Boilerplate to support localized strings if intllib mod is installed.
local S = rawget(_G, "intllib") and intllib.Getter() or function(s) return s end

local steel_ingot
if minetest.get_modpath("technic_worldgen") then
	steel_ingot = "technic:carbon_steel_ingot"
else
	steel_ingot = "default:steel_ingot"
end

minetest.register_craft({
	output = 'technic:rebar 6',
	recipe = {
		{'','', steel_ingot},
		{'',steel_ingot,''},
		{steel_ingot, '', ''},
	}
})

minetest.register_craft({
	output = 'technic:concrete 5',
	recipe = {
		{'default:stone','technic:rebar','default:stone'},
		{'technic:rebar','default:stone','technic:rebar'},
		{'default:stone','technic:rebar','default:stone'},
	}
})

minetest.register_craft({
	output = 'technic:concrete_post_platform 6',
	recipe = {
		{'technic:concrete','technic:concrete_post','technic:concrete'},
	}
})

minetest.register_craft({
	output = 'technic:concrete_post 12',
	recipe = {
		{'default:stone','technic:rebar','default:stone'},
		{'default:stone','technic:rebar','default:stone'},
		{'default:stone','technic:rebar','default:stone'},
	}
})

minetest.register_craft({
	output = 'technic:blast_resistant_concrete 5',
	recipe = {
		{'technic:concrete','technic:composite_plate','technic:concrete'},
		{'technic:composite_plate','technic:concrete','technic:composite_plate'},
		{'technic:concrete','technic:composite_plate','technic:concrete'},
	}
})

minetest.register_craft({
	output = 'technic:reinforced_concrete 8',
	recipe = {
		{'technic:concrete','technic:composite_plate','technic:concrete'},
		{'technic:concrete','technic:uranium35_block','technic:concrete'},
		{'technic:concrete','technic:composite_plate','technic:concrete'},
	}
})

minetest.register_craft({
	output = 'technic:reinforced_concrete 6',
	recipe = {
		{'technic:concrete','technic:composite_plate','technic:concrete'},
		{'technic:concrete','technic:uranium_fuel','technic:concrete'},
		{'technic:concrete','technic:composite_plate','technic:concrete'},
	}
})


minetest.register_craftitem(":technic:rebar", {
	description = S("Rebar"),
	inventory_image = "technic_rebar.png",
})

minetest.register_node(":technic:concrete", {
	description = S("Concrete Block"),
	tiles = {"technic_concrete_block.png",},
	groups = {cracky=1, level=2, concrete=1},
	sounds = default.node_sound_stone_defaults(),
})
