local View = require("src.ui.view")
local Button = require("src.ui.button")
local PrevButton = require("src.ui.player.prevbutton")
local PlayButton = require("src.ui.player.playbutton")
local NextButton = require("src.ui.player.nextbutton")
local LoopButton = require("src.ui.player.loopbutton")
local HStack = require("src.ui.hstack")
local colors = require("src.ui.colors")
local imageDataModule = require("src.ui.imagedata")

---@class PlayerViewDelegate
---@field getQueue fun(self: PlayerViewDelegate): Song[]

---@class PlayerView : View
---@field delegate PlayerViewDelegate?
---@field private contentView HStack
---@field private prevButton PrevButton
---@field private playButton PlayButton
---@field private nextButton NextButton
---@field private loopButton LoopButton
---@field private minimizeButton Button
---@field private interactor PlayerInteractor
local PlayerView = View()

---@class PlayerViewOpts : ViewOpts
---@field interactor PlayerInteractor?
---@param opts PlayerViewOpts?
function PlayerView:init(opts)
   self._shader = Config.res.shaders.coloring()
   self._shader:send("tocolor", colors.accent:asVec4())

   View.init(self, opts)
end

function PlayerView:update(dt)
   View.update(self, dt)

   self.size = self.contentView.size
   self.contentView.origin = self.origin
end

---@param opts PlayerViewOpts
function PlayerView:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = opts.interactor or self.interactor

   self:updateContentViewOpts {
      backgroundColor = colors.secondary,
      alignment = "center",
      spacing = 10,
   }
   self:updatePrevButtonOpts()
   self:updatePlayButtonOpts()
   self:updateNextButtonOpts()
   self:updateLoopButtonOpts()
   self:updateMinimizeButtonOpts()
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

function PlayerView:toString()
   return "PlayerView"
end

return PlayerView
