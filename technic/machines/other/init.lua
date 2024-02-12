local path = technic.modpath.."/machines/other"

-- Mesecons and tubes related
dofile(path.."/injector.lua")
dofile(path.."/constructor.lua")

-- Coal-powered machines
dofile(path.."/coal_alloy_furnace.lua")
dofile(path.."/coal_furnace.lua")
dofile(path.."/solar_furnace.lua")
dofile(path.."/water_extractor.lua")
dofile(path.."/water_powered_grinder.lua")

-- Force-loading
dofile(path.."/anchor.lua")
