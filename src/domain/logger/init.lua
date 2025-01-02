local json = require("cluautils.json")

---@class Logger
---@field default Logger
local Logger = class()

---@enum (value) LogLevel
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
---@param args ...?
function Logger.log(message, level, args)
   local lvl = level or LogLevel.INFO
   local msg = json.encode(message, jsonOpts)

   if args then
      msg = string.format(msg, json.encode(args))
   end

   print("[" .. lvl .. "]: " .. msg)
end

Logger.default = Logger()

return {
   logger = Logger,
   level = LogLevel,
}
