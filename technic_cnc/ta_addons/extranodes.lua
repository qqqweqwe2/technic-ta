local S = technic_cnc.getter

if minetest.get_modpath("extranodes") then
    local ta_materials_for_cnc = {
        {
            name = "technic:plastic_clean",
            groups = { dig_immediate = 2, not_in_creative_inventory = 1 },
            textures = { "technic_plastic_clean.png" },
            description = S("Plastic Clean")
        },
    }
    technic_cnc.ta_materials.register(ta_materials_for_cnc)
end
