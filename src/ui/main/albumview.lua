local View = require("src.ui.view")
local Image = require("src.ui.image")
local VStack = require("src.ui.vstack")
local Label = require("src.ui.label")
local List = require("src.ui.list")
local songRow = require("src.ui.main.songrow")
local colors = require("src.ui.colors")

---@class AlbumView : View, ListDataSourceDelegate
---@field private songs Song[]
---@field private album Album?
---@field private headerView View
---@field private albumImage Image
---@field private titlesStack VStack
---@field private albumNameLabel Label
---@field private artistNameLabel Label
---@field private songsList List
local AlbumView = View()

---@class AlbumViewOpts : ViewOpts
---@field songs Song[]?
---@field album Album?
---@param opts AlbumViewOpts?
function AlbumView:init(opts)
   View.init(self, opts)
end

function AlbumView:update(dt)
   View.update(self, dt)

   self.headerView.origin = self.origin
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
   self.songsList.origin.x = self.origin.x
end

local function bubbleSort(arr, comp)
    local n = #arr
    while true do
        local swapped = false
        for i = 1, n-1 do
            if comp(arr[i], arr[i+1]) then
                arr[i], arr[i+1] = arr[i+1], arr[i]
                swapped = true
            end
        end
        if not swapped then
            break
        end
    end
    return arr
end

---@param opts AlbumViewOpts
function AlbumView:updateOpts(opts)
   View.updateOpts(self, opts)

   self.songs = opts.songs or self.songs or {}
   bubbleSort(self.songs, function (lhs, rhs)
      return lhs.tracknumber > rhs.tracknumber
   end)
   self.album = opts.album or self.album

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
end

---@param index integer
---@return Row
function AlbumView:onRowCreate(index)
   return songRow.factoryMethod(self.songs[index])
end

---@param row Row
---@param index integer
function AlbumView:onRowSetup(row, index) end

---@return integer
function AlbumView:rowsCount()
   return #self.songs
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

return AlbumView
