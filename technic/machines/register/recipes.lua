local have_ui = minetest.get_modpath("unified_inventory")
local have_cg = minetest.get_modpath("craftguide")
local have_i3 = minetest.get_modpath("i3")

technic.recipes = { cooking = { input_size = 1, output_size = 1 } }

technic.craft_groups = {"wood", "stone", "soil", "mossycobble", "sand", "tree", "water", "cobblestone", "bakedclay", "leaves", "uranium_dust"} -- add all groups used in technic recipes here!

function technic.register_recipe_type(typename, origdata)
	local data = {}
	for k, v in pairs(origdata) do data[k] = v end
	data.input_size = data.input_size or 1
	data.output_size = data.output_size or 1
	if have_ui and unified_inventory.register_craft_type then
		local ctable = {
				description = data.description,
				width = data.input_size,
				height = 1,
		}
		if data.output_size > 1 then
			ctable.icon = data.icon or "technic_recipe_icon_empty.png"
			ctable.icon = ctable.icon .. "^technic_recipe_icon_plus.png"
		else
			ctable.icon = data.icon or "technic_recipe_icon_empty.png"
		end

		unified_inventory.register_craft_type(typename, ctable)

		if data.output_size == 1 then
			if have_cg and craftguide.register_craft_type then
				craftguide.register_craft_type(typename, {
					description = data.description,
				})
			end
			if have_i3 then
				i3.register_craft_type(typename, {
					description = data.description,
				})
			end
		end
	end
	data.recipes = {}
	technic.recipes[typename] = data
end

local function get_recipe_index(items)
	if not items or type(items) ~= "table" then return false end
	local l = {}
	for i, stack in ipairs(items) do
		l[i] = ItemStack(stack):get_name()
	end
	table.sort(l)
	return table.concat(l, "/")
end

local function register_recipe(typename, data)
	-- Handle aliases
	for i, stack in ipairs(data.input) do
		data.input[i] = ItemStack(stack):to_string()
	end
	if type(data.output) == "table" then
		for i, v in ipairs(data.output) do
			data.output[i] = ItemStack(data.output[i]):to_string()
		end
	else
		data.output = ItemStack(data.output):to_string()
	end

	local recipe = {time = data.time, input = {}, output = data.output}

	local index = get_recipe_index(data.input)
	if not index then
		print("[Technic] ignored registration of garbage recipe!")
		return
	end
	for _, stack in ipairs(data.input) do
		recipe.input[#recipe.input+1] = {name = ItemStack(stack):get_name(), count = ItemStack(stack):get_count()}
	end

	technic.recipes[typename].recipes[index] = recipe
	if have_ui and technic.recipes[typename].output_size == 1 then
		unified_inventory.register_craft({
			type = typename,
			output = data.output,
			items = data.input,
			width = 0,
		})
	end
	if (have_cg or have_i3) and technic.recipes[typename].output_size == 1 then
		local result = data.output
		if (type(result)=="table") then
			result = result[1]
		end
		local items = table.concat(data.input, ", ")
		if have_cg and craftguide.register_craft then
			craftguide.register_craft({
				type = typename,
				result = result,
				items = {items},
			})
		end
		if have_i3 then
			i3.register_craft({
				type = typename,
				result = result,
				items = {items},
			})
		end
	end

	if unified_inventory and technic.recipes[typename].output_size > 1 then
		local short_output = data.output[1]
		unified_inventory.register_craft({
			type = typename,
			output = short_output,
			items = data.input,
			width = 0,
		})
	end

end

-- Postpone registration until aliases can be handled.
do
	local recipes = {}

	minetest.register_on_mods_loaded(function()
		for _, recipe in ipairs(recipes) do
			register_recipe(unpack(recipe))
		end
		recipes = nil
	end)
		
	function technic.register_recipe(typename, data)
		assert(recipes, "it is too late to register recipes!")
		table.insert(recipes, {typename, data})
	end
end

local air_item = ItemStack("air 1");
local air_item2 = ItemStack("air 2");

function technic.get_recipe(typename, items)
	-- return early if there are no input items
        if items == nil then
		return
	end
	for k, v in pairs(items) do
		if not ItemStack(v):is_empty() then
			break
		end
		return
	end

	-- empty slots will be filled with a node of air each, for ease of processing later
	for i=1, #items do
		if ItemStack(items[i]):is_empty() then
			items[i] = air_item;
        elseif ItemStack(items[i]):get_name() == "technic:blocker" then
            items[i] = air_item2;
		end
	end

	if typename == "cooking" then -- Already builtin in Minetest, so use that
		if not items then
			return nil
		end
		local result, new_input = minetest.get_craft_result({
			method = "cooking",
			width = 1,
			items = items})
		-- Compatibility layer
		if not result or result.time == 0 then
			return nil
		else
			return {time = result.time,
			        new_input = new_input.items,
			        output = result.item}
		end
	end

	-- build a table with all valid group and item name combinations
	local function build_candidates(items)
		local result = {}
		for i, item in ipairs(items) do
			local entry = {}
			entry[1] = ItemStack(item):get_name()
			for ii, g in ipairs(technic.craft_groups) do
				if minetest.get_item_group(entry[1], g) == 1 then
					entry[ii + 1] = "group:"..g
				end
			end
			result[i] = entry
		end
		return result
	end

	-- iterate previously built table and return the first match
	local function recurse_candidates(candidates, num, _items)
		if num <= #candidates then
			for k, v in pairs(candidates[num]) do
				_items[num] = v
				local result = recurse_candidates(candidates, num + 1, _items)
				if result then
					local r
					if num == #candidates then
						r = {_recipe = result}
					else
						r = result
					end
                    if not r[v] then r[v] = {} end
					r[v][#r[v] + 1] = candidates[num][1	]
					return r;
				end
			end
		else
			local index = get_recipe_index(_items)
			if not index then
				print("[Technic] ignored registration of garbage recipe!")
				return
			end
			local result = technic.recipes[typename].recipes[index]

			return result
		end
	end

	local index = get_recipe_index(items)
	if not index then
		print("[Technic] ignored registration of garbage recipe!")
		return
	end
	local recipe = technic.recipes[typename].recipes[index]

	local function replace_group_by_item(result, input_item)
        local group = result[input_item.name]
        if #group < 1 then return nil end
        local ret_value = {
			name = group[#group],
			count = input_item.count
		}
        group[#group] = nil
		return ret_value
	end

    local function input_conform_to_receipt(input_candidates, ordered_items)
        for i, input_item in ipairs(ordered_items) do
            local input = input_candidates[i]
            if not input then
                return false
            end
            local found = false
            for  key, candidate in pairs(input) do
				if candidate == input_item.name then
                    found = true
					break
                end
            end
            if not found then
				return false
            end
        end
		return true
	end

	if not recipe then -- if the direct recipe doesn't exist, we need to take the groups into account and retry
		local candidates = build_candidates(items)

		local result = recurse_candidates(candidates, 1, {})

		if result then
			if not input_conform_to_receipt(candidates, result._recipe.input) then
				return nil
			end
			-- copy recipe
			recipe = {}
			for k, v in pairs(result._recipe) do
				recipe[k] = v
			end

			-- erase original inputs and write new ones with groups replaced by actual items
			recipe.input = {}
			for _, input_item in ipairs(result._recipe.input) do
				recipe.input[#recipe.input + 1] = replace_group_by_item(result, input_item)
			end
		end
	end
    local inputamount = 0
	if recipe then
		local new_input = {}
		local extra_output = {}
        local function get_input_cost(input_items, input_item_name)
			for _, input_item in ipairs(input_items) do
				if input_item.name == input_item_name then
					return input_item.count
				end
			end
			return 0
		end

		for i, stack in ipairs(items) do
            --minetest.log(stack:get_name())
            inputamount = stack:get_count() or 1
			if stack:get_name() == "air" or stack:get_name() == "technic:blocker" then
                if stack:get_count() == 2 then
                    new_input[i] = ItemStack(stack)
                    new_input[i]:replace("technic:blocker")
                end
				-- air and blocker are placeholders, do nothing
			elseif technic.cans[stack:get_name()] then
			-- Check if a can is used. If so, with each iteration its contents are depleted,
			-- and when it runs dry, an empty can is added to the recipe's output.
				local level = technic.manage_can_state(stack)
				if not level or level < 1 then
					return nil
				else
					if level > 1 then
						new_input[i] = technic.manage_can_state(ItemStack(stack), -1)
					else
						empty_can = technic.manage_can_state(ItemStack(stack), -1)
						table.insert(extra_output, empty_can)
					end
				end
			else
				local input = get_input_cost(recipe.input, stack:get_name())
				if stack:get_count() ~= nil and stack:get_count() < input then
					return nil
				else
					new_input[i] = ItemStack(stack)
					new_input[i]:take_item(input)
				end
			end
		end

		-- A necessary hack to avoid reusing the original table
		if #extra_output > 0 then
			local ro = {}
			if type(recipe.output) == "string" then
				table.insert(ro, recipe.output)
			else
				for _,o in ipairs(recipe.output) do
					table.insert(ro, o)
				end
			end
			for _,o in ipairs(extra_output) do
				table.insert(ro, o)
			end
			return {time = recipe.time,
				  new_input = new_input,
				  output = ro}
		end
		-- regular output
        if typename == "decay_accelerator" then
			local time = 0
			if inputamount >= 20 then
            	time = recipe.time / (inputamount / 300) or 100
			else
				time = recipe.time / (inputamount / 100) or 100
			end
		    return {time = time,
			  new_input = new_input,
			  output = recipe.output}
        else
		    return {time = recipe.time,
			  new_input = new_input,
			  output = recipe.output}
        end
	else
		return nil
	end
end
