local View = require("src.ui.view")
local Image = require("src.ui.image")
local tableutils = require("src.utils.tableutils")
local imageDataModule = require("src.ui.imagedata")
local colors = require("src.ui.colors")

---@class VolumeView : View
---@field private resizing boolean
---@field private offColor table
---@field private onColor table
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
---@field static boolean
---@field orientation ("portrait"|"landscape")?
---@field offColor Color?
---@field onColor Color?
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
      if self.orientation == "portrait" then
         self:updateVolume(y)
      else
         self:updateVolume(x)
      end
   end
end

function VolumeView:update(dt)
   View.update(self, dt)

   self._shader:send("offColor", self.offColor)
   self._shader:send("onColor", self.onColor)
   self._shader:send("volumeState", self.interactor:getVolume())

   self.volumeImage.origin = self.origin

   local vr = self.volumeRangeView

   if self.orientation == "portrait" then
      self._shader:send("orientation", 0)

      vr:centerX(self)
      vr.origin.y = self.volumeImage.origin.y
         + self.volumeImage.size.height
         + padding

      self.draggingView:centerX(self)

      local d = self.draggingView
      local volume = self.interactor:getVolume()
      local halfH = d.size.height / 2

      d.origin.y = volume * vr.size.height + vr.origin.y - halfH
   else
      self._shader:send("orientation", 1)

      vr:centerY(self)
      vr.origin.x = self.volumeImage.origin.x
         + self.volumeImage.size.width
         + padding

      self.draggingView:centerY(self)

      local d = self.draggingView
      local volume = self.interactor:getVolume()
      local halfW = d.size.width / 2

      d.origin.x = volume * vr.size.width + vr.origin.x - halfW
   end

   self:expandIfNeeded(dt)
   self:handleDragging()
   self:updateVolumeImage()
end

---@param opts VolumeViewOpts
function VolumeView:updateOpts(opts)
   View.updateOpts(self, opts)

   self.static = opts.static
   self.onColor = (opts.onColor or colors.accent):asVec4()
   self.offColor = (opts.offColor or colors.secondary):asVec4()
   self.orientation = opts.orientation or "portrait"
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
   local vw
   local vh
   local dw
   local dh

   if self.orientation == "portrait" then
      dw = self.size.width
      dh = self.size.width / 2
   else
      dw = self.size.height
      dh = self.size.height / 2
   end

   if self.orientation == "portrait" then
      vw = self.size.width / 2
      vh = self.size.height - padding - self.volumeImage.size.height - dh / 2
   else
      vw = self.size.width - padding - self.volumeImage.size.width - dw / 2
      vh = self.size.height / 2
   end

   self:updateVolumeRangeViewOpts {
      backgroundColor = colors.clear,
      width = vw,
      height = vh,
      imageData = self.highVolumeImage,
      shader = self._shader,
   }

   self:updateDraggingViewOpts {
      backgroundColor = colors.clear,
      height = dh,
      width = dw,
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
   if self.static then
      self.animState = 1
   else
      local x, y = love.mouse.getX(), love.mouse.getY()
      local animSpeed = 0.03
      local pointInside = self.volumeImage:isPointInside(x, y)

      if
         pointInside and self.animState < 1
         or self.animState > 0 and self:isPointInside(x, y)
      then
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
   end

   self._shader:send("animProgress", self.animState)
end

---@private
function VolumeView:handleDragging()
   local x, y = love.mouse.getX(), love.mouse.getY()

   if self.draggingView:isPointInside(x, y) and self.animState == 1 then
      self.resizing = true
   end

   if love.mouse.isDown(1) and self.resizing then
      if self.orientation == "portrait" then
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
         local vr = self.volumeRangeView
         local d = self.draggingView
         local halfW = d.size.width / 2

         d.origin.x = x - halfW

         if d.origin.x + halfW < vr.origin.x then
            d.origin.x = vr.origin.x - halfW
         end

         if d.origin.x + halfW > vr.size.width + vr.origin.x then
            d.origin.x = vr.size.width + vr.origin.x - halfW
         end

         self:updateVolume(d.origin.x + halfW)
      end
   else
      self.resizing = false
   end
end

---@private
---@param value number
function VolumeView:updateVolume(value)
   if self.animState ~= 1 then
      return
   end

   local this = self.volumeRangeView
   local volume

   if self.orientation == "portrait" then
      volume = (value - this.origin.y) / this.size.height
   else
      volume = (value - this.origin.x) / this.size.width
   end

   if volume < 0 then
      volume = 0
   end

   self.interactor:setVolume(volume)
end

return VolumeView
