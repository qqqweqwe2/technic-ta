--[[
	The Lawn Trimmer, also known as Weed Whacker, is a common gardening power
	tool. In minetest, it has several uses. While it removes all members of
	'flora' group and can be used for literally mowing grass or trimming it
	around vegetable beds, it's not its most important application.

	1. The tool can be used when searching for plants that can be cultivated
	in the wilderness. Some of them are hard to see through grass; some of
	them are hard to tell from the grass; some of them are actually obtained
	by removing the grass (e.g. barley seeds).

	2. Producing organic dye pigments. While growing flowers is a matter of
	fertilizing the soil with bone meal, harvesting them by hand is a chore.

	In both scenarios, the tool will be very handy for the player.
	It comes with 4 modes of operation, defined by how wide its sweep is:
	from 0 (at one's feet) to 3 nodes in radius (square radius, as most
	things in minetest are).

	The sound is an edited fragment from
	https://www.cutestockfootage.com/sound-effect/9251/grass-trimmer-01
	used in accordance with its licensing terms (free use for any purpose in
	an altered form)
]]

-- Configuration
-- Intended to hold as much as the chainsaw, 10000 units
local lawn_trimmer_max_charge        = 10000
-- With 25 units per object can mow 400 'group:flora' blocks
local lawn_trimmer_charge_per_object = 25

local S = technic.getter

local lawn_trimmer_mode_text = {
	S("sweep a single block under the user"),
	S("sweep 1 block around the user"),
	S("sweep 2 blocks around the user"),
	S("sweep 3 blocks around the user")
}

local node_removed

-- Mode switcher for the tool
local function lawn_trimmer_setmode(user, itemstack)
	local player_name = user:get_player_name()

	local mode = itemstack:get_definition()._lawn_trimmer_mode

	if mode == 0 then
		minetest.chat_send_player(player_name,
			S("Use while sneaking to change Lawn Trimmer modes."))
	end

	mode = mode % 4 + 1

	itemstack:set_name("technic:lawn_trimmer_" .. mode)
	minetest.chat_send_player(player_name,
		S("Lawn Trimmer Mode @1: ", mode) .. lawn_trimmer_mode_text[mode])

	return itemstack
end


-- Perform the trimming action
local function trim_the_lawn(itemstack, user, pointed_thing)
	local keys = user:get_player_control()

	local mode = itemstack:get_definition()._lawn_trimmer_mode

	if mode == 0 or keys.sneak then
		return lawn_trimmer_setmode(user, itemstack)
	end

	local charge = technic.get_RE_charge(itemstack)

	if charge < lawn_trimmer_charge_per_object then
		return -- no charge for even a single node, aborting
	end

	local pos
	if user.get_pos ~= nil then
		pos = user:get_pos()
	else
		-- we are held in a node breaker
		pos = pointed_thing.under
	end

	minetest.sound_play("technic_lawn_trimmer", {
-- 		to_player = user:get_player_name(),
		pos = pos,
		gain = 0.4,
	})

	-- Defining the area for the search needs two positions
	-- The tool has a limited range in the vertical axis, which is capped at +/- 1 node
	local start_pos = {
		x = pos.x - mode + 1,
		z = pos.z - mode + 1,
		y = pos.y - 1
	}
	local end_pos = {
		x = pos.x + mode - 1,
		z = pos.z + mode - 1,
		y = pos.y + 1
	}

	-- Since nodes sometimes cannot be removed, we cannot rely on repeating
	-- find_node_near() and removing found nodes
	local found_flora = minetest.find_nodes_in_area(start_pos, end_pos, {"group:flora"})
	for _, f in ipairs(found_flora) do
		node_removed = false
		-- Callback will set the flag to true if the node is dug successfully,
		-- otherwise skip to the next one.
		minetest.node_dig(f, minetest.get_node(f), user)
		if node_removed then
			charge = charge - lawn_trimmer_charge_per_object
			-- Abort if no charge left for another node
			if charge < lawn_trimmer_charge_per_object then break end
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
technic.register_power_tool("technic:lawn_trimmer", {
	description = S("Lawn Trimmer"),
	inventory_image = "technic_lawn_trimmer.png",
	stack_max = 1,
	technic_max_charge = lawn_trimmer_max_charge,
	on_use = trim_the_lawn,
	after_use = check_removal,

	_lawn_trimmer_mode = 0
})

for i = 1, 4 do
	technic.register_power_tool("technic:lawn_trimmer_" .. i, {
		description = S("Lawn Trimmer Mode @1", i),
		groups = {not_in_creative_inventory = 1},
		inventory_image = "technic_lawn_trimmer.png^technic_tool_mode" .. i .. ".png",
		technic_max_charge = lawn_trimmer_max_charge,
		wield_image = "technic_lawn_trimmer.png",
		on_use = trim_the_lawn,
		after_use = check_removal,

		_lawn_trimmer_mode = i
	})
end


-- Provide a crafting recipe
local trigger = minetest.get_modpath("mesecons_button") and "mesecons_button:button_off"
	or "default:mese_crystal_fragment"

minetest.register_craft({
	output = 'technic:lawn_trimmer',
	recipe = {
		{'', 'default:stick', trigger},
		{'technic:motor', 'default:stick', 'technic:battery'},
		{'technic:stainless_steel_ingot', '', ''},
	}
})
