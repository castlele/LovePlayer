--- Module is responsible for managing track lists.
--- Its main goal it to sort, filter and combine lists of songs.

local log = require("src.domain.logger.init")

---@class MediaDataStore
---@field save fun(self: MediaDataStore, item: Song[])
---@field getAll fun(self: MediaDataStore): Song[]
---@field clear fun(self: MediaDataStore)

---@class MediaRepository
---@field saveMedia fun(self: MediaRepository, items: Song[])
---@field getMedia fun(self: MediaRepository): Song[]
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

---@param path string?
function ListsInteractor:requestMedia(path)
   local mediaPath = path or self.mediaRepository:getMediaFolderPath()

   if not mediaPath then
      ---@diagnostic disable-next-line
      log.logger.default.log("No media folder provided", log.level.ERROR)
      return
   end

   -- TODO: Temporary return
   -- TODO: Error handling?
   local songs = self.mediaLoader.loadMedia(mediaPath)

   self.mediaRepository:saveMedia(songs)
   self.mediaRepository:saveMediaFolderPath(mediaPath)
end

function ListsInteractor:reload()
   self:requestMedia()
end


return ListsInteractor
