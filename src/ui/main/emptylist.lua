local View = require("lovekit.ui.view")
local Label = require("lovekit.ui.label")
local Image = require("lovekit.ui.image")
local colors = require("lovekit.ui.colors")
local imageDataModule = require("lovekit.ui.imagedata")

---@class FolderPickerDelegate
---@field onFolderPicked fun(isSuccess: boolean)

---@class EmptyView : View
---@field folderPickerDelegate FolderPickerDelegate?
---@field interactor ListsInteractor
---@field private noFolderImage Image
---@field private noFolderLabel Label
local EmptyView = View()

function EmptyView:load()
   View.load(self)

   self.backgroundColor = colors.background

   self.noFolderImage = Image {
      isUserInteractionEnabled = true,
      autoResizing = true,
      backgroundColor = colors.background,
      imageData = imageDataModule.imageData:new(
         Config.res.images.noFolder,
         imageDataModule.imageDataType.PATH
      ),
   }
   self.noFolderLabel = Label {
      title = "No music folder selected! To start using the app, tap on the image above :)",
      textColor = colors.white,
      fontPath = Config.res.fonts.bold,
      fontSize = Config.res.fonts.size.header1,
      backgroundColor = colors.clear,
      align = "center",
   }

   self.noFolderImage.handleMousePressed = function(...)
      self:openFolder()
   end

   self:addSubview(self.noFolderImage)
   self:addSubview(self.noFolderLabel)
end

function EmptyView:openFolder()
   local i = self.interactor
   local path = i:requestFilePicker()

   if not path then
      return
   end

   i:requestMedia(path)

   self:onFolderPicked(true)
end

function EmptyView:update(dt)
   View.update(self, dt)

   local noFolderImageX = self.size.width / 2
      - self.noFolderImage.size.width / 2
   local noFolderImageY = self.size.height / 2
      - self.noFolderImage.size.height / 2
   self.noFolderImage.origin.x = noFolderImageX
   self.noFolderImage.origin.y = noFolderImageY

   self.noFolderLabel.size.width = self.size.width
   self.noFolderLabel:centerX(self)
   self.noFolderLabel.origin.y = noFolderImageY
      + self.noFolderImage.size.height
      + 20
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
