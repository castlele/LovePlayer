local View = require("src.ui.view")

---@class Image : View
---@field image love.Image
---@field private imagePath string
local Image = View()

function Image:init()
   View.init(self)

   self.imagePath = ""
end

---@param path string
function Image:addImage(path)
   self.image = love.graphics.newImage(path)
   self.imagePath = path
end

function Image:update(dt)
   local imageWidth = self.image:getWidth()
   local imageHeight = self.image:getHeight()

   if imageWidth ~= self.size.width then
      self.size.width = imageWidth
   end

   if imageHeight ~= self.size.height then
      self.size.height = imageHeight
   end

   View.update(self, dt)
end

function Image:draw()
   View.draw(self)

   love.graphics.draw(self.image, self.origin.x, self.origin.y)
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
