-- API for the technic CNC machine
-- Again code is adapted from the NonCubic Blocks MOD v1.4 by yves_de_beck

local S = technic_cnc.getter
local ALPHA_CLIP = minetest.features.use_texture_alpha_string_modes and "clip" or true
local recycling_registered = {}

-- REGISTER NONCUBIC FORMS, CREATE MODELS AND RECIPES:
------------------------------------------------------

-- Define slope boxes for the various nodes
-------------------------------------------
technic_cnc.programs = {
	{ suffix  = "technic_cnc_stick",
		model = {-0.15, -0.5, -0.15, 0.15, 0.5, 0.15},
		desc  = S("Stick")
	},

	{ suffix  = "technic_cnc_element_end_double",
		model = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.5},
		desc  = S("Element End Double")
	},

	{ suffix  = "technic_cnc_element_cross_double",
		model = {
			{0.3, -0.5, -0.3, 0.5, 0.5, 0.3},
			{-0.3, -0.5, -0.5, 0.3, 0.5, 0.5},
			{-0.5, -0.5, -0.3, -0.3, 0.5, 0.3}},
		desc  = S("Element Cross Double")
	},

	{ suffix  = "technic_cnc_element_t_double",
		model = {
			{-0.3, -0.5, -0.5, 0.3, 0.5, 0.3},
			{-0.5, -0.5, -0.3, -0.3, 0.5, 0.3},
			{0.3, -0.5, -0.3, 0.5, 0.5, 0.3}},
		desc  = S("Element T Double")
	},

	{ suffix  = "technic_cnc_element_edge_double",
		model = {
			{-0.3, -0.5, -0.5, 0.3, 0.5, 0.3},
			{-0.5, -0.5, -0.3, -0.3, 0.5, 0.3}},
		desc  = S("Element Edge Double")
	},

	{ suffix  = "technic_cnc_element_straight_double",
		model = {-0.3, -0.5, -0.5, 0.3, 0.5, 0.5},
		desc  = S("Element Straight Double")
	},

	{ suffix  = "technic_cnc_element_end",
		model = {-0.3, -0.5, -0.3, 0.3, 0, 0.5},
		desc  = S("Element End")
	},

	{ suffix  = "technic_cnc_element_cross",
		model = {
			{0.3, -0.5, -0.3, 0.5, 0, 0.3},
			{-0.3, -0.5, -0.5, 0.3, 0, 0.5},
			{-0.5, -0.5, -0.3, -0.3, 0, 0.3}},
		desc  = S("Element Cross")
	},

	{ suffix  = "technic_cnc_element_t",
		model = {
			{-0.3, -0.5, -0.5, 0.3, 0, 0.3},
			{-0.5, -0.5, -0.3, -0.3, 0, 0.3},
			{0.3, -0.5, -0.3, 0.5, 0, 0.3}},
		desc  = S("Element T")
	},

	{ suffix  = "technic_cnc_element_edge",
		model = {
			{-0.3, -0.5, -0.5, 0.3, 0, 0.3},
			{-0.5, -0.5, -0.3, -0.3, 0, 0.3}},
		desc  = S("Element Edge")
	},

	{ suffix  = "technic_cnc_element_straight",
		model = {-0.3, -0.5, -0.5, 0.3, 0, 0.5},
		desc  = S("Element Straight")
	},

	{ suffix  = "technic_cnc_oblate_spheroid",
		model = "technic_cnc_oblate_spheroid.obj",
		desc  = S("Oblate spheroid"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -6/16,  4/16, -6/16, 6/16,  8/16, 6/16 },
				{ -8/16, -4/16, -8/16, 8/16,  4/16, 8/16 },
				{ -6/16, -8/16, -6/16, 6/16, -4/16, 6/16 }
			}
		}
	},

	{ suffix  = "technic_cnc_sphere",
		model = "technic_cnc_sphere.obj",
		desc  = S("Sphere")
	},


	{ suffix  = "technic_cnc_sphere_half",
		model = "technic_cnc_sphere_half.obj",
		desc  = S("Half Sphere"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -0.5,  -0.5, -0.5, 0.5,  0, 0.5 },
			}
		}
	},

	{ suffix  = "technic_cnc_sphere_quarter",
		model = "technic_cnc_sphere_quarter.obj",
		desc  = S("Quarter Sphere"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -0.5,  -0.5, -0.5, 0.5,  0, 0 },
			}
		}
	},

	{ suffix  = "technic_cnc_cylinder_half_corner",
		model = "technic_cnc_cylinder_half_corner.obj",
		desc  = S("Half Cylinder Corner"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -0.5,  -0.5, -0.5, 0.5,  0, 0.5 },
			}
		}
	},

	{ suffix  = "technic_cnc_twocurvededge",
		model = "technic_cnc_two_curved_edge.obj",
		desc  = S("Two Curved Edge/Corner Block")
	},

	{ suffix  = "technic_cnc_onecurvededge",
		model = "technic_cnc_one_curved_edge.obj",
		desc  = S("One Curved Edge Block")
	},

	{ suffix  = "technic_cnc_innercurvededge",
		model = "technic_cnc_inner_curved_edge.obj",
		desc  = S("Inner Curved Edge Block")
	},

	{ suffix  = "technic_cnc_opposedcurvededge",
		model = "technic_cnc_opposed_curved_edge.obj",
		desc  = S("Opposed Curved Edges Block")
	},

	-- large radius

	{ suffix  = "technic_cnc_onecurvededge_lr",
		model = "technic_cnc_one_curved_edge_lr.obj",
		desc  = S("One Curved Edge LR Block")
	},

	{ suffix  = "technic_cnc_twocurvededge_lr",
		model = "technic_cnc_two_curved_edge_lr.obj",
		desc  = S("Two Curved Edges LR Block")
	},

	-- 4/16 Diagonal truss

	{ suffix  = "technic_cnc_diagonal_truss",
		model = "technic_cnc_diagonal_truss.obj",
		desc  = S("Diagonal Truss"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -0.5,  -0.5, -0.25, 0.5,  0.5, 0.25 },
			}
		}
	},

	{ suffix  = "technic_cnc_diagonal_truss_cross",
		model  = "technic_cnc_diagonal_truss_cross.obj",
		desc  = S("Diagonal Truss Cross"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -0.5,  -0.5, -0.25, 0.5,  0.5, 0.25 },
			}
		}
	},

	-- 2/16 Beams

	{ suffix  = "technic_cnc_beam216",
		model = "technic_cnc_beam_216.obj",
		desc  = S("2/16 Beam"),
		cbox  = {
			type = "fixed",
			fixed = {
				{0.5, 0.5, 0.065, -0.5, 0, -0.065},
			}
		}
	},

	{ suffix  = "technic_cnc_beam216_cross",
		model = "technic_cnc_beam_216_cross.obj",
		desc  = S("2/16 Beam Cross"),
		cbox  = {
			type = "fixed",
			fixed = {
				{0.5, 0.5, 0.5, -0.5, 0, -0.5},
			}
		}
	},

	{ suffix  = "technic_cnc_beam216_tee",
		model = "technic_cnc_beam_216_tee.obj",
		desc  = S("2/16 Beam T"),
		cbox  = {
			type = "fixed",
			fixed = {
				{-0.5, 0.5, -0.5, 0.5, 0, 0.0625},
			}
		}
	},

	{ suffix  = "technic_cnc_beam216_cross_column",
		model = "technic_cnc_beam_216_cross_column.obj",
		desc  = S("2/16 Beam Cross with Column"),
		cbox  = {
			type = "fixed",
			fixed = {
				{0.5, 0.5, 0.5, -0.5, -0.5, -0.5},
			}
		}
	},

	-- 2/16 slope panel


	{ suffix  = "technic_cnc_d45_slope_216",
		model = "technic_cnc_45_slope_216.obj",
		desc  = S("2/16 45° Slope"),
		cbox  = {
			type = "fixed",
			fixed = {
				{0.25, -0.5, -0.5, 0.5, -0.25, 0.5},
				{0, -0.25, -0.5, 0.25, 0, 0.5},
				{-0.25, 0, -0.5, 0, 0.25, 0.5},
				{-0.5, 0.25, -0.5, -0.25, 0.5, 0.5},
			}
		}
	},

	-- 2/16 Arch

	{ suffix  = "technic_cnc_arch216",
		model = "technic_cnc_arch_216.obj",
		desc  = S("2/16 Arch"),
		cbox  = {
			type = "fixed",
			fixed = {
				{0.4375, -0.5, -0.5, 0.5, -0.1875, 0.5},
				{-0.5, 0.4375, -0.5, -0.1875, 0.5, 0.5},
				{-0.1875, 0.25, -0.5, 0, 0.4375, 0.5},
				{0.25, -0.1875, -0.5, 0.4375, 0, 0.5},
				{-0.0625, 0.1875, -0.5, 0.125, 0.3125, 0.5},
				{0.1875, -0.0625, -0.5, 0.3125, 0.125, 0.5},
				{0.0625, 0.0625, -0.5, 0.25, 0.25, 0.5},
			}
		}
	},

	{ suffix  = "technic_cnc_pyramid",
		model = "technic_cnc_pyramid.obj",
		desc  = S("Pyramid"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -2/16, -2/16, -2/16, 2/16,     0, 2/16 },
				{ -4/16, -4/16, -4/16, 4/16, -2/16, 4/16 },
				{ -6/16, -6/16, -6/16, 6/16, -4/16, 6/16 },
				{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }
			}
		}
	},

}

-- Allow disabling certain programs for some node. Default is allowing all types for all nodes
technic_cnc.programs_disable = {
	-- ["default:brick"] = {"technic_cnc_stick"}, -- Example: Disallow the stick for brick
	-- ...
	["default:dirt"] = {"technic_cnc_oblate_spheroid", "technic_cnc_slope_upsdown", "technic_cnc_edge",
	                    "technic_cnc_inner_edge", "technic_cnc_slope_edge_upsdown",
	                    "technic_cnc_slope_inner_edge_upsdown", "technic_cnc_stick",
	                    "technic_cnc_cylinder_horizontal"},

}

-- Allow enabling only few select programs
technic_cnc.programs_enable = {

	["default:glass"] = {"technic_cnc_d45_slope_216", "technic_cnc_arch216"},
	["default:obsidian_glass"] = {"technic_cnc_d45_slope_216", "technic_cnc_arch216"},
	["moreblocks:clean_glass"] = {"technic_cnc_d45_slope_216", "technic_cnc_arch216"},
	["moreblocks:coal_glass"] = {"technic_cnc_d45_slope_216", "technic_cnc_arch216"},
	["moreblocks:iron_glass"] = {"technic_cnc_d45_slope_216", "technic_cnc_arch216"}
}

-- Generic function for registering all the different node types
function technic_cnc.register_program(recipeitem, suffix, model, groups, images, description, cbox, sbox)
	local shaped_name = recipeitem.."_"..suffix

	local dtype
	local nodeboxdef
	local meshdef

	if type(model) ~= "string" then -- assume a nodebox if it's a table or function call
		dtype = "nodebox"
		nodeboxdef = {
			type  = "fixed",
			fixed = model
		}
	else
		dtype = "mesh"
		meshdef = model
	end

	if cbox and not sbox then sbox = cbox end

	minetest.register_node(":"..shaped_name, {
		description   = description,
		drawtype      = dtype,
		node_box      = nodeboxdef,
		mesh          = meshdef,
		tiles         = images,
		paramtype     = "light",
		paramtype2    = "facedir",
		use_texture_alpha = ALPHA_CLIP,
		walkable      = true,
		groups        = groups,
		selection_box = sbox,
		collision_box = cbox,
		light_source  = groups.light_source,
	})

	local output_count = technic_cnc.output_counts[suffix]
	if output_count and not recycling_registered[shaped_name] then
		recycling_registered[shaped_name] = true
		local ingredients = {}
		for i = 1, output_count do
			ingredients[i] = shaped_name
		end
		minetest.register_craft({
			type = "shapeless",
			output = recipeitem,
			recipe = ingredients,
		})

		if circular_saw and circular_saw.register_recycling then
			circular_saw.register_recycling(shaped_name, recipeitem, output_count)
		end
	end
end

-- function to iterate over all the programs the CNC machine knows
function technic_cnc.register_all(recipeitem, groups, images, description)
	for _, data in ipairs(technic_cnc.programs) do
		-- Disable node creation for disabled node types for some material
		local do_register = true
		if technic_cnc.programs_disable[recipeitem] ~= nil then
			for __, disable in ipairs(technic_cnc.programs_disable[recipeitem]) do
				if disable == data.suffix then
					do_register = false
				end
			end
		end

		if technic_cnc.programs_enable[recipeitem] ~= nil then
			do_register = false
			for __, enable in ipairs(technic_cnc.programs_enable[recipeitem]) do
				if enable == data.suffix then
					do_register = true
				end
			end
		end

		-- Create the node if it passes the test
		if do_register then
			technic_cnc.register_program(recipeitem, data.suffix, data.model,
			    groups, images, description.." "..data.desc, data.cbox, data.sbox)
            if minetest.registered_nodes[recipeitem] then
                local old_groups = minetest.registered_nodes[recipeitem].groups or {}
                local new_groups = {}
                for k,v in pairs(old_groups) do
                    new_groups[k] = v
                end
                new_groups["cnc"] = 1

                minetest.override_item(recipeitem, {
                    groups = new_groups,
                })
            end
		end
	end
end

-- REGISTER NEW TECHNIC_CNC_API's PART 2: technic_cnc..register_element_end(subname, recipeitem, groups, images, desc_element_xyz)
-----------------------------------------------------------------------------------------------------------------------
function technic_cnc.register_slope_edge_etc(recipeitem, groups, images, desc_slope, desc_slope_lying, desc_slope_upsdown, desc_slope_edge, desc_slope_inner_edge, desc_slope_upsdwn_edge, desc_slope_upsdwn_inner_edge, desc_pyramid, desc_spike, desc_onecurvededge, desc_twocurvededge, desc_cylinder, desc_cylinder_horizontal, desc_spheroid, desc_element_straight, desc_element_edge, desc_element_t, desc_element_cross, desc_element_end)
		-- TODO: Remove this evil sorcery
         technic_cnc.register_slope(recipeitem, groups, images, desc_slope)
         technic_cnc.register_slope_lying(recipeitem, groups, images, desc_slope_lying)
         technic_cnc.register_slope_upsdown(recipeitem, groups, images, desc_slope_upsdown)
         technic_cnc.register_slope_edge(recipeitem, groups, images, desc_slope_edge)
         technic_cnc.register_slope_inner_edge(recipeitem, groups, images, desc_slope_inner_edge)
         technic_cnc.register_slope_edge_upsdown(recipeitem, groups, images, desc_slope_upsdwn_edge)
         technic_cnc.register_slope_inner_edge_upsdown(recipeitem, groups, images, desc_slope_upsdwn_inner_edge)
         technic_cnc.register_pyramid(recipeitem, groups, images, desc_pyramid)
         technic_cnc.register_spike(recipeitem, groups, images, desc_spike)
         technic_cnc.register_onecurvededge(recipeitem, groups, images, desc_onecurvededge)
         technic_cnc.register_twocurvededge(recipeitem, groups, images, desc_twocurvededge)
	   technic.cnc.register_cylinder(recipeitem, groups, images, desc_cylinder)
         technic_cnc.register_cylinder_horizontal(recipeitem, groups, images, desc_cylinder_horizontal)
         technic_cnc.register_spheroid(recipeitem, groups, images, desc_spheroid)
         technic_cnc.register_element_straight(recipeitem, groups, images, desc_element_straight)
         technic_cnc.register_element_edge(recipeitem, groups, images, desc_element_edge)
         technic_cnc.register_element_t(recipeitem, groups, images, desc_element_t)
         technic_cnc.register_element_cross(recipeitem, groups, images, desc_element_cross)
         technic_cnc.register_element_end(recipeitem, groups, images, desc_element_end)
end

-- REGISTER STICKS: noncubic.register_xyz(recipeitem, groups, images, desc_element_xyz)
------------------------------------------------------------------------------------------------------------
function technic_cnc.register_stick_etc(recipeitem, groups, images, desc_stick)
		-- TODO: Remove this evil sorcery
         technic_cnc.register_stick(recipeitem, groups, images, desc_stick)
end

function technic_cnc.register_elements(recipeitem, groups, images, desc_element_straight_double, desc_element_edge_double, desc_element_t_double, desc_element_cross_double, desc_element_end_double)
		-- TODO: Remove this evil sorcery
         technic_cnc.register_element_straight_double(recipeitem, groups, images, desc_element_straight_double)
         technic_cnc.register_element_edge_double(recipeitem, groups, images, desc_element_edge_double)
         technic_cnc.register_element_t_double(recipeitem, groups, images, desc_element_t_double)
         technic_cnc.register_element_cross_double(recipeitem, groups, images, desc_element_cross_double)
         technic_cnc.register_element_end_double(recipeitem, groups, images, desc_element_end_double)
end
