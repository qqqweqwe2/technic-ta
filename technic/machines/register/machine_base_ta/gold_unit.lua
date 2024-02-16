local S = technic.getter
local gold_unit = {
    IS_PRESENT_FLAG_NAME = "IS_GCLU",
    PERCENT_NAME = "GCLU_Percent",
    WAIT_NAME = "GCLU_Wait",
    item_name = "technic:control_logic_unit_gold",
    upgrade_increment_number = 106,
}

function gold_unit.get_formspec(pos)
    local meta = minetest.get_meta(pos)
    if not meta or meta:get_int(gold_unit.IS_PRESENT_FLAG_NAME) ~= 1 then return "" end

    local formspec = "" ..
        "image[4.6,0.1;1,1;technic_control_logic_unit_gold.png]" ..
        "label[3.7,0.1;" .. S("GCLU\nSettings") .. "]" ..
        ("field[5.8,0.45;1.1,1;%s;;${%s}]"):format(gold_unit.PERCENT_NAME, gold_unit.PERCENT_NAME) ..
        ("field[6.8,0.45;1.1,1;%s;;${%s}]"):format(gold_unit.WAIT_NAME, gold_unit.WAIT_NAME) ..
        "tooltip[5.5,0;1,1;" .. S("For the Gold Control Logic Unit ONLY") .. ":" ..
        "\n" ..
        "\n\t" .. S("The percent of the max stack size to reach before sending the stack") .. "" ..
        "\n\t" .. S("between") .. " (0,100%)]" ..
        "tooltip[6.5,0;1,1;" .. S("For the Gold Control Logic Unit ONLY") .. ":" ..
        "\n" ..
        "\n\t" .. S("The max time (second) to wait before sending the stack") .. "" ..
        "\n\t" .. S("between") .. " (2,3600s)," ..
        "\n\t " ..
        S("'0' means no time-checking: be carefull if a stack never reach the percent, it will stay in the machine") ..
        "!" ..
        "\n" ..
        "\n\t" .. S("EXAMPLE") .. ":" ..
        "\n\t\t " .. S("if a stack never reachs the percent after x seconds, the stack is sent") .. ". ]" ..
        "label[5.55,-0.1;" .. S("Percent") .. "]" ..
        "label[6.55,-0.1;" .. S("Time (s)") .. "]"
    return formspec
end

function gold_unit.on_receive_fields(registration_context, pos, formname, fields, sender)
    local meta = minetest.get_meta(pos)
    if not meta or meta:get_int(gold_unit.IS_PRESENT_FLAG_NAME) ~= 1 then return end

    if fields[gold_unit.PERCENT_NAME] then
        local percent = tonumber(fields[gold_unit.PERCENT_NAME])
        if percent and percent >= 0 and percent <= 100 then
            meta:set_int(gold_unit.PERCENT_NAME, percent)
        end
    end
    if fields[gold_unit.WAIT_NAME] then
        local wait = tonumber(fields[gold_unit.WAIT_NAME])
        if wait and wait >= 0 and wait <= 3600 then
            meta:set_int(gold_unit.WAIT_NAME, wait)
        end
    end
end

function gold_unit.init_meta(meta)
    -- default value
    meta:set_int(gold_unit.IS_PRESENT_FLAG_NAME, 1)
    local percent = meta:get_int(gold_unit.PERCENT_NAME)
    if percent == nil or percent == 0 then
        meta:set_int(gold_unit.PERCENT_NAME, 90)
    end
    local wait = meta:get_int(gold_unit.WAIT_NAME)
    if wait == nil or wait == 0 then
        meta:set_int(gold_unit.WAIT_NAME, 30)
    end
end

function gold_unit.cleanup_meta(meta)
    meta:set_string(gold_unit.IS_PRESENT_FLAG_NAME, nil)
    meta:set_string(gold_unit.PERCENT_NAME, nil)
    meta:set_string(gold_unit.WAIT_NAME, nil)
end

function gold_unit.register_craft()
    minetest.register_craft({
        output = 'technic:control_logic_unit_gold',
        recipe = {
            { 'technic:fine_gold_wire', 'technic:fine_gold_wire', 'technic:fine_gold_wire' },
            { 'technic:silicon_wafer',  'technic:silicon_wafer',  'technic:silicon_wafer' },
            { 'default:gold_ingot',     'technic:chromium_ingot', 'default:gold_ingot' },
        }
    })
end

function gold_unit.register_craftitem()
    minetest.register_craftitem("technic:control_logic_unit_gold", {
        description = S("Gold Control Logic Unit"),
        inventory_image = "technic_control_logic_unit_gold.png",
    })
end

return gold_unit
