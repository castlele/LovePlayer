local MockDataStore = {}


function MockDataStore:new()
   local this = {
      storage = {}
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


function MockMediaRepo:new(dataStore)
   local this = {
      dataStore = dataStore,
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


return {
   dataStore = MockDataStore,
   mediaRepo = MockMediaRepo,
}
