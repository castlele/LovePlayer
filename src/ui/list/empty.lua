local View = require("src.ui.view")
local Button = require("src.ui.button")
local Image = require("src.ui.image")
local Color = require("src.ui.color")
local geom = require("src.ui.geometry")

---@class EmptyView : View
---@field private image Image
---@field private folderPickerButton Button
local EmptyView = View()


function EmptyView:load()
   ---@diagnostic disable-next-line
   View.load(self)
   self.size = geom.Size(
      love.graphics.getWidth(),
      love.graphics.getHeight()
   )

   local path = "res/no_folder.png"
   self.image = Image()
   self.image:addImage(path)

   self.folderPickerButton = Button()
   self.folderPickerButton.size = geom.Size(100, 50)
   self.folderPickerButton.backgroundColor = Color(0, 0, 1, 1)
   self.folderPickerButton:addTapAction(function ()
      print("Picking folder with music!")
   end)

   self:addSubview(self.image)
   self:addSubview(self.folderPickerButton)
end

function EmptyView:update(dt)
   local buttonX = self.size.width / 2 - self.folderPickerButton.size.width / 2
   local buttonY = self.size.height - self.folderPickerButton.size.height
   self.folderPickerButton.origin.x = buttonX
   self.folderPickerButton.origin.y = buttonY

   local imageX = self.size.width / 2 - self.image.size.width / 2
   local imageY = self.size.height / 2 - self.image.size.height / 2
   self.image.origin.x = imageX
   self.image.origin.y = imageY

   View.update(self, dt)
end

function EmptyView:toString()
   return "EmptyView"
end


return EmptyView
