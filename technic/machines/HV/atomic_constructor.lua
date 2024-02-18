local S = technic.getter

technic.register_recipe_type("atomic_constructor", {
    description = S("Atomic Construction\nAccepts isotopes"),
    input_size = 5,
})

local data = {
    tier = "HV",
    speed = 3,
    output_size = 9,
    upgrade = true,
    typename = "atomic_constructor",
    machine_name = "atomic_constructor",
    machine_desc = S("%s Atomic Constructor"),
    demand = { 2000 }
}

technic.register_base_machine(data)
