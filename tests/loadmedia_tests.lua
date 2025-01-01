if not class then
   require("src.utils.class")
end

local sut = require("src.domain.fm.init")
local t = require("cluautils.tests")
local utils = require("tests.utils.fmutils")
local ext = require("src.domain.audioext")

require("cluautils.table_utils")

t.describe("Load media tests", function()
   t.it("No media is provided if directory is empty", function()
      ---@type MediaFile[]
      local result = {}

      utils.runInEnvironment({}, function(cwd)
         result = sut.loadMedia(cwd)
      end)

      t.expect(table.is_empty(result))
   end)

   t.it("MediaFiles is parsed if they are in the folder", function()
      ---@type MediaFile[]
      local result = {}

      utils.runInEnvironment({
         cwd = utils.MockData.musicFolderPath,
         prepare = utils.prepareOnlyMusicFolder,
         clean = utils.cleanOnlyMusicFolder,
      }, function(cwd)
         result = sut.loadMedia(cwd)
      end)

      t.expect(not table.is_empty(result))
   end)
end)

t.describe("Metadata parsing tests", function ()
   t.it("Flac info can be parsed", function ()
      local filePath = "./tests/music_folder/animals.flac"
      ---@type MediaFile
      local media = {
         type = ext.FLAC,
         path = filePath,
      }

      local result = sut.loadMetadata(media)

      t.expect("Животные" == result.title)
      t.expect("Скриптонит" == result.artist)
      t.expect("Уроборос: Улица 36" == result.album)
      t.expect("1" == result.discnumber)
      t.expect("2" == result.tracknumber)
   end)

   t.it("Unsupported media parses file name as song's name", function ()
      local filePath = "./tests/music_folder/random.mp3"
      ---@type MediaFile
      local media = {
         type = ext.MP3,
         path = filePath,
      }

      local result = sut.loadMetadata(media)

      t.expect("random" == result.title)
      t.expect(nil == result.artist)
      t.expect(nil == result.album)
      t.expect(nil == result.discnumber)
      t.expect(nil == result.tracknumber)
   end)
end)
