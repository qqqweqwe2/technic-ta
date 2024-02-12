-- NONRadioactive materials that can result from destroying a reactor
local griefing = technic.config:get_bool("enable_corium_griefing")

local S = technic.getter

for _, state in pairs({"flowing", "source"}) do
	minetest.register_node("technic:corium_"..state, {
		description = S(state == "source" and "Corium Source" or "Flowing Corium"),
		drawtype = (state == "source" and "liquid" or "flowingliquid"),
		tiles = {{
			name = "technic_corium_"..state.."_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		}},
		special_tiles = {
			{
				name = "technic_corium_"..state.."_animated.png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 3.0,
				},
			},
			{
				name = "technic_corium_"..state.."_animated.png",
				backface_culling = true,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 3.0,
				},
			},
		},
		paramtype = "light",
		paramtype2 = (state == "flowing" and "flowingliquid" or nil),
		light_source = (state == "source" and 8 or 5),
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		drop = "",
		drowning = 1,
		liquidtype = state,
		liquid_alternative_flowing = "technic:corium_flowing",
		liquid_alternative_source = "technic:corium_source",
		liquid_viscosity = LAVA_VISC,
		liquid_renewable = false,
		liquid_range = 1,
		damage_per_second = 20,
		post_effect_color = {a=192, r=80, g=160, b=80},
		groups = {
			liquid = 2,
			hot = 3,
			igniter = (griefing and 1 or 0),
			not_in_creative_inventory = (state == "flowing" and 1 or nil),
		},
	})
end

if rawget(_G, "bucket") and bucket.register_liquid then
	bucket.register_liquid(
		"technic:corium_source",
		"technic:corium_flowing",
		"technic:bucket_corium",
		"technic_bucket_corium.png",
		"Corium Bucket"
	)
end

minetest.register_node("technic:chernobylite_block", {
        description = S("Chernobylite Block"),
	tiles = {"technic_chernobylite_block.png"},
        collision_box = { 
          type = "fixed",
           fixed = {-0.4,-0.4,-0.4,0.4,0.4,0.4},
        },
	is_ground_content = true,
	groups = {cracky=1, level=2},
	sounds = default.node_sound_stone_defaults(),
        damage_per_second = 8,
	light_source = 2,
})

minetest.register_abm({
	label = "Corium: boil-off water (sources)",
	nodenames = {"group:water"},
	neighbors = {"technic:corium_source"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		minetest.remove_node(pos)
	end,
})

minetest.register_abm({
	label = "Corium: boil-off water (flowing)",
	nodenames = {"technic:corium_flowing"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		minetest.set_node(pos, {name="technic:chernobylite_block"})
	end,
})

minetest.register_abm({
	label = "Corium: become chernobylite",
	nodenames = {"technic:corium_flowing"},
	interval = 5,
	chance = (griefing and 10 or 1),
	action = function(pos, node)
		minetest.set_node(pos, {name="technic:chernobylite_block"})
	end,
})

minetest.register_abm({
	label = "Corium: griefing",
	nodenames = {"technic:corium_source", "technic:corium_flowing"},
	interval = 10,
	chance = 1,
	action = function(pos, node)
        if pos.y and pos.y > -20000 then return end
		for _, offset in ipairs({
			vector.new(1,0,0),
			vector.new(-1,0,0),
			vector.new(0,0,1),
			vector.new(0,0,-1),
			vector.new(0,-1,0),
		}) do
			if math.random(1,8) == 1 then
				minetest.dig_node(vector.add(pos, offset))
			end
		end
	end,
})

