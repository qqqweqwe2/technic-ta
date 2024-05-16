-- Minetest 0.4.6 mod: extranodes
-- namespace: technic
-- Boilerplate to support localized strings if intllib mod is installed.
local S = rawget(_G, "intllib") and intllib.Getter() or function(s) return s end

local path = minetest.get_modpath("extranodes")

-----------------------------------------------------------------------------------------
--                           Introducing Extra Stuff
-----------------------------------------------------------------------------------------
dofile(path.."/aspirin.lua")
dofile(path.."/trampoline.lua")
dofile(path.."/extratubes.lua")
dofile(path.."/extramesecons.lua")
--dofile(path.."/lox.lua")
dofile(path.."/plastic_block.lua")
--dofile(path.."/diamonds.lua")
dofile(path.."/insulator_clips.lua")
dofile(path.."/cottonseed_oil.lua")

if minetest.get_modpath("ethereal") and minetest.get_modpath("flowers") then
	dofile(path.."/antishroom.lua")
end


-----------------------------------------------------------------------------------------
--                           Compatibility Stuff and Co
-----------------------------------------------------------------------------------------

if minetest.get_modpath("bakedclay") then
	-- bring back them sticks
	minetest.register_craft( {
		type = "shapeless",
		output = "default:stick",
		recipe = {"default:dry_shrub"}
	})
end

-- register procedurally-generated arcs
if minetest.get_modpath("pkarcs") then
	pkarcs.register_node("technic:marble")
	pkarcs.register_node("technic:marble_bricks")
	if technic.config:get_bool("enable_granite_generation") then
		pkarcs.register_node(technic.extranodes.granite)
	end
end

if minetest.get_modpath("moreblocks") then

	-- register stairsplus/circular_saw nodes
	-- we skip blast resistant concrete and uranium intentionally
	-- chrome seems to be too hard of a metal to be actually sawable

	stairsplus:register_all("technic", "marble", "technic:marble", {
		description=S("Marble"),
		groups={cracky=3, not_in_creative_inventory=1},
		tiles={"technic_marble.png"},
	})

	stairsplus:register_all("technic", "marble_bricks", "technic:marble_bricks", {
		description=S("Marble Bricks"),
		groups={cracky=3, not_in_creative_inventory=1},
		tiles={"technic_marble_bricks.png"},
	})

	if technic.config:get_bool("enable_granite_generation") then
		stairsplus:register_all("technic", "granite", technic.extranodes.granite, {
			description = S("Granite"),
			groups = { cracky = 1, not_in_creative_inventory = 1 },
			tiles = { "technic_granite.png" },
		})

		stairsplus:register_all("technic", "granite_bricks", "technic:granite_bricks", {
			description = S("Granite Bricks"),
			groups = { cracky = 1, not_in_creative_inventory = 1 },
			tiles = { "technic_granite_bricks.png" },
		})
	end
	stairsplus:register_all("technic", "concrete", "technic:concrete", {
		description=S("Concrete"),
		groups={cracky=3, not_in_creative_inventory=1},
		tiles={"basic_materials_concrete_block.png"},
	})

	stairsplus:register_all("technic", "zinc_block", "technic:zinc_block", {
		description=S("Zinc Block"),
		groups={cracky=1, not_in_creative_inventory=1},
		tiles={"technic_zinc_block.png"},
	})

	stairsplus:register_all("technic", "cast_iron_block", "technic:cast_iron_block", {
		description=S("Cast Iron Block"),
		groups={cracky=1, not_in_creative_inventory=1},
		tiles={"technic_cast_iron_block.png"},
	})

	stairsplus:register_all("technic", "carbon_steel_block", "technic:carbon_steel_block", {
		description=S("Carbon Steel Block"),
		groups={cracky=1, not_in_creative_inventory=1},
		tiles={"technic_carbon_steel_block.png"},
	})

	stairsplus:register_all("technic", "stainless_steel_block", "technic:stainless_steel_block", {
		description=S("Stainless Steel Block"),
		groups={cracky=1, not_in_creative_inventory=1},
		tiles={"technic_stainless_steel_block.png"},
	})

	stairsplus:register_all("technic", "brass_block", "technic:brass_block", {
		description=S("Brass Block"),
		groups={cracky=1, not_in_creative_inventory=1},
		tiles={"technic_brass_block.png"},
	})

	function register_technic_stairs_alias(origmod, origname, newmod, newname)
		local func = minetest.register_alias
		local function remap(kind, suffix)
			-- Old: stairsplus:slab_concrete_wall
			-- New:    technic:slab_concrete_wall
			func(("%s:%s_%s%s"):format(origmod, kind, origname, suffix),
				("%s:%s_%s%s"):format(newmod, kind, newname, suffix))
		end

		-- Slabs
		remap("slab", "")
		remap("slab", "_inverted")
		remap("slab", "_wall")
		remap("slab", "_quarter")
		remap("slab", "_quarter_inverted")
		remap("slab", "_quarter_wall")
		remap("slab", "_three_quarter")
		remap("slab", "_three_quarter_inverted")
		remap("slab", "_three_quarter_wall")

		-- Stairs
		remap("stair", "")
		remap("stair", "_inverted")
		remap("stair", "_wall")
		remap("stair", "_wall_half")
		remap("stair", "_wall_half_inverted")
		remap("stair", "_half")
		remap("stair", "_half_inverted")
		remap("stair", "_right_half")
		remap("stair", "_right_half_inverted")
		remap("stair", "_inner")
		remap("stair", "_inner_inverted")
		remap("stair", "_outer")
		remap("stair", "_outer_inverted")

		-- Other
		remap("panel", "_bottom")
		remap("panel", "_top")
		remap("panel", "_vertical")
		remap("micro", "_bottom")
		remap("micro", "_top")
	end

	register_technic_stairs_alias("stairsplus", "concrete", "technic", "concrete")
	register_technic_stairs_alias("stairsplus", "marble", "technic", "marble")
	if technic.config:get_bool("enable_granite_generation") then
		register_technic_stairs_alias("stairsplus", "granite", "technic", "granite")
	end
	register_technic_stairs_alias("stairsplus", "marble_bricks", "technic", "marble_bricks")

end
