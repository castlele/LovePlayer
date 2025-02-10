local View = require("src.ui.view")
local Button = require("src.ui.button")
local tableutils = require("src.utils.tableutils")
local imageDataModule = require("src.ui.imagedata")
local colors = require("src.ui.colors")

---@class SongsQueue : View
---@field private interactor PlayerInteractor
---@field private isExpanded boolean
---@field private headerView View
---@field private expandButton Button
local SongsQueue = View()

---@class SongsQueueOpts : ViewOpts
---@field interactor PlayerInteractor
---@param opts SongsQueueOpts
function SongsQueue:init(opts)
   ---@type SongsQueueOpts
   local o = tableutils.concat({
      backgroundColor = colors.white,
   }, opts)

   View.init(self, o)
end

function SongsQueue:update(dt)
   View.update(self, dt)

   self.headerView.size.width = self.size.width
   self.headerView.origin = self.origin

   self.expandButton:centerX(self.headerView)
   self.expandButton.origin.y = self.headerView.origin.y + 5
end

---@param opts SongsQueueOpts
function SongsQueue:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = opts.interactor or self.interactor
   self.isExpanded = false

   self:updateHeaderViewOpts {
      height = Config.navBar.height,
   }
   self:updateExpandButtonOpts {
      state = {
         normal =  {
            backgroundColor = colors.clear,
         },
      },
      titleState = {
         type = "image",
         normal = {
            backgroundColor = colors.clear,
            width = 16 * 2,
            height = 6 * 2,
            imageData = imageDataModule.imageData:new(
               Config.res.images.expandArrowUp,
               imageDataModule.imageDataType.PATH
            )
         },
      },
   }
end

function SongsQueue:toString()
   return "SongsQueue"
end

---@private
---@param opts ViewOpts
function SongsQueue:updateHeaderViewOpts(opts)
   if self.headerView then
      self.headerView:updateOpts(opts)
      return
   end

   self.headerView = View(opts)
   self:addSubview(self.headerView)
end

---@private
---@param opts ButtonOpts
function SongsQueue:updateExpandButtonOpts(opts)
   if self.expandButton then
      self.expandButton:updateOpts(opts)
      return
   end

   self.expandButton = Button(opts)
   self.headerView:addSubview(self.expandButton)
end

return SongsQueue
