local Button = require("src.ui.button")
local colors = require("src.ui.colors")
local imageDataModule = require("src.ui.imagedata")
local tableutils = require("src.utils.tableutils")

---@class ShuffleButton : Button
---@field private interactor PlayerInteractor
---@field private _shader love.Shader
---@field private onColor table
---@field private offColor table
local ShuffleButton = Button()

---@class ShuffleButtonOpts : ButtonOpts
---@field interactor PlayerInteractor
---@field onColor Color?
---@field offColor Color?
---@param opts ShuffleButtonOpts
function ShuffleButton:init(opts)
   self.interactor = opts.interactor or self.interactor
   self._shader = Config.res.shaders.coloring()

   ---@type ShuffleButtonOpts
   local o = tableutils.concat({
      action = function()
         self.interactor:toggleShuffle()
      end,
      state = {
         normal = {
            backgroundColor = colors.clear,
         },
      },
      titleState = {
         type = "image",
         normal = {
            width = Config.buttons.shuffle.width,
            height = Config.buttons.shuffle.height,
            backgroundColor = colors.clear,
            imageData = imageDataModule.imageData:new(
               Config.res.images.shuffle,
               imageDataModule.imageDataType.PATH
            ),
         },
      },
   }, opts)

   o.titleState.normal.shader = self._shader

   Button.init(self, o)
end

function ShuffleButton:update(dt)
   Button.update(self, dt)

   if self.interactor:isShufflingEnabled() then
      self._shader:send("tocolor", self.onColor)
   else
      self._shader:send("tocolor", self.offColor)
   end
end

---@param opts ShuffleButtonOpts
function ShuffleButton:updateOpts(opts)
   Button.updateOpts(self, opts)

   self.onColor = (opts.onColor or colors.accent):asVec4()
   self.offColor = (opts.offColor or colors.secondary):asVec4()
end

return ShuffleButton
