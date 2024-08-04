--[[
	Planter: a tool for placing rows of objects (primarily, farming plants)
	Has 6 mods, corresponding to the width of the row (2...7 blocks). 1 block can be
	always planted by hand.
]]

-- Configuration
-- Intended to hold as much as the chainsaw, 20000 units
local planter_max_charge        = 20000
-- Cost of planting action
local planter_charge_per_object = 25


local S = technic.getter

-- Mode switcher for the tool
local function planter_setmode(user, itemstack)
	local player_name = user:get_player_name()

	local mode = itemstack:get_definition()._planter_mode

	if mode == 0 then
		minetest.chat_send_player(player_name,
			S("Use while sneaking to change Planter modes."))
	end

	mode = mode % 6 + 1

	itemstack:set_name("technic:planter_" .. mode)
	minetest.chat_send_player(player_name,
		S("Planter Mode @1: @2 blocks wide planting", mode, mode + 1))
	return itemstack
end


-- Perform the planting action
local function work_on_soil(itemstack, user, pointed_thing)

	local meta = itemstack:get_meta()
	local keys = user:get_player_control()

	local mode = itemstack:get_definition()._planter_mode

	if mode == 0 or keys.sneak then
		return planter_setmode(user, itemstack)
	end

	local selected = meta:get_string("selected")
	if selected == "" then
		return
	end

	local charge = technic.get_RE_charge(itemstack)

	local offset = mode
	local offset_r = math.floor(offset / 2)
	local offset_l = offset - offset_r

	if charge < planter_charge_per_object * (offset+1) then
		return -- no charge for a complete row
	end

	if pointed_thing.type ~= "node" then
		return itemstack
	end

	local name = user:get_player_name()

	local pcoord = {x = pointed_thing.under.x, y = pointed_thing.under.y + 1, z = pointed_thing.under.z}
	if minetest.is_protected(pcoord, name) then
		minetest.record_protection_violation(pcoord, name)
		return
	end

	local player_name = user:get_player_name()
	local inv = user:get_inventory()

	if not inv:contains_item("main", ItemStack({name=selected, count = offset + 1})) then
		minetest.chat_send_player(player_name, S("Not enough @1 to continue!", selected))
		return itemstack
	end

	minetest.sound_play("technic_walking_tractor", {
-- 		to_player = user:get_player_name(),
		pos = user:get_pos(),
		gain = 0.5,
	})

	local c = 0

	local udir = user:get_look_dir()
	local dir_right
	-- Negate the x axis and swap x and z axes to get a vector rotated by 90 degrees right
	if math.abs(udir.x) > math.abs(udir.z) then
		dir_right = vector.new(0, 0, -math.sign(udir.x, 0.0))
	else
		dir_right = vector.new(math.sign(udir.z, 0.0), 0, 0)
	end

	local work_pos = {}
	for rel_pos = -offset_l,offset_r do

		work_pos = {
			type = "node",
			under = pointed_thing.under + dir_right * rel_pos,
			above = pointed_thing.under + vector.new(0, 1, 0) + dir_right * rel_pos,
			ref = nil
		}

		local k = (minetest.registered_items[selected] or {on_place=minetest.item_place}).on_place(ItemStack({name=selected, count=1}), user, work_pos)

		if k and k:get_count() == 0 then
			c = c + 1
		end
	end


	charge = charge - planter_charge_per_object * c

	-- The charge won't expire in creative mode, but the tool still
	-- has to be charged prior to use
	if not technic.creative_mode then
		inv:remove_item("main", ItemStack({name=selected, count = c}))
		technic.set_RE_charge(itemstack, charge)
	end
	return itemstack
end

local function update_plant_in_wielded_meta(player, plant_name)
	local wielded_stack = player:get_wielded_item()
	if not string.find(wielded_stack:get_name(), "^technic:planter") then
		return
	end

	local meta = wielded_stack:get_meta()
	meta:set_string("selected", plant_name)

	player:set_wielded_item(wielded_stack)
end

local function select_plant(itemstack, user, pointed_thing)
	if not user or not user:is_player() or user.is_fake_player then return end
	local meta = itemstack:get_meta()
	local player_name = user:get_player_name()

	local inv = minetest.create_detached_inventory("planter_" .. player_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,
		allow_put = function(inv, listname, index, stack, player)
			if player:get_player_name() ~= player_name or listname ~= "crop" or index ~= 1 then
				return 0
			end

			update_plant_in_wielded_meta(player, stack:get_name())

			inv:set_stack(listname, index, ItemStack(stack:get_name()))

			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			if player:get_player_name() ~= player_name then
				return 0
			end

			update_plant_in_wielded_meta(player, "")

			inv:set_stack(listname, index, ItemStack())

			return 0
		end
	}, player_name)

	inv:set_size("crop", 1)

	local crop_name = meta:get("selected")
	if crop_name then
		inv:set_stack("crop", 1, ItemStack(crop_name))
	end

	minetest.show_formspec(user:get_player_name(), "technic:planter_control",
		"size[8,5]"..
		"label[0,0;   \nCrops selected:]" ..
		"list[detached:planter_"..player_name..";crop;2,0;1,1;]" ..
		"button_exit[7,0;1,1;quit;Cancel]" ..
		"list[current_player;main;0,1;8,4;]" ..
		default.get_hotbar_bg(0,1))
end


minetest.register_on_player_receive_fields(function(user, formname, fields)

	if formname ~= "technic:planter_control" then return false end

	if not user or not user:is_player() or user.is_fake_player then return true end

	local itemstack = user:get_wielded_item()
	if not string.find(itemstack:get_name(), "^technic:planter") then return true end

	if fields.quit then
		minetest.remove_detached_inventory("planter_"..user:get_player_name())
		return true
	end

	return true
end)


-- Register the tool and its varieties in the game
technic.register_power_tool("technic:planter", {
	description = ("Planter"),
	inventory_image = "technic_planter.png",
	stack_max = 1,
	technic_max_charge = planter_max_charge,
	on_use = work_on_soil,
	on_place = select_plant,

	_planter_mode = 0,
})

for i = 1, 6 do
	technic.register_power_tool("technic:planter_" .. i, {
		description = ("Planter Mode %d"):format(i),
		inventory_image = "technic_planter.png^technic_tool_mode" .. i .. ".png",
		technic_max_charge = planter_max_charge,
		wield_image = "technic_planter.png",
		groups = {not_in_creative_inventory = 1},
		on_use = work_on_soil,
		on_place = select_plant,

		_planter_mode = i,
	})
end


-- Provide a crafting recipe
local trigger = minetest.get_modpath("mesecons_button") and "mesecons_button:button_off"
	or "default:mese_crystal_fragment"

minetest.register_craft({
	output = 'technic:planter',
	recipe = {
		{'dye:red',       'technic:battery',               trigger},
		{'technic:motor', 'technic:battery',               'default:stick'},
		{'default:chest', 'technic:stainless_steel_ingot', 'technic:rubber'},
	}
})
