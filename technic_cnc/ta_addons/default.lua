local S = technic_cnc.getter

local ta_materials_for_cnc = {
    -- WOOD
    {
        name = "default:junglewood",
        groups = technic_cnc.ta_materials.groups.wood,
        textures = { "default_junglewood.png" },
        description = S("Junglewood"),
    },
    {
        name = "default:pine_wood",
        groups = technic_cnc.ta_materials.groups.wood,
        textures = { "default_pine_wood.png" },
        description = S("Pine"),
    },

    {
        name = "default:acacia_wood",
        groups = technic_cnc.ta_materials.groups.wood,
        textures = { "default_acacia_wood.png" },
        description = S("Acacia"),
    },
    {
        name = "default:aspen_wood",
        groups = technic_cnc.ta_materials.groups.wood,
        textures = { "default_aspen_wood.png" },
        description = S("Aspen"),
    },
    -- COBBLE
    {
        name = "default:mossycobble",
        groups = technic_cnc.ta_materials.groups.stone,
        textures = { "default_mossycobble.png" },
        description = S("Mossy Cobblestone"),
    },
    -- STONE
    {
        name = "default:desert_stone",
        groups = technic_cnc.ta_materials.groups.stone,
        textures = { "default_desert_stone.png" },
        description = S("Desert Stone"),
    },

    -- SANDSTONE
    {
        name = "default:silver_sandstone",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_silver_sandstone.png" },
        description = S("Silver Sandstone"),
    },
    {
        name = "default:desert_sandstone",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_desert_sandstone.png" },
        description = S("Desert Sandstone")
    },
    -- BRICK
    {
        name = "default:silver_sandstone_brick",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_silver_sandstone_brick.png" },
        description = S("Silver Sandstone Brick"),

    },
    {
        name = "default:desert_stonebrick",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_desert_stone_brick.png" },
        description = S("Desert Stone Brick"),
    },
    {
        name = "default:stonebrick",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_stone_brick.png" },
        description = S("Stone Brick"),
    },
    {
        name = "default:sandstonebrick",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_sandstone_brick.png" },
        description = S("Sandstone Brick"),

    },
    {
        name = "default:desert_sandstone_brick",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_desert_sandstone_brick.png" },
        description = S("Desert Sandstone Brick")
    },
    -- BLOCK
    {
        name = "default:stone_block",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_stone_block.png" },
        description = S("Stone Block"),
    },
    {
        name = "default:silver_sandstone_block",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_silver_sandstone_block.png" },
        description = S("Silver Sandstone Block"),
    },
    {
        name = "default:desert_stone_block",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_desert_stone_block.png" },
        description = S("Desert Stone Block"),
    },
    {
        name = "default:sandstone_block",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_sandstone_block.png" },
        description = S("Sandstone Block")
    },
    {
        name = "default:desert_sandstone_block",
        groups = technic_cnc.ta_materials.groups.sandstone,
        textures = { "default_desert_sandstone_block.png" },
        description = S("Desert Sandstone Block")

    },
    -- ICE
    -------
    {
        name = "default:ice",
        groups = { cracky = 3, puts_out_fire = 1, cools_lava = 1, not_in_creative_inventory = 1 },
        textures = { "default_ice.png" },
        description = S("Ice")
    },
    -- OBSIDIAN
    -----------
    {
        name = "default:obsidian_block",
        groups = technic_cnc.ta_materials.groups.default,
        textures = { "default_obsidian_block.png" },
        description = S("Obsidian")
    },
    -- Copper
    ---------
    {
        name = "default:copperblock",
        groups = technic_cnc.ta_materials.groups.default,
        textures = { "default_copper_block.png" },
        description = S("Copper")
    },
    -- Tin
    ------
    {
        name = "default:tinblock",
        groups = technic_cnc.ta_materials.groups.default,
        textures = { "default_tin_block.png" },
        description = S("Tin")
    },
    -- Gold
    -------
    {
        name = "default:goldblock",
        groups = technic_cnc.ta_materials.groups.default,
        textures = { "default_gold_block.png" },
        description = S("Gold")
    },
}

technic_cnc.ta_materials.register(ta_materials_for_cnc)
