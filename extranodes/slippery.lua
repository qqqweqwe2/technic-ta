local S = rawget(_G, "intllib") and intllib.Getter() or function(s) return s end

-- The slippery levels are chosen such that, starting from ice, it multiplies
-- the absolute slipperiness by 6.3 in three steps to reach the maximum of 0.001
-- ("friction"). Absolute slipperiness is calculated by 1/(1+x), ice has x = 3 and
-- as such 0.25 absolute slipperiness. Our values are calculated by solving for x
-- in 1/(1+x) = 0.25*6.3^-level.
local levels = {
	{
		name = S("Basic Slippery Aluminum"),
		slippery = 24,
	},
	{
		name = S("Super Slippery Aluminum"),
		slippery = 158,
	},
	{
		name = S("Ultra Slippery Aluminum"),
		-- For player movement this is equivalent to 999.
		-- Items have a slightly different formula so we choose the maximum possible
		-- value.
		slippery = 32767,
	}
}

-- We need this to be available
assert(technic.alternate_paintable_nodes)

local base_item = "elements:aluminum_block"
local base_name = "extranodes:slippery_aluminum_"
local oil_item = "homedecor:oil_extract"

for i, data in ipairs(levels) do
	local name = base_name .. i
	
	minetest.register_node(name, {
		description = data.name,
		tiles = {
			{
				name = "technic_slippery_aluminum_" .. i .. ".png",
				align_style = "world",
				scale = 2
			},
		},
		is_ground_content = false,
		groups = {cracky = 1, level = 2, slippery = data.slippery},
		sounds = default.node_sound_metal_defaults(),
	})

	technic.make_alternate_paintable(name)

	local upper = name
	local lower
	if i > 1 then
		lower = base_name .. (i - 1)
	elseif i == 1 then
		lower = base_item
	end

	-- Burn off one layer of oil
	minetest.register_craft({
		type = "cooking",
		cooktime = 2,
		output = lower,
		recipe = upper,
	})

	-- Coat node in one layer of oil
	minetest.register_craft({
		output = upper,
		recipe = {
			{ oil_item, oil_item, oil_item },
			{ oil_item, lower, oil_item },
			{ oil_item, oil_item, oil_item },
		}
	})
end
