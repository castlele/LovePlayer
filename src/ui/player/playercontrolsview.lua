local View = require("src.ui.view")
local PrevButton = require("src.ui.player.prevbutton")
local PlayButton = require("src.ui.player.playbutton")
local NextButton = require("src.ui.player.nextbutton")
local PlaybackView = require("src.ui.player.playbackview")
local HStack = require("src.ui.hstack")
local VStack = require("src.ui.vstack")
local colors = require("src.ui.colors")

---@class PlayerControlsView : View
---@field private interactor PlayerInteractor
---@field private prevButton PrevButton
---@field private playButton PlayButton
---@field private nextButton NextButton
---@field private controlButtonsContainer HStack
---@field private playbackView PlaybackView
---@field private contentContainer VStack
local PlayerControls = View()

---@class PlayerControlsViewOpts : ViewOpts
---@field interactor PlayerInteractor
---@param opts PlayerControlsViewOpts
function PlayerControls:init(opts)
   self._shader = Config.res.shaders.coloring()

   View.init(self, opts)
end

function PlayerControls:update(dt)
   View.update(self, dt)

   self.contentContainer.size.width = self.size.width
   self.contentContainer:centerX(self)
   self.contentContainer.origin.y = self.origin.y
   self.controlButtonsContainer:centerX(self.contentContainer)
   self.controlButtonsContainer.origin.y = self.contentContainer.origin.y

   self.playbackView.size.width = self.contentContainer.size.width

   self._shader:send("tocolor", colors.accent:asVec4())
end

---@param opts PlayerControlsViewOpts
function PlayerControls:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = opts.interactor
   local buttonOpts = {
      interactor = self.interactor,
      state = {
         normal = {
            backgroundColor = colors.clear,
         },
      },
      titleState = {
         normal = {
            shader = self._shader,
         },
      },
   }

   self:updatePrevButtonOpts(buttonOpts)
   self:updatePlayButtonOpts {
      interactor = self.interactor,
      action = function()
         self.interactor:toggle()
      end,
      shader = self._shader,
      state = {
         normal = {
            backgroundColor = colors.background,
         },
      },
      titleState = {},
   }
   self:updateNextButtonOpts(buttonOpts)
   self:updateControlButtonsContainerOpts {
      backgroundColor = colors.clear,
      alignment = "center",
      spacing = 50,
      views = {
         self.prevButton,
         self.playButton,
         self.nextButton,
      },
   }
   self:updatePlaybackViewOpts {
      interactor = self.interactor,
   }
   self:updateContentContainerOpts {
      backgroundColor = colors.clear,
      alignment = "center",
      spacing = 20,
      views = {
         self.controlButtonsContainer,
         self.playbackView,
      }
   }
end

---@private
---@param opts PrevButtonOpts
function PlayerControls:updatePrevButtonOpts(opts)
   if self.prevButton then
      self.prevButton:updateOpts(opts)
      return
   end

   self.prevButton = PrevButton(opts)
end

---@private
---@param opts PlayButtonOpts
function PlayerControls:updatePlayButtonOpts(opts)
   if self.playButton then
      return
   end

   self.playButton = PlayButton(opts)
end

---@private
---@param opts NextButtonOpts
function PlayerControls:updateNextButtonOpts(opts)
   if self.nextButton then
      self.nextButton:updateOpts(opts)
      return
   end

   self.nextButton = NextButton(opts)
end

---@private
---@param opts HStackOpts
function PlayerControls:updateControlButtonsContainerOpts(opts)
   if self.controlButtonsContainer then
      self.controlButtonsContainer:updateOpts(opts)
      return
   end

   self.controlButtonsContainer = HStack(opts)
end

---@private
---@param opts PlaybackViewOpts
function PlayerControls:updatePlaybackViewOpts(opts)
   if self.playbackView then
      self.playbackView:updateOpts(opts)
      return
   end

   self.playbackView = PlaybackView(opts)
end

---@private
---@param opts VStackOpts
function PlayerControls:updateContentContainerOpts(opts)
   if self.contentContainer then
      self.contentContainer:updateOpts(opts)
      return
   end

   self.contentContainer = VStack(opts)
   self:addSubview(self.contentContainer)
end

return PlayerControls
