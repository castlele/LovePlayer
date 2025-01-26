local View = require("src.ui.view")
local PlayButton = require("src.ui.player.playbutton")
local HStack = require("src.ui.hstack")
local colors = require("src.ui.colors")
local playerModule = require("src.domain.player")
-- local miniaudioPlayer = require("src.domain.player.miniaudioplayer")
local loveAudioPlayer = require("src.domain.player.loveaudioplayer")

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
      initialState = playerModule.state.PLAYING,
      player = loveAudioPlayer(),
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
      action = function()
         if self.interactor:isQueueEmpty() and self.delegate then
            self.interactor:setQueue(self.delegate:getQueue())
         end

         self.interactor:toggle()
      end,
   }
   self.contentView:addSubview(self.playButton)
end

function PlayerView:toString()
   return "PlayerView"
end

return PlayerView
