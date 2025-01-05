local View = require("src.ui.view")

---@class Image : View
---@field image love.Image?
---@field private autoResizing boolean
---@field private imageData image.ImageData?
local Image = View()

---@class ImageOpts : ViewOpts
---@field width number?
---@field height number?
---@field imageData image.ImageData?
---@field autoResizing boolean?
---@param opts ImageOpts
function Image:init(opts)
   View.init(self, opts)
end

function Image:update(dt)
   View.update(self, dt)

   if self.autoResizing and self.image then
      local imageW, imageH = self.image:getWidth(), self.image:getHeight()

      self.size.width, self.size.height = imageW, imageH
   end
end

function Image:draw()
   View.draw(self)

   if self.image then
      local imageW, imageH = self.image:getWidth(), self.image:getHeight()

      love.graphics.draw(
         self.image,
         self.origin.x,
         self.origin.y,
         nil,
         self.size.width / imageW,
         self.size.height / imageH
      )
   end
end

---@param opts ImageOpts
function Image:updateOpts(opts)
   View.updateOpts(self, opts)

   self.imageData = opts.imageData or self.imageData
   self.size.width = opts.width or self.size.width or 0
   self.size.height = opts.height or self.size.height or 0
   self.autoResizing = opts.autoResizing or self.autoResizing or false

   if self.imageData then
      self.image = self.imageData:getImage()
   end
end

function Image:toString()
   return "Image"
end

---@protected
function Image:debugInfo()
   local info = View.debugInfo(self)

   return info .. string.format("; image=%s", self.imagePath)
end

return Image
