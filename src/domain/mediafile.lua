local AudioExt = require("src.domain.audioext")

require("cluautils.string_utils")

---@class MediaFile
---@filed path string
---@field type AudioExt

---@class Author
---@field name string

---@class Album
---@field author Author
---@field songs Song[]

---@class Song
---@field album Album
---@field author Author
---@field file MediaFile

---@param path string
---@return MediaFile?
local function createMediaFile(path)
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

   ---@type MediaFile
   return {
      path = path,
      type = extType,
   }
end

---@param media MediaFile
---@return Song
local function createSong(media) end

return {
   createMediaFile = createMediaFile,
   song = 1,
   album = 2,
   author = 3,
}
