local View = require("src.ui.view")
local Image = require("src.ui.image")
local tableutils = require("src.utils.tableutils")
local imageDataModule = require("src.ui.imagedata")
local colors = require("src.ui.colors")

---@class VolumeView : View
---@field private resizing boolean
---@field private interactor PlayerInteractor
---@field private noVolumeImage image.ImageData
---@field private lowVolumeImage image.ImageData
---@field private highVolumeImage image.ImageData
---@field private volumeImage Image
---@field private volumeRangeView View
---@field private draggingView View
local VolumeView = View()

local padding = 10

---@class VolumeViewOpts : ViewOpts
---@field interactor PlayerInteractor
---@param opts VolumeViewOpts
function VolumeView:init(opts)
   self.noVolumeImage = imageDataModule.imageData:new(
      Config.res.images.no_volume,
      imageDataModule.imageDataType.PATH,
      "noVolume"
   )
   self.lowVolumeImage = imageDataModule.imageData:new(
      Config.res.images.low_volume,
      imageDataModule.imageDataType.PATH,
      "lowVolume"
   )
   self.highVolumeImage = imageDataModule.imageData:new(
      Config.res.images.high_volume,
      imageDataModule.imageDataType.PATH,
      "highVolume"
   )
   self.animState = 0.0

   local o = tableutils.concat({
      backgroundColor = colors.clear,
      isUserInteractionEnabled = true,
   }, opts)

   View.init(self, o)
end

function VolumeView:handleMousePressed(x, y, mouse, isTouch)
   if self.volumeImage:isPointInside(x, y) then
      self:toggleMuteState()
   end

   if self.volumeRangeView:isPointInside(x, y) then
      self:updateVolume(y)
   end
end

function VolumeView:update(dt)
   View.update(self, dt)

   self._shader:send("offColor", colors.secondary:asVec4())
   self._shader:send("onColor", colors.accent:asVec4())
   self._shader:send("volumeState", self.interactor:getVolume())

   self.volumeImage.origin = self.origin

   local vr = self.volumeRangeView

   vr:centerX(self)
   vr.origin.y = self.volumeImage.origin.y
      + self.volumeImage.size.height
      + padding

   self.draggingView:centerX(self)

   local d = self.draggingView
   local volume = self.interactor:getVolume()
   local halfH = d.size.height / 2

   d.origin.y = volume * vr.size.height + vr.origin.y - halfH

   self:expandIfNeeded(dt)
   self:handleDragging()
   self:updateVolumeImage()
end

---@param opts VolumeViewOpts
function VolumeView:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = opts.interactor or self.interactor
   self.shader = nil

   self._shader = Config.res.shaders.volume()

   self:updateVolumeImageOpts {
      isUserInteractionEnabled = true,
      backgroundColor = colors.clear,
      width = Config.buttons.volume.width,
      height = Config.buttons.volume.height,
      imageData = self.highVolumeImage,
      shader = opts.shader,
   }
   self:updateVolumeRangeViewOpts {
      backgroundColor = colors.clear,
      width = self.size.width / 2,
      height = self.size.height - padding - self.volumeImage.size.height,
      imageData = self.highVolumeImage,
      shader = self._shader,
   }
   self:updateDraggingViewOpts {
      backgroundColor = colors.clear,
      width = self.size.width,
      height = self.size.width / 2,
   }
end

function VolumeView:toString()
   return "VolumeView"
end

---@private
---@param opts ImageOpts
function VolumeView:updateVolumeImageOpts(opts)
   if self.volumeImage then
      self.volumeImage:updateOpts(opts)
      return
   end

   self.volumeImage = Image(opts)
   self:addSubview(self.volumeImage)
end

---@private
---@param opts ImageOpts
function VolumeView:updateVolumeRangeViewOpts(opts)
   if self.volumeRangeView then
      self.volumeRangeView:updateOpts(opts)
      return
   end

   self.volumeRangeView = Image(opts)
   self:addSubview(self.volumeRangeView)
end

---@private
---@param opts ViewOpts
function VolumeView:updateDraggingViewOpts(opts)
   if self.draggingView then
      self.draggingView:updateOpts(opts)
      return
   end

   self.draggingView = View(opts)
   self:addSubview(self.draggingView)
end

---@private
function VolumeView:toggleMuteState()
   self.interactor:toggleMute()
end

---@private
function VolumeView:updateVolumeImage()
   if self.interactor:getVolume() == 0 then
      self:updateVolumeImageOpts {
         imageData = self.noVolumeImage,
      }
   else
      if self.interactor:getVolume() > 0.5 then
         self:updateVolumeImageOpts {
            imageData = self.highVolumeImage,
         }
      else
         self:updateVolumeImageOpts {
            imageData = self.lowVolumeImage,
         }
      end
   end
end

---@private
---@param dt number
function VolumeView:expandIfNeeded(dt)
   local x, y = love.mouse.getX(), love.mouse.getY()
   local animSpeed = 0.03

   if self.volumeImage:isPointInside(x, y) and self.animState < 1 then
      self.animState = self.animState + dt + animSpeed

      if self.animState > 1 then
         self.animState = 1
      end
   elseif not self:isPointInside(x, y) then
      self.animState = self.animState - dt - animSpeed

      if self.animState < 0 then
         self.animState = 0
      end
   end

   self._shader:send("animProgress", self.animState)
end

---@private
function VolumeView:handleDragging()
   local x, y = love.mouse.getX(), love.mouse.getY()

   if self.draggingView:isPointInside(x, y) then
      self.resizing = true
   end

   if love.mouse.isDown(1) and self.resizing then
      local vr = self.volumeRangeView
      local d = self.draggingView
      local halfH = d.size.height / 2

      d.origin.y = y - halfH

      if d.origin.y + halfH < vr.origin.y then
         d.origin.y = vr.origin.y - halfH
      end

      if d.origin.y + halfH > vr.size.height + vr.origin.y then
         d.origin.y = vr.size.height + vr.origin.y - halfH
      end

      self:updateVolume(d.origin.y + halfH)
   else
      self.resizing = false
   end
end

---@private
---@param y number
function VolumeView:updateVolume(y)
   local this = self.volumeRangeView
   local volume = (y - this.origin.y) / this.size.height

   if volume < 0 then
      volume = 0
   end

   self.interactor:setVolume(volume)
end

return VolumeView
