local Button = require("src.ui.button")
local colors = require("src.ui.colors")
local EmptyView = require("src.ui.list.emptylist")
local NavBar = require("src.ui.navbar")
local View = require("src.ui.view")
local SongsList = require("src.ui.list.songs_list_view")
local Interactor = require("src.domain.lists")
local storage = require("src.ui.list.media_storage")

---@class List : View, FolderPickerDelegate
---@field private state ListState
---@field private navBar NavBar
---@field private songsList SongsList
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

   self.songsList = SongsList()
   self.state = ListState.NO_FOLDER
   self.backgroundColor = colors.background
   self.interactor =
      Interactor(storage.mediaRepository(storage.mediaDataStore()))
   local reloadButton = Button()
   reloadButton:addTapAction(function()
      self.interactor:reload()
      self.songsList:addSongs(self.interactor:getSongs())
   end)
   reloadButton.backgroundColor = colors.green
   reloadButton.size.width = 50
   reloadButton.size.height = 50

   self.navBar = NavBar(reloadButton)
   self.emptyStateView = EmptyView()
   self.emptyStateView.interactor = self.interactor

   ---@type fun(isSuccess: boolean)
   self.onFolderPicked = function(isSuccess)
      if isSuccess then
         self.songsList:addSongs(self.interactor:getSongs())
         self.state = ListState.SONGS
      end
   end

   self.emptyStateView.folderPickerDelegate = self
   self:addSubview(self.emptyStateView)
   self:addSubview(self.songsList)
   self:addSubview(self.navBar)
end

function List:update(dt)
   self:updateState()

   self.emptyStateView.origin.y = self.navBar.origin.y
   self.emptyStateView.size.width = self.size.width
   self.emptyStateView.size.height = self.size.height - self.navBar.size.height

   self.navBar.size.width = self.size.width
   self.navBar.backgroundColor = colors.secondary

   self.songsList.size.width = self.size.width
   self.songsList.size.height = self.size.height - self.navBar.size.height
   self.songsList.origin.y = self.navBar.size.height

   View.update(self, dt)
end

function List:toString()
   return "List"
end

---@private
function List:updateState()
   local d = Config.debug

   if d.isDebug and d.mock.isMocking and d.mock.folderPath then
      self.state = ListState.SONGS
   end

   if self.state == ListState.NO_FOLDER then
      self.emptyStateView.isHidden = false
      self.songsList.isHidden = true
      self.navBar.isHidden = true
   elseif self.state == ListState.SONGS then
      self.emptyStateView.isHidden = true
      self.songsList.isHidden = false
      self.navBar.isHidden = false
   end
end

return List
