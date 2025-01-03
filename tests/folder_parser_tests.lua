if not Config then
   require("src.configfile")
end

if not class then
   require("src.utils.class")
end

local sut = require("src.domain.fm.folder_parser")
local utils = require("tests.utils.fmutils")
local t = require("cluautils.tests")

local tableutils = require("cluautils.table_utils")


t.describe("Folder parser tests", function ()
   t.it("Empty music folder will return empty table", function ()
      ---@type string[]
      local result = {}

      utils.runInEnvironment({}, function (cwd)
         result = sut.parse(cwd)
      end)

      t.expect(tableutils.is_empty(result))
   end)

   t.it("Parser return music files from folder with only music files", function ()
      ---@type string[]
      local result = {}

      utils.runInEnvironment({
         cwd = utils.MockData.musicFolderPath,
         prepare = utils.prepareOnlyMusicFolder,
         clean = utils.cleanOnlyMusicFolder,
      }, function (cwd)
         result = sut.parse(cwd)
      end)

      t.expect(not tableutils.is_empty(result))
   end)
end)
