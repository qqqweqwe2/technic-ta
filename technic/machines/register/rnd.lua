local base16_enctable = {
    [0] = "0",
    [1] = "1",
    [2] = "2",
    [3] = "3",
    [4] = "4",
    [5] = "5",
    [6] = "6",
    [7] = "7",
    [8] = "8",
    [9] = "9",
    [10] = "A",
    [11] = "B",
    [12] = "C",
    [13] = "D",
    [14] = "E",
    [15] = "F",
}

local base16_dectable = {}
for k,v in pairs(base16_enctable) do
    base16_dectable[v] = k
end

local function base16enc(str)
    local result = ""
    for i = 1, #str do
        local c = string.byte(str:sub(i, i))
        local high = base16_enctable[math.floor(c / 16)]
        local low = base16_enctable[c % 16]
        assert(high ~= nil)
        assert(low ~= nil)
        result = result..high..low
    end
    return result
end

local function base16dec(str)
    local result = ""
    for i=1, #str, 2 do
        local high = base16_dectable[str:sub(i, i)]
        local low = base16_dectable[str:sub(i+1, i+1)]
        if high == nil or low == nil then
            break
        end
        local val = string.char(high * 16 + low)
        result = result..val
    end
    return result
end

--expected structure:
--    {
--        {
--            name: <itemstring>
--            chance: <in 1/1000>
--        },{
--            ...
--        },
--        ...
--    }
function rndenc(data)
    local result = "rnd:"
    local totalchance = 0 -- should end up between 1000 and 1000.5 (some rounding tolerance)
    for _,item in pairs(data) do
        assert(item.chance > 0)
        totalchance = totalchance + item.chance
        result = result..base16enc(item.name).."a"..item.chance.."b"
    end
    assert(totalchance < 1000.5 and totalchance >= 1000)
    return result
end

local function rnddec(data)
    local result = {}
    assert(data:sub(1, 4) == "rnd:")
    local data = data:sub(5)
    assert(#data > 0)
    local i = 1
    while #data > 0 do
        local nameterm,_ = string.find(data, "a", 1, true)
        local name = base16dec(data:sub(1, nameterm-1))
        data = data:sub(nameterm+1)
        local chanceterm,_ = string.find(data, "b", 1, true)
        local chance = tonumber(data:sub(1, chanceterm-1))
        data = data:sub(chanceterm+1)
        result[i] = {name = name, chance = chance}
        i = i + 1
    end
    return result
end

local function resolve_rnd_single(name)
    local rnddata = rnddec(name)
    local choice = math.random()*1000
    local itemstring
    for k,v in pairs(rnddata) do
        itemstring = v.name -- always assign so the last item is always chosen in case the chances don't add up
        choice = choice - v.chance
        if choice <= 0 then
            itemstring = v.name
            break
        end
    end
    return ItemStack(itemstring)
end

function resolve_rnd_recursive(name)
    local output_stacks = {}
    table.insert(output_stacks, resolve_rnd_single(name))
    for k,v in pairs(output_stacks) do
        if v:get_name():sub(1, 4) == "rnd:" then
            output_stacks[k] = nil
            table.insert(output_stacks, resolve_rnd_single(v))
        end
    end
    return output_stacks
end