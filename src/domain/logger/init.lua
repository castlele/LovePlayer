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

---@param lhs LogLevel
---@param rhs LogLevel
---@return boolean
local function less(lhs, rhs)
   if lhs == rhs then
      return false
   end

   if lhs == LogLevel.DEBUG then
      return lhs ~= rhs
   elseif lhs == LogLevel.INFO then
      return rhs == LogLevel.DEBUG
   elseif lhs == LogLevel.WARN then
      return rhs == LogLevel.DEBUG or rhs == LogLevel.INFO
   end

   return false
end

---@param message any
---@param level LogLevel?
---@param args ...?
function Logger.log(message, level, args)
   local lvl = level or LogLevel.INFO
   local msg = json.encode(message, jsonOpts)

   if args then
      msg = string.format(msg, json.encode(args))
   end

   ---@diagnostic disable-next-line
   if not less(level, Config.logging.minLevel) then
      print("[" .. lvl .. "]: " .. msg)
   end
end

Logger.default = Logger()

return {
   logger = Logger,
   level = LogLevel,
}
