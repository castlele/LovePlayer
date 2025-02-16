local View = require("src.ui.view")
local Button = require("src.ui.button")
local Image = require("src.ui.image")
local Label = require("src.ui.label")
local VStack = require("src.ui.vstack")
local VolumeView = require("src.ui.player.volumeview")
local PlayerControlsView = require("src.ui.player.playercontrolsview")
local SongsQueueView = require("src.ui.player.songsqueue")
local imageDataModule = require("src.ui.imagedata")
local colors = require("src.ui.colors")

---@class MiniPlayer : View
---@field private interactor PlayerInteractor
---@field private isSongsQueueExpanded boolean
---@field private _shader love.Shader
---@field private volumeView VolumeView
---@field private expandButton Button
---@field private imageView Image
---@field private titlesContainer VStack
---@field private songNameLabel Label
---@field private artistNameLabel Label
---@field private playerControlsView PlayerControlsView
---@field private songsQueueShadowView View
---@field private songsQueueView SongsQueue
local MiniPlayer = View()

local w = 400
local h = 600

function MiniPlayer:init()
   love.window.setMode(w, h, {
      resizable = false,
      borderless = false,
      centered = true,
   })

   self.isSongsQueueExpanded = false
   self._shader = Config.res.shaders.coloring()
   self._shader:send("tocolor", colors.accent:asVec4())

   View.init(self, {
      backgroundColor = colors.background,
      width = w,
      height = h,
   })
end

function MiniPlayer:update(dt)
   View.update(self, dt)

   local currentSong = self.interactor:getCurrent()
   local padding = 20

   self.songsQueueShadowView.isHidden = currentSong == nil
   self.songsQueueView.isHidden = currentSong == nil

   if currentSong then
      self:updateImageOpts {
         imageData = currentSong.imageData,
      }
      self:updateSongNameLabelOpts {
         title = currentSong.title,
      }
      self:updateArtistNameLabelOpts {
         title = currentSong.artist.name or "Unknown",
      }
   else
      self:updateImageOpts {
         imageData = imageDataModule.imageData.placeholder,
      }
      self:updateSongNameLabelOpts {
         title = "Unknown",
      }
      self:updateArtistNameLabelOpts {
         title = "Unknown",
      }
   end

   self.imageView:centerX(self)
   self.imageView.origin.y = self.origin.y + padding

   self.volumeView.origin.x = self.origin.x + padding
   self.volumeView.origin.y = self.origin.y + padding

   self.expandButton.origin.x = self.origin.x
      + self.size.width
      - self.expandButton.size.width
      - padding
   self.expandButton.origin.y = self.origin.y + padding

   self.titlesContainer:centerX(self)
   self.titlesContainer.origin.y = self.imageView.origin.y
      + self.imageView.size.height
      + padding

   self.playerControlsView.size.width = self.size.width - padding * 2
   self.playerControlsView.size.height = self.size.height
      - self.titlesContainer.origin.y
      - self.titlesContainer.size.height
      - padding * 2
   self.playerControlsView.origin.y = self.titlesContainer.origin.y
      + self.titlesContainer.size.height
      + padding * 2
   self.playerControlsView.origin.x = self.origin.x + padding

   self.songsQueueView:centerX(self)
   self.songsQueueView.size.width = self.size.width

   if self.isSongsQueueExpanded then
      self.songsQueueView.origin.y = self.imageView.origin.y
      self.songsQueueView.size.height = self.size.height - self.imageView.origin.y
   else
      self.songsQueueView.origin.y = self.playerControlsView.origin.y
         + self.playerControlsView.size.height / 3
         + padding
      self.songsQueueView.size.height = self.size.height
         - self.songsQueueView.origin.y
   end

   self.songsQueueShadowView.origin.x = self.origin.x
   self.songsQueueShadowView.size.width = self.size.width
   self.songsQueueShadowView.origin.y = self.songsQueueView.origin.y
      - self.songsQueueShadowView.size.height
end

---@param opts ViewOpts
function MiniPlayer:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = PlayerInteractor

   self:updateVolumeViewOpts {
      interactor = self.interactor,
      shader = self._shader,
      static = false,
      width = Config.buttons.volume.width,
      height = w / 2,
   }
   self:updateExpandButtonOpts {
      action = function()
         Config.app.state = "normal"
         Config.app.isFlowChanged = true
      end,
      state = {
         normal = {
            backgroundColor = colors.background,
            width = Config.buttons.expand.width,
            height = Config.buttons.expand.height,
         },
      },
      titleState = {
         type = "image",
         normal = {
            width = Config.buttons.expand.width,
            height = Config.buttons.expand.height,
            backgroundColor = colors.clear,
            shader = self._shader,
            imageData = imageDataModule.imageData:new(
               Config.res.images.expand,
               imageDataModule.imageDataType.PATH
            ),
         },
      },
   }
   self:updateImageOpts {
      width = w / 2,
      height = w / 2,
   }
   self:updateSongNameLabelOpts {
      fontPath = Config.res.fonts.bold,
      fontSize = Config.res.fonts.size.header1,
      textColor = colors.white,
      backgroundColor = colors.clear,
   }
   self:updateArtistNameLabelOpts {
      fontPath = Config.res.fonts.regular,
      fontSize = Config.res.fonts.size.header3,
      textColor = colors.white,
      backgroundColor = colors.clear,
   }
   self:updateTitlesContainerOpts {
      backgroundColor = colors.clear,
      views = {
         self.songNameLabel,
         self.artistNameLabel,
      },
   }
   self:updatePlayerControlsViewOpts()
   self:updateSongsQueueShadowViewOpts {
      backgroundColor = colors.shadow,
      height = 2,
   }
   self:updateSongsQueueViewOpts {
      interactor = self.interactor,
      expandAction = function()
         self.isSongsQueueExpanded = not self.isSongsQueueExpanded
      end,
   }
end

function MiniPlayer:toString()
   return "MiniPlayer"
end

---@private
---@param opts VolumeViewOpts
function MiniPlayer:updateVolumeViewOpts(opts)
   if self.volumeView then
      self.volumeView:updateOpts(opts)
      return
   end

   self.volumeView = VolumeView(opts)
   self:addSubview(self.volumeView)
end

---@private
---@param opts ButtonOpts
function MiniPlayer:updateExpandButtonOpts(opts)
   if self.expandButton then
      self.expandButton:updateOpts(opts)
      return
   end

   self.expandButton = Button(opts)
   self:addSubview(self.expandButton)
end

---@private
---@param opts ImageOpts
function MiniPlayer:updateImageOpts(opts)
   if self.imageView then
      self.imageView:updateOpts(opts)
      return
   end

   self.imageView = Image(opts)
   self:addSubview(self.imageView)
end

---@private
---@param opts LabelOpts
function MiniPlayer:updateSongNameLabelOpts(opts)
   if self.songNameLabel then
      self.songNameLabel:updateOpts(opts)
      return
   end

   self.songNameLabel = Label(opts)
end

---@private
---@param opts LabelOpts
function MiniPlayer:updateArtistNameLabelOpts(opts)
   if self.artistNameLabel then
      self.artistNameLabel:updateOpts(opts)
      return
   end

   self.artistNameLabel = Label(opts)
end

---@private
---@param opts VStackOpts
function MiniPlayer:updateTitlesContainerOpts(opts)
   if self.titlesContainer then
      self.titlesContainer:updateOpts(opts)
      return
   end

   self.titlesContainer = VStack(opts)
   self:addSubview(self.titlesContainer)
end

---@private
function MiniPlayer:updatePlayerControlsViewOpts()
   if self.playerControlsView then
      return
   end

   self.playerControlsView = PlayerControlsView {
      backgroundColor = colors.background,
      interactor = self.interactor,
   }
   self:addSubview(self.playerControlsView)
end

---@private
---@param opts ViewOpts
function MiniPlayer:updateSongsQueueShadowViewOpts(opts)
   if self.songsQueueShadowView then
      self.songsQueueShadowView:updateOpts(opts)
      return
   end

   self.songsQueueShadowView = View(opts)
   self:addSubview(self.songsQueueShadowView)
end

---@private
---@param opts SongsQueueOpts
function MiniPlayer:updateSongsQueueViewOpts(opts)
   if self.songsQueueView then
      self.songsQueueView:updateOpts(opts)
      return
   end

   self.songsQueueView = SongsQueueView(opts)
   self:addSubview(self.songsQueueView)
end

return MiniPlayer
