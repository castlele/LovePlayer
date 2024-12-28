local Button = require("src.ui.button")
local Color = require("src.ui.color")
local EmptyView = require("src.ui.list.emptylist")
local NavBar = require("src.ui.navbar")
local View = require("src.ui.view")
local Interactor = require("src.domain.lists")
local storage = require("src.ui.list.media_storage")

---@class List : View, FolderPickerDelegate
---@field private navBar NavBar
---@field private emptyStateView EmptyView
---@field private interactor ListsInteractor
local List = View()


function List:load()
   ---@diagnostic disable-next-line
   View.load(self)

   self.interactor =Interactor(
      storage.mediaRepository(storage.mediaDataStore())
   )
   -- TODO: Nav bar should have link to parent to automatically fill width?
   self.navBar = NavBar()
   local reloadButton = Button()
   -- TODO: Move to constants
   reloadButton:addTapAction(function ()
      self.interactor:reload()
   end)
   reloadButton.backgroundColor = Color(0, 1, 0, 1)
   reloadButton.size.width = 50
   reloadButton.size.height = 50

   self.navBar.trailingView = reloadButton
   self.navBar:addSubview(reloadButton)
   self.emptyStateView = EmptyView()
   self.emptyStateView.interactor = self.interactor

   ---@type fun(isSuccess: boolean)
   self.onFolderPicked = function (isSuccess)
      self.emptyStateView.isHidden = isSuccess
      self.navBar.isHidden = not isSuccess
   end

   self.emptyStateView.folderPickerDelegate = self
   self:addSubview(self.emptyStateView)
   self:addSubview(self.navBar)
end

function List:update(dt)
   self.emptyStateView.size = self.size

   self.navBar.size.width = self.size.width
   self.navBar.size.height = 50
   -- TODO: Move to constants
   self.navBar.backgroundColor = Color(233/255, 233/255, 233/255, 1)


   View.update(self, dt)
end

function List:toString()
   return "List"
end


return List
