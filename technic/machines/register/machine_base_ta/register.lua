local path = technic.modpath .. "/machines/register/machine_base_ta"
local run_func = assert(loadfile(path .. "/run.lua"))()
local formspec_func = assert(loadfile(path .. "/formspec.lua"))()

local fs_helpers = pipeworks.fs_helpers
local tube_entry = "^pipeworks_tube_connection_metallic.png"

local connect_default = { "bottom", "back", "left", "right" }

return function(registration_context)
    local tentry = tube_entry
    local formspec = formspec_func(registration_context)

    if registration_context.ltier == "lv" then
        tentry = ""
    end

    local tube = technic.new_default_tube()
    if registration_context.def.can_insert then
        tube.can_insert = registration_context.def.can_insert
    end
    if registration_context.def.insert_object then
        tube.insert_object = registration_context.def.insert_object
    end

    minetest.register_node(registration_context.colon .. registration_context.nodename, {
        description = registration_context.def.description,
        tiles = {
            registration_context.texture_prefix .. "_top.png" .. tentry,
            registration_context.texture_prefix .. "_bottom.png" .. tentry,
            registration_context.texture_prefix .. "_side.png" .. tentry,
            registration_context.texture_prefix .. "_side.png" .. tentry,
            registration_context.texture_prefix .. "_side.png" .. tentry,
            registration_context.texture_prefix .. "_front.png"
        },
        paramtype2 = "facedir",
        groups = registration_context.groups,
        _mcl_blast_resistance = 1,
        _mcl_hardness = 0.8,
        tube = registration_context.def.tube and tube or nil,
        connect_sides = registration_context.def.connect_sides or connect_default,
        legacy_facedir_simple = true,
        sounds = technic.sounds.node_sound_wood_defaults(),
        on_construct = function(pos)
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

            meta:set_string("infotext", registration_context.def.description)
            meta:set_int("tube_time", 0)
            meta:set_string("formspec", formspec .. form_buttons)
            local inv = meta:get_inventory()
            inv:set_size("src", registration_context.input_size)
            inv:set_size("dst", 4)
            inv:set_size("upgrade1", 1)
            inv:set_size("upgrade2", 1)
        end,
        can_dig = technic.machine_can_dig,
        allow_metadata_inventory_put = technic.machine_inventory_put,
        allow_metadata_inventory_take = technic.machine_inventory_take,
        allow_metadata_inventory_move = technic.machine_inventory_move,
        technic_run = run_func(registration_context),
        after_place_node = registration_context.def.tube and pipeworks.after_place,
        after_dig_node = technic.machine_after_dig_node,
        on_receive_fields = function(pos, formname, fields, sender)
            if fields.quit then return end
            if not pipeworks.may_configure(pos, sender) then return end
            fs_helpers.on_receive_fields(pos, fields)
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
            meta:set_string("formspec", formspec .. form_buttons)
        end,
    })

    minetest.register_node(registration_context.colon .. registration_context.nodename .. "_active", {
        description = registration_context.def.description,
        tiles = {
            registration_context.texture_prefix .. "_top.png" .. tentry,
            registration_context.texture_prefix .. "_bottom.png" .. tentry,
            registration_context.texture_prefix .. "_side.png" .. tentry,
            registration_context.texture_prefix .. "_side.png" .. tentry,
            registration_context.texture_prefix .. "_side.png" .. tentry,
            registration_context.texture_prefix .. "_front_active.png"
        },
        paramtype2 = "facedir",
        drop = registration_context.nodename,
        groups = registration_context.active_groups,
        _mcl_blast_resistance = 1,
        _mcl_hardness = 0.8,
        connect_sides = registration_context.def.connect_sides or connect_default,
        legacy_facedir_simple = true,
        sounds = technic.sounds.node_sound_wood_defaults(),
        tube = registration_context.def.tube and tube or nil,
        can_dig = technic.machine_can_dig,
        allow_metadata_inventory_put = technic.machine_inventory_put,
        allow_metadata_inventory_take = technic.machine_inventory_take,
        allow_metadata_inventory_move = technic.machine_inventory_move,
        technic_run = run_func(registration_context),
        technic_disabled_machine_name = registration_context.nodename,
        on_receive_fields = function(pos, formname, fields, sender)
            if fields.quit then return end
            if not pipeworks.may_configure(pos, sender) then return end
            fs_helpers.on_receive_fields(pos, fields)
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
            meta:set_string("formspec", formspec .. form_buttons)
        end,
    })

    technic.register_machine(registration_context.def.tier, registration_context.nodename, technic.receiver)
    technic.register_machine(registration_context.def.tier, registration_context.nodename .. "_active", technic.receiver)
end
