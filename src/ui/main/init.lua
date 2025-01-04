local Button = require("src.ui.button")
local colors = require("src.ui.colors")
local EmptyView = require("src.ui.main.emptylist")
local NavBar = require("src.ui.navbar")
local View = require("src.ui.view")
local List = require("src.ui.list")
local Row = require("src.ui.row")
local Interactor = require("src.domain.lists")
local storage = require("src.ui.main.media_storage")

---@class MainView : View, FolderPickerDelegate, ListDataSourceDelegate
---@field private state ListState
---@field private navBar NavBar
---@field private songsList List
---@field private emptyStateView EmptyView
---@field private interactor ListsInteractor
---@field private songs Song[]
local MainView = View()

---@enum (value) ListState
local ListState = {
   NO_FOLDER = 0,
   SONGS = 2,
}

function MainView:init()
   View.init(self)

   self.songs = {}
   self.state = ListState.NO_FOLDER
   self.interactor =
      Interactor(storage.mediaRepository(storage.mediaDataStore()))
   ---@type fun(isSuccess: boolean)
   self.onFolderPicked = function(isSuccess)
      if isSuccess then
         self.songs = self.interactor:getSongs()
         self.state = ListState.SONGS
      end
   end
end

function MainView:load()
   ---@diagnostic disable-next-line
   View.load(self)

   self:setupListView()
   self.backgroundColor = colors.background
   local reloadButton = Button()
   reloadButton:addTapAction(function()
      self.interactor:reload()
      self.songs = self.interactor:getSongs()
   end)
   reloadButton.backgroundColor = colors.green
   reloadButton.size.width = 50
   reloadButton.size.height = 50

   self.navBar = NavBar(reloadButton)
   self.emptyStateView = EmptyView()
   self.emptyStateView.interactor = self.interactor

   self.emptyStateView.folderPickerDelegate = self
   self:addSubview(self.emptyStateView)
   self:addSubview(self.songsList)
   self:addSubview(self.navBar)
end

function MainView:update(dt)
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

function MainView:toString()
   return "Main"
end

function MainView:rowsCount()
   return #self.songs
end

---@return Row
function MainView:onRowCreate()
   return Row()
end

---@param row Row
---@param index integer
function MainView:onRowSetup(row, index)
   row.title = self.songs[index].title
end

---@private
function MainView:setupListView()
   self.songsList = List {
      dataSourceDelegate = self,
   }
end

---@private
function MainView:updateState()
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

return MainView
