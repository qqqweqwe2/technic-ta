local S = technic_cnc.getter

local addons_path = minetest.get_modpath("technic_cnc") .. "/ta_addons/"
technic_cnc.ta_materials = {}

technic_cnc.ta_materials.register = function(materials)
    for _, material in ipairs(materials) do
        technic_cnc.register_all(material.name, material.groups, material.textures, material.description)
    end
end

technic_cnc.ta_materials.groups = {
    default = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
    stone = { cracky = 3, stone = 1, not_in_creative_inventory = 1 },
    sandstone = { crumbly = 2, cracky = 3, stone = 1, not_in_creative_inventory = 1 },
    wood = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1 },
}

for _, addon_name in ipairs({
    "default",
    "technic",
    "ethereal",
    "moreblocks",
    "pathv7",
    "maple",
    "extranodes",
    "farming",
    "bakedclay",
}) do
    dofile(addons_path .. addon_name .. ".lua")
end
