local AudioExt = require("src.domain.audioext")

local strutils = require("cluautils.string_utils")

---@class MediaFileMetadata
---@field title string
---@field artist string?
---@field album string?
---@field genre string?
---@field discnumber integer?
---@field tracknumber integer?
---@field picture string?
---@field pictureWidth number?
---@field pictureHeight number?

---@class MediaFile
---@field path string
---@field type AudioExt

---@class Artist
---@field name string?
---@field imageData image.ImageData

---@class Album
---@field name string?
---@field artist Artist?
---@field discnumber integer?
---@field tracknumber integer?
---@field imageData image.ImageData

---@class Picture
---@field data string
---@field width number
---@field height number

---@class Song
---@field title string
---@field genre string?
---@field album Album
---@field artist Artist
---@field file MediaFile
---@field imageData image.ImageData

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
