local path = technic.modpath .. "/machines/register/machine_base_ta"
local run_func = assert(loadfile(path .. "/run.lua"))()
local formspec_func = assert(loadfile(path .. "/formspec.lua"))()

local fs_helpers = pipeworks.fs_helpers
local tube_entry = "^pipeworks_tube_connection_metallic.png"

local connect_default = { "bottom", "back", "left", "right" }

local function update_formspec(registration_context, pos)
    local node = minetest.get_node(pos)
    local meta = minetest.get_meta(pos)

    local form_buttons = ""
    if not string.find(node.name, ":lv_") then
        form_buttons = fs_helpers.cycling_button(
            meta,
            pipeworks.button_base,
            "splitstacks",
            {
                pipeworks.button_off,
                pipeworks.button_on
            }
        ) .. pipeworks.button_label
    end
    meta:set_string("formspec", registration_context.formspec .. form_buttons)
end

local on_receive_fields = function(registration_context, pos, formname, fields, sender)
    if fields.quit then return end
    if not pipeworks.may_configure(pos, sender) then return end
    fs_helpers.on_receive_fields(pos, fields)

    update_formspec(registration_context, pos)
end

local on_construct = function(registration_context, pos)
    local meta = minetest.get_meta(pos)

    meta:set_string("infotext", registration_context.def.description)
    meta:set_int("tube_time", 0)
    local inv = meta:get_inventory()
    inv:set_size("src", registration_context.input_size)
    inv:set_size("dst", 4)
    inv:set_size("upgrade1", 1)
    inv:set_size("upgrade2", 1)
    update_formspec(registration_context, pos)
end

local function register(registration_context, data)
    local front_tile = data.is_active and "_front_active.png" or "_front.png"
    local nodename = data.is_active
        and registration_context.nodename .. "_active"
        or registration_context.nodename

    minetest.register_node(registration_context.colon .. nodename, {
        description = registration_context.def.description,
        tiles = {
            registration_context.texture_prefix .. "_top.png" .. registration_context.tentry,
            registration_context.texture_prefix .. "_bottom.png" .. registration_context.tentry,
            registration_context.texture_prefix .. "_side.png" .. registration_context.tentry,
            registration_context.texture_prefix .. "_side.png" .. registration_context.tentry,
            registration_context.texture_prefix .. "_side.png" .. registration_context.tentry,
            registration_context.texture_prefix .. front_tile
        },
        paramtype2 = "facedir",
        drop = data.drop,
        groups = data.groups,
        _mcl_blast_resistance = 1,
        _mcl_hardness = 0.8,
        connect_sides = registration_context.def.connect_sides or connect_default,
        legacy_facedir_simple = true,
        sounds = technic.sounds.node_sound_wood_defaults(),
        tube = registration_context.def.tube and registration_context.tube or nil,
        on_construct = data.on_construct,
        can_dig = technic.machine_can_dig,
        allow_metadata_inventory_put = technic.machine_inventory_put,
        allow_metadata_inventory_take = technic.machine_inventory_take,
        allow_metadata_inventory_move = technic.machine_inventory_move,
        technic_run = run_func(registration_context),
        after_place_node = data.after_place_node,
        after_dig_node = data.after_dig_node,
        technic_disabled_machine_name = data.technic_disabled_machine_name,
        on_receive_fields = function(pos, formname, fields, sender)
            return on_receive_fields(registration_context, pos, formname, fields, sender)
        end,
    })
    technic.register_machine(registration_context.def.tier, nodename, technic.receiver)
end

return function(registration_context)
    registration_context.tube = technic.new_default_tube()
    if registration_context.def.can_insert then
        registration_context.tube.can_insert = registration_context.def.can_insert
    end
    if registration_context.def.insert_object then
        registration_context.tube.insert_object = registration_context.def.insert_object
    end
    registration_context.tentry = tube_entry
    registration_context.formspec = formspec_func(registration_context)

    if registration_context.ltier == "lv" then
        registration_context.tentry = ""
    end

    register(registration_context, {
        is_active = false,
        groups = registration_context.groups,
        on_construct = function(pos)
            return on_construct(registration_context, pos)
        end,
        after_place_node = registration_context.def.tube and pipeworks.after_place,
        after_dig_node = technic.machine_after_dig_node,
    })

    register(registration_context, {
        is_active = true,
        drop = registration_context.nodename,
        groups = registration_context.active_groups,
        technic_disabled_machine_name = registration_context.nodename,
    })
end
