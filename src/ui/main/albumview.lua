local View = require("src.ui.view")
local Image = require("src.ui.image")
local VStack = require("src.ui.vstack")
local Label = require("src.ui.label")
local List = require("src.ui.list")
local songRow = require("src.ui.main.songrow")
local colors = require("src.ui.colors")
local sectionsModule = require("src.ui.listsection")
local tableutils = require("cluautils.table_utils")

---@class AlbumView : View, ListDataSourceDelegate
---@field private isResizing boolean
---@field private minWidth number
---@field private songs Song[]
---@field private album Album?
---@field private headerView View
---@field private resizingView View
---@field private albumImage Image
---@field private titlesStack VStack
---@field private albumNameLabel Label
---@field private artistNameLabel Label
---@field private songsList List
local AlbumView = View()

---@class AlbumViewOpts : ViewOpts
---@field minWidth number?
---@field songs Song[]?
---@field album Album?
---@param opts AlbumViewOpts?
function AlbumView:init(opts)
   View.init(self, opts)
end

function AlbumView:update(dt)
   View.update(self, dt)

   local x, y = love.mouse.getX(), love.mouse.getY()

   if self.resizingView:isPointInside(x, y) then
      self.isResizing = true
      love.mouse.setCursor(love.mouse.getSystemCursor("sizewe"))
   elseif not self.isResizing then
      love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
   end

   if love.mouse.isDown(1) and self.isResizing then
      local ps = self.parentSize

      if ps then
         local newW = ps.width - x

         if
            newW >= self.albumImage.size.width
            and newW >= self.titlesStack.size.width
            and newW <= self.minWidth
         then
            self.origin.x = x
            self.size.width = newW
         end
      end
   else
      self.isResizing = false
   end

   self.resizingView.origin = self.origin
   self.resizingView.size.height = self.size.height

   self.headerView.origin.x = self.origin.x + self.resizingView.size.width
   self.headerView.origin.y = self.origin.y
   self.headerView.size.width = self.size.width

   local w = self.albumImage.size.width
   self.albumImage.origin.x = self.headerView.origin.x
      + self.headerView.size.width / 2
      - w / 2
   self.albumImage.origin.y = self.headerView.origin.y + 10

   self.titlesStack.origin.x = self.headerView.origin.x
      + self.headerView.size.width / 2
      - self.titlesStack.size.width / 2
   self.titlesStack.origin.y = self.albumImage.origin.y
      + self.albumImage.size.height
      + 10

   self.headerView.size.height = self.titlesStack.origin.y
      + self.titlesStack.size.height
      - 10

   self.songsList.size.width = self.size.width
   self.songsList.size.height = self.size.height
      - self.titlesStack.origin.y
      + self.titlesStack.size.height
      - 10
   self.songsList.origin.y = self.headerView.origin.y
      + self.headerView.size.height
   self.songsList.origin.x = self.origin.x + self.resizingView.size.width
end

---@param opts AlbumViewOpts
function AlbumView:updateOpts(opts)
   View.updateOpts(self, opts)

   self.songs = opts.songs or self.songs or {}
   table.sort(self.songs, function(lhs, rhs)
      return lhs.tracknumber < rhs.tracknumber
   end)
   if not self.isResizing then
      self.isResizing = false
   end
   self.album = opts.album or self.album
   self.minWidth = opts.minWidth
      or self.minWidth
      or love.graphics.getWidth() / 2

   local imageData = nil
   local albumName = nil

   if self.album then
      imageData = self.album.imageData
   end

   if self.album then
      albumName = self.album.name
   end

   self:updateListOpts {
      dataSourceDelegate = self,
      backgroundColor = colors.background,
   }
   self:updateAlbumNameLabelOpts {
      title = albumName,
      fontPath = Config.res.fonts.bold,
      fontSize = Config.res.fonts.size.header1,
      textColor = colors.white,
      backgroundColor = colors.clear,
   }
   self:updateHeaderViewOpts {
      backgroundColor = colors.background,
   }
   self:updateImageOpts {
      imageData = imageData,
      width = 200,
      height = 200,
   }
   self:updateArtistNameLabelOpts {
      title = albumName,
      fontPath = Config.res.fonts.regular,
      fontSize = Config.res.fonts.size.header3,
      textColor = colors.white,
      backgroundColor = colors.clear,
   }
   self:updateTitlesStackOpts {
      backgroundColor = colors.clear,
      views = {
         self.albumNameLabel,
         self.artistNameLabel,
      },
   }
   self:updateResizingViewOpts {
      backgroundColor = colors.secondary,
      isUserInteractionEnabled = true,
      width = 5,
   }
end

---@param index integer
---@return Section
function AlbumView:onSectionCreate(index)
   return sectionsModule.section {
      backgroundColor = colors.clear,
      header = Label {
         title = string.format("%i Disk", index),
         fontPath = Config.res.fonts.regular,
         fontSize = Config.res.fonts.size.header2,
         textColor = colors.white,
         backgroundColor = colors.clear,
         paddingLeft = 5,
      },
   }
end

---@param index integer
---@return Row
function AlbumView:onRowCreate(index, sectionIndex)
   local discSongs = {}

   for _, song in pairs(self.songs) do
      if song.discnumber == sectionIndex then
         table.insert(discSongs, song)
      end
   end

   return songRow.factoryMethod(discSongs[index])
end

---@param row Row
---@param index integer
function AlbumView:onRowSetup(row, index, sectionIndex)
   local discSongs = {}

   for _, song in pairs(self.songs) do
      if song.discnumber == sectionIndex then
         table.insert(discSongs, song)
      end
   end

   local song = discSongs[index]

   row:updateImage {
      imageData = song.imageData,
   }

   row:updateTitle {
      title = song.title,
   }

   row:updateSubtitle {
      title = song.artist.name,
   }
end

---@param sectionIndex integer
---@return integer
function AlbumView:rowsCount(sectionIndex)
   local count = 0

   for _, song in pairs(self.songs) do
      if song.discnumber == sectionIndex then
         count = count + 1
      end
   end

   return count
end

---@return integer
function AlbumView:sectionsCount()
   local maxDisnumber = 1

   for _, song in pairs(self.songs) do
      if song.discnumber and song.discnumber > maxDisnumber then
         maxDisnumber = song.discnumber or maxDisnumber
      end
   end

   return maxDisnumber
end

function AlbumView:toString()
   return "AlbumView"
end

---@private
---@param opts ImageOpts
function AlbumView:updateImageOpts(opts)
   if self.albumImage then
      self.albumImage:updateOpts(opts)
      return
   end

   self.albumImage = Image(opts)
   self.headerView:addSubview(self.albumImage)
end

---@private
---@param opts LabelOpts
function AlbumView:updateAlbumNameLabelOpts(opts)
   if self.albumNameLabel then
      self.albumNameLabel:updateOpts(opts)
      return
   end

   self.albumNameLabel = Label(opts)
end

---@private
---@param opts LabelOpts
function AlbumView:updateArtistNameLabelOpts(opts)
   if self.artistNameLabel then
      self.artistNameLabel:updateOpts(opts)
      return
   end

   self.artistNameLabel = Label(opts)
end

---@private
---@param opts VStackOpts
function AlbumView:updateTitlesStackOpts(opts)
   if self.titlesStack then
      self.titlesStack:updateOpts(opts)
      return
   end

   self.titlesStack = VStack(opts)
   self.headerView:addSubview(self.titlesStack)
end

---@private
---@param opts ViewOpts
function AlbumView:updateHeaderViewOpts(opts)
   if self.headerView then
      self.headerView:updateOpts(opts)
      return
   end

   self.headerView = View(opts)
   self:addSubview(self.headerView)
end

---@private
---@param opts ListOpts
function AlbumView:updateListOpts(opts)
   if self.songsList then
      self.songsList:updateOpts(opts)
      return
   end

   self.songsList = List(opts)
   self:addSubview(self.songsList)
end

---@param opts ViewOpts
function AlbumView:updateResizingViewOpts(opts)
   if self.resizingView then
      self.resizingView:updateOpts(opts)
      return
   end

   self.resizingView = View(opts)
   self:addSubview(self.resizingView)
end

return AlbumView
