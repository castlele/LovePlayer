local View = require("src.ui.view")
local Button = require("src.ui.button")
local Image = require("src.ui.image")
local Color = require("src.ui.color")
local geom = require("src.ui.geometry")
local mediaLoader = require("src.domain.fm")
local log = require("src.domain.logger")

---@class List : View
---@field private noFolderImage Image
---@field private folderPickerButton Button
local List = View()


function List:load()
   ---@diagnostic disable-next-line
   View.load(self)
   self.size = geom.Size(
      love.graphics.getWidth(),
      love.graphics.getHeight()
   )

   local path = "res/no_folder.png"
   self.noFolderImage = Image()
   self.noFolderImage:addImage(path)

   self.folderPickerButton = Button()
   self.folderPickerButton.size = geom.Size(100, 50)
   self.folderPickerButton.backgroundColor = Color(0, 0, 1, 1)
   self.folderPickerButton:addTapAction(function () self:openFolder() end)

   self:addSubview(self.noFolderImage)
   self:addSubview(self.folderPickerButton)
end

function List:openFolder()
   local nfd = require("nfd")
   local folderPath = nfd.openFolder()

   --WARN: Error handling should be added here
   if not folderPath and not type(folderPath) == "string" then
      log.logger.default.log(
         "Can't get folder! Got: " .. folderPath,
         ---@diagnostic disable-next-line
         log.level.ERROR
      )
      return
   end

   local songs = mediaLoader.loadMedia(folderPath)
end

function List:update(dt)
   local buttonX = self.size.width / 2 - self.folderPickerButton.size.width / 2
   local buttonY = self.size.height - self.folderPickerButton.size.height
   self.folderPickerButton.origin.x = buttonX
   self.folderPickerButton.origin.y = buttonY

   local noFolderImageX = self.size.width / 2 - self.noFolderImage.size.width / 2
   local noFolderImageY = self.size.height / 2 - self.noFolderImage.size.height / 2
   self.noFolderImage.origin.x = noFolderImageX
   self.noFolderImage.origin.y = noFolderImageY

   View.update(self, dt)
end

function List:toString()
   return "List"
end


return List
