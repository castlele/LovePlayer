local View = require("src.ui.view")
local Button = require("src.ui.button")
local VolumeView = require("src.ui.player.volumeview")
local ShuffleButton = require("src.ui.player.shufflebutton")
local PrevButton = require("src.ui.player.prevbutton")
local PlayButton = require("src.ui.player.playbutton")
local NextButton = require("src.ui.player.nextbutton")
local LoopButton = require("src.ui.player.loopbutton")
local PlaybackView = require("src.ui.player.playbackview")
local HStack = require("src.ui.hstack")
local colors = require("src.ui.colors")
local imageDataModule = require("src.ui.imagedata")
local tableutils = require("src.utils.tableutils")

---@class PlayerViewDelegate
---@field getQueue fun(self: PlayerViewDelegate): Song[]

---@class PlayerView : View
---@field delegate PlayerViewDelegate?
---@field private interactor PlayerInteractor
---@field private contentView HStack
---@field private volumeView VolumeView
---@field private shuffleButton ShuffleButton
---@field private prevButton PrevButton
---@field private playButton PlayButton
---@field private nextButton NextButton
---@field private loopButton LoopButton
---@field private minimizeButton Button
---@field private playbackView PlaybackView
local PlayerView = View()

local padding = 20

---@class PlayerViewOpts : ViewOpts
---@field interactor PlayerInteractor?
---@param opts PlayerViewOpts?
function PlayerView:init(opts)
   self._shader = Config.res.shaders.coloring()
   self._shader:send("tocolor", colors.accent:asVec4())

   ---@type PlayerViewOpts
   local o = tableutils.concat({
      backgroundColor = colors.secondary,
   }, opts or {})

   View.init(self, o)
end

function PlayerView:update(dt)
   View.update(self, dt)

   self.contentView.origin.x = self.origin.x + padding
   self.contentView:centerY(self)
   self.contentView.size.height = self.size.height
end

---@param opts PlayerViewOpts
function PlayerView:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = opts.interactor or self.interactor

   self:updateContentViewOpts {
      backgroundColor = colors.clear,
      alignment = "center",
      spacing = padding,
   }
   self:updateVolumeViewOpts {
      interactor = self.interactor,
      shader = self._shader,
      static = true,
      orientation = "landscape",
      width = 150,
      height = Config.buttons.volume.height,
   }
   self:updateShuffleButtonOpts()
   self:updatePrevButtonOpts()
   self:updatePlayButtonOpts()
   self:updateNextButtonOpts()
   self:updateLoopButtonOpts()
   self:updateMinimizeButtonOpts()
   self:updatePlaybackViewOpts()
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

---@private
---@param opts VolumeViewOpts
function PlayerView:updateVolumeViewOpts(opts)
   if self.volumeView then
      self.volumeView:updateOpts(opts)
      return
   end

   self.volumeView = VolumeView(opts)
   self.contentView:addSubview(self.volumeView)
end

function PlayerView:updateShuffleButtonOpts()
   if self.shuffleButton then
      return
   end

   self.shuffleButton = ShuffleButton {
      interactor = self.interactor,
      state = {
         normal = {
            backgroundColor = colors.clear
         },
      },
      titleState = {
         normal = {
         },
      },
      offColor = colors.background,
   }
   self.contentView:addSubview(self.shuffleButton)
end

function PlayerView:updatePrevButtonOpts()
   if self.prevButton then
      return
   end

   self.prevButton = PrevButton {
      interactor = self.interactor,
      titleState = {
         normal = {
            shader = self._shader,
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
      action = function()
         if self.interactor:isQueueEmpty() and self.delegate then
            self.interactor:setQueue(self.delegate:getQueue())
         end

         self.interactor:toggle()
      end,
      interactor = self.interactor,
      state = {
         normal = {
            backgroundColor = colors.clear,
         },
      },
      shader = self._shader,
   }
   self.contentView:addSubview(self.playButton)
end

function PlayerView:updateNextButtonOpts()
   if self.nextButton then
      return
   end

   self.nextButton = NextButton {
      interactor = self.interactor,
      titleState = {
         normal = {
            shader = self._shader,
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
      shader = self._shader,
   }
   self.contentView:addSubview(self.loopButton)
end

function PlayerView:updateMinimizeButtonOpts()
   if self.minimizeButton then
      return
   end

   self.minimizeButton = Button {
      action = function()
         Config.app.state = "miniplayer"
         Config.app.isFlowChanged = true
      end,
      state = {
         normal = {
            backgroundColor = colors.clear,
         },
      },
      titleState = {
         type = "image",
         normal = {
            width = Config.buttons.minimize.width,
            height = Config.buttons.minimize.height,
            backgroundColor = colors.clear,
            imageData = imageDataModule.imageData:new(
               Config.res.images.minimize,
               imageDataModule.imageDataType.PATH
            ),
            shader = self._shader,
         },
      },
   }
   self.contentView:addSubview(self.minimizeButton)
end

---@private
function PlayerView:updatePlaybackViewOpts()
   if self.playbackView then
      return
   end

   self.playbackView = PlaybackView {
      interactor = self.interactor,
      width = 200,
      offColor = colors.background,
   }
   self.contentView:addSubview(self.playbackView)
end

function PlayerView:toString()
   return "PlayerView"
end

return PlayerView
