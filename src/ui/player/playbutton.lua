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
---@field action fun(isPaused: boolean)
---@param opts PlayButtonOpts
function PlayButton:init(opts)
   local shader = Config.res.shaders.coloring()
   shader:send("tocolor", colors.accent:asVec4())

   self.opts = {
      action = function()
         self.isPaused = not self.isPaused
         opts.action(self.isPaused)
      end,
      state = {
         normal = {
            backgroundColor = colors.secondary,
         },
      },
      titleState = {
         type = "image",
         normal = {
            width = 40,
            height = 40,
            imageData = playImage,
            backgroundColor = colors.clear,
            shader = shader,
         },
      },
   }

   Button.init(self, self.opts)

   self.isPaused = false
end

function PlayButton:update(dt)
   Button.update(self, dt)

   if self.isPaused then
      self.opts.titleState.normal.imageData = pauseImage
   else
      self.opts.titleState.normal.imageData = playImage
   end

   self:updateOpts(self.opts)
end

return PlayButton
