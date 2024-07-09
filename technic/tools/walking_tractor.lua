--[[
	Walking tractor: a dedicated farming tool, a miracle of small mechanization.
	Replaces hoes and harvests useful plants (fully-grown cultivars, mostly from farming)
	Has a variable swipe from 3 to 7 nodes, in either case - in a line, perpendicular
	to the user's direction of sight. For smaller areas there are always hoes.
	Modes 1-3 are for tilling
	Modes 4-6 are for harvesting
]]

-- Configuration
-- Intended to hold as much as the chainsaw, 10000 units
local walking_tractor_max_charge        = 20000
-- Can remove a curious number of objects
local walking_tractor_charge_per_object = 30
-- For tilling: cost is less but spent regardless of actual success
local walking_tractor_charge_per_tilled_node = 25

local S = technic.getter

local walking_tractor_mode_text = {
	S("@1 blocks wide tilling", 3),
	S("@1 blocks wide tilling", 5),
	S("@1 blocks wide tilling", 7),
	S("@1 blocks wide harvesting", 3),
	S("@1 blocks wide harvesting", 5),
	S("@1 blocks wide harvesting", 7),
}

local ripe_for_harvest = {
	"farming:barley_8",
	"farming:beanpole_5",
	"farming:beetroot_5",
	"farming:blueberry_4",
	"farming:carrot_8",
	"farming:chili_8",
	"farming:cocoa_4",
	"farming:coffee_5",
	"farming:corn_8",
	"farming:cotton_8",
	"farming:cucumber_4",
	"farming:garlic_5",
	"farming:grapes_8",
	"farming:hemp_8",
	"farming:melon_8",
	"farming:onion_5",
	"farming:oat_8",
	"farming:pea_5",
-- 	"farming:pepper_5",
	"farming:pineapple_8",
	"farming:potato_4",
	"farming:pumpkin_8",
	"farming:raspberry_4",
	"farming:rhubarb_3",
	"farming:rice_8",
	"farming:rye_8",
	"farming:tomato_8",
	"farming:wheat_8",
	"ethereal:onion_5",
	"ethereal:strawberry_8",
	-- also doubles as a snow-plough
	"default:snow",
	"default:snowblock",
	"stairs:slab_snowblock",
	-- mushrooms
	"flowers:mushroom_red",
	"flowers:mushroom_brown",
	-- agave
	"wine:blue_agave",
	-- additions in farming undo
	"farming:artichoke_5",
	"farming:blackberry_4",
	"farming:lettuce_5",
	"farming:oregano_5",
	"farming:parsley_3",
	"farming:vanilla_8"
}

if minetest.get_modpath("farming") and farming.mod and (farming.mod == "redo") then
	table.insert(ripe_for_harvest, "farming:pepper_5")
	table.insert(ripe_for_harvest, "farming:pepper_6")
	table.insert(ripe_for_harvest, "farming:pepper_7")
end
if minetest.get_modpath("farming") and farming.mod and (farming.mod == "undo") then
	table.insert(ripe_for_harvest, "farming:pepper_7")
end

local compatible_soils = {
	"group:soil",
	"default:dirt_with_snow",
	"ethereal:dry_dirt"
}

local node_removed

-- Mode switcher for the tool
local function walking_tractor_setmode(user, itemstack)
	local player_name = user:get_player_name()

	local mode = itemstack:get_definition()._tractor_mode

	if mode == 0 then
		minetest.chat_send_player(player_name,
			S("Use while sneaking to change Walking Tractor modes."))
	end

	mode = mode % 6 + 1

	itemstack:set_name("technic:walking_tractor_" .. mode)
	minetest.chat_send_player(player_name,
		S("Walking Tractor Mode @1: ", mode) .. walking_tractor_mode_text[mode])

	return itemstack
end


-- Perform the trimming action
local function work_on_soil(itemstack, user, pointed_thing)
	local keys = user:get_player_control()

	local mode = itemstack:get_definition()._tractor_mode
	if mode == 0 or keys.sneak then
		return walking_tractor_setmode(user, itemstack)
	end

	local charge = technic.get_RE_charge(itemstack)
	
	if charge < walking_tractor_charge_per_object then
		return -- no charge for even a single node, aborting
	end
	
	if pointed_thing.type ~= "node" then
		return itemstack
	end
	
	local name = user:get_player_name()
	if minetest.is_protected(pointed_thing.under, name) then
		minetest.record_protection_violation(pointed_thing.under, name)
		return
	end
	
	minetest.sound_play("technic_walking_tractor", {
-- 		to_player = user:get_player_name(),
		pos = user:get_pos(),
		gain = 0.5,
	})

	local dir_right
	local udir = user:get_look_dir()
	-- Negate the x axis and swap x and z axes to get a vector rotated by 90 degrees right
	if math.abs(udir.x) > math.abs(udir.z) then
		dir_right = vector.new(0, 0, -math.sign(udir.x, 0.0))
	else
		dir_right = vector.new(math.sign(udir.z, 0.0), 0, 0)
	end
	
	local offset = mode
	if offset > 3 then
		offset = offset - 3
	end
	offset = offset + 0.1
	
	local start_pos = pointed_thing.under - offset * dir_right - vector.new(0, 0.1, 0)
	local end_pos = pointed_thing.under + offset * dir_right + vector.new(0, 1.1, 0)

	if mode <= 3 then
	-- tilling
		local found_obj = minetest.find_nodes_in_area(start_pos, end_pos, compatible_soils)
		for _, f in ipairs(found_obj) do
			-- unfortunately, there is no callback to track the node change without
			-- digging it first
			if not minetest.is_protected(f, name) then
				minetest.remove_node(f)
				minetest.set_node(f, {name = "farming:soil"})
				charge = charge - walking_tractor_charge_per_tilled_node
			end
			-- Abort if no charge left for another node
			if charge < walking_tractor_charge_per_tilled_node then break end
		end
	
	else
	-- harvesting
		-- Since nodes sometimes cannot be removed, we cannot rely on repeating
		-- find_node_near() and removing found nodes
		local found_obj = minetest.find_nodes_in_area(start_pos, end_pos, ripe_for_harvest)
		for _, f in ipairs(found_obj) do
			node_removed = false
			-- Callback will set the flag to true if the node is dug successfully,
			-- otherwise skip to the next one.
			minetest.node_dig(f, minetest.get_node(f), user)
			if node_removed then
				charge = charge - walking_tractor_charge_per_object
				-- Abort if no charge left for another node
				if charge < walking_tractor_charge_per_object then break end
			end
		end
	end
	
	-- The charge won't expire in creative mode, but the tool still
	-- has to be charged prior to use
	if not technic.creative_mode then
		technic.set_RE_charge(itemstack, charge)
	end

	return itemstack
end

function check_removal()
	node_removed = true
end

-- Register the tool and its varieties in the game
technic.register_power_tool("technic:walking_tractor", {
	description = ("Walking Tractor"),
	inventory_image = "technic_walking_tractor.png",
	stack_max = 1,
	technic_max_charge = walking_tractor_max_charge,
	on_use = work_on_soil,
	after_use = check_removal,

	_tractor_mode = 0
})

for i = 1, 6 do
	technic.register_power_tool("technic:walking_tractor_" .. i, {
		description = ("Walking Tractor Mode %d"):format(i),
		groups = {not_in_creative_inventory = 1},
		inventory_image = "technic_walking_tractor.png^technic_tool_mode" .. i .. ".png",
		technic_max_charge = walking_tractor_max_charge,
		wield_image = "technic_walking_tractor.png",
		on_use = work_on_soil,
		after_use = check_removal,

		_tractor_mode = i
	})
end


-- Provide a crafting recipe
local trigger = minetest.get_modpath("mesecons_button") and "mesecons_button:button_off"
	or "default:mese_crystal_fragment"

minetest.register_craft({
	output = 'technic:walking_tractor',
	recipe = {
		{'dye:green',                  'technic:battery',               trigger},
		{'technic:motor',              'technic:battery',               'default:stick'},
		{'technic:diamond_drill_head', 'technic:stainless_steel_ingot', 'technic:rubber'},
	}
})
