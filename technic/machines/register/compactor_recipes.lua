local S = technic.getter

technic.register_recipe_type("compacting", {
	description = S("Compacting"),
	icon = "technic_recipe_icon_compacting.png" })

function technic.register_compactor_recipe(data)
	data.time = data.time or 4
	technic.register_recipe("compacting", data)
end

minetest.register_alias("default:coal_block", "default:coalblock") --because of previous bug

local recipes = {
	-- default metal ingots
	{"default:copper_ingot 9", "default:copperblock"},
	{"default:bronze_ingot 9", "default:bronzeblock"},
	{"default:gold_ingot 9", "default:goldblock"},
	{"default:steel_ingot 9", "default:steelblock"},
	{"default:tin_ingot 9", "default:tinblock"},

	-- technic metal ingots
	{"technic:brass_ingot 9", "technic:brass_block"},
	{"technic:carbon_steel_ingot 9", "technic:carbon_steel_block"},
	{"technic:cast_iron_ingot 9", "technic:cast_iron_block"},
	{"technic:chromium_ingot 9", "technic:chromium_block"},
	{"technic:lead_ingot 9", "technic:lead_block"},
	{"technic:stainless_steel_ingot 9", "technic:stainless_steel_block"},
	{"technic:uranium0_ingot 9", "technic:uranium0_block"},
	{"technic:uranium35_ingot 9", "technic:uranium35_block"},
	{"technic:uranium_ingot 9", "technic:uranium_block"},
	{"technic:zinc_ingot 9", "technic:zinc_block"},
	{"technic:sulfur_lump 9", "technic:sulfur_block"},

	-- default gems
	{"default:diamond 9", "default:diamondblock"},
	{"default:mese_crystal 9", "default:mese"},

	-- default shards
	{"default:obsidian_shard 9", "default:obsidian"},
	{"default:mese_crystal_fragment 9", "default:mese_crystal"},

	-- default carbon
	{"default:coal_lump 9", "default:coalblock"},

	-- default clay
	{"default:clay_lump 4", "default:clay"},
	{"default:clay_brick 4", "default:brick"}
}


if minetest.get_modpath("ethereal") then
	table.insert(recipes, {"ethereal:crystal_ingot 9", "ethereal:crystal_block"})
end

if minetest.get_modpath("lavastuff") then
	table.insert(recipes, {"lavastuff:ingot 9", "lavastuff:block"})
end

if minetest.get_modpath("moreores") then
	table.insert(recipes, {"moreores:mithril_ingot 9", "moreores:mithril_block"})
	table.insert(recipes, {"moreores:silver_ingot 9", "moreores:silver_block"})
end

if minetest.get_modpath("xtraores") then
	-- metal ingots
	table.insert(recipes, {"xtraores:adamantite_ingot 9", "xtraores:adamantite_block"})
	table.insert(recipes, {"xtraores:cobalt_ingot 9", "xtraores:cobalt_block"})
	table.insert(recipes, {"xtraores:geminitinum_ingot 9", "xtraores:geminitinum_block"})
	table.insert(recipes, {"xtraores:osmium_ingot 9", "xtraores:osmium_block"})
	table.insert(recipes, {"xtraores:platinum_ingot 9", "xtraores:platinum_block"})
	table.insert(recipes, {"xtraores:rarium_ingot 9", "xtraores:rarium_block"})
	table.insert(recipes, {"xtraores:titanium_ingot 9", "xtraores:titanium_block"})
	table.insert(recipes, {"xtraores:unobtainium_ingot 9", "xtraores:unobtainium_block"})

	-- blocks
	table.insert(recipes, {"xtraores:adamantite_block 8", "xtraores:adamantite_block_compressed"})
	table.insert(recipes, {"xtraores:cobalt_block 8", "xtraores:cobalt_block_compressed"})
		-- no geminitinum
	table.insert(recipes, {"xtraores:osmium_block 8", "xtraores:osmium_block_compressed"})
	table.insert(recipes, {"xtraores:platinum_block 8", "xtraores:platinum_block_compressed"})
	table.insert(recipes, {"xtraores:rarium_block 8", "xtraores:rarium_block_compressed"})
	table.insert(recipes, {"xtraores:titanium_block 8", "xtraores:titanium_block_compressed"})
	table.insert(recipes, {"xtraores:unobtainium_block 8", "xtraores:unobtainium_block_compressed"})
end

if minetest.get_modpath("underch") then
	-- gems
	table.insert(recipes, {"underch:ruby 9", "underch:ruby_block"})
	table.insert(recipes, {"underch:emerald 9", "underch:emerald_block"})
	table.insert(recipes, {"underch:aquamarine 9", "underch:aquamarine_block"})
	table.insert(recipes, {"underch:amethyst 9", "underch:amethyst_block"})
	table.insert(recipes, {"underch:saphire 9", "underch:saphire_block"})
	table.insert(recipes, {"underch:quartz 9", "underch:quartz_block"})

	-- eyes
	table.insert(recipes, {"underch:blackeye_item 9", "underch:blackeye_block"})
	table.insert(recipes, {"underch:greeneye_item 9", "underch:greeneye_block"})
	table.insert(recipes, {"underch:redeye_item 9", "underch:redeye_block"})
	table.insert(recipes, {"underch:purpleeye_item 9", "underch:purpleeye_block"})

	--clay
	table.insert(recipes, {"underch:clay_lump 4", "underch:clay"})

end

if minetest.get_modpath("moreblocks") then
	-- regular
	table.insert(recipes, {"default:cobble 9", "moreblocks:cobble_compressed"})
	table.insert(recipes, {"default:dirt 9", "moreblocks:dirt_compressed"})

	-- compressed
	table.insert(recipes, {"moreblocks:cobble_compressed 9", "moreblocks:cobble_condensed"})
end

if minetest.get_modpath("compressed") and minetest.get_modpath("underch") then
	table.insert(recipes, {"underch:afualite_cobble 9", "compressed:afualite"})
	table.insert(recipes, {"underch:amphibolite_cobble 9", "compressed:amphibolite"})
	table.insert(recipes, {"underch:andesite_cobble 9", "compressed:andesite"})
	table.insert(recipes, {"underch:aplite_cobble 9", "compressed:aplite"})
	table.insert(recipes, {"underch:basalt_cobble 9", "compressed:basalt"})
	table.insert(recipes, {"underch:dark_vindesite_cobble 9", "compressed:dark_vindesite"})
	table.insert(recipes, {"underch:diorite_cobble 9", "compressed:diorite"})
	table.insert(recipes, {"underch:dolomite_cobble 9", "compressed:dolomite"})
	table.insert(recipes, {"underch:emutite_cobble 9", "compressed:emutite"})
	table.insert(recipes, {"underch:gabbro_cobble 9", "compressed:gabbro"})
	table.insert(recipes, {"underch:gneiss_cobble 9", "compressed:gneiss"})
	table.insert(recipes, {"underch:granite_cobble 9", "compressed:granite"})
	table.insert(recipes, {"underch:green_slimestone_cobble 9", "compressed:green_slimestone"})
	table.insert(recipes, {"underch:hektorite_cobble 9", "compressed:hektorite"})
	table.insert(recipes, {"underch:limestone_cobble 9", "compressed:limestone"})
	table.insert(recipes, {"underch:marble_cobble 9", "compressed:marble"})
	table.insert(recipes, {"underch:omphyrite_cobble 9", "compressed:omphyrite"})
	table.insert(recipes, {"underch:pegmatite_cobble 9", "compressed:pegmatite"})
	table.insert(recipes, {"underch:peridotite_cobble 9", "compressed:peridotite"})
	table.insert(recipes, {"underch:phonolite_cobble 9", "compressed:phonolite"})
	table.insert(recipes, {"underch:phylite_cobble 9", "compressed:phylite"})
	table.insert(recipes, {"underch:purple_slimestone_cobble 9", "compressed:purple_slimestone"})
	table.insert(recipes, {"underch:quartzite_cobble 9", "compressed:quartzite"})
	table.insert(recipes, {"underch:red_slimestone_cobble 9", "compressed:red_slimestone"})
	table.insert(recipes, {"underch:schist_cobble 9", "compressed:schist"})
	table.insert(recipes, {"underch:sichamine_cobble 9", "compressed:sichamine"})
	table.insert(recipes, {"underch:slate_cobble 9", "compressed:slate"})
	table.insert(recipes, {"underch:vindesite_cobble 9", "compressed:vindesite"})
end

if minetest.get_modpath("condensed") and minetest.get_modpath("underch") then
	table.insert(recipes, {"compressed:afualite 9", "condensed:afualite"})
	table.insert(recipes, {"compressed:amphibolite 9", "condensed:amphibolite"})
	table.insert(recipes, {"compressed:andesite 9", "condensed:andesite"})
	table.insert(recipes, {"compressed:aplite 9", "condensed:aplite"})
	table.insert(recipes, {"compressed:basalt 9", "condensed:basalt"})
	table.insert(recipes, {"compressed:dark_vindesite 9", "condensed:dark_vindesite"})
	table.insert(recipes, {"compressed:diorite 9", "condensed:diorite"})
	table.insert(recipes, {"compressed:dolomite 9", "condensed:dolomite"})
	table.insert(recipes, {"compressed:emutite 9", "condensed:emutite"})
	table.insert(recipes, {"compressed:gabbro 9", "condensed:gabbro"})
	table.insert(recipes, {"compressed:gneiss 9", "condensed:gneiss"})
	table.insert(recipes, {"compressed:granite 9", "condensed:granite"})
	table.insert(recipes, {"compressed:green_slimestone 9", "condensed:green_slimestone"})
	table.insert(recipes, {"compressed:hektorite 9", "condensed:hektorite"})
	table.insert(recipes, {"compressed:limestone 9", "condensed:limestone"})
	table.insert(recipes, {"compressed:marble 9", "condensed:marble"})
	table.insert(recipes, {"compressed:omphyrite 9", "condensed:omphyrite"})
	table.insert(recipes, {"compressed:pegmatite 9", "condensed:pegmatite"})
	table.insert(recipes, {"compressed:peridotite 9", "condensed:peridotite"})
	table.insert(recipes, {"compressed:phonolite 9", "condensed:phonolite"})
	table.insert(recipes, {"compressed:phylite 9", "condensed:phylite"})
	table.insert(recipes, {"compressed:purple_slimestone 9", "condensed:purple_slimestone"})
	table.insert(recipes, {"compressed:quartzite 9", "condensed:quartzite"})
	table.insert(recipes, {"compressed:red_slimestone 9", "condensed:red_slimestone"})
	table.insert(recipes, {"compressed:schist 9", "condensed:schist"})
	table.insert(recipes, {"compressed:sichamine 9", "condensed:sichamine"})
	table.insert(recipes, {"compressed:slate 9", "condensed:slate"})
	table.insert(recipes, {"compressed:vindesite 9", "condensed:vindesite"})
end

if minetest.get_modpath("xdecor") then
	table.insert(recipes, {"default:ice 9", "xdecor:packed_ice"})
end

if minetest.get_modpath("elements") then
	table.insert(recipes, {"elements:aluminum_ingot 9", "elements:aluminum_block"})
	table.insert(recipes, {"elements:nickel_ingot 9", "elements:nickel_block"})
	table.insert(recipes, {"elements:lithium_ingot 9", "elements:lithium_block"})
	table.insert(recipes, {"default:desert_cobble 9", "compressed:desert_stone"})
	table.insert(recipes, {"compressed:desert_stone 9", "condensed:desert_stone"})
	table.insert(recipes, {"farming:string 36", "wool:white"})
end

for _, data in pairs(recipes) do
	technic.register_compactor_recipe({input = {data[1]}, output = data[2]})
end
