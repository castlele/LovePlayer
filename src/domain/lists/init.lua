--- Module is responsible for managing track lists.
--- Its main goal it to sort, filter and combine lists of songs.

local log = require("src.domain.logger.init")
local imageDataModule = require("lovekit.ui.imagedata")

---@class MediaDataStore
---@field save fun(self: MediaDataStore, item: MediaFile[])
---@field getAll fun(self: MediaDataStore): MediaFile[]
---@field clear fun(self: MediaDataStore)

---@class MediaRepository
---@field clearAll fun(self: MediaRepository)
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
         or self:createSongFromMedia(media)

      if song then
         table.insert(songs, song)
      end
   end

   self.mediaRepository:saveSongs(songs)

   return songs
end

---@return Album[]
function ListsInteractor:getAlbums()
   local songs = self:getSongs()
   ---@type Album[]
   local albums = {}
   local set = {}

   for _, song in pairs(songs) do
      local album = song.album

      if album.name and not set[album.name] then
         set[album.name] = 1
         table.insert(albums, album)
      end
   end

   return albums
end

function ListsInteractor:getAlbumSongs(album)
   local albumName = album.name
   local albumSongs = {}

   if not albumName then
      return albumSongs
   end

   for _, song in pairs(self:getSongs()) do
      if song.album.name == albumName then
         table.insert(albumSongs, song)
      end
   end

   return albumSongs
end

---@return Artist[]
function ListsInteractor:getArtists()
   local songs = self:getSongs()
   ---@type Artist[]
   local artists = {}
   local set = {}

   for _, song in pairs(songs) do
      local artist = song.artist

      if artist.name and not set[artist.name] then
         set[artist.name] = 1
         table.insert(artists, artist)
      end
   end

   return artists
end

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

function ListsInteractor:clearAll()
   self.mediaRepository:clearAll()
end

---@private
---@param media MediaFile
---@return Song?
function ListsInteractor:createSongFromMedia(media)
   local metadata = self.mediaLoader.loadMetadata(media)

   if not metadata then
      return nil
   end
   ---@type image.ImageData?
   local imageData = nil

   if metadata.picture then
      imageData = imageDataModule.imageData:new(
         metadata.picture,
         imageDataModule.imageDataType.DATA,
         media.path
      )
   else
      imageData = imageDataModule.imageData.placeholder
   end

   ---@type Artist
   local artist = {
      name = metadata.artist,
      imageData = imageData,
   }

   ---@type Song
   local song = {
      title = metadata.title,
      genre = metadata.genre,
      discnumber = tonumber(metadata.discnumber),
      tracknumber = tonumber(metadata.tracknumber),
      album = {
         name = metadata.album,
         artist = artist,
         imageData = imageData,
      },
      artist = artist,
      file = media,
      imageData = imageData,
   }

   return song
end

return ListsInteractor
