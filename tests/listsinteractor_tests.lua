if not Config then
   require("src.configfile")
end

if not class then
   require("src.utils.class")
end

local sutModule = require("src.domain.lists.init")
local t = require("cluautils.tests")
local utils = require("tests.utils.fmutils")
local mocks = require("tests.utils.mocks")
local FM = require("cluautils.file_manager")
local ext = require("src.domain.audioext")

local strutils = require("cluautils.string_utils")
local tableutils = require("cluautils.table_utils")

t.describe("ListInteractor tests", function()
   local musicEnv = {
      cwd = utils.MockData.musicFolderPath,
      prepare = utils.prepareOnlyMusicFolder,
      clean = utils.cleanOnlyMusicFolder,
   }

   local function createRepo()
      local dataStore = mocks.dataStore:new {
         {
            path = "path_1",
            type = ext.FLAC,
         },
         {
            path = "path_2",
            type = ext.MP3,
         },
      }
      local repo = mocks.mediaRepo:new(dataStore, {
         path_1 = {
            title = "Song1",
            file = { path = "path_1" },
            album = { name = "Album1" },
         },
         path_2 = {
            title = "Song2",
            file = { path = "path_2" },
            album = { name = "Album2" },
         },
      })

      return repo
   end

   t.it("No media is provided if directory is empty", function()
      local dataStore = mocks.dataStore:new()
      local repo = mocks.mediaRepo:new(dataStore)
      local sut = sutModule(repo)

      utils.runInEnvironment({}, function(cwd)
         sut:requestMedia(cwd)
      end)

      t.expect(tableutils.is_empty(dataStore:getAll()))
   end)

   t.it("Songs are parsed if they are in the folder", function()
      local dataStore = mocks.dataStore:new()
      local repo = mocks.mediaRepo:new(dataStore)
      local sut = sutModule(repo)

      utils.runInEnvironment(musicEnv, function(cwd)
         sut:requestMedia(cwd)
      end)

      t.expect(not tableutils.is_empty(dataStore:getAll()))
   end)

   t.it(
      "If on after reloading folder doesn't changed data store doesn't change too",
      function()
         local interMediateResult = 0
         local finalResult = 0
         local expectedResult = 2
         local dataStore = mocks.dataStore:new()
         local repo = mocks.mediaRepo:new(dataStore)
         local sut = sutModule(repo)

         utils.runInEnvironment(musicEnv, function(cwd)
            sut:requestMedia(cwd)

            interMediateResult = #dataStore:getAll()

            sut:reload()

            finalResult = #dataStore:getAll()
         end)

         t.expect(
            interMediateResult == expectedResult,
            "Got wrong interMediateResult. Expected: "
               .. expectedResult
               .. ". But got: "
               .. interMediateResult
         )
         t.expect(
            finalResult == expectedResult,
            "Got wrong final result. Expected: "
               .. expectedResult
               .. ". But got: "
               .. finalResult
         )
      end
   )

   t.it("Songs list can be got from data source", function()
      local dataStore = mocks.dataStore:new()
      local repo = mocks.mediaRepo:new(dataStore)
      local sut = sutModule(repo)
      ---@type Song
      local song

      utils.runInEnvironment(musicEnv, function(cwd)
         sut:requestMedia(cwd)

         local songs = sut:getSongs()

         for _, s in ipairs(songs) do
            if s.file.type == ext.FLAC then
               song = s
               return
            end
         end
      end)

      t.expect(
         "Животные" == song.title,
         "Wrong title, got: " .. song.title
      )
      t.expect(
         "Скриптонит" == song.artist.name,
         "Wrong artist's name, got: " .. song.artist.name
      )
      t.expect(
         "Уроборос: Улица 36" == song.album.name,
         "Wrong album name, got: " .. song.album.name
      )
   end)

   t.it("Songs can be taken from cache", function()
      local repo = createRepo()
      ---@type ListsInteractor
      local sut = sutModule(repo)

      local result = sut:getSongs()

      t.expect(result[1].title == "Song1")
      t.expect(result[2].title == "Song2")
   end)

   t.it("Albums can be taken from cached songs list", function()
      local repo = createRepo()
      ---@type ListsInteractor
      local sut = sutModule(repo)

      local result = sut:getAlbums()

      t.expect(result[1].name == "Album1")
      t.expect(result[2].name == "Album2")
   end)

   t.it("Album's songs can be taken from album", function ()
      local repo = createRepo()
      ---@type ListsInteractor
      local sut = sutModule(repo)
      local album = sut:getAlbums()[1]

      local result = sut:getAlbumSongs(album)

      t.expect(result[1].title == "Song1")
      t.expect(#result == 1)
   end)
end)
