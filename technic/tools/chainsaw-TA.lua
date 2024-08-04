-- Configuration

-- Cut down tree leaves.  Leaf decay may cause slowness on large trees
-- if this is disabled.
local chainsaw_leaves = true

local S = technic.getter

local dig_less_tree_trunks = minetest.settings:get_bool("ta_technic_dig_less_tree_trunks", true)
--[[
Format: [node_name] = dig_cost

This table is filled automatically afterwards to support mods such as:

	cool_trees
	ethereal
	moretrees
]]
local tree_nodes = {
	-- For the sake of maintenance, keep this sorted alphabetically!
	["default:acacia_bush_stem"] = -1,
	["default:bush_stem"] = -1,
	["default:pine_bush_stem"] = -1,

	["default:cactus"] = -1,
	["default:papyrus"] = -1,

	-- dfcaves "fruits"
	["df_trees:blood_thorn_spike"] = -1,
	["df_trees:blood_thorn_spike_dead"] = -1,
	["df_trees:tunnel_tube_fruiting_body"] = -1,

	["ethereal:bamboo"] = -1,
	["ethereal:basandra_bush_stem"] = -1,
}
local leaves_nodes = {
	["ethereal:mushroom"]      = -1,
	["ethereal:mushroom_pore"] = -1,
}

local tree_nodes_by_cid = {
	-- content ID indexed table, data populated on mod load.
	-- Format: [node_name] = cost_number
}

-- Function to decide whether or not to cut a certain node (and at which energy cost)
local function populate_costs(name, def)
	repeat
		if tree_nodes[name] then
			break -- Manually specified node to chop
		end
		if leaves_nodes[name] then
			break -- Manually specified node to chop
		end
		if (def.groups.tree or 0) > 0 then
			break -- Tree node
		end
		if (def.groups.leaves or 0) > 0 and chainsaw_leaves then
			break -- Leaves
		end
		if (def.groups.leafdecay_drop or 0) > 0 then
			break -- Food
		end
		return -- Abort function: do not dig this node

	-- luacheck: push ignore 511
	until 1
	-- luacheck: pop

	-- Add the node cost to the content ID indexed table
	local content_id = minetest.get_content_id(name)

	-- Make it so that the giant sequoia can be cut with a full charge
	local cost = tree_nodes[name] or leaves_nodes[name] or 0
	if def.groups.choppy then
		cost = math.max(cost, def.groups.choppy * 14) -- trunks (usually 3 * 14)
	end
	if def.groups.snappy then
		cost = math.max(cost, def.groups.snappy * 2) -- leaves
	end
	tree_nodes_by_cid[content_id] = math.max(4, cost)
end

minetest.register_on_mods_loaded(function()
	local ndefs = minetest.registered_nodes
	-- Populate hardcoded nodes
	for name in pairs(tree_nodes) do
		local ndef = ndefs[name]
		if ndef and ndef.groups then
			populate_costs(name, ndef)
		end
	end
	for name in pairs(leaves_nodes) do
		local ndef = ndefs[name]
		if ndef and ndef.groups then
			populate_costs(name, ndef)
		end
	end
	-- Find all trees and leaves
	for name, def in pairs(ndefs) do
		if def.groups then
			populate_costs(name, def)
		end
	end
end)

local pos9dir = {
	-- up
	{ 0,  1, 0 },
	{ 1,  1, 0 }, -- right
	{ -1, 1, 0 }, -- left
	{ 0,  1, 1 }, -- front
	{ 0,  1, -1 }, -- back
	{ 1,  1, 1 }, -- front right
	{ -1, 1, -1 }, -- back left
	{ 1,  1, -1 }, -- back right
	{ -1, 1, 1 }, -- front left
	-- middle
	{ 1,  0, 0 }, -- right
	{ -1, 0, 0 }, -- left
	{ 0,  0, 1 }, -- front
	{ 0,  0, -1 }, -- back
	{ 1,  0, 1 }, -- front right
	{ -1, 0, -1 }, -- back left
	{ 1,  0, -1 }, -- back right
	{ -1, 0, 1 }, -- front left
}

local function merge_tables(table1, table2)
	local result = table.copy(table1)
	for _, v in pairs(table2) do
		table.insert(result, v)
	end
	return result
end

local pos9dir_leaves = merge_tables (pos9dir, {
	-- down
	{ 0,  -1, 0 },
	{ 1,  -1, 0 }, -- right
	{ -1, -1, 0 }, -- left
	{ 0,  -1, 1 }, -- front
	{ 0,  -1, -1 }, -- back
	{ 1,  -1, 1 }, -- front right
	{ -1, -1, -1 }, -- back left
	{ 1,  -1, -1 }, -- back right
	{ -1, -1, 1 }, -- front left
})

local function handle_one_drop(pos, cutter)
	local node = minetest.get_node(pos)
	for _, dropped_node in ipairs(minetest.get_node_drops(node.name, "")) do
		local stack = ItemStack(dropped_node)
		cutter.drops[stack:get_name()] = (cutter.drops[stack:get_name()] or 0) + stack:get_count()
	end
end

local function process_digged_item(pos, cutter)
	local i = cutter.area:index(pos.x, pos.y, pos.z)
	if cutter.seen[i] then
		return false
	end
	cutter.seen[i] = 1 -- Mark as visited

	local c_id = cutter.data[i]
	local cost = tree_nodes_by_cid[c_id]
	if not cost or cost > cutter.charge then
		return false -- Cannot dig this node
	end

	-- Count dug nodes
	handle_one_drop(pos, cutter)
	cutter.seen[i] = 2 -- Mark as dug (for callbacks)
	cutter.data[i] = minetest.CONTENT_AIR
	cutter.param2[i] = 0
	cutter.charge = cutter.charge - cost

	-- Expand maximal bounds for area protection check
	if pos.x < cutter.minp.x then cutter.minp.x = pos.x end
	if pos.y < cutter.minp.y then cutter.minp.y = pos.y end
	if pos.z < cutter.minp.z then cutter.minp.z = pos.z end
	if pos.x > cutter.maxp.x then cutter.maxp.x = pos.x end
	if pos.y > cutter.maxp.y then cutter.maxp.y = pos.y end
	if pos.z > cutter.maxp.z then cutter.maxp.z = pos.z end
	return true
end

local function get_tree_node_type_at(pos)
	local node = minetest.get_node(pos)
	local node_def = minetest.registered_nodes[node.name]
	if not node_def then return nil end
	if node_def.groups.tree or tree_nodes[node.name] then
		return "tree"
	elseif node_def.groups.leaves or leaves_nodes[node.name] then
		return "leaves"
	elseif node_def.groups.leafdecay_drop then
		return "leafdecay_drop"
	else
		return nil
	end
end

local dig_recursive
local function dig_leaves_recursive(pos, cutter, leaves_reach)
	if not process_digged_item(pos, cutter) then return end

	if (leaves_reach <= 0) then return end
	local posn = {}
	
	for _, offset in ipairs(pos9dir_leaves) do
		posn = {
			x = pos.x + offset[1],
			y = pos.y + offset[2],
			z = pos.z + offset[3],
		}

		if cutter.area:contains(posn.x, posn.y, posn.z) then
			local tree_node_type = get_tree_node_type_at(posn)
			if tree_node_type then
				if tree_node_type == "tree" then
					if not dig_less_tree_trunks and cutter.leaves_reach == leaves_reach then
						dig_recursive(pos, cutter)
					else
						process_digged_item(posn, cutter)
					end
				else
					dig_leaves_recursive(posn, cutter, leaves_reach - 1)
				end
			end
		end
	end
end

dig_recursive = function(pos, cutter)
	if not process_digged_item(pos, cutter) then return end
	-- Traverse neighbors
	local posn = {}
	for _, offset in ipairs(pos9dir) do
		posn = {
			x = pos.x + offset[1],
			y = pos.y + offset[2],
			z = pos.z + offset[3],
		}

		if cutter.area:contains(posn.x, posn.y, posn.z) then
			local tree_node_type = get_tree_node_type_at(posn)
			if tree_node_type then
				if tree_node_type == "tree" then
					dig_recursive(posn, cutter)
				else
					table.insert(cutter.leaves, posn)
				end
			end
		end
	end
end

-- Function to randomize positions for new node drops
local function get_drop_pos(pos)
	local drop_pos = {}

	for i = 0, 8 do
		-- Randomize position for a new drop
		drop_pos.x = pos.x + math.random(-3, 3)
		drop_pos.y = pos.y - 1
		drop_pos.z = pos.z + math.random(-3, 3)

		-- Move the randomized position upwards until
		-- the node is air or unloaded.
		for y = drop_pos.y, drop_pos.y + 5 do
			drop_pos.y = y
			local node = minetest.get_node_or_nil(drop_pos)

			if not node then
				-- If the node is not loaded yet simply drop
				-- the item at the original digging position.
				return pos
			elseif node.name == "air" then
				-- Add variation to the entity drop position,
				-- but don't let drops get too close to the edge
				drop_pos.x = drop_pos.x + (math.random() * 0.8) - 0.5
				drop_pos.z = drop_pos.z + (math.random() * 0.8) - 0.5
				return drop_pos
			end
		end
	end

	-- Return the original position if this takes too long
	return pos
end

local function handle_drops(pos, cutter)
	local n_slots = 100
	local drop_inv = minetest.create_detached_inventory("technic:chainsaw_drops", {}, ":technic")
	drop_inv:set_size("main", n_slots)
	drop_inv:set_list("main", {})

	-- Put all dropped items into the detached inventory
	for name, count in pairs(cutter.drops) do

		while count > 0 do
			local stack = ItemStack(name)
			local stack_max = stack:get_stack_max()
			local size = math.min(count, stack_max) * cutter.chainsaw_efficiency
			stack:set_count(size)
			drop_inv:add_item("main", stack)
			count = count - stack_max
		end
	end

	-- Drop in random places
	for i = 1, n_slots do
		local stack = drop_inv:get_stack("main", i)
		if stack:is_empty() then
			break
		end
		minetest.add_item(get_drop_pos(pos), stack)
	end

	drop_inv:set_size("main", 0) -- free RAM
end

local function chainsaw_dig(player, pos, cutter)
	cutter.leaves = {}
	dig_recursive(pos, cutter)
	for _, leaves_pos in pairs(cutter.leaves) do
		dig_leaves_recursive(leaves_pos, cutter, cutter.leaves_reach)
	end

	-- Check protection
	local player_name = player:get_player_name()
	if minetest.is_area_protected(cutter.minp, cutter.maxp, player_name, 6) then
		minetest.chat_send_player(player_name, "The chainsaw cannot cut this tree. The cuboid " ..
			minetest.pos_to_string(cutter.minp) .. ", " .. minetest.pos_to_string(cutter.maxp) ..
			" contains protected nodes.")
		minetest.record_protection_violation(pos, player_name)
		return
	end

	minetest.sound_play("chainsaw", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 20
	})

	handle_drops(pos, cutter)

	local old_data = cutter.vm:get_data()
	local old_light_data = cutter.vm:get_light_data()
	local old_param2_data = cutter.vm:get_param2_data()

	cutter.vm:set_data(cutter.data)
	cutter.vm:set_param2_data(cutter.param2)
	cutter.vm:write_to_map(true)
	cutter.vm:update_map()

	minetest.fix_light(cutter.minp, cutter.maxp)

	-- Update falling nodes
	for i, status in pairs(cutter.seen) do
		if status == 2 then -- actually dug
			local old_node_name = minetest.get_name_from_content_id(old_data[i])
			local old_node_def = minetest.registered_nodes[old_node_name]
			local node = { name = old_node_name, param1 = old_light_data[i], param2 = old_param2_data[i] }
			if old_node_def then
				local pos_cur = cutter.area:position(i)
				if old_node_def.after_destruct then
					old_node_def.after_destruct(pos_cur, node)
				end
				if old_node_def.after_dig_node then
					old_node_def.after_dig_node(pos_cur, node, {}, player)
				end
			end

			minetest.check_for_falling(cutter.area:position(i))
		end
	end
end

local function create_cutter_object(init_chainsaw_data, chainsaw_obj, pos)
	local minp = {
		x = pos.x - (init_chainsaw_data.tree_max_radius + 1),
		y = pos.y,
		z = pos.z - (init_chainsaw_data.tree_max_radius + 1)
	}
	local maxp = {
		x = pos.x + (init_chainsaw_data.tree_max_radius + 1),
		y = pos.y + init_chainsaw_data.tree_max_height,
		z = pos.z + (init_chainsaw_data.tree_max_radius + 1)
	}

	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(minp, maxp)

	return {
		area = VoxelArea:new { MinEdge = emin, MaxEdge = emax },
		vm = vm,
		data = vm:get_data(),
		param2 = vm:get_param2_data(),
		seen = {},
		drops = {}, -- [content_id] = count
		minp = vector.copy(pos),
		maxp = vector.copy(pos),
		charge = technic.get_RE_charge(chainsaw_obj),
	}
end

local function chainsaw_on_use(init_chainsaw_data)
	return function(chainsaw_obj, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return chainsaw_obj
		end

		local name = user:get_player_name()
		if minetest.is_protected(pointed_thing.under, name) then
			minetest.record_protection_violation(pointed_thing.under, name)
			return
		end

		local cutter = create_cutter_object(init_chainsaw_data, chainsaw_obj, pointed_thing.under)
		cutter.chainsaw_efficiency = init_chainsaw_data.efficiency or 0.92
		cutter.leaves_reach = init_chainsaw_data.leaves_reach or 2
		-- Send current charge to digging function so that the
		-- chainsaw will stop after digging a number of nodes
		chainsaw_dig(user, pointed_thing.under, cutter)

		if not technic.creative_mode then
			technic.set_RE_charge(chainsaw_obj, cutter.charge)
		end
		return chainsaw_obj
	end
end

local mesecons_button = minetest.get_modpath("mesecons_button")
local trigger = mesecons_button and "mesecons_button:button_off" or "default:mese_crystal_fragment"
local chainsaws_data = {
	{
		name = "technic:chainsaw_mini",
		description = S("Chainsaw Mini"),
		inventory_image = "technic_chainsaw_mini.png",
		-- Maximal dimensions of the tree to cut (giant sequoia)
		tree_max_radius = 10,
		tree_max_height = 70,
		leaves_reach = 2,
		efficiency = 1,
		max_charge = 15000,
		recipe = {
			{ "technic:wrought_iron_ingot", "technic:wrought_iron_ingot", "technic:battery" },
			{ "",                           "technic:motor",              trigger },
			{ "",                           "",                           "" },
		},
	},
	{
		name = "technic:chainsaw",
		description = S("Chainsaw"),
		inventory_image = "technic_chainsaw.png",
		-- Maximal dimensions of the tree to cut (giant sequoia)
		tree_max_radius = 10,
		tree_max_height = 70,
		leaves_reach = 2,
		efficiency = 1,
		max_charge = 30000,
		recipe = {
			{ "technic:stainless_steel_ingot", trigger,                 "technic:battery" },
			{ "basic_materials:copper_wire",   "basic_materials:motor", "technic:battery" },
			{ "",                              "",                      "technic:stainless_steel_ingot" },
		},
		replacements = { { "basic_materials:copper_wire", "basic_materials:empty_spool" }, },
	},
	{
		name = "technic:chainsaw_mk2",
		description = S("Chainsaw Mk2"),
		inventory_image = "technic_chainsaw_mk2.png",
		-- Maximal dimensions of the tree to cut (giant sequoia)
		tree_max_radius = 10,
		tree_max_height = 70,
		leaves_reach = 2,
		efficiency = 1,
		max_charge = 120000,
		recipe = {
			{ "technic:chainsaw", "technic:stainless_steel_ingot", "technic:stainless_steel_ingot" },
			{ "technic:battery",  "technic:battery",               "" },
			{ "technic:battery",  "dye:green",                     "" },
		}
	},
}

for _, chainsaw in ipairs(chainsaws_data) do
	technic.register_power_tool(chainsaw.name, {
		description = chainsaw.description,
		inventory_image = chainsaw.inventory_image,
		stack_max = 1,
		technic_max_charge = chainsaw.max_charge,
		on_use = chainsaw_on_use(chainsaw),
	})

	minetest.register_craft({
		output = chainsaw.name,
		recipe = chainsaw.recipe,
		replacements = chainsaw.replacements,
	})
end
