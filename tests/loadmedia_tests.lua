if not class then
   require("src.utils.class")
end

local sut = require("src.domain.fm.init")
local t = require("cluautils.tests")
local utils = require("tests.utils.fmutils")

require("cluautils.table_utils")


t.describe("Load media tests", function ()
   t.it("No media is provided if directory is empty", function ()
      ---@type Song[]
      local result = {}

      utils.runInEnvironment({}, function (cwd)
         result = sut.loadMedia(cwd)
      end)

      t.expect(table.is_empty(result))
   end)

   t.it("Songs is parsed if they are in the folder", function ()
      ---@type Song[]
      local result = {}

      utils.runInEnvironment({
         cwd = utils.MockData.musicFolderPath,
         prepare = utils.prepareOnlyMusicFolder,
         clean = utils.cleanOnlyMusicFolder,
      }, function (cwd)
         result = sut.loadMedia(cwd)
      end)

      t.expect(not table.is_empty(result))
   end)
end)
