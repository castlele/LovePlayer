local View = require("src.ui.view")
local Button = require("src.ui.button")
local Image = require("src.ui.image")
local colors = require("src.ui.colors")
local geom = require("src.ui.geometry")

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

   self.backgroundColor = colors.background

   local path = "res/no_folder.png"
   self.noFolderImage = Image()
   self.noFolderImage.backgroundColor = colors.background
   self.noFolderImage:addImage(path)

   self.folderPickerButton = Button()
   self.folderPickerButton.size = geom.Size(100, 50)
   self.folderPickerButton.backgroundColor = colors.blue
   self.folderPickerButton:addTapAction(function () self:openFolder() end)

   self:addSubview(self.noFolderImage)
   self:addSubview(self.folderPickerButton)
end

function EmptyView:openFolder()
   local i = self.interactor
   local path = i:requestFilePicker()

   if not path then
      return
   end

   self:onFolderPicked(true)

   i:requestMedia(path)
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
