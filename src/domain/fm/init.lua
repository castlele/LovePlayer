--- Module is responsible for getting data about audio files in the requested folder.
--- Its main goal is to provide a list of songs with every possible metadata.
local Parser = require("src.domain.fm.folder_parser")
local mediaParser = require("src.domain.fm.mediafile_metadata_parser")
local songs = require("src.domain.mediafile")
local log = require("src.domain.logger.init")

---@class MediaLoaderModule
local M = {}

---@param path string
---@param parser Parser?
---@return MediaFile[]
function M.loadMedia(path, parser)
   local p = parser or Parser
   local files = p.parse(path)
   ---@type MediaFile[]
   local result = {}

   for _, songPath in pairs(files) do
      local song = songs.createMediaFile(songPath)

      if song then
         table.insert(result, song)
      end
   end

   log.logger.default.log(result)

   return result
end


---@param media MediaFile
---@return MediaFileMetadata?
function M.loadMetadata(media)
   return mediaParser.parse(media)
end

return M
