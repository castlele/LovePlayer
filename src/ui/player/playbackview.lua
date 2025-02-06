local View = require("src.ui.view")
local Image = require("src.ui.image")
local tableutils = require("src.utils.tableutils")
local imageDataModule = require("src.ui.imagedata")
local colors = require("src.ui.colors")

---@class PlaybackView : View
---@field private interactor PlayerInteractor
---@field private timelineView Image
---@field private progressView View
local PlaybackView = View()

---@class PlaybackViewOpts : ViewOpts
---@field interactor PlayerInteractor
---@param opts PlaybackViewOpts
function PlaybackView:init(opts)
   local o = tableutils.concat({
      backgroundColor = colors.clear,
      height = 40,
      isUserInteractionEnabled = true,
   }, opts)

   View.init(self, o)
end

function PlaybackView:handleMousePressed(x, y, mouse, isTouch)
   local progress = (x - self.origin.x) / self.size.width
   self.interactor:setProgress(progress)
end

function PlaybackView:update(dt)
   View.update(self, dt)

   local progress = self.interactor:getProgress()

   self.timelineView:centerX(self)
   self.timelineView:centerY(self)
   self.timelineView.size.width = self.size.width

   self.progressView:centerY(self.timelineView)
   self.progressView.origin.x = progress * self.size.width + self.origin.x - self.progressView.size.width / 2

   self._shader:send("progress", progress)
end

---@param opts PlaybackViewOpts
function PlaybackView:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = opts.interactor
   self._shader = Config.res.shaders.timeline()
   self._shader:send("onColor", colors.accent:asVec4())
   self._shader:send("offColor", colors.secondary:asVec4())

   self:updateTimelineViewOpts {
      height = 5,
      autoResizing = false,
      imageData = imageDataModule.imageData:new(
         Config.res.images.pause, -- random image to use shaders
         imageDataModule.imageDataType.PATH
      ),
      shader = self._shader,
   }
   self:updateProgressviewOpts {
      width = 12,
      height = 12,
      cornerRadius = 5,
      backgroundColor = colors.white,
   }
end

---@private
---@param opts ImageOpts
function PlaybackView:updateTimelineViewOpts(opts)
   if self.timelineView then
      self.timelineView:updateOpts(opts)
      return
   end

   self.timelineView = Image(opts)
   self:addSubview(self.timelineView)
end

---@private
---@param opts ViewOpts
function PlaybackView:updateProgressviewOpts(opts)
   if self.progressView then
      self.progressView:updateOpts(opts)
      return
   end

   self.progressView = View(opts)
   self:addSubview(self.progressView)
end

function PlaybackView:toString()
   return "PlaybackView"
end

return PlaybackView
