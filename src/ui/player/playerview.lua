local View = require("src.ui.view")
local Button = require("src.ui.button")
local PlayButton = require("src.ui.player.playbutton")
local LoopButton = require("src.ui.player.loopbutton")
local HStack = require("src.ui.hstack")
local colors = require("src.ui.colors")
local playerModule = require("src.domain.player")
local imageDataModule = require("src.ui.imagedata")

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
---@field prevButton Button
---@field playButton PlayButton
---@field nextButton Button
---@field loopButton LoopButton
---@field delegate PlayerViewDelegate?
---@field private interactor PlayerInteractor
local PlayerView = View()

---@class PlayerViewOpts : ViewOpts
---@param opts PlayerViewOpts?
function PlayerView:init(opts)
   self.shader = Config.res.shaders.coloring()
   self.shader:send("tocolor", colors.accent:asVec4())
   self.interactor = playerModule.interactor {
      initialState = playerModule.state.PAUSED,
      player = audioPlayer(),
   }

   View.init(self, opts)
end

function PlayerView:update(dt)
   View.update(self, dt)

   self.size = self.contentView.size
   self.contentView.origin = self.origin

   self.interactor:update()
end

---@param opts PlayerViewOpts
function PlayerView:updateOpts(opts)
   View.updateOpts(self, opts)

   self:updateContentViewOpts {
      backgroundColor = colors.secondary,
      alignment = "center",
      spacing = 10,
   }
   self:updatePrevButtonOpts()
   self:updatePlayButtonOpts()
   self:updateNextButtonOpts()
   self:updateLoopButtonOpts()
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

function PlayerView:updatePrevButtonOpts()
   if self.prevButton then
      return
   end

   self.prevButton = Button {
      action = function()
         self.interactor:prev()
      end,
      state = {
         normal = {
            backgroundColor = colors.secondary,
         },
      },
      titleState = {
         type = "image",
         normal = {
            width = Config.buttons.next_prev.width,
            height = Config.buttons.next_prev.height,
            backgroundColor = colors.clear,
            imageData = imageDataModule.imageData:new(
               Config.res.images.prev,
               imageDataModule.imageDataType.PATH
            ),
            shader = self.shader,
         },
      },
   }
   self.contentView:addSubview(self.prevButton)
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
      shader = self.shader,
   }
   self.contentView:addSubview(self.playButton)
end

function PlayerView:updateNextButtonOpts()
   if self.nextButton then
      return
   end

   self.nextButton = Button {
      action = function()
         self.interactor:next()
      end,
      state = {
         normal = {
            backgroundColor = colors.secondary,
         },
      },
      titleState = {
         type = "image",
         normal = {
            width = Config.buttons.next_prev.width,
            height = Config.buttons.next_prev.height,
            backgroundColor = colors.clear,
            imageData = imageDataModule.imageData:new(
               Config.res.images.next,
               imageDataModule.imageDataType.PATH
            ),
            shader = self.shader,
         },
      },
   }
   self.contentView:addSubview(self.nextButton)
end

function PlayerView:updateLoopButtonOpts()
   if self.loopButton then
      return
   end

   self.loopButton = LoopButton {
      action = function(button)
         button.loopMode = self.interactor:nextLoopMode()
      end,
      loopMode = self.interactor:getLoopMode(),
      shader = self.shader,
   }
   self.contentView:addSubview(self.loopButton)
end

function PlayerView:toString()
   return "PlayerView"
end

return PlayerView
