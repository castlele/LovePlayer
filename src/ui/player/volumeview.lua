local View = require("src.ui.view")
local Image = require("src.ui.image")
local tableutils = require("src.utils.tableutils")
local imageDataModule = require("src.ui.imagedata")
local colors = require("src.ui.colors")

---@class VolumeView : View
---@field private interactor PlayerInteractor
---@field private noVolumeImage image.ImageData
---@field private lowVolumeImage image.ImageData
---@field private highVolumeImage image.ImageData
---@field private volumeImage Image
---@field private volumeRangeView View
local VolumeView = View()

---@class VolumeViewOpts : ViewOpts
---@field interactor PlayerInteractor
---@field expandedHeight number
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
      width = Config.buttons.volume.width,
      height = Config.buttons.volume.height,
      isUserInteractionEnabled = true,
      expandedHeight = 40,
   }, opts)

   View.init(self, o)
end

function VolumeView:handleMousePressed(x, y, mouse, isTouch)
   if self.volumeImage:isPointInside(x, y) then
      self:updateVolumeImage()
   end
end

function VolumeView:update(dt)
   View.update(self, dt)

   self.volumeImage.origin = self.origin
   self.volumeRangeView.origin.x = self.origin.x
   self.volumeRangeView.origin.y = self.origin.y + self.size.height

   self:expandIfNeeded(dt)
end

---@param opts VolumeViewOpts
function VolumeView:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = opts.interactor or self.interactor
   self.shader = nil

   self._shader = love.graphics.newShader([[
extern number progress;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
   if (texture_coords.y <= progress) {
      return vec4(1, 0, 0, 1);
   } else {
      return vec4(0, 0, 0, 0);
   }
}
   ]])

   self:updateImageOpts {
      isUserInteractionEnabled = true,
      backgroundColor = colors.clear,
      width = self.size.width,
      height = self.size.height,
      shader = self._shader,
      imageData = self.highVolumeImage,
   }
   self:updateVolumeRangeViewOpts {
      backgroundColor = colors.clear,
      width = self.size.width,
      height = opts.expandedHeight,
      imageData = self.highVolumeImage,
      -- shader = self._shader,
   }
end

function VolumeView:toString()
   return "VolumeView"
end

---@private
---@param opts ImageOpts
function VolumeView:updateImageOpts(opts)
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
function VolumeView:updateVolumeImage()
   if self.interactor:getVolume() > 0 then
      self.interactor:toggleMute()

      self:updateImageOpts {
         imageData = self.noVolumeImage,
      }
   else
      self.interactor:toggleMute()

      if self.interactor:getVolume() > 0.5 then
         self:updateImageOpts {
            imageData = self.highVolumeImage,
         }
      else
         self:updateImageOpts {
            imageData = self.lowVolumeImage,
         }
      end
   end
end

---@private
---@param dt number
function VolumeView:expandIfNeeded(dt)
   local x, y = love.mouse.getX(), love.mouse.getY()

   if self:isPointInside(x, y) then
      self.animState = self.animState + dt

      if self.animState > 1 then
         self.animState = 1
      end
   else
      self.animState = self.animState - dt

      if self.animState < 0 then
         self.animState = 0
      end
   end

   self._shader:send("progress", self.animState)
end

return VolumeView
