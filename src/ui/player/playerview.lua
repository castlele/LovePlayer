local View = require("lovekit.ui.view")
local Button = require("lovekit.ui.button")
local Label = require("lovekit.ui.label")
local Image = require("lovekit.ui.image")
local VolumeView = require("src.ui.player.volumeview")
local ShuffleButton = require("src.ui.player.shufflebutton")
local PrevButton = require("src.ui.player.prevbutton")
local PlayButton = require("src.ui.player.playbutton")
local TitleSubtitle = require("lovekit.ui.titlesubtitle")
local NextButton = require("src.ui.player.nextbutton")
local LoopButton = require("src.ui.player.loopbutton")
local PlaybackView = require("src.ui.player.playbackview")
local HStack = require("lovekit.ui.hstack")
local VStack = require("lovekit.ui.vstack")
local colors = require("lovekit.ui.colors")
local imageDataModule = require("lovekit.ui.imagedata")
local tableutils = require("lovekit.utils.tableutils")

---@class PlayerViewDelegate
---@field getQueue fun(self: PlayerViewDelegate): Song[]

---@class PlayerView : View
---@field delegate PlayerViewDelegate?
---@field private songsImageShader love.Shader
---@field private interactor PlayerInteractor
---@field private contentView HStack
---@field private controlsButtonsView HStack
---@field private playbackContentView HStack
---@field private playbackContainerView VStack
---@field private titlesContainer TitleSubtitle
---@field private songNameLabel Label
---@field private artistNameLabel Label
---@field private volumeView VolumeView
---@field private shuffleButton ShuffleButton
---@field private prevButton PrevButton
---@field private playButton PlayButton
---@field private nextButton NextButton
---@field private loopButton LoopButton
---@field private songImage Image
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
   self.shader = nil

   ---@type PlayerViewOpts
   local o = tableutils.concat({
      backgroundColor = colors.secondary,
   }, opts or {})

   View.init(self, o)
end

function PlayerView:update(dt)
   View.update(self, dt)

   local s = self.interactor:getCurrent()

   if s then
      self.songImage:updateOpts {
         imageData = s.imageData,
         isHidden = false,
      }
   else
      self.songImage:updateOpts {
         isHidden = true,
      }
   end

   self:showMinimizeButtonIfNeeded()

   local p = 50

   self.minimizeButton:centerX(self.songImage)
   self.minimizeButton:centerY(self.songImage)

   self.contentView.origin.x = self.origin.x + p
   self.contentView.size.width = self.size.width - p
   self.contentView.size.height = self.size.height
   self.contentView:centerY(self)
end

---@param opts PlayerViewOpts
function PlayerView:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = opts.interactor or self.interactor

   self:updateContentViewOpts {
      backgroundColor = colors.clear,
      alignment = "center",
      spacing = "max",
   }
   self:updateControlsButtonsViewOpts {
      backgroundColor = colors.clear,
      alignment = "center",
      spacing = padding,
   }
   self:updatePlaybackConainerViewOpts {
      backgroundColor = colors.clear,
      alignment = "center",
      spacing = 5,
   }
   self:updatePlaybackContentViewOpts {
      backgroundColor = colors.clear,
      alignment = "center",
      spacing = 5,
   }
   self:updateSongImageOpts()
   self:updateTitleSubtitleOpts {
      backgroundColor = colors.clear,
      update = function()
         local song = self.interactor:getCurrent()

         if song then
            return song.title, song.artist.name
         end
      end,
      titleOpts = {
         fontPath = Config.res.fonts.bold,
         fontSize = Config.res.fonts.size.header3,
         textColor = colors.white,
         backgroundColor = colors.clear,
      },
      subtitleOpts = {
         fontPath = Config.res.fonts.regular,
         fontSize = Config.res.fonts.size.body,
         textColor = colors.white,
         backgroundColor = colors.clear,
      },
   }
   self:updateShuffleButtonOpts()
   self:updatePrevButtonOpts()
   self:updatePlayButtonOpts()
   self:updateNextButtonOpts()
   self:updateLoopButtonOpts()
   self:updateMinimizeButtonOpts()
   self:updatePlaybackViewOpts()
   self:updateVolumeViewOpts {
      interactor = self.interactor,
      shader = self._shader,
      static = true,
      orientation = "landscape",
      width = 150,
      height = Config.buttons.volume.height,
   }
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
---@param opts TitleSubtitleOpts
function PlayerView:updateTitleSubtitleOpts(opts)
   if self.titlesContainer then
      self.titlesContainer:updateOpts(opts)
      return
   end

   self.titlesContainer = TitleSubtitle(opts)
   self.playbackContentView:addSubview(self.titlesContainer)
end

---@param opts HStackOpts
function PlayerView:updatePlaybackContentViewOpts(opts)
   if self.playbackContentView then
      self.playbackContentView:updateOpts(opts)
      return
   end

   self.playbackContentView = HStack(opts)
   self.playbackContainerView:addSubview(self.playbackContentView)
end

---@param opts HStackOpts
function PlayerView:updateControlsButtonsViewOpts(opts)
   if self.controlsButtonsView then
      self.controlsButtonsView:updateOpts(opts)
      return
   end

   self.controlsButtonsView = HStack(opts)
   self.contentView:addSubview(self.controlsButtonsView)
end

---@param opts VStackOpts
function PlayerView:updatePlaybackConainerViewOpts(opts)
   if self.playbackContainerView then
      self.playbackContainerView:updateOpts(opts)
      return
   end

   self.playbackContainerView = VStack(opts)
   self.contentView:addSubview(self.playbackContainerView)
end

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
            backgroundColor = colors.clear,
         },
      },
      titleState = {
         normal = {},
      },
      offColor = colors.background,
   }
   self.controlsButtonsView:addSubview(self.shuffleButton)
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
   self.controlsButtonsView:addSubview(self.prevButton)
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
   self.controlsButtonsView:addSubview(self.playButton)
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
   self.controlsButtonsView:addSubview(self.nextButton)
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
   self.controlsButtonsView:addSubview(self.loopButton)
end

function PlayerView:updateSongImageOpts()
   if self.songImage then
      return
   end

   self.songsImageShader = Config.res.shaders.shadowing()
   self.songsImageShader:send("enabled", 0)
   self.songsImageShader:send("tocolor", colors.secondary:asVec4())

   self.songImage = Image {
      width = 30,
      height = 30,
      autoResizing = false,
      backgroundColor = colors.white,
      shader = self.songsImageShader,
   }
   self.playbackContentView:addSubview(self.songImage)
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
   -- Don't add this view to imageview in order to prevent wrong coloring with shader
   self:addSubview(self.minimizeButton)
end

function PlayerView:toString()
   return "PlayerView"
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
   self.playbackContainerView:addSubview(self.playbackView)
end

---@private
function PlayerView:showMinimizeButtonIfNeeded()
   local x, y = love.mouse.getX(), love.mouse.getY()

   self.minimizeButton.isHidden = not self.minimizeButton:isPointInside(x, y)
      or self.songImage.isHidden

   ---@type integer
   local enabled

   if self.minimizeButton.isHidden then
      enabled = 1
   else
      enabled = 0
   end

   self.songsImageShader:send("enabled", enabled)
end

return PlayerView
