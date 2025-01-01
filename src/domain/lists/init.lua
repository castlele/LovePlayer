--- Module is responsible for managing track lists.
--- Its main goal it to sort, filter and combine lists of songs.

local log = require("src.domain.logger.init")

---@class MediaDataStore
---@field save fun(self: MediaDataStore, item: MediaFile[])
---@field getAll fun(self: MediaDataStore): MediaFile[]
---@field clear fun(self: MediaDataStore)

---@class MediaRepository
---@field saveMedia fun(self: MediaRepository, items: MediaFile[])
---@field getMedia fun(self: MediaRepository): MediaFile[]
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
function ListsInteractor:getSongs() end

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
