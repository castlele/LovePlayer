local json = require("cluautils.json")

---@class Logger
---@filed default Logger
local Logger = class()

---@enum (key) LogLevel
local LogLevel = {
    DEBUG = "DEBUG",
    INFO = "INFO",
    WARN = "WARN",
    ERROR = "ERROR",
}

---@type encode_options
local jsonOpts = {
   pretty = true,
   indent = "    ",
}


---@param message any
---@param level LogLevel?
function Logger.log(message, level)
   local lvl = level or LogLevel.INFO
   local msg = json.encode(message, jsonOpts)

   print("[" .. lvl .. "]: " .. msg)
end


Logger.default = Logger()

return {
   logger = Logger,
   level = LogLevel
}
