local S = technic_cnc.getter

local ta_materials_for_cnc = {
    -- Zinc
    --------
    {
        name = "technic:zinc_block",
        groups = technic_cnc.ta_materials.groups.default,
        textures = { "technic_zinc_block.png" },
        description = S("Zinc")
    },
    -- Cast Iron
    ------------
    {
        name = "technic:cast_iron_block",
        groups = technic_cnc.ta_materials.groups.default,
        textures = { "technic_cast_iron_block.png" },
        description = S("Cast Iron")
    },
    -- Carbon steel
    ---------------
    {
        name = "technic:carbon_steel_block",
        groups = technic_cnc.ta_materials.groups.default,
        textures = { "technic_carbon_steel_block.png" },
        description = S("Carbon Steel")
    },
    -- Brass
    --------
    {
        name = "technic:brass_block",
        groups = technic_cnc.ta_materials.groups.default,
        textures = { "technic_brass_block.png" },
        description = S("Brass")
    },
}
if minetest.get_modpath("technic_worldgen") then
    table.insert(ta_materials_for_cnc, {
        name = "moretrees:rubber_tree_planks",
        groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
        textures = { "technic_rubber_tree_wood.png" },
        description = S("Rubber Tree Planks")
    })
end


technic_cnc.ta_materials.register(ta_materials_for_cnc)
