local S = technic.getter

return function(registration_context)
    local formspec_size = minetest.get_modpath("mcl_formspec") and "size[9,10]" or "size[8,9]"

    local formspec =
        formspec_size ..
        "list[context;src;" ..
        (4 - registration_context.input_size) .. ",1;" .. registration_context.input_size .. ",1;]" ..
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
    return formspec
end
