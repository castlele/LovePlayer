---@class MediaDataStoreImpl : MediaDataStore
---@field storage MediaFile[]
local MediaDataStore = class()

function MediaDataStore:save(item)
   self.storage = item
end

function MediaDataStore:getAll()
   return self.storage
end

function MediaDataStore:clear()
   self.storage = {}
end

-- TODO: Add data store for path
---@class MediaRepositoryImpl : MediaRepository
---@field mediaDataStore MediaDataStore
---@field mediaFolderPath string?
local MediaRepository = class()

---@param dataStore MediaDataStore
function MediaRepository:init(dataStore)
   self.mediaDataStore = dataStore
end

---@param items MediaFile[]
function MediaRepository:saveMedia(items)
   self.mediaDataStore:save(items)
end

---@return MediaFile[]
function MediaRepository:getMedia()
   return self.mediaDataStore:getAll()
end

---@param path string
function MediaRepository:saveMediaFolderPath(path)
   self.mediaFolderPath = path
end

---@return string?
function MediaRepository:getMediaFolderPath()
   local d = Config.debug

   if d.isDebug and d.mock.isMocking then
      return d.mock.folderPath
   end

   return self.mediaFolderPath
end

return {
   mediaDataStore = MediaDataStore,
   mediaRepository = MediaRepository,
}
