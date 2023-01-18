Log = require("log")
Fiber = require('fiber')
local fio = require("fio")
local json = require ("json")

local under_tarantoolctl = Fiber.name() == 'tarantoolctl'
if not under_tarantoolctl then
    under_tarantoolctl = os.getenv('TARANTOOLCTL') == 'true'
end
local config = {}
local data = os.getenv('TNT_CONFIG')
local config_file
if not data then
    config_file = os.getenv('TNT_CONFIG_PATH') or "etc/config.json"
    local f, e = fio.open(config_file)
    if not f then error("Failed to open "..config_file..": "..e, 0) end
    data = f:read()
    f:close()
end
Log.info("tnt config '%s'", data)

local ok, cfg_data = pcall(json.decode, data)
if not ok then error(config_file
        and "Failed to read "..config_file..": "..cfg_data
        or "Failed Env "..data..": "..cfg_data,0) end

for k,v in pairs(cfg_data or {}) do
    if k ~= "appl_config" then
        config[k] = v
    else
        _G["CONFIG"] = v
    end
end

print(CONFIG.text)
Log.info("Text '%s'", CONFIG.text)

if under_tarantoolctl == false then
    require'console'.start()
    os.exit()
end
