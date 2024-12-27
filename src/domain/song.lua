local AudioExt = require("src.domain.audioext")

require("cluautils.string_utils")


---@class Song
---@filed path string
---@field type AudioExt


---@param path string
---@return Song?
local function createSong(path)
   ---@diagnostic disable-next-line
   local components = string.split(path, "%.")

   if #components < 2 then
      return nil
   end

   local ext = components[#components]
   local extType = AudioExt[string.upper(ext)]

   if not extType then
      return nil
   end

   ---@type Song
   return {
      path = path,
      type = extType,
   }
end


return {
   createSong = createSong,
}
