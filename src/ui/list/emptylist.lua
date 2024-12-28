local View = require("src.ui.view")
local Button = require("src.ui.button")
local Image = require("src.ui.image")
local Color = require("src.ui.color")
local geom = require("src.ui.geometry")
local log = require("src.domain.logger")

---@class FolderPickerDelegate
---@field onFolderPicked fun(isSuccess: boolean)

---@class EmptyView : View
---@field folderPickerDelegate FolderPickerDelegate?
---@field interactor ListsInteractor
---@field private noFolderImage Image
---@field private folderPickerButton Button
local EmptyView = View()


function EmptyView:load()
   View.load(self)

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

function EmptyView:openFolder()
   local nfd = require("nfd")
   local folderPath = nfd.openFolder()

   --WARN: Error handling should be added here
   if not folderPath or not type(folderPath) == "string" then
      ---@diagnostic disable-next-line
      log.logger.default.log( "Can't get folder!", log.level.ERROR)
      self:onFolderPicked(false)
      return
   end

   self:onFolderPicked(true)

   self.interactor:requestMedia(folderPath)
end

function EmptyView:update(dt)
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

function EmptyView:toString()
   return "EmptyView"
end

---@private
---@param isSuccess boolean
function EmptyView:onFolderPicked(isSuccess)
   if self.folderPickerDelegate then
      self.folderPickerDelegate.onFolderPicked(isSuccess)
   end
end


return EmptyView()
