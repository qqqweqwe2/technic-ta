local S = technic.getter

local path = technic.modpath .. "/machines/register/machine_base_ta"
local machine_state = assert(loadfile(path .. "/state.lua"))()

local machine_digilines = {}

local DIGILINES_MSG_MAX_LENGTH = 200
local DIGILINES_META_COMMAND_NAME = "digiline_command"
local DIGILINES_META_CHANNEL_NAME = "digiline_channel"
local DIGILINE_COMMAND = {
    EJECT_INPUT = "eject_input",
    STATE = "state",
}

local direction_rules = {
    { x = 0,  y = -1, z = 0 },  -- down
    { x = 1,  y = 0,  z = 0 },  -- sideways
    { x = -1, y = 0,  z = 0 },  --
    { x = 0,  y = 0,  z = 1 },  --
    { x = 0,  y = 0,  z = -1 }, --
    { x = 1,  y = -1, z = 0 },  -- sideways + down
    { x = -1, y = -1, z = 0 },  --
    { x = 0,  y = -1, z = 1 },  --
    { x = 0,  y = -1, z = -1 }, --
}

function machine_digilines.get_formspec(pos)
    if not digilines then return "" end

    local formspec = {}
    formspec[#formspec + 1] = ("label[4.3,0.07;%s]"):format(S("Digiline channel"))
    formspec[#formspec + 1] = ("field[6.3,0.15;2,1;%s;;${%s}]"):format(
        DIGILINES_META_CHANNEL_NAME, DIGILINES_META_CHANNEL_NAME)
    formspec[#formspec + 1] = "tooltip[5,0;3,0.75; \n" .. S("Digiline Channel (!advanced user setting!)") .. ":\n\n\t"
    formspec[#formspec + 1] = "\n\t" .. S("You can choose a digiline channel to send and receive messages.") .. "\n\t\t"
    formspec[#formspec + 1] = S(" - When object is inside the machine, \"Starting\" digiline message is raised. ") ..
        "\n\t\t"
    formspec[#formspec + 1] = S(" - When crafting is done \"Ending\" digiline message is raised.") .. "\n\t\t"
    formspec[#formspec + 1] = S(" - You can send a digiline message \"state\" to get status of the machine.") .. "\n\t\t"
    formspec[#formspec + 1] = S(" - You can use the \"eject_input\" command to eject input inside the HV machinery") ..
        "\n\t\t\t"
    formspec[#formspec + 1] = S(" * \"eject_input top\" is the default command") .. "\n\t\t\t"
    formspec[#formspec + 1] =
        S(
            " * instead of top you can use: top/bottom/right/left/front/back, to eject the input to the respective direction from the machinery,") ..
        "\n\t\t\t"
    formspec[#formspec + 1] = S(
        " * third parameter specifies comma separated slot(s) or item(s) to eject (1, 2, ...), if omitted, all slots will be ejected")
    formspec[#formspec + 1] = "\n\n\t" .. S("Leave it empty when you don't use it.") .. "\n ]"
    return table.concat(formspec, "")
end

local function parse_message(msg)
    local template = {
        "command",
        "direction",
        "items"
    }
    local ret_map = {}
    local i = 1
    for token in string.gmatch(msg, "%S+") do
        if not template[i] then break end
        ret_map[template[i]] = token
        i = i + 1
    end
    if ret_map.items then
        local items = {}
        for item in string.gmatch(ret_map.items, "[^%,]+") do
            items[#items + 1] = string.gsub(item, "^%s*(.-)%s*$", "%1")
        end
        ret_map.items = items
    end
    return ret_map
end

local function on_digiline_receive(pos, node, channel, msg)
    if not digilines then return end
    local meta = minetest.get_meta(pos)
    if not meta then return end
    local channel_name = meta:get_string(DIGILINES_META_CHANNEL_NAME)
    if not channel_name or channel_name == "" then return end
    if channel_name ~= channel then return end

    local digiline_request = msg
    if type(msg) == "string" then
        if #msg > DIGILINES_MSG_MAX_LENGTH then return end
        digiline_request = parse_message(msg)
    end
    if type(digiline_request) ~= "table" then return end

    -- for reducing lags, answer once per machine run() execution (default: 1 times per 1 second)
    -- it means, if more than 1 digiline message is sent to the machine, only the last one will be answered
    meta:set_string(DIGILINES_META_COMMAND_NAME, minetest.serialize(digiline_request))
end

function machine_digilines.get_node_def_field()
    if not digilines then return nil end
    return {
        receptor = {
            rules = direction_rules,
        },
        effector = {
            rules = direction_rules,
            action = on_digiline_receive,
        },
    }
end

function machine_digilines.on_receive_fields(_, pos, _, fields, _)
    if not digilines then return end
    local meta = minetest.get_meta(pos)
    if not meta then return end
    if fields[DIGILINES_META_CHANNEL_NAME] then
        meta:set_string(DIGILINES_META_CHANNEL_NAME, fields[DIGILINES_META_CHANNEL_NAME])
    end
end

local function get_eject_direction(command_context, pos)
    local directions_table = {
        ["top"] = { x = 0, y = 1, z = 0 },
        ["bottom"] = { x = 0, y = -1, z = 0 },
        ["front"] = 1,
        ["right"] = 2,
        ["back"] = 3,
        ["left"] = 4,
    }
    local rotations_table = {
        { x = 0,  y = 0, z = -1 },
        { x = -1, y = 0, z = 0 },
        { x = 0,  y = 0, z = 1 },
        { x = 1,  y = 0, z = 0 },
    }

    local direction = directions_table[command_context.direction or "top"]
    if direction == nil then return nil end

    if type(direction) == "table" then
        return direction
    end
    local node = minetest.get_node(pos)
    if not node then return nil end
    local node_def = minetest.registered_nodes[node.name]
    if not node_def then return nil end
    return rotations_table[(direction + node.param2) % 4]
end

local function is_tubedevice_at(pos)
    local node = minetest.get_node(pos)
    if not node then return false end
    if not minetest.registered_nodes[node.name] then return false end

    return minetest.get_item_group(node.name, "tubedevice") > 0
end

local function get_items_and_slots_to_eject(command_context)
    local to_eject = {}

    if not command_context.items or next(command_context.items) == nil then
        -- Eject all.
        return true
    end

    for _, specifier in ipairs(command_context.items) do
        -- Number-likes specify slots, others item names.
        to_eject[tonumber(specifier) or specifier] = true
    end
    return to_eject
end

local function handle_event__eject_input(command_context, _, pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if not inv then return false end
    local stack_list = inv:get_list("src")
    if not stack_list then return false end
    if command_context.command ~= DIGILINE_COMMAND.EJECT_INPUT then return false end
    local eject_direction = get_eject_direction(command_context, pos)
    if not eject_direction then return false end
    local to_eject = get_items_and_slots_to_eject(command_context)
    local eject_position = {
        x = pos.x + eject_direction.x,
        y = pos.y + eject_direction.y,
        z = pos.z + eject_direction.z,
    }
    local output_tube_connected = is_tubedevice_at(eject_position)

    for index, item_stack in ipairs(stack_list) do
        if to_eject == true or to_eject[index] or to_eject[item_stack:get_name()] then
            if output_tube_connected then
                technic.tube_inject_item(pos, pos, eject_direction, item_stack)
            else
                minetest.add_item(eject_position, item_stack)
            end
            item_stack:clear()
            inv:set_stack("src", index, item_stack)
        end
    end
    return true
end

local function handle_event__state(command_context, digiline_channel, pos)
    if command_context.command ~= DIGILINE_COMMAND.STATE then return false end
    local meta = minetest.get_meta(pos)
    local current_state = machine_state.get(meta)
    local inv = meta:get_inventory()
    if not inv then return false end
    local stacks = {}
    local inv_source_list = inv:get_list("src")
    for _, stack in ipairs(inv_source_list) do
        stacks[#stacks + 1] = stack:to_table()
    end
    stacks.type = "status"
    stacks.state = current_state

    digilines.receptor_send(pos, direction_rules, digiline_channel, stacks)
    return true
end

local function get_current_action(current_state)
    local translation_table = {
        [machine_state.STATE.IDLE] = machine_state.STATE.IDLE,
        [machine_state.STATE.STARTED] = machine_state.STATE.STARTING,
        [machine_state.STATE.ACTIVE] = machine_state.STATE.ACTIVE,
        [machine_state.STATE.STALLED] = machine_state.STATE.STALLED,
    }

    return translation_table[current_state] or nil
end

local function handle_digiline_events(pos, meta, digiline_channel)
    local command_str = meta:get_string(DIGILINES_META_COMMAND_NAME)
    if not command_str or command_str == "" then return false end
    local command_context = minetest.deserialize(command_str)
    if not command_context then return false end
    meta:set_string(DIGILINES_META_COMMAND_NAME, nil)

    if handle_event__eject_input(command_context, digiline_channel, pos) then return true end
    if handle_event__state(command_context, digiline_channel, pos) then return true end
    return false
end

function machine_digilines.run(_, pos, _)
    if not digilines then return end
    local meta = minetest.get_meta(pos)
    if not meta then return end
    local digiline_channel = meta:get_string(DIGILINES_META_CHANNEL_NAME)
    if not digiline_channel or digiline_channel == "" then return end
    if handle_digiline_events(pos, meta, digiline_channel) then return end

    local current_state = machine_state.get(meta)
    local previous_state = machine_state.get_previous(meta)
    if current_state == previous_state then return false end
    machine_state.set_previous(meta, current_state)

    local current_action = get_current_action(current_state, previous_state)
    if not current_action then
        return false
    end
    local digiline_msg = {
        type = "auto",
        status = current_action,
        current_state = current_state,
        previous_state = previous_state,
    }
    digilines.receptor_send(pos, direction_rules, digiline_channel, digiline_msg)
end

return machine_digilines
