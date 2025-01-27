local View = require("src.ui.view")
local PlayButton = require("src.ui.player.playbutton")
local HStack = require("src.ui.hstack")
local colors = require("src.ui.colors")
local playerModule = require("src.domain.player")

---@type MusicPlayer
local audioPlayer

if Config.backend == "love" then
   audioPlayer = require("src.domain.player.loveaudioplayer")
elseif Config.backend == "miniaudio" then
   audioPlayer = require("src.domain.player.miniaudioplayer")
else
   assert(false, "Unsupported backend: " .. Config.backend)
end

---@class PlayerViewDelegate
---@field getQueue fun(self: PlayerViewDelegate): Song[]

---@class PlayerView : View
---@field contentView HStack
---@field playButton PlayButton
---@field delegate PlayerViewDelegate?
---@field private interactor PlayerInteractor
local PlayerView = View()

---@class PlayerViewOpts : ViewOpts
---@param opts PlayerViewOpts?
function PlayerView:init(opts)
   View.init(self, opts)

   self.interactor = playerModule.interactor {
      initialState = playerModule.state.PAUSED,
      player = audioPlayer(),
   }
end

function PlayerView:update(dt)
   View.update(self, dt)

   self.size = self.contentView.size
   self.contentView.origin = self.origin
end

---@param opts PlayerViewOpts
function PlayerView:updateOpts(opts)
   View.updateOpts(self, opts)

   self:updateContentViewOpts {
      backgroundColor = colors.red,
      contentViewOpts = {
         alignment = "center",
      },
   }
   self:updatePlayButtonOpts()
end

---@param opts HStackOpts
function PlayerView:updateContentViewOpts(opts)
   if self.contentView then
      self.contentView:updateOpts(opts)
      return
   end

   self.contentView = HStack(opts)
   self:addSubview(self.contentView)
end

function PlayerView:updatePlayButtonOpts()
   if self.playButton then
      return
   end

   self.playButton = PlayButton {
      action = function(playButton)
         if self.interactor:isQueueEmpty() and self.delegate then
            self.interactor:setQueue(self.delegate:getQueue())
         end

         self.interactor:toggle()

         playButton.isPaused = self.interactor:getState()
            == playerModule.state.PAUSED
      end,
   }
   self.contentView:addSubview(self.playButton)
end

function PlayerView:toString()
   return "PlayerView"
end

return PlayerView
