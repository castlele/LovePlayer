local Button = require("src.ui.button")
local colors = require("src.ui.colors")
local EmptyView = require("src.ui.main.emptylist")
local NavBar = require("src.ui.navbar")
local View = require("src.ui.view")
local List = require("src.ui.list")
local Row = require("src.ui.row")
local Interactor = require("src.domain.lists")
local imageDataModule = require("src.ui.imagedata")
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

   View.init(self, {
      backgroundColor = colors.background,
   })
end

function MainView:load()
   ---@diagnostic disable-next-line
   View.load(self)

   self:setupListView()
   local reloadButton = Button()
   reloadButton:addTapAction(function()
      self:updateSongsList()
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

   self:updateSongsList()
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
   return "MainView"
end

function MainView:rowsCount()
   return #self.songs
end

---@param index integer
---@return Row
function MainView:onRowCreate(index)
   local l = Config.lists
   local s = l.rows.sep
   ---@type ImageOpts?
   local leadingImage = nil

   if self.songs[index].picture then
      local imageData = imageDataModule.imageData:new(
         self.songs[index].picture.data,
         imageDataModule.imageDataType.DATA
      )
      leadingImage = {
         imageData = imageData,
         width = 40,
         height = 40,
         autoResizing = false,
      }
   end

   return Row {
      backgroundColor = colors.background,
      height = l.rows.height,
      contentPaddingLeft = l.rows.padding.l,
      contentPaddingRight = l.rows.padding.r,
      sep = {
         height = s.height,
         paddingLeft = s.padding.l,
         paddingRight = s.padding.r,
         color = colors.green,
      },
      leadingImage = leadingImage,
      titlesStack = {
         backgroundColor = colors.background,
      },
      leadingHStack = {
         backgroundColor = colors.background,
         spacing = 10,
      },
      title = {
         backgroundColor = colors.background,
         title = self.songs[index].title,
         fontPath = Config.res.fonts.bold,
         textColor = colors.white,
         fontSize = Config.res.fonts.size.header2,
      },
      subtitle = {
         backgroundColor = colors.background,
         title = self.songs[index].artist.name,
         fontPath = Config.res.fonts.regular,
         textColor = colors.white,
         fontSize = Config.res.fonts.size.body,
      },
   }
end

---@param row Row
---@param index integer
function MainView:onRowSetup(row, index)
   row:updateTitle {
      title = self.songs[index].title,
   }
   row:updateSubtitle {
      title = self.songs[index].artist.name,
   }
end

---@private
function MainView:setupListView()
   self.songsList = List {
      dataSourceDelegate = self,
      backgroundColor = colors.background,
   }
end

---@private
function MainView:updateSongsList()
   self.interactor:reload()
   self.songs = self.interactor:getSongs()
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
