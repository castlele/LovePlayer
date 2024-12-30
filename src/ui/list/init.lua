local Button = require("src.ui.button")
local colors = require("src.ui.colors")
local EmptyView = require("src.ui.list.emptylist")
local NavBar = require("src.ui.navbar")
local View = require("src.ui.view")
local Interactor = require("src.domain.lists")
local storage = require("src.ui.list.media_storage")

---@class List : View, FolderPickerDelegate
---@field private state ListState
---@field private navBar NavBar
---@field private emptyStateView EmptyView
---@field private interactor ListsInteractor
local List = View()

---@enum (value) ListState
local ListState = {
   NO_FOLDER = 0,
   SONGS = 2,
}


function List:load()
   ---@diagnostic disable-next-line
   View.load(self)

   self.state = ListState.NO_FOLDER
   self.backgroundColor = colors.background
   self.interactor = Interactor(
      storage.mediaRepository(storage.mediaDataStore())
   )
   -- TODO: Nav bar should have link to parent to automatically fill width?
   self.navBar = NavBar()
   local reloadButton = Button()
   reloadButton:addTapAction(function ()
      self.interactor:reload()
   end)
   reloadButton.backgroundColor = colors.green
   reloadButton.size.width = 50
   reloadButton.size.height = 50

   self.navBar.trailingView = reloadButton
   self.navBar:addSubview(reloadButton)
   self.emptyStateView = EmptyView()
   self.emptyStateView.interactor = self.interactor

   ---@type fun(isSuccess: boolean)
   self.onFolderPicked = function (isSuccess)
      if isSuccess then
         self.state = ListState.SONGS
      end
   end

   self.emptyStateView.folderPickerDelegate = self
   self:addSubview(self.emptyStateView)
   self:addSubview(self.navBar)
end

function List:update(dt)
   self:updateState()
   self.emptyStateView.size = self.size

   self.navBar.size.width = self.size.width
   self.navBar.backgroundColor = colors.secondary

   View.update(self, dt)
end

function List:toString()
   return "List"
end

---@private
function List:updateState()
   if Config.mock.isMocking and Config.mock.folderPath then
      self.state = ListState.SONGS
   end

   if self.state == ListState.NO_FOLDER then
      self.emptyStateView.isHidden = false
      self.navBar.isHidden = true
   elseif self.state == ListState.SONGS then
      self.emptyStateView.isHidden = true
      self.navBar.isHidden = false
   end
end


return List
