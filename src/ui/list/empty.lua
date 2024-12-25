local View = require("src.ui.view")
local Color = require("src.ui.color")
local geom = require("src.ui.geometry")

---@class EmptyView
---@field private image love.Image
---@field private folderPickerButton View
local EmptyView = View()


function EmptyView:load()
   ---@diagnostic disable-next-line
   View.load(self)
   self.size = geom.Size(
      love.graphics.getWidth(),
      love.graphics.getHeight()
   )

   local path = "res/no_folder.png"
   --TODO: This should be abstracted to view and added to subviews
   self.image = love.graphics.newImage(path)

   self.folderPickerButton = View()
   self.folderPickerButton:load()
   self.folderPickerButton.size = geom.Size(100, 50)
   self.folderPickerButton.backgroundColor = Color(0, 0, 1, 1)
   self.folderPickerButton:subcribe(
      "press",
      function ()
         local x = love.mouse.getX()
         local y = love.mouse.getY()
         local isPointInside = self.folderPickerButton:isPointInside(x, y)
         return love.mouse.isDown(1, 1) and isPointInside
      end,
      function () print("Picking folder with music!") end
   )

   self:addSubview(self.folderPickerButton)
end

function EmptyView:update(dt)
   ---@diagnostic disable-next-line
   View.update(self)
   local x = self.size.width / 2 - self.folderPickerButton.size.width / 2
   local y = self.size.height - self.folderPickerButton.size.height
   self.folderPickerButton.origin = geom.Point(x, y)
end

function EmptyView:draw()
   ---@diagnostic disable-next-line
   View.draw(self)

   local x = self.size.width / 2 - self.image:getWidth() / 2
   local y = self.size.height / 2 - self.image:getHeight() / 2
   love.graphics.draw(self.image, x, y)
end


return EmptyView
