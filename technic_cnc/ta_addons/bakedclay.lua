local S = technic_cnc.getter

if minetest.get_modpath("bakedclay") then
    local clay = {
        { "white",      "White" },
        { "grey",       "Grey" },
        { "black",      "Black" },
        { "red",        "Red" },
        { "yellow",     "Yellow" },
        { "green",      "Green" },
        { "cyan",       "Cyan" },
        { "blue",       "Blue" },
        { "magenta",    "Magenta" },
        { "orange",     "Orange" },
        { "violet",     "Violet" },
        { "brown",      "Brown" },
        { "pink",       "Pink" },
        { "dark_grey",  "Dark Grey" },
        { "dark_green", "Dark Green" },
    }

    for _, c in ipairs(clay) do
        technic_cnc.register_all("bakedclay:" .. c[1],
            { cracky = 3, not_in_creative_inventory = 1 },
            { "baked_clay_" .. c[1] .. ".png" },
            S(c[2] .. " Clay"))
    end
end
