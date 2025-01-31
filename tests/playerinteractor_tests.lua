if not class then
   require("src.utils.class")
end

local t = require("cluautils.tests")
local sutModule = require("src.domain.player.init")
local LoopMode = require("src.domain.player.loopmode")
local mocks = require("tests.utils.mocks")

---@diagnostic disable
---@type Song[]
local mockSongs = {
   {
      title = "Javie",
   },
   {
      title = "Shanty",
   },
   {
      title = "Puh",
   },
}

---@diagnostic enable

t.describe("Player Interactor Tests", function()
   t.it("Interactor plays audio", function()
      local isPlayed = false
      local player = mocks.player:new {
         play = function(_)
            isPlayed = true
         end,
      }
      local sut = sutModule.interactor { player = player }
      sut:setQueue(mockSongs)

      sut:play()

      t.expect(
         isPlayed,
         "Interactor doesn't call method from MusicPlayer object"
      )
      t.expect(sut:getState() == sutModule.state.PLAYING)
   end)

   t.it("Interactor plays audio with initial state PLAYING", function()
      local isPlayed = false
      local player = mocks.player:new {
         play = function(_)
            isPlayed = true
         end,
      }
      local sut = sutModule.interactor {
         player = player,
         initialState = sutModule.state.PLAYING,
         queue = mockSongs,
      }

      t.expect(
         isPlayed,
         "Interactor doesn't call method from MusicPlayer object"
      )
      t.expect(sut:getState() == sutModule.state.PLAYING)
   end)

   t.it("Interactor can pause playing audio", function()
      local isPaused = false
      local player = mocks.player:new {
         pause = function(_)
            isPaused = true
         end,
      }
      local sut = sutModule.interactor {
         player = player,
         initialState = sutModule.state.PLAYING,
      }
      sut:setQueue(mockSongs)

      sut:pause()

      t.expect(
         isPaused,
         "Interactor doesn't call method from MusicPlayer object"
      )
      t.expect(sut:getState() == sutModule.state.PAUSED)
   end)

   t.it("Interactor can play next song", function()
      ---@type Song?
      local playingSong = nil
      local player = mocks.player:new {
         play = function(_, song)
            playingSong = song
         end,
      }
      local sut = sutModule.interactor {
         player = player,
         initialState = sutModule.state.PLAYING,
         queue = mockSongs,
      }

      sut:next()

      t.expect(
         sut:getCurrent().title == mockSongs[2].title,
         string.format(
            "Current interactor song is wrong. Expected: %s, got: %s",
            mockSongs[2].title,
            sut:getCurrent().title
         )
      )
      t.expect(playingSong ~= nil, "Playgin song is missing")
      t.expect(
         playingSong.title == mockSongs[2].title, ---@diagnostic disable-line
         string.format(
            "Current playing song is wrong. Expected: %s, got: %s",
            mockSongs[2].title,
            playingSong.title ---@diagnostic disable-line
         )
      )
   end)

   t.it("Interactor can play previous song", function()
      ---@type Song?
      local playingSong = nil
      local player = mocks.player:new {
         play = function(_, song)
            playingSong = song
         end,
      }
      local sut = sutModule.interactor {
         player = player,
         initialState = sutModule.state.PLAYING,
         currentQueueIndex = #mockSongs,
         queue = mockSongs,
      }

      sut:prev()

      t.expect(
         sut:getCurrent().title == mockSongs[2].title,
         string.format(
            "Current interactor song is wrong. Expected: %s, got: %s",
            mockSongs[2].title,
            sut:getCurrent().title
         )
      )
      t.expect(playingSong ~= nil, "Playgin song is missing")
      t.expect(
         playingSong.title == mockSongs[2].title, ---@diagnostic disable-line
         string.format(
            "Current playing song is wrong. Expected: %s, got: %s",
            mockSongs[2].title,
            playingSong.title ---@diagnostic disable-line
         )
      )
   end)

   t.it(
      "Interactor stops playing on next button if looping is disabled and current song was the last",
      function()
         ---@type Song?
         local playingSong = nil
         local player = mocks.player:new {
            play = function(_, song)
               playingSong = song
            end,
         }
         local sut = sutModule.interactor {
            player = player,
            initialState = sutModule.state.PLAYING,
            currentQueueIndex = #mockSongs,
            queue = mockSongs,
         }

         sut:next()

         t.expect(playingSong == nil, "Current playing song isn't nil")
         t.expect(
            sut:getCurrent() == nil,
            "Current interactor's song isn't nil"
         )
         t.expect(
            sut:getState() == sutModule.state.PAUSED,
            "Interactor in a wrong state"
         )
      end
   )

   t.it(
      "Interactor starts song from the beginning on prev button if song was the first",
      function()
         ---@type Song?
         local playingSong = nil
         local player = mocks.player:new {
            play = function(_, song)
               playingSong = song
            end,
         }
         local sut = sutModule.interactor {
            player = player,
            initialState = sutModule.state.PLAYING,
            currentQueueIndex = 1,
            queue = mockSongs,
         }

         sut:prev()

         -- TODO: TBD
      end
   )

   t.it(
      "Interactor starts playing from the beginning of the queu on next button if looping is enabled and current song is the last",
      function()
         ---@type Song?
         local playingSong = nil
         local player = mocks.player:new {
            play = function(_, song)
               playingSong = song
            end,
         }
         local sut = sutModule.interactor {
            player = player,
            initialState = sutModule.state.PLAYING,
            currentQueueIndex = #mockSongs,
            loopMode = LoopMode.QUEUE,
            queue = mockSongs,
         }

         sut:next()

         t.expect(playingSong ~= nil, "Current playing song souldn't be nil")
         t.expect(
            sut:getCurrent() ~= nil,
            "Current interactor playing song souldn't be nil"
         )
         t.expect(
            sut:getCurrent().title == playingSong.title, ---@diagnostic disable-line
            "Current playing song differes from interactor song"
         )
         t.expect(
            sut:getCurrent().title == mockSongs[1].title,
            string.format(
               "Current song isn't the first one. Expected: %s, got: %s",
               mockSongs[1].title,
               sut:getCurrent().title
            )
         )
      end
   )

   t.it(
      "Interactor starts playing last song in the queue on prev button if looping is disabled and current song is the first",
      function()
         ---@type Song?
         local playingSong = nil
         local player = mocks.player:new {
            play = function(_, song)
               playingSong = song
            end,
         }
         local sut = sutModule.interactor {
            player = player,
            initialState = sutModule.state.PLAYING,
            currentQueueIndex = 1,
            loopMode = LoopMode.QUEUE,
            queue = mockSongs,
         }

         sut:prev()

         t.expect(playingSong ~= nil, "Current playing song souldn't be nil")
         t.expect(
            sut:getCurrent() ~= nil,
            "Current interactor playing song souldn't be nil"
         )
         t.expect(
            sut:getCurrent().title == playingSong.title, ---@diagnostic disable-line
            "Current playing song differes from interactor song"
         )
         t.expect(
            sut:getCurrent().title == mockSongs[#mockSongs].title,
            string.format(
               "Current song isn't the last one. Expected: %s, got: %s",
               mockSongs[#mockSongs].title,
               sut:getCurrent().title
            )
         )
      end
   )
end)
