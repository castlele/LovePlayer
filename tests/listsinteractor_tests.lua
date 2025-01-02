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
require("cluautils.table_utils")


t.describe("ListInteractor tests", function ()
   local musicEnv = {
      cwd = utils.MockData.musicFolderPath,
      prepare = utils.prepareOnlyMusicFolder,
      clean = utils.cleanOnlyMusicFolder,
   }

   t.it("No media is provided if directory is empty", function ()
      local dataStore = mocks.dataStore:new()
      local repo = mocks.mediaRepo:new(dataStore)
      local sut = sutModule(repo)

      utils.runInEnvironment({}, function (cwd)
         sut:requestMedia(cwd)
      end)

      t.expect(table.is_empty(dataStore:getAll()))
   end)

   t.it("Songs are parsed if they are in the folder", function ()
      local dataStore = mocks.dataStore:new()
      local repo = mocks.mediaRepo:new(dataStore)
      local sut = sutModule(repo)

      utils.runInEnvironment(musicEnv, function (cwd)
         sut:requestMedia(cwd)
      end)

      t.expect(not table.is_empty(dataStore:getAll()))
   end)

   t.it("If on after reloading folder doesn't changed data store doesn't change too", function ()
      local interMediateResult = 0
      local finalResult = 0
      local expectedResult = 2
      local dataStore = mocks.dataStore:new()
      local repo = mocks.mediaRepo:new(dataStore)
      local sut = sutModule(repo)

      utils.runInEnvironment(musicEnv, function (cwd)
         sut:requestMedia(cwd)

         interMediateResult = #dataStore:getAll()

         sut:reload()

         finalResult = #dataStore:getAll()
      end)

      t.expect(
         interMediateResult == expectedResult,
         "Got wrong interMediateResult. Expected: "
         .. expectedResult
         .. ". But got: " .. interMediateResult
      )
      t.expect(
         finalResult == expectedResult,
         "Got wrong final result. Expected: "
         .. expectedResult
         .. ". But got: " .. finalResult
      )
   end)

   t.it("If after reloading folder was changed data store will change too", function ()
      local interMediateResult = 0
      local finalResult = 0
      local expectedIntermediateResult = 2
      local expectedFinalResult = 1
      local dataStore = mocks.dataStore:new()
      local repo = mocks.mediaRepo:new(dataStore)
      local sut = sutModule(repo)

      utils.runInEnvironment(musicEnv, function (cwd)
         sut:requestMedia(cwd)

         interMediateResult = #dataStore:getAll()
         local file = FM.get_dir_content {
            dir_path = cwd,
            file_type = "file",
         }[1]
         os.execute("mv " .. "$(pwd)/" .. file .. " ../")

         sut:reload()

         local comps = strutils.split(file, "%/")
         os.execute("mv ../" .. comps[#comps] .. " " .. file)

         finalResult = #dataStore:getAll()
      end)

      t.expect(
         interMediateResult == expectedIntermediateResult,
         "Got wrong interMediateResult. Expected: "
         .. expectedIntermediateResult
         .. ". But got: " .. interMediateResult
      )
      t.expect(
         finalResult == expectedFinalResult,
         "Got wrong final result. Expected: "
         .. expectedFinalResult
         .. ". But got: " .. finalResult
      )
   end)

   t.it("Songs list can be got from data source", function ()
      local dataStore = mocks.dataStore:new()
      local repo = mocks.mediaRepo:new(dataStore)
      local sut = sutModule(repo)
      ---@type Song
      local song

      utils.runInEnvironment(musicEnv, function (cwd)
         sut:requestMedia(cwd)

         local songs = sut:getSongs()

         for _, s in ipairs(songs) do
            if s.file.type == ext.FLAC then
               song = s
               return
            end
         end
      end)

      t.expect("Животные" == song.title, "Wrong title, got: " .. song.title)
      t.expect("Скриптонит" == song.artist.name, "Wrong artist's name, got: " .. song.artist.name)
      t.expect("Уроборос: Улица 36" == song.album.name, "Wrong album name, got: " .. song.album.name)
      t.expect(1 == song.album.discnumber, "Wrong discnumber, got: " .. song.album.discnumber)
      t.expect(2 == song.album.tracknumber, "Wrong tracknumber, got: " .. song.album.tracknumber)
   end)
end)
