local Button = require("src.ui.button")
local imageDataModule = require("src.ui.imagedata")
local colors = require("src.ui.colors")

---@class PlayButton : Button
---@field private opts ButtonOpts
---@field private isPaused boolean
local PlayButton = Button()

local playImage = imageDataModule.imageData:new(
   Config.res.images.play,
   imageDataModule.imageDataType.PATH
)
local pauseImage = imageDataModule.imageData:new(
   Config.res.images.pause,
   imageDataModule.imageDataType.PATH
)

---@class PlayButtonOpts : ViewOpts
---@field action fun(self: PlayButton)
---@field shader love.Shader
---@field isPaused boolean?
---@param opts PlayButtonOpts
function PlayButton:init(opts)
   self.opts = {
      action = function()
         opts.action(self)
      end,
      state = {
         normal = {
            backgroundColor = colors.secondary,
         },
      },
      titleState = {
         type = "image",
         normal = {
            width = opts.width or Config.buttons.play.width,
            height = opts.height or Config.buttons.play.height,
            imageData = playImage,
            backgroundColor = colors.clear,
            shader = opts.shader,
         },
      },
   }

   Button.init(self, self.opts)

   self.isPaused = opts.isPaused or true
end

function PlayButton:update(dt)
   Button.update(self, dt)

   if self.isPaused then
      self.opts.titleState.normal.imageData = playImage
   else
      self.opts.titleState.normal.imageData = pauseImage
   end

   self:updateOpts(self.opts)
end

function PlayButton:toString()
   return "PlayButton"
end

return PlayButton
