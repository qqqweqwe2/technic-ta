local S = technic.getter
local path = technic.modpath .. "/machines/register/machine_base_ta"
local machine_digilines = assert(loadfile(path .. "/digilines.lua"))()
local machine_state = assert(loadfile(path .. "/state.lua"))()

local RND_SEED_NAME = "rnd_seed"
local function round(v)
    return math.floor(v + 0.5)
end

local function start_random_seed(meta)
    if not meta:contains(RND_SEED_NAME) then
        meta:set_float(RND_SEED_NAME, minetest.get_us_time() + math.random())
        meta:mark_as_private(RND_SEED_NAME)
    end
    local rnd_seed = meta:get_float(RND_SEED_NAME)
    math.randomseed(rnd_seed)
    return rnd_seed
end

local function stop_random_seed(meta, rnd_seed)
    if rnd_seed then
        math.randomseed(minetest.get_us_time())
        meta:set_float("rnd_seed", minetest.get_us_time() + math.random())
    end
end

local function is_stack_empty(inv_list)
    return #inv_list == 0 or (inv_list[1]:get_count() == 0 and #inv_list == 1)
end

return function(registration_context)
    return function(pos, node)
        local meta = minetest.get_meta(pos)
        if not meta then return end

        machine_digilines.run(registration_context, pos, node)
        local inv = meta:get_inventory()
        local eu_input = meta:get_int(registration_context.def.tier .. "_EU_input")
        local machine_demand = registration_context.def.demand

        -- Setup meta registration_context.def if it does not exist.
        if not eu_input then
            meta:set_int(registration_context.def.tier .. "_EU_demand", machine_demand[1])
            meta:set_int(registration_context.def.tier .. "_EU_input", 0)
            machine_state.set(meta, machine_state.STATE.UNPOWERED)
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
        local rnd_seed = start_random_seed(meta)
        while true do
            local recipe = inv:get_list("src") and
                technic.get_recipe(registration_context.def.typename, inv:get_list("src"))
            if not recipe then
                technic.swap_node(pos, registration_context.nodename)
                meta:set_string("infotext", registration_context.infotext_idle)
                meta:set_int(registration_context.def.tier .. "_EU_demand", 0)
                meta:set_int("src_time", 0)
                machine_state.set(meta, is_stack_empty(inv:get_list("src"))
                    and machine_state.STATE.IDLE
                    or machine_state.STATE.STALLED)
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
                    machine_state.set(meta, machine_state.STATE.NOT_ENOUGH_ENERGY)
                    stop_random_seed(meta, rnd_seed)
                    return
                end
                stop_random_seed(meta, rnd_seed)
                return
            end
            if not technic.process_recipe(recipe, inv) then
                technic.swap_node(pos, registration_context.nodename)
                meta:set_string("infotext", registration_context.infotext_idle)
                meta:set_int(registration_context.def.tier .. "_EU_demand", 0)
                meta:set_int("src_time", round(recipe.time * 10))
                stop_random_seed(meta, rnd_seed)
                machine_state.set(meta, is_stack_empty(inv:get_list("src"))
                    and machine_state.STATE.IDLE
                    or machine_state.STATE.STALLED)
                return
            end
            meta:set_int("src_time", meta:get_int("src_time") - round(recipe.time * 10))
            machine_state.set(meta, machine_state.STATE.ACTIVE)
        end
    end
end
