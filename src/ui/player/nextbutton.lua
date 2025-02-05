local Button = require("src.ui.button")
local colors = require("src.ui.colors")
local imageDataModule = require("src.ui.imagedata")
local tableutils = require("src.utils.tableutils")

---@class NextButton : Button
---@field private interactor PlayerInteractor
local NextButton = Button()

---@class NextButtonOpts : ButtonOpts
---@field interactor PlayerInteractor
---@param opts NextButtonOpts
function NextButton:init(opts)
   self.interactor = opts.interactor or self.interactor

   local o = tableutils.concat({
      action = function()
         self.interactor:next()
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
               Config.res.images.next,
               imageDataModule.imageDataType.PATH
            ),
         },
      },
   }, opts)

   Button.init(self, o)
end

---@param opts NextButtonOpts
function NextButton:updateOpts(opts)
   Button.updateOpts(self, opts)
end

return NextButton
