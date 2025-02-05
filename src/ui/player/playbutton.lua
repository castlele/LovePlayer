local Button = require("src.ui.button")
local imageDataModule = require("src.ui.imagedata")
local PlayerState = require("src.domain.player.playerstate")
local colors = require("src.ui.colors")

---@class PlayButton : Button
---@field private opts PlayButtonOpts
---@field private interactor PlayerInteractor
---@field private isPaused boolean
local PlayButton = Button()

PlayButton.playImage = imageDataModule.imageData:new(
   Config.res.images.play,
   imageDataModule.imageDataType.PATH
)
PlayButton.pauseImage = imageDataModule.imageData:new(
   Config.res.images.pause,
   imageDataModule.imageDataType.PATH
)

---@class PlayButtonOpts : ButtonOpts
---@field interactor PlayerInteractor
---@field isPaused boolean?
---@param opts PlayButtonOpts
function PlayButton:init(opts)
   local bg = (opts.state or { normal = { backgroundColor = nil } }).normal.backgroundColor

   self.opts = {
      interactor = opts.interactor,
      shader = opts.shader,
      action = opts.action,
      state = {
         normal = {
            backgroundColor = bg or colors.secondary,
         },
      },
      titleState = {
         type = "image",
         normal = {
            width = opts.width or Config.buttons.play.width,
            height = opts.height or Config.buttons.play.height,
            backgroundColor = colors.clear,
            shader = opts.shader,
         },
      },
   }

   Button.init(self, self.opts)

   self.isPaused = opts.isPaused or true
   self.interactor = opts.interactor
end

function PlayButton:update(dt)
   Button.update(self, dt)

   self.isPaused = self.interactor:getState() == PlayerState.PAUSED

   if self.isPaused then
      self.opts.titleState.normal.imageData = PlayButton.playImage
   else
      self.opts.titleState.normal.imageData = PlayButton.pauseImage
   end

   self:updateOpts(self.opts)
end

---@param opts PlayButtonOpts
function PlayButton:updateOpts(opts)
   Button.updateOpts(self, opts)
end

function PlayButton:toString()
   return "PlayButton"
end

return PlayButton
