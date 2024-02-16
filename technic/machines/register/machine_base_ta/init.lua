local path = technic.modpath .. "/machines/register/machine_base_ta"
local register_func = assert(loadfile(path .. "/register.lua"))()

local S = technic.getter

function technic.default_can_insert(pos, node, stack, direction)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if meta:get_int("splitstacks") == 1 then
        stack = stack:peek_item(1)
    end
    return inv:room_for_item("src", stack)
end

function technic.new_default_tube()
    return {
        insert_object = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            return inv:add_item("src", stack)
        end,
        can_insert = technic.default_can_insert,
        connect_sides = { left = 1, right = 1, back = 1, top = 1, bottom = 1 },
    }
end

local function make_registration_context(nodename, data)
    local colon, modname, name, def = technic.register_compat_v1_to_v2(nodename, data)
    local ltier = string.lower(def.tier)
    local nodename = modname .. ":" .. name

    local texture_prefix = modname .. "_" .. name
    if not name:find("lv") and not name:find("hv") then
        nodename = modname .. ":" .. ltier .. "_" .. name
        texture_prefix = modname .. "_" .. ltier .. "_" .. name
    end

    local groups = { cracky = 2, technic_machine = 1, ["technic_" .. ltier] = 1, pickaxey = 2 }

    if def.tube then
        groups.tubedevice = 1
        groups.tubedevice_receiver = 1
    end
    local active_groups = table.copy(groups)
    active_groups.not_in_creative_inventory = 1

    local output_size = def.output_size and tonumber(def.output_size) or 6
    if output_size > 9 then
        output_size = 9
    end

    return {
        texture_prefix = texture_prefix,
        colon = colon,
        def = def,
        modname = modname,
        nodename = nodename,
        groups = groups,
        active_groups = active_groups,
        input_size = technic.recipes[def.typename].input_size,
        output_size = output_size,
        ltier = ltier,
        infotext_idle = S("@1 Idle", def.description),
        infotext_active = S("@1 Active", def.description),
        infotext_unpowered = S("@1 Unpowered", def.description),
    }
end

function technic.register_base_machine(nodename, data)
    local registration_context = make_registration_context(nodename, data)
    register_func(registration_context)
end
