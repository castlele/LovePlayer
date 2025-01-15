local MockDataStore = {}

function MockDataStore:new(storage)
   local this = {
      storage = storage or {},
   }

   setmetatable(this, self)

   self.__index = self

   return this
end

function MockDataStore:save(item)
   self.storage = item
end

function MockDataStore:getAll()
   return self.storage
end

function MockDataStore:clear()
   self.storage = {}
end

local MockMediaRepo = {}

function MockMediaRepo:new(dataStore, songs)
   local this = {
      dataStore = dataStore,
      songs = songs or {},
   }

   setmetatable(this, self)

   self.__index = self

   return this
end

function MockMediaRepo:saveMedia(items)
   self.dataStore:save(items)
end

function MockMediaRepo:getMedia()
   return self.dataStore:getAll()
end

function MockMediaRepo:saveMediaFolderPath(path)
   self.path = path
end

function MockMediaRepo:getMediaFolderPath()
   return self.path
end

function MockMediaRepo:saveSongs(items)
   for _, song in pairs(items) do
      self.songs[song.file.path] = song
   end
end

function MockMediaRepo:getSong(item)
   return self.songs[item.path]
end

local MockPlayer = {}

function MockPlayer:new(opts)
   local this = {}
   this.play = opts.play or function() end
   this.pause = opts.pause or function() end

   setmetatable(this, self)

   self.__index = self

   return this
end

return {
   dataStore = MockDataStore,
   mediaRepo = MockMediaRepo,
   player = MockPlayer,
}
