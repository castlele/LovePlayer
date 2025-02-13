local View = require("src.ui.view")
local Label = require("src.ui.label")
local Image = require("src.ui.image")
local tableutils = require("src.utils.tableutils")
local imageDataModule = require("src.ui.imagedata")
local colors = require("src.ui.colors")

---@class PlaybackView : View
---@field private interactor PlayerInteractor
---@field private minLabel Label
---@field private maxLabel Label
---@field private timelineView Image
---@field private progressView View
local PlaybackView = View()

---@class PlaybackViewOpts : ViewOpts
---@field interactor PlayerInteractor
---@field offColor Color?
---@field onColor Color?
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
   self:handleProgressChange(x)
end

function PlaybackView:update(dt)
   View.update(self, dt)

   local progress = self.interactor:getProgress()

   self:handleDragging()

   if self.interactor:getCurrent() then
      self:updateMinLabelOpts {
         title = self.interactor:getCurrentFormattedProgress(),
      }
      self:updateMaxLabelOpts {
         title = self.interactor:getFormattedDuration(),
      }
   else
      self:updateMinLabelOpts {
         title = "--:--",
      }
      self:updateMaxLabelOpts {
         title = "--:--",
      }
   end

   self.minLabel.origin = self.origin
   self.maxLabel.origin.x = self.origin.x
      + self.size.width
      - self.maxLabel.size.width
   self.maxLabel.origin.y = self.origin.y

   self.timelineView:centerX(self)
   self.timelineView:centerY(self)
   self.timelineView.size.width = self.size.width

   self.progressView:centerY(self.timelineView)
   self.progressView.origin.x = progress * self.size.width
      + self.origin.x
      - self.progressView.size.width / 2

   self._shader:send("progress", progress)
end

---@param opts PlaybackViewOpts
function PlaybackView:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = opts.interactor
   self._shader = Config.res.shaders.timeline()
   self._shader:send("onColor", (opts.onColor or colors.accent):asVec4())
   self._shader:send("offColor", (opts.offColor or colors.secondary):asVec4())

   ---@type LabelOpts
   local labelOpts = {
      textColor = colors.white,
      fontPath = Config.res.fonts.regular,
      fontSize = Config.res.fonts.size.body,
      backgroundColor = colors.clear,
   }

   self:updateMinLabelOpts(labelOpts)
   self:updateMaxLabelOpts(labelOpts)
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

function PlaybackView:toString()
   return "PlaybackView"
end

---@private
---@param opts LabelOpts
function PlaybackView:updateMinLabelOpts(opts)
   if self.minLabel then
      self.minLabel:updateOpts(opts)
      return
   end

   self.minLabel = Label(opts)
   self:addSubview(self.minLabel)
end

---@private
---@param opts LabelOpts
function PlaybackView:updateMaxLabelOpts(opts)
   if self.maxLabel then
      self.maxLabel:updateOpts(opts)
      return
   end

   self.maxLabel = Label(opts)
   self:addSubview(self.maxLabel)
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

---@private
---@param x number
function PlaybackView:handleProgressChange(x)
   local progress = (x - self.origin.x) / self.size.width

   if progress < 0 then
      progress = 0
   end

   self.interactor:setProgress(progress)
end

---@private
function PlaybackView:handleDragging()
   local x, y = love.mouse.getX(), love.mouse.getY()

   if self.progressView:isPointInside(x, y) then
      self.resizing = true
   end

   if love.mouse.isDown(1) and self.resizing then
      self.interactor:pause()
      local min = self.progressView.origin.x
      local max = self.progressView.origin.x + self.progressView.size.width
      self.progressView.origin.x = x

      if x < min then
         self.progressView.origin.x = min
      end

      if x > max then
         self.progressView.origin.x = max
      end

      self:handleProgressChange(self.progressView.origin.x)
   else
      if self.resizing then
         self.interactor:play()
      end

      self.resizing = false
   end
end

return PlaybackView
