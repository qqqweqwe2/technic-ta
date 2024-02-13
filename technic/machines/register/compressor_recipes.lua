
local S = technic.getter
local mat = technic.materials
local has_mcl = minetest.get_modpath("mcl_core")

technic.register_recipe_type("compressing", {
	description = S("Compressing"),
	icon = "technic_hv_compressor_front.png",
})

function technic.register_compressor_recipe(data)
	data.time = data.time or 4
	technic.register_recipe("compressing", data)
end

local recipes = {
	{"default:snowblock",          "default:ice"},
	{"default:sand 2",             "default:sandstone"},
	{"default:desert_sand 2",      "default:desert_sandstone"},
	{"default:silver_sand 2",      "default:silver_sandstone"},
--	for consistency, any sand should be compressed into respective sandstone type
	{"default:desert_sand 2",      "default:desert_sandstone"},
	{"technic:mixed_metal_ingot",  "technic:composite_plate"},
	{"default:copper_ingot 5",     "technic:copper_plate"},
	{"technic:coal_dust 4",        "technic:graphite"},
	{"technic:carbon_cloth",       "technic:carbon_plate"},
	{"technic:uranium35_ingot 5",  "technic:uranium_fuel"},
	{"technic:sulfur_dust 2", "technic:sulfur_lump"},
--	{"technic:diamond_seed 25",    "default:diamond"}
}

if minetest.get_modpath("ethereal") then

	-- substitute for old recipe chain
	-- instead of 5 dry dirt -> 1 desert sand -> compressing -> desert_stone
	table.insert(recipes, {"ethereal:dry_dirt 5", "default:desert_stone"})
	
	-- compressing most copious leaves into more compact fuel
	-- this conversion is based on the burn time (1 vs. 10) + some overhead
	table.insert(recipes, {"group:leaves 15", "ethereal:charcoal_lump 1"})

	-- the density of charcoal is ~1/10 of coal, otherwise it's pure carbon
	table.insert(recipes, {"ethereal:charcoal_lump 10", "default:coal_lump 1"})
	
	if minetest.get_modpath("technic_worldgen") or minetest.get_modpath("moretrees") then
		table.insert(recipes, {"moretrees:rubber_tree_leaves 15", "ethereal:charcoal_lump 1"})
	end

end

for _, data in pairs(recipes) do
	technic.register_compressor_recipe({input = {data[1]}, output = data[2]})
end

