local machine_state = {
    STATE_META_NAME = "machine_state",
    PREVIOUS_STATE_META_NAME = "machine_state_previous",
    STATE = {
        STARTED = "Started",
        UNPOWERED = "Unpowered",
        NOT_ENOUGH_ENERGY = "Not enough energy",
        IDLE = "Idle",
        ACTIVE = "Active",
        STALLED = "Stalled",
    },

}

function machine_state.set_previous(meta, state)
    meta:set_string(machine_state.PREVIOUS_STATE_META_NAME, state)
end

function machine_state.get_previous(meta)
    return meta:get_string(machine_state.PREVIOUS_STATE_META_NAME)
end

function machine_state.set(meta, state)
    if state == machine_state.STATE.ACTIVE then
        if machine_state.get_previous(meta) == machine_state.STATE.ACTIVE then
            return
        end
    end

    if state == machine_state.STATE.NOT_ENOUGH_ENERGY then
        if machine_state.get_previous(meta) == machine_state.STATE.IDLE then
            return
        end
    end

    meta:set_string(machine_state.STATE_META_NAME, state)
end

function machine_state.get(meta)
    return meta:get_string(machine_state.STATE_META_NAME)
end

return machine_state
