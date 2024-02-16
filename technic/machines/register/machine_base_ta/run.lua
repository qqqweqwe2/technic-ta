local S = technic.getter
local function round(v)
    return math.floor(v + 0.5)
end

local STATE_META_NAME = "machine_state"
local STATE = {
    UNPOWERED = "Unpowered",
    IDLE = "Idle",
    ACTIVE = "Active",
    STUCK = "Stuck",
}

local RND_SEED_NAME = "rnd_seed"

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

local function set_state(meta, state)
    meta:set_string(STATE_META_NAME, state)
end

local function is_stack_empty(inv_list)
    return next(inv_list) == nil
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
            set_state(meta, STATE.UNPOWERED)
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
                set_state(meta, is_stack_empty(inv:get_list("src")) and STATE.IDLE or STATE.STUCK)
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
                    set_state(meta, STATE.UNPOWERED)
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
                set_state(meta, is_stack_empty(inv:get_list("src")) and STATE.IDLE or STATE.STUCK)
                return
            end
            meta:set_int("src_time", meta:get_int("src_time") - round(recipe.time * 10))
            set_state(meta, STATE.ACTIVE)
        end
    end
end
