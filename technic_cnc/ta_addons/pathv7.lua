local S = technic_cnc.getter

if minetest.get_modpath("pathv7") then
    local ta_materials_for_cnc = {
        {
            -- jungle wood already exists (and hence the CNC'd parts would be identical)
            name = "pathv7:bridgewood",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "pathv7_bridgewood.png" },
            description = S("Bridge Wood")
        },
    }

    technic_cnc.ta_materials.register(ta_materials_for_cnc)
end
