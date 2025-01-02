local AudioExt = require("src.domain.audioext")

local strutils = require("cluautils.string_utils")

---@class MediaFileMetadata
---@field title string
---@field artist string?
---@field album string?
---@field genre string?
---@field discnumber integer?
---@field tracknumber integer?

---@class MediaFile
---@field path string
---@field type AudioExt

---@class Artist
---@field name string?

---@class Album
---@field name string?
---@field artist Artist?
---@field discnumber integer?
---@field tracknumber integer?

---@class Song
---@field title string
---@field genre string?
---@field album Album
---@field artist Artist
---@field file MediaFile

---@param path string
---@return MediaFile?
local function createMediaFile(path)
   local components = strutils.split(path, "%.")

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

return {
   createMediaFile = createMediaFile,
   song = 1,
   album = 2,
   author = 3,
}
