local AlbumView = require("src.ui.main.albumview")
local SelectionView = require("src.ui.selectionview")
local Button = require("src.ui.button")
local colors = require("src.ui.colors")
local EmptyView = require("src.ui.main.emptylist")
local NavBar = require("src.ui.navbar")
local View = require("src.ui.view")
local PlayerView = require("src.ui.player.playerview")
local List = require("src.ui.list")
local Row = require("src.ui.row")
local songRow = require("src.ui.main.songrow")
local Interactor = require("src.domain.lists")
local storage = require("src.ui.main.media_storage")

---@class MainView : View, FolderPickerDelegate, ListDataSourceDelegate, PlayerViewDelegate
---@field private state ListState
---@field private navBar NavBar
---@field private songsList List
---@field private emptyStateView EmptyView
---@field private albumView AlbumView
---@field private interactor ListsInteractor
---@field private songs Song[]
local MainView = View()

---@enum (value) ListState
local ListState = {
   NO_FOLDER = 0,
   SONGS = 1,
   ALBUMS = 2,
   ARTISTS = 3,
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
   local reloadButton = Button {
      action = function()
         self:updateSongsList()
      end,
      state = {
         normal = {
            backgroundColor = colors.accent,
            cornerRadius = 8,
         },
         highlighted = {
            backgroundColor = colors.black,
         },
      },
      titleState = {
         type = "label",
         normal = {
            title = "Reload",
            textColor = colors.black,
            fontPath = Config.res.fonts.regular,
            fontSize = Config.res.fonts.size.header2,
            paddingTop = 5,
            paddingBottom = 5,
            paddingLeft = 5,
            paddingRight = 5,
            backgroundColor = colors.clear,
         },
         highlighted = {
            title = "Reload",
            textColor = colors.accent,
            fontPath = Config.res.fonts.regular,
            fontSize = Config.res.fonts.size.header2,
            paddingTop = 5,
            paddingBottom = 5,
            paddingLeft = 5,
            paddingRight = 5,
            backgroundColor = colors.clear,
         },
      },
   }
   local playerView = PlayerView {
      interactor = PlayerInteractor,
   }
   playerView.delegate = self

   self.navBar = NavBar {
      leadingView = SelectionView {
         selectedLabelOpts = {
            backgroundColor = colors.accent,
            fontPath = Config.res.fonts.regular,
            textColor = colors.black,
            fontSize = Config.res.fonts.size.header3,
            cornerRadius = 8,
            paddingTop = 5,
            paddingBottom = 5,
            paddingLeft = 5,
            paddingRight = 5,
         },
         deselectedLabelOpts = {
            backgroundColor = colors.white,
            fontPath = Config.res.fonts.regular,
            textColor = colors.black,
            fontSize = Config.res.fonts.size.header3,
            cornerRadius = 8,
            paddingTop = 5,
            paddingBottom = 5,
            paddingLeft = 5,
            paddingRight = 5,
         },
         container = {
            maxHeight = 50,
            alignment = "center",
            spacing = 5,
            backgroundColor = colors.secondary,
         },
         items = {
            "songs",
            "albums",
            "artists",
         },
         selected = 1,
         height = 50,
         backgroundColor = colors.secondary,
         onItemSelected = function(item, index)
            self.songsList:resetScrollState()
            if item == "songs" then
               self.state = ListState.SONGS
            elseif item == "albums" then
               self.state = ListState.ALBUMS
            elseif item == "artists" then
               self.state = ListState.ARTISTS
            end
         end,
      },
      centerView = playerView,
      trailingView = reloadButton,
   }
   self.emptyStateView = EmptyView()
   self.emptyStateView.interactor = self.interactor

   self.albumView = AlbumView {
      interactor = PlayerInteractor,
      backgroundColor = colors.background,
      isHidden = true,
      parentSize = self.size,
   }

   self.emptyStateView.folderPickerDelegate = self
   self:addSubview(self.emptyStateView)
   self:addSubview(self.songsList)
   self:addSubview(self.albumView)
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

   if not self.albumView.isHidden then
      local albumViewWidth = self.albumView.size.width

      if albumViewWidth == 0 then
         self.albumView.size.width = self.size.width / 2
      end

      self.albumView.origin.y = self.navBar.size.height
      self.albumView.origin.x = self.origin.x
         + self.size.width
         - self.albumView.size.width
      self.albumView.size.height = self.size.height - self.navBar.size.height
      self.songsList.size.width = self.size.width - albumViewWidth
   end

   View.update(self, dt)
end

function MainView:rowsCount()
   local count = 0
   if self.state == ListState.SONGS then
      count = #self.interactor:getSongs()
   elseif self.state == ListState.ALBUMS then
      count = #self.interactor:getAlbums()
   elseif self.state == ListState.ARTISTS then
      count = #self.interactor:getArtists()
   end

   return count
end

---@param index integer
---@return Row
function MainView:onRowCreate(index)
   ---@type Row
   local row = nil
   if self.state == ListState.SONGS then
      row = self:createSongsRow(index)
   elseif self.state == ListState.ALBUMS then
      row = self:createAlbumsRow(index)
   elseif self.state == ListState.ARTISTS then
      row = self:createArtistsRow(index)
   end

   assert(row, "Unknown state: " .. self.state)

   return row
end

---@param row Row
---@param index integer
function MainView:onRowSetup(row, index)
   if self.state == ListState.SONGS then
      ---@type Song
      local song = self.interactor:getSongs()[index]

      assert(song, "Update row that shouldn't exist")

      row:updateTitle {
         title = song.title,
      }
      row:updateSubtitle {
         title = song.artist.name,
         isHidden = false,
      }
      row:updateImage {
         imageData = song.imageData,
      }
   elseif self.state == ListState.ALBUMS then
      ---@type Album
      local album = self.interactor:getAlbums()[index]

      assert(album, "Update row that shouldn't exist")

      row:updateTitle {
         title = album.name,
      }
      row:updateSubtitle {
         isHidden = true,
      }
      row:updateImage {
         imageData = album.imageData,
      }
   elseif self.state == ListState.ARTISTS then
      ---@type Artist
      local artist = self.interactor:getArtists()[index]

      assert(artist, "Update row that shouldn't exist")

      row:updateTitle {
         title = artist.name,
      }
      row:updateSubtitle {
         isHidden = true,
      }
      row:updateImage {
         imageData = artist.imageData,
      }
   end
end

function MainView:onItemSelected(index)
   if self.state == ListState.SONGS then
   elseif self.state == ListState.ALBUMS then
      local album = self.interactor:getAlbums()[index]
      local albumSongs = self.interactor:getAlbumSongs(album)
      self.albumView:updateOpts {
         album = album,
         songs = albumSongs,
         isHidden = false,
         parentSize = self.size,
         minWidth = self.size.width - self.size.width / 3,
      }
   elseif self.state == ListState.ARTISTS then
   end
end

function MainView:getQueue()
   return self.interactor:getSongs()
end

function MainView:toString()
   return "MainView"
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

   if
      d.isDebug
      and d.mock.isMocking
      and d.mock.folderPath
      and self.state == ListState.NO_FOLDER
   then
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

---@private
---@param index integer
function MainView:createSongsRow(index)
   local song = self.songs[index]

   return songRow.factoryMethod(song)
end

---@private
---@param index integer
function MainView:createAlbumsRow(index)
   local l = Config.lists
   local s = l.rows.sep
   ---@type ImageOpts?
   local leadingImage = nil
   ---@type Album
   local album = self.interactor:getAlbums()[index]

   leadingImage = {
      imageData = album.imageData,
      width = 40,
      height = 40,
      autoResizing = false,
   }

   if album.imageData.id == "placeholder" then
      leadingImage.backgroundColor = colors.background
   end

   return Row {
      isUserInteractionEnabled = true,
      backgroundColor = colors.background,
      height = l.rows.height,
      contentPaddingLeft = l.rows.padding.l,
      contentPaddingRight = l.rows.padding.r,
      sep = {
         height = s.height,
         paddingLeft = s.padding.l,
         paddingRight = s.padding.r,
         color = colors.secondary,
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
         title = album.name,
         fontPath = Config.res.fonts.bold,
         textColor = colors.white,
         fontSize = Config.res.fonts.size.header2,
      },
   }
end

---@private
---@param index integer
function MainView:createArtistsRow(index)
   local l = Config.lists
   local s = l.rows.sep
   ---@type ImageOpts?
   local leadingImage = nil
   ---@type Artist
   local artist = self.interactor:getArtists()[index]

   local imageData = artist.imageData
   leadingImage = {
      imageData = imageData,
      width = 40,
      height = 40,
      autoResizing = false,
   }

   if imageData.id == "placeholder" then
      leadingImage.backgroundColor = colors.background
   end

   return Row {
      isUserInteractionEnabled = true,
      backgroundColor = colors.background,
      height = l.rows.height,
      contentPaddingLeft = l.rows.padding.l,
      contentPaddingRight = l.rows.padding.r,
      sep = {
         height = s.height,
         paddingLeft = s.padding.l,
         paddingRight = s.padding.r,
         color = colors.secondary,
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
         title = artist.name,
         fontPath = Config.res.fonts.bold,
         textColor = colors.white,
         fontSize = Config.res.fonts.size.header2,
      },
   }
end

return MainView
