--- Module is responsible for managing track lists.
--- Its main goal it to sort, filter and combine lists of songs.

local log = require("src.domain.logger.init")
local imageDataModule = require("src.ui.imagedata")

---@class MediaDataStore
---@field save fun(self: MediaDataStore, item: MediaFile[])
---@field getAll fun(self: MediaDataStore): MediaFile[]
---@field clear fun(self: MediaDataStore)

---@class MediaRepository
---@field saveMedia fun(self: MediaRepository, items: MediaFile[])
---@field saveSongs fun(self: MediaRepository, items: Song[])
---@field getMedia fun(self: MediaRepository): MediaFile[]
---@field getSong fun(self: MediaRepository, item: MediaFile): Song?
---@field saveMediaFolderPath fun(self: MediaRepository, path: string)
---@field getMediaFolderPath fun(self: MediaRepository): string?

---@class ListsInteractor
---@field private mediaLoader MediaLoaderModule
---@field private mediaRepository MediaRepository
local ListsInteractor = class()

---@param repo MediaRepository
function ListsInteractor:init(repo)
   self.mediaLoader = require("src.domain.fm.init")
   self.mediaRepository = repo
end

---@return Song[]
function ListsInteractor:getSongs()
   ---@type Song[]
   local songs = {}
   local mediaList = self.mediaRepository:getMedia()

   if not mediaList then
      return songs
   end

   for _, media in ipairs(mediaList) do
      local song = self.mediaRepository:getSong(media)

      if song then
         table.insert(songs, song)
      else
         local metadata = self.mediaLoader.loadMetadata(media)

         if metadata then
            ---@type Artist
            local artist = {
               name = metadata.artist,
            }
            ---@type image.ImageData?
            local imageData = nil

            if metadata.picture then
               imageData = imageDataModule.imageData:new(
                  metadata.picture,
                  imageDataModule.imageDataType.DATA,
                  media.path
               )
            end

            ---@type Song
            local song = {
               title = metadata.title,
               genre = metadata.genre,
               album = {
                  name = metadata.album,
                  discnumber = tonumber(metadata.discnumber),
                  tracknumber = tonumber(metadata.tracknumber),
                  artist = artist,
               },
               artist = artist,
               file = media,
               imageData = imageData,
            }

            log.logger.default.log("Processing song: %s", log.level.INFO, song)

            table.insert(songs, song)
         end
      end
   end

   self.mediaRepository:saveSongs(songs)

   return songs
end

---@return Album[]
function ListsInteractor:getAlbums() end

---@return Artist[]
function ListsInteractor:getArtists() end

---@return string?
function ListsInteractor:requestFilePicker()
   local nfd = require("nfd")
   local isSuccess, result = pcall(nfd.openFolder)

   if not isSuccess or type(result) ~= "string" then
      return
   end

   return result
end

---@param path string?
function ListsInteractor:requestMedia(path)
   local mediaPath = path or self.mediaRepository:getMediaFolderPath()

   if not mediaPath then
      ---@diagnostic disable-next-line
      log.logger.default.log("No media folder provided", log.level.ERROR)
      return
   end

   local repo = self.mediaRepository
   local songs = self.mediaLoader.loadMedia(mediaPath)

   repo:saveMedia(songs)
   repo:saveMediaFolderPath(mediaPath)
end

function ListsInteractor:reload()
   self:requestMedia()
end

return ListsInteractor
