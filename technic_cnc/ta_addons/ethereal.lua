local S = technic_cnc.getter

if minetest.get_modpath("ethereal") then
    local ta_materials_for_cnc = {
        -- Glostone
        ------------
        {
            name = "ethereal:glostone",
            groups = { cracky = 1, not_in_creative_inventory = 1, light_source = 13 },
            textures = { "glostone.png" },
            description = S("Glo Stone")
        },
        -- Crystal block
        ----------------
        {
            name = "ethereal:crystal_block",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "crystal_block.png" },
            description = S("Crystal")
        },
        -- Misc. Wood types
        -------------------
        {
            name = "ethereal:banana_wood",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "banana_wood.png" },
            description = S("Banana Wood")
        },
        {
            name = "ethereal:birch_wood",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "moretrees_birch_wood.png" },
            description = S("Birch Wood")
        },
        {
            name = "ethereal:frost_wood",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "frost_wood.png" },
            description = S("Frost Wood")
        },
        {
            name = "ethereal:palm_wood",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "moretrees_palm_wood.png" },
            description = S("Palm Wood")
        },
        {
            name = "ethereal:willow_wood",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "willow_wood.png" },
            description = S("Willow Wood")
        },
        {
            name = "ethereal:yellow_wood",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "yellow_wood.png" },
            description = S("Healing Tree Wood")
        },
        {
            name = "ethereal:redwood_wood",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "redwood_wood.png" },
            description = S("Redwood")
        },
        {
            name = "ethereal:sakura_wood",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "ethereal_sakura_wood.png" },
            description = S("Sakura")
        },

        -- Glorious bamboo
        -------------------
        {
            name = "ethereal:bamboo_floor",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "bamboo_floor.png" },
            description = S("Bamboo")
        },
        -- Shaped hedge bush for gardens and parks
        -------------------------------------------
        {
            name = "ethereal:bush",
            groups = { snappy = 3, flamable = 2, not_in_creative_inventory = 1 },
            textures = { "ethereal_bush.png" },
            description = S("Bush")
        },
    }

    -- if baked clay isn't added and barebones ethereal is used

    if not minetest.get_modpath("bakedclay") then
        -- Clay
        ------------
        table.insert(ta_materials_for_cnc, {
            name = "bakedclay:red",
            groups = { cracky = 3, not_in_creative_inventory = 1 },
            textures = { "baked_clay_red.png" },
            description = S("Red Clay")
        })

        table.insert(ta_materials_for_cnc, {
            name = "bakedclay:orange",
            groups = { cracky = 3, not_in_creative_inventory = 1 },
            textures = { "baked_clay_orange.png" },
            description = S("Orange Clay")
        })

        table.insert(ta_materials_for_cnc, {
            name = "bakedclay:grey",
            groups = { cracky = 3, not_in_creative_inventory = 1 },
            textures = { "baked_clay_grey.png" },
            description = S("Grey Clay")
        })
    end

    -- undo-specific items
    if ethereal.mod and ethereal.mod == "undo" then
        table.insert(ta_materials_for_cnc, {
            name = "ethereal:olive_wood",
            groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
            textures = { "olive_wood.png" },
            description = S("Olive Wood")
        })
    end

    technic_cnc.ta_materials.register(ta_materials_for_cnc)
end
