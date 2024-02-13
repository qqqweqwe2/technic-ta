
local S = technic.getter
local mat = technic.materials

-- handles the machine upgrades every tick
function technic.handle_machine_upgrades(meta)
	-- Get the names of the upgrades
	local inv = meta:get_inventory()

	local srcstack = inv:get_stack("upgrade1", 1)
	local upg_item1 = srcstack and srcstack:get_name()

	srcstack = inv:get_stack("upgrade2", 1)
	local upg_item2 = srcstack and srcstack:get_name()

	-- Save some power by installing battery upgrades.
	-- Tube loading speed can be upgraded using control logic units.
	local EU_upgrade = 0
	local tube_upgrade = 0

	if upg_item1 == "technic:control_logic_unit" then
		tube_upgrade = tube_upgrade + 1
	elseif upg_item1 == "technic:control_logic_unit_adv" then
		tube_upgrade = tube_upgrade + 6
	elseif upg_item1 == "technic:control_logic_unit_gold" then
		tube_upgrade = tube_upgrade + 106
	elseif upg_item1 == "technic:battery" then
		EU_upgrade = EU_upgrade + 1
	end

	if upg_item2 == "technic:control_logic_unit" then
		tube_upgrade = tube_upgrade + 1
	elseif upg_item2 == "technic:control_logic_unit_adv" then
		tube_upgrade = tube_upgrade + 6
	elseif upg_item2 == "technic:control_logic_unit_gold" then
		tube_upgrade = tube_upgrade + 106
	elseif  upg_item2 == "technic:battery" then
		EU_upgrade = EU_upgrade + 1
	end

	return EU_upgrade, tube_upgrade
end

-- handles the machine upgrades when set or removed
local function on_machine_upgrade(meta, stack)
	local stack_name = stack:get_name()
	if stack_name == "default:chest" then
		meta:set_int("public", 1)
		return 1
	elseif stack_name == "technic:control_logic_unit_gold" then
		-- default value
		meta:set_int("IS_GCLU",1)
        if meta:get_int("GCLU_Percent") == nil then
		    meta:set_int("GCLU_Percent",90)
        end
        if meta:get_int("GCLU_Wait") == nil then
		    meta:set_int("GCLU_Wait",30)
        end
		--show form
		update_formspec(meta)

		return 1
	elseif stack_name ~= "technic:control_logic_unit"
	and stack_name ~= "technic:control_logic_unit_adv"
	   and stack_name ~= "technic:battery" then
		return 0
	end
	return 1
end

-- something is about to be removed
local function on_machine_downgrade(meta, stack, list)
	if stack:get_name() == "default:chest" or stack:get_name() == "technic:control_logic_unit_gold" then
		local inv = meta:get_inventory()
		local upg1, upg2 = inv:get_stack("upgrade1", 1), inv:get_stack("upgrade2", 1)

		-- only set 0 if theres not a nother chest in the other list too
		if (not upg1 or not upg2 or upg1:get_name() ~= upg2:get_name()) then
			if stack:get_name() == "default:chest" then
				meta:set_int("public", 0)
			elseif stack:get_name() == "technic:control_logic_unit_gold" then
				meta:set_string("IS_GCLU",nil)
				meta:set_string("GCLU_Percent",nil) 
				meta:set_string("GCLU_Wait",nil)
		
				--hide form
				update_formspec(meta)
				
			end
		end
	end
	return 1
end


function technic.send_items(pos, x_velocity, z_velocity, output_name, full,is_percent)
	-- Send items on their way in the pipe system.
	if output_name == nil then
		output_name = "dst"
	end

	if is_percent == nil then
		is_percent = false
	end

	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	local invlist = inv:get_list(output_name)
	local shift = (meta:get_int("output_round_robin") - 1) or 1
	if shift < 1 or shift > #invlist then
		shift = #invlist
	end

	local wait
	local game_time
	local function try_send(cursor,is_percent)
		local stack = invlist[cursor]
		local name = stack:get_name() or "air"
		if minetest.get_item_group(name, "bag") == 0 and stack then
			local item0 = stack:to_table()
			if item0 then
				if full then
					local is_to_send = true
					if is_percent then 
						wait = wait or meta:get_int("GCLU_Wait")
						
						local clock_last_send = meta:get_int("clock_last_send"..tostring(cursor))
						game_time = game_time or minetest.get_gametime()

						if wait ~= 0 and clock_last_send ~= 0 and game_time - clock_last_send >= wait + 20  then 
							-- stack with old meta to clean 
							meta:set_int("clock_last_send"..tostring(cursor), game_time)
						elseif wait == 0 or clock_last_send == 0 or game_time - clock_last_send < wait then
							-- wait == 0 mean the  stack is never sent after x second
							-- waiting stack so check if the percent is reach
							if is_percent > 100 then is_percent = 100 end
							is_to_send = stack:get_count() >= stack:get_stack_max() * is_percent / 100 -- send stack that reach the percent of stack_max
							if clock_last_send == 0 and not is_to_send then
								-- new stack to wait we set the meta
								meta:set_int("clock_last_send"..tostring(cursor), game_time)
							end
						end
					end

					if is_to_send then
						technic.tube_inject_item(pos, pos, vector.new(x_velocity, 0, z_velocity), item0)
						stack:clear()
						if is_percent  then
							meta:set_string("clock_last_send"..tostring(cursor), nil)
						end
						inv:set_stack(output_name, cursor, stack)
						meta:set_int("output_round_robin", cursor)
						return true					
					end
				else
					item0["count"] = "1"
					technic.tube_inject_item(pos, pos, vector.new(x_velocity, 0, z_velocity), item0)
					stack:take_item(1)
					inv:set_stack(output_name, cursor, stack)
					meta:set_int("output_round_robin", cursor)
					return true
				end
			end
		end
	end

	for i = shift, 1, -1 do
		if try_send(i,is_percent) then
			return
		end
	end
	for i = #invlist, shift, -1 do
		if try_send(i,is_percent) then
			return
		end
	end
end


function technic.smelt_item(meta, result, speed)
	local inv = meta:get_inventory()
	meta:set_int("cook_time", meta:get_int("cook_time") + 1)
	if meta:get_int("cook_time") < result.time / speed then
		return
	end
	local result
	local afterfuel
	result, afterfuel = minetest.get_craft_result({method = "cooking", width = 1, items = inv:get_list("src")})

	if result and result.item then
		meta:set_int("cook_time", 0)
		-- check if there's room for output in "dst" list
		if inv:room_for_item("dst", result.item) then
			inv:set_stack("src", 1, afterfuel.items[1])
			inv:add_item("dst", result.item)
		end
	end
end

function technic.handle_machine_pipeworks(pos, tube_upgrade, send_function)
	if send_function == nil then
		send_function = technic.send_items
	end

	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	--local inv = meta:get_inventory()     unused?
	local pos1 = vector.new(pos)
	local x_velocity = 0
	local z_velocity = 0

	-- The machines shall always eject items to the right side
	-- This will be easy to remember, since the destination inventory is always on the right as well

	if node.param2 == 3 then pos1.z = pos1.z + 1  z_velocity =  1 end
	if node.param2 == 2 then pos1.x = pos1.x - 1  x_velocity = -1 end
	if node.param2 == 1 then pos1.z = pos1.z - 1  z_velocity = -1 end
	if node.param2 == 0 then pos1.x = pos1.x + 1  x_velocity =  1 end


	local output_tube_connected = false
	local node1 = minetest.get_node(pos1)
	if minetest.get_item_group(node1.name, "tubedevice") > 0 then
		output_tube_connected = true
	end


	local send_stack = false
	local is_percent = 0
	
	if tube_upgrade > 100 then -- gold control unit to send less stack but bigger
		is_percent = meta:get_int("GCLU_Percent")
		tube_upgrade = tube_upgrade % 100

	end

	if tube_upgrade > 2 then
		send_stack = true
		tube_upgrade = tube_upgrade % 5
	end

	local tube_time = meta:get_int("tube_time") + tube_upgrade
	if tube_time >= 2 then
		tube_time = 0
		if output_tube_connected then
			send_function(pos, x_velocity, z_velocity, nil, send_stack,is_percent)
		end
	end
	meta:set_int("tube_time", tube_time)
end

function technic.machine_can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if not inv:is_empty("src") or not inv:is_empty("dst") then
		if player then
			minetest.chat_send_player(player:get_player_name(),
				S("Machine cannot be removed because it is not empty"))
		end
		return false
	end

	return true
end

function technic.machine_after_dig_node(pos, oldnode, oldmetadata, player)
	if oldmetadata.inventory then
		if oldmetadata.inventory.upgrade1 and oldmetadata.inventory.upgrade1[1] then
			local stack = ItemStack(oldmetadata.inventory.upgrade1[1])
			if not stack:is_empty() then
				minetest.add_item(pos, stack)
			end
		end
		if oldmetadata.inventory.upgrade2 and oldmetadata.inventory.upgrade2[1] then
			local stack = ItemStack(oldmetadata.inventory.upgrade2[1])
			if not stack:is_empty() then
				minetest.add_item(pos, stack)
			end
		end
	end

	if minetest.registered_nodes[oldnode.name].tube then
		pipeworks.after_dig(pos, oldnode, oldmetadata, player)
	end
end

local function inv_change(pos, player, count, from_list, to_list, stack)
	local playername = player:get_player_name()
	local meta = minetest.get_meta(pos);
	local public = (meta:get_int("public") == 1)
	local to_upgrade = to_list == "upgrade1" or to_list == "upgrade2"
	local from_upgrade = from_list == "upgrade1" or from_list == "upgrade2"

	if (not public or to_upgrade or from_upgrade) and minetest.is_protected(pos, playername) then
		minetest.chat_send_player(playername, S("Inventory move disallowed due to protection"))
		return 0
	end
	if to_upgrade then
		-- only place a single item into it, if it's empty
		local empty = meta:get_inventory():is_empty(to_list)
		if empty then
			return on_machine_upgrade(meta, stack)
		end
		return 0
	elseif from_upgrade then
		-- only called on take (not move)
		on_machine_downgrade(meta, stack, from_list)
	end
	return count
end

function technic.machine_inventory_put(pos, listname, index, stack, player)
	local player_name = player:get_player_name()
	minetest.log(player_name.. " put ".. stack:get_name().. " ".. stack:get_count().. " in "..listname.. " form".. " at ".. minetest.pos_to_string(pos).. " (machines).")
	return inv_change(pos, player, stack:get_count(), nil, listname, stack)
end

function technic.machine_inventory_take(pos, listname, index, stack, player)
	local player_name = player:get_player_name()
	minetest.log(player_name.. " took ".. stack:get_name().. " ".. stack:get_count().. " in "..listname.. " form".. " at ".. minetest.pos_to_string(pos).. " (machines).")
	return inv_change(pos, player, stack:get_count(), listname, nil, stack)
end

function technic.machine_inventory_move(pos, from_list, from_index,
		to_list, to_index, count, player)
	local stack = minetest.get_meta(pos):get_inventory():get_stack(from_list, from_index)
	return inv_change(pos, player, count, from_list, to_list, stack)
end

