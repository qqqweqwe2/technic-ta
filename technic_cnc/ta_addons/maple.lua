local S = technic_cnc.getter

if minetest.get_modpath("maple") then
    local ta_materials_for_cnc = {
        {
            name = "maple:maple_wood",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "maple_wood.png" },
            description = S("Maple")
        },
    }

    technic_cnc.ta_materials.register(ta_materials_for_cnc)
end
