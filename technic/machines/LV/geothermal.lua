-- A geothermal EU generator
-- Using hot lava and water this device can create energy from steam
-- The machine is only producing LV EUs and can thus not drive more advanced equipment
-- The output is a little more than the coal burning generator (max 300EUs)

minetest.register_alias("geothermal", "technic:geothermal")

technic.geothermal_supply_levels = {
	-- 1 water and 1 lava
	[11] = {
		production_level = 25,
		eu_supply = 200
	},
	-- 2 water and 1 lava
	[21] = {
		production_level = 50,
		eu_supply = 400
	},
	-- 3 water and 1 lava
	[31] = {
		production_level = 50,
		eu_supply = 500
	},
	-- 1 water and 2 lava
	[12] = {
		production_level = 75,
		eu_supply = 600

	},
	-- 1 water and 3 lava
	[13] = {
		production_level = 75,
		eu_supply = 700

	},
	-- 2 water and 2 lava
	[22] = {
		production_level = 100,
		eu_supply = 800
	}
}
local S = technic.getter
local mat = technic.materials

minetest.register_craft({
	output = 'technic:geothermal',
	recipe = {
		{'underch:granite',          mat.diamond,        'underch:granite'},
		{'basic_materials:copper_wire', 'technic:machine_casing', 'basic_materials:copper_wire'},
		{'underch:granite',          'technic:lv_cable',       'underch:granite'},
	},
	replacements = {
		{"basic_materials:copper_wire", "basic_materials:empty_spool"},
		{"basic_materials:copper_wire", "basic_materials:empty_spool"}
	},
})

minetest.register_craftitem("technic:geothermal", {
	description = S("Geothermal @1 Generator", S("LV")),
})

local check_node_around = function(pos)
	local node = minetest.get_node(pos)
	if node.name == mat.water_source or node.name == mat.water_flowing then return 1 end
	if node.name == mat.lava_source or node.name == mat.lava_flowing then return 2 end
	return 0
end

local run = function(pos, node)
	local meta             = minetest.get_meta(pos)
	local water_nodes      = 0
	local lava_nodes       = 0
	local supply_level = {
		production_level = 0,
		eu_supply = 0
	}

	-- Correct positioning is water on one side and lava on the other.
	-- The two cannot be adjacent because the lava the turns into obsidian or rock.
	-- To get to 100% production stack the water and lava one extra block down as well:
	--    WGL (W=Water, L=Lava, G=the generator, |=an LV cable)
	--    W|L

	local positions = {
		{x=pos.x+1, y=pos.y,   z=pos.z},
		{x=pos.x+1, y=pos.y-1, z=pos.z},
		{x=pos.x-1, y=pos.y,   z=pos.z},
		{x=pos.x-1, y=pos.y-1, z=pos.z},
		{x=pos.x,   y=pos.y,   z=pos.z+1},
		{x=pos.x,   y=pos.y-1, z=pos.z+1},
		{x=pos.x,   y=pos.y,   z=pos.z-1},
		{x=pos.x,   y=pos.y-1, z=pos.z-1},
	}
	for _, p in pairs(positions) do
		local check = check_node_around(p)
		if check == 1 then water_nodes = water_nodes + 1 end
		if check == 2 then lava_nodes  = lava_nodes  + 1 end
	end

	if technic.geothermal_supply_levels[water_nodes * 10 + lava_nodes] then
		supply_level = technic.geothermal_supply_levels[water_nodes * 10 + lava_nodes]
	end

	if supply_level.production_level > 0 then
		meta:set_int("LV_EU_supply", supply_level.eu_supply)
	end

	meta:set_string("infotext", S("@1 (@2% Efficiency)",
		S("Geothermal @1 Generator", S("LV")), supply_level.production_level))

	if supply_level.production_level > 0 and minetest.get_node(pos).name == "technic:geothermal" then
		technic.swap_node (pos, "technic:geothermal_active")
		return
	end
	if supply_level.production_level == 0 then
		technic.swap_node(pos, "technic:geothermal")
		meta:set_int("LV_EU_supply", 0)
	end
end

minetest.register_node("technic:geothermal", {
	description = S("Geothermal @1 Generator", S("LV")),
	tiles = {"technic_geothermal_top.png", "technic_machine_bottom.png", "technic_geothermal_side.png",
	         "technic_geothermal_side.png", "technic_geothermal_side.png", "technic_geothermal_side.png"},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2,
		technic_machine=1, technic_lv=1, axey=2, handy=1},
	_mcl_blast_resistance = 1,
	_mcl_hardness = 0.8,
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	sounds = technic.sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Geothermal @1 Generator", S("LV")))
		meta:set_int("LV_EU_supply", 0)
	end,
	technic_run = run,
})

minetest.register_node("technic:geothermal_active", {
	description = S("Geothermal @1 Generator", S("LV")),
	tiles = {"technic_geothermal_top_active.png", "technic_machine_bottom.png", "technic_geothermal_side.png",
	         "technic_geothermal_side.png", "technic_geothermal_side.png", "technic_geothermal_side.png"},
	paramtype2 = "facedir",
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2,
		technic_machine=1, technic_lv=1, not_in_creative_inventory=1, axey=2, handy=1},
	_mcl_blast_resistance = 1,
	_mcl_hardness = 0.8,
	legacy_facedir_simple = true,
	sounds = technic.sounds.node_sound_wood_defaults(),
	drop = "technic:geothermal",
	technic_run = run,
})

technic.register_machine("LV", "technic:geothermal",        technic.producer)
technic.register_machine("LV", "technic:geothermal_active", technic.producer)

