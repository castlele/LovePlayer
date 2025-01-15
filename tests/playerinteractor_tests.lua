if not class then
   require("src.utils.class")
end

local t = require("cluautils.tests")
local sutModule = require("src.domain.player.init")
local mocks = require("tests.utils.mocks")

t.describe("Player Interactor Tests", function()
   t.it("Interactor plays audio", function()
      local isPlayed = false
      local player = mocks.player:new {
         play = function(_)
            isPlayed = true
         end,
      }
      local sut = sutModule.interactor { player = player }

      sut:play()

      t.expect(isPlayed, "Interactor doesn't call method from MusicPlayer object")
      t.expect(sut:getState() == sutModule.state.PLAYING)
   end)

   t.it("Interactor plays audio with initial state PLAYING", function ()
      local isPlayed = false
      local player = mocks.player:new {
         play = function(_)
            isPlayed = true
         end,
      }
      local sut = sutModule.interactor {
         player = player,
         initialState = sutModule.state.PLAYING
      }

      t.expect(isPlayed, "Interactor doesn't call method from MusicPlayer object")
      t.expect(sut:getState() == sutModule.state.PLAYING)
   end)

   t.it("Interactor can pause playing audio", function ()
      local isPaused = false
      local player = mocks.player:new {
         pause = function(_)
            isPaused = true
         end,
      }
      local sut = sutModule.interactor {
         player = player,
         initialState = sutModule.state.PLAYING
      }

      sut:pause()

      t.expect(isPaused, "Interactor doesn't call method from MusicPlayer object")
      t.expect(sut:getState() == sutModule.state.PAUSED)
   end)
end)
