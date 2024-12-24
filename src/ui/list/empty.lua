local View = require("src.ui.view")
local geom = require("src.ui.geometry")

---@class EmptyView
---@field private image love.Image
local EmptyView = View()


function EmptyView:load()
   ---@diagnostic disable-next-line
   View.load(self)
   self.size = geom.Size(
      love.graphics.getWidth(),
      love.graphics.getHeight()
   )
   local path = "res/no_folder.png"

   self.image = love.graphics.newImage(path)
end

function EmptyView:draw()
   ---@diagnostic disable-next-line
   View.draw(self)

   local x = self.size.width / 2 - self.image:getWidth() / 2
   local y = self.size.height / 2 - self.image:getHeight() / 2
   love.graphics.draw(self.image, x, y)
end


return EmptyView
