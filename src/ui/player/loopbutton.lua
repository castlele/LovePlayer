local Button = require("src.ui.button")
local LoopMode = require("src.domain.player.loopmode")
local imageDataModule = require("src.ui.imagedata")
local colors = require("src.ui.colors")
local tableutils = require("src.utils.tableutils")

---@class LoopButton : Button
---@field loopMode LoopMode
---@field private opts ButtonOpts
local LoopButton = Button()

local noneLoop = imageDataModule.imageData:new(
   Config.res.images.loop_none,
   imageDataModule.imageDataType.PATH
)
local queueLoop = imageDataModule.imageData:new(
   Config.res.images.loop_queue,
   imageDataModule.imageDataType.PATH
)
local songLoop = imageDataModule.imageData:new(
   Config.res.images.loop_song,
   imageDataModule.imageDataType.PATH
)

---@class LoopButtonOpts : ButtonOpts
---@field action fun(self: LoopButton)
---@field shader love.Shader
---@field loopMode LoopMode?
---@param opts LoopButtonOpts
function LoopButton:init(opts)
   self.opts = tableutils.concat(opts, {
      action = function()
         opts.action(self)
      end,
      state = {
         normal = {
            backgroundColor = colors.clear,
         },
      },
      titleState = {
         type = "image",
         normal = {
            width = opts.width or Config.buttons.loop.width,
            height = opts.height or Config.buttons.loop.height,
            imageData = noneLoop,
            backgroundColor = colors.clear,
            shader = opts.shader,
         },
      },
   })

   Button.init(self, self.opts)

   self.loopMode = opts.loopMode or LoopMode.NONE
end

function LoopButton:update(dt)
   Button.update(self, dt)

   self:updateLoopModeImage()

   self:updateOpts(self.opts)
end

function LoopButton:toString()
   return "LoopButton"
end

---@private
function LoopButton:updateLoopModeImage()
   local m = self.loopMode
   ---@type image.ImageData
   local img

   if m == LoopMode.NONE then
      img = noneLoop
   elseif m == LoopMode.QUEUE then
      img = queueLoop
   elseif m == LoopMode.SONG then
      img = songLoop
   else
      assert(false, "Unknown LoopMode case: " .. m)
   end

   self.opts.titleState.normal.imageData = img
end

return LoopButton
