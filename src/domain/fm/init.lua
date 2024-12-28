--- Module is responsible for getting data about audio files in the requested folder.
--- Its main goal is to provide a list of songs with every possible metadata.
local Parser = require("src.domain.fm.folder_parser")
local songs = require("src.domain.song")
local log = require("src.domain.logger.init")


---@class MediaLoaderModule
local M = {}


---@param path string
---@param parser Parser?
---@return Song[]
function M.loadMedia(path, parser)
   local p = parser or Parser
   local files = p.parse(path)
   ---@type Song[]
   local result = {}

   for _, songPath in pairs(files) do
      local song = songs.createSong(songPath)

      if song then
         table.insert(result, song)
      end
   end

   log.logger.default.log(result)

   return result
end


return M
