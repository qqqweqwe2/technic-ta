local S = technic.getter
local path = technic.modpath .. "/machines/register/machine_base_ta"
local gold_unit = assert(loadfile(path .. "/gold_unit.lua"))()
local machine_digilines = assert(loadfile(path .. "/digilines.lua"))()

local fs_helpers = pipeworks.fs_helpers

local function get_form_buttons_formspec(pos)
    local node = minetest.get_node(pos)
    local meta = minetest.get_meta(pos)

    local form_buttons = ""
    local button_base  = "image_button[0,1.3;1,0.6"
    local button_label = "label[0.9,1.31;" .. S("Allow splitting incoming stacks from tubes") .. "]"
    if not string.find(node.name, ":lv_") then
        form_buttons = fs_helpers.cycling_button(
            meta,
            button_base,
            "splitstacks",
            {
                pipeworks.button_off,
                pipeworks.button_on
            }
        ) .. button_label
    end
    return form_buttons
end

local function make_formspec_context(registration_context)
    local has_mcl = minetest.get_modpath("mcl_formspec")
    local input_slot_width = 4
    local input_x = 4 - math.min(registration_context.input_size, input_slot_width)
    local output_slot_width = registration_context.output_size > 4 and 3 or 2
    local output_slot_height = math.ceil(registration_context.output_size / output_slot_width)
    local form_width = (has_mcl and 1 or 0) + 8
    local form_height = 7 + (has_mcl and 1 or 0) + math.max(output_slot_height, 2)
    local container_x = 0
    return {
        form_size = {
            width = form_width,
            height = form_height,
        },
        input_label = {
            x = input_x,
            y = 0.6,
        },
        input = {
            x = input_x,
            y = 1,
            width = math.min(registration_context.input_size, input_slot_width),
            height = math.ceil(registration_context.input_size / input_slot_width),
        },
        output = {
            x = 5,
            y = 1,
            width = math.min(registration_context.output_size, output_slot_width),
            height = output_slot_height,
        },
        container = {
            x = container_x,
            y = 1 + math.max(output_slot_height, 2),
        },
    }
end
return function(registration_context, pos)
    local formspec_context = make_formspec_context(registration_context)

    local formspec_size = ("size[%f,%f]"):format(formspec_context.form_size.width, formspec_context.form_size.height)
    local formspec = {}
    formspec[#formspec + 1] = formspec_size
    formspec[#formspec + 1] = ("label[0,0;%s]"):format(minetest.formspec_escape(registration_context.def.description))
    formspec[#formspec + 1] = ("label[%f,%f;%s]"):format(
        formspec_context.input_label.x,
        formspec_context.input_label.y,
        minetest.formspec_escape(S("Input"))
    )
    formspec[#formspec + 1] = ("list[context;src;%f,%f;%f,%f;]"):format(
        formspec_context.input.x,
        formspec_context.input.y,
        formspec_context.input.width,
        formspec_context.input.height
    )
    formspec[#formspec + 1] = ("label[%f,%f;%s]"):format(
        formspec_context.output.x,
        formspec_context.output.y - 0.4,
        minetest.formspec_escape(S("Output"))
    )
    formspec[#formspec + 1] = ("list[context;dst;%f,%f;%f,%f;]"):format(
        formspec_context.output.x,
        formspec_context.output.y,
        formspec_context.output.width,
        formspec_context.output.height
    )
    -- listrings
    formspec[#formspec + 1] = "listring[context;dst]"
    formspec[#formspec + 1] = "listring[current_player;main]"
    formspec[#formspec + 1] = "listring[context;src]"
    formspec[#formspec + 1] = "listring[current_player;main]"

    -- Upgrade slots
    if registration_context.def.upgrade then
        formspec[#formspec + 1] = "listring[context;upgrade1]"
        formspec[#formspec + 1] = "listring[current_player;main]"
        formspec[#formspec + 1] = "listring[context;upgrade2]"
        formspec[#formspec + 1] = "listring[current_player;main]"
    end
    formspec[#formspec + 1] = ("container[%f,%f]"):format(formspec_context.container.x, formspec_context.container.y)
    if registration_context.def.upgrade then
        formspec[#formspec + 1] = ("list[context;upgrade1;1,0;1,1;]")
        formspec[#formspec + 1] = ("list[context;upgrade2;2,0;1,1;]")
        formspec[#formspec + 1] = ("label[1,1;%s]"):format(minetest.formspec_escape(S("Upgrade Slots")))
    end

    if minetest.get_modpath("mcl_formspec") then
        formspec[#formspec + 1] = mcl_formspec.get_itemslot_bg(4 - registration_context.input_size, 1,
            registration_context.input_size, 1)
        formspec[#formspec + 1] = mcl_formspec.get_itemslot_bg(5, 1, 2, 2)
        formspec[#formspec + 1] = "list[current_player;main;0,2.5;9,3;9]"
        formspec[#formspec + 1] = mcl_formspec.get_itemslot_bg(0, 2.5, 9, 3)
        formspec[#formspec + 1] = "list[current_player;main;0,5.74;9,1;]"
        formspec[#formspec + 1] = mcl_formspec.get_itemslot_bg(0, 5.74, 9, 1)
        if registration_context.def.upgrade then
            formspec[#formspec + 1] = mcl_formspec.get_itemslot_bg(1, 0, 1, 1)
            formspec[#formspec + 1] = mcl_formspec.get_itemslot_bg(2, 0, 1, 1)
        end
    else
        formspec[#formspec + 1] = "list[current_player;main;0,2;8,4;]"
    end
    formspec[#formspec + 1] = get_form_buttons_formspec(pos)
    formspec[#formspec + 1] = gold_unit.get_formspec(pos)
    formspec[#formspec + 1] = "container_end[]"
    formspec[#formspec + 1] = machine_digilines.get_formspec(pos)
    return table.concat(formspec, "")
end
