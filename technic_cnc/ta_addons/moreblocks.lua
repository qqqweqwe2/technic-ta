local S = technic_cnc.getter

if minetest.get_modpath("moreblocks") then
    local ta_materials_for_cnc = {
        -- Tiles
        ------------
        {
            name = "moreblocks:stone_tile",
            groups = technic_cnc.ta_materials.groups.stone,
            textures = { "moreblocks_stone_tile.png" },
            description = S("Stone Tile")
        },

        {
            name = "moreblocks:split_stone_tile",
            groups = technic_cnc.ta_materials.groups.stone,
            textures = { "moreblocks_split_stone_tile.png" },
            description = S("Split Stone Tile")
        },

        {
            name = "moreblocks:checker_stone_tile",
            groups = technic_cnc.ta_materials.groups.stone,
            textures = { "moreblocks_checker_stone_tile.png" },
            description = S("Checker Stone Tile")
        },

        {
            name = "moreblocks:cactus_checker",
            groups = technic_cnc.ta_materials.groups.stone,
            textures = { "moreblocks_cactus_checker.png" },
            description = S("Cactus Checker")
        },

        -- Bricks
        ------------
        {
            name = "moreblocks:cactus_brick",
            groups = { cracky = 3, not_in_creative_inventory = 1 },
            textures = { "moreblocks_cactus_brick.png" },
            description = S("Cactus Brick")
        },

        {
            name = "moreblocks:grey_bricks",
            groups = { cracky = 3, not_in_creative_inventory = 1 },
            textures = { "moreblocks_grey_bricks.png" },
            description = S("Grey Bricks")
        },

        -- Metals
        ------------
        {
            name = "moreblocks:copperpatina",
            groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
            textures = { "moreblocks_copperpatina.png" },
            description = S("Copper Patina")
        },

        -- Glass types
        ------------
        {
            name = "moreblocks:clean_glass",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1 },
            textures = { "moreblocks_clean_glass.png" },
            description = S("Clean Glass")
        },

        {
            name = "moreblocks:coal_glass",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1 },
            textures = { "moreblocks_coal_glass.png" },
            description = S("Coal Glass")
        },

        {
            name = "moreblocks:iron_glass",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1 },
            textures = { "moreblocks_iron_glass.png" },
            description = S("Iron Glass")
        },
    }

    technic_cnc.ta_materials.register(ta_materials_for_cnc)
end
