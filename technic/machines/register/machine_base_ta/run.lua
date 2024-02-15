local S = technic.getter
local function round(v)
    return math.floor(v + 0.5)
end

return function(registration_context)
    return function(pos, node)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local eu_input = meta:get_int(registration_context.def.tier .. "_EU_input")
        local machine_demand = registration_context.def.demand

        -- Setup meta registration_context.def if it does not exist.
        if not eu_input then
            meta:set_int(registration_context.def.tier .. "_EU_demand", machine_demand[1])
            meta:set_int(registration_context.def.tier .. "_EU_input", 0)
            return
        end

        local EU_upgrade, tube_upgrade = 0, 0
        if registration_context.def.upgrade then
            EU_upgrade, tube_upgrade = technic.handle_machine_upgrades(meta)
        end
        if registration_context.def.tube then
            technic.handle_machine_pipeworks(pos, tube_upgrade)
        end

        local powered = eu_input >= machine_demand[EU_upgrade + 1]
        if powered then
            meta:set_int("src_time", meta:get_int("src_time") + round(registration_context.def.speed * 10))
        end
        while true do
            local recipe = inv:get_list("src") and
                technic.get_recipe(registration_context.def.typename, inv:get_list("src"))
            if not recipe then
                technic.swap_node(pos, registration_context.nodename)
                meta:set_string("infotext", registration_context.infotext_idle)
                meta:set_int(registration_context.def.tier .. "_EU_demand", 0)
                meta:set_int("src_time", 0)
                return
            end
            meta:set_int(registration_context.def.tier .. "_EU_demand", machine_demand[EU_upgrade + 1])
            technic.swap_node(pos, registration_context.nodename .. "_active")
            meta:set_string("infotext", registration_context.infotext_active .. "\n" ..
                S("Demand: @1", technic.EU_string(machine_demand[EU_upgrade + 1])))
            if meta:get_int("src_time") < round(recipe.time * 10) then
                if not powered then
                    technic.swap_node(pos, registration_context.nodename)
                    meta:set_string("infotext", registration_context.infotext_unpowered)
                end
                return
            end
            if not technic.process_recipe(recipe, inv) then
                technic.swap_node(pos, registration_context.nodename)
                meta:set_string("infotext", registration_context.infotext_idle)
                meta:set_int(registration_context.def.tier .. "_EU_demand", 0)
                meta:set_int("src_time", round(recipe.time * 10))
                return
            end
            meta:set_int("src_time", meta:get_int("src_time") - round(recipe.time * 10))
        end
    end
end
