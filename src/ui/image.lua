local View = require("src.ui.view")

---@class Image : View
---@field image love.Image
local Image = View()


---@param path string
function Image:addImage(path)
   self.image = love.graphics.newImage(path)
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


return Image
