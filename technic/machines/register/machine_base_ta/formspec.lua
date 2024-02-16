local S = technic.getter
local path = technic.modpath .. "/machines/register/machine_base_ta"
local gold_unit = assert(loadfile(path .. "/gold_unit.lua"))()

local fs_helpers = pipeworks.fs_helpers

local function get_form_buttons_formspec(pos)
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
    return form_buttons
end

return function(registration_context, pos)
    local formspec_size = minetest.get_modpath("mcl_formspec") and "size[9,10]" or "size[8,9]"

    local formspec =
        formspec_size ..
        "label[" .. (4 - math.min(registration_context.input_size, 4)) .. ",0.6;" .. S("Input") .. "]" ..
        "list[context;src;"
        .. (4 - math.min(registration_context.input_size, 4)) .. ",1;"
        .. math.min(registration_context.input_size, 4) .. ","
        .. math.ceil(registration_context.input_size / 4) .. ";]" ..
        "label[5,0.6;" .. S("Output") .. "]" ..
        "list[context;dst;5,1;2,2;]" ..
        "label[0,0;" .. registration_context.def.description .. "]"
    if registration_context.def.upgrade then
        formspec = formspec ..
            "list[context;upgrade1;1,3;1,1;]" ..
            "list[context;upgrade2;2,3;1,1;]" ..
            "label[1,4;" .. S("Upgrade Slots") .. "]"
    end

    if minetest.get_modpath("mcl_formspec") then
        formspec = formspec ..
            mcl_formspec.get_itemslot_bg(4 - registration_context.input_size, 1, registration_context.input_size, 1) ..
            mcl_formspec.get_itemslot_bg(5, 1, 2, 2) ..
            -- player inventory
            "list[current_player;main;0,5.5;9,3;9]" ..
            mcl_formspec.get_itemslot_bg(0, 5.5, 9, 3) ..
            "list[current_player;main;0,8.74;9,1;]" ..
            mcl_formspec.get_itemslot_bg(0, 8.74, 9, 1)
        if registration_context.def.upgrade then
            formspec = formspec ..
                mcl_formspec.get_itemslot_bg(1, 3, 1, 1) ..
                mcl_formspec.get_itemslot_bg(2, 3, 1, 1)
        end
    else
        formspec = formspec ..
            "list[current_player;main;0,5;8,4;]"
    end

    -- listrings
    formspec = formspec ..
        "listring[context;dst]" ..
        "listring[current_player;main]" ..
        "listring[context;src]" ..
        "listring[current_player;main]"
    if registration_context.def.upgrade then
        formspec = formspec ..
            "listring[context;upgrade1]" ..
            "listring[current_player;main]" ..
            "listring[context;upgrade2]" ..
            "listring[current_player;main]"
    end
    formspec = formspec .. get_form_buttons_formspec(pos)
    formspec = formspec .. gold_unit.get_formspec(pos)
    return formspec
end
