local Button = require("lovekit.ui.button")
local colors = require("lovekit.ui.colors")
local imageDataModule = require("lovekit.ui.imagedata")
local tableutils = require("lovekit.utils.tableutils")

---@class PrevButton : Button
---@field private interactor PlayerInteractor
local PrevButton = Button()

---@class PrevButtonOpts : ButtonOpts
---@field interactor PlayerInteractor
---@param opts PrevButtonOpts
function PrevButton:init(opts)
   self.interactor = opts.interactor or self.interactor

   local o = tableutils.concat({
      action = function()
         self.interactor:prev()
      end,
      state = {
         normal = {
            backgroundColor = colors.clear,
         },
      },
      titleState = {
         type = "image",
         normal = {
            width = Config.buttons.next_prev.width,
            height = Config.buttons.next_prev.height,
            backgroundColor = colors.clear,
            imageData = imageDataModule.imageData:new(
               Config.res.images.prev,
               imageDataModule.imageDataType.PATH
            ),
         },
      },
   }, opts)

   Button.init(self, o)
end

---@param opts PrevButtonOpts
function PrevButton:updateOpts(opts)
   Button.updateOpts(self, opts)
end

return PrevButton
