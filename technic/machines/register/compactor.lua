
local S = technic.getter

function technic.register_compactor(data)
	data.typename = "compacting"
	data.machine_name = "compactor"
	data.machine_desc = S("%s Compactor")
	technic.register_base_machine(data)
end
