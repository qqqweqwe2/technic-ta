local S = technic_cnc.getter

if minetest.get_modpath("farming") and farming.mod and (farming.mod == "redo" or farming.mod == "undo") then
    local ta_materials_for_cnc = {
        {
            name = "farming:hemp_block",
            groups = { snappy = 1, oddly_breakable_by_hand = 1, flammable = 2, not_in_creative_inventory = 1 },
            textures = { "farming_hemp_block.png" },
            description = S("Hemp Block")
        },
    }

    technic_cnc.ta_materials.register(ta_materials_for_cnc)
end
