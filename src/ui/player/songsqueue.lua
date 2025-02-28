local View = require("lovekit.ui.view")
local Button = require("lovekit.ui.button")
local List = require("lovekit.ui.list")
local tableutils = require("lovekit.utils.tableutils")
local imageDataModule = require("lovekit.ui.imagedata")
local songRowFactory = require("src.ui.main.songrow").factoryMethod
local colors = require("lovekit.ui.colors")

---@class SongsQueue : View, ListDataSourceDelegate
---@field private interactor PlayerInteractor
---@field private expandButtonShader love.Shader
---@field private isExpanded boolean
---@field private headerView View
---@field private headerShadowView View
---@field private expandButton Button
---@field private queueListView List
local SongsQueue = View()

---@class SongsQueueOpts : ViewOpts
---@field interactor PlayerInteractor
---@field expandAction fun()
---@param opts SongsQueueOpts
function SongsQueue:init(opts)
   self.expandButtonShader = Config.res.shaders.coloring()

   ---@type SongsQueueOpts
   local o = tableutils.concat({
      backgroundColor = colors.background,
   }, opts)

   View.init(self, o)
end

function SongsQueue:update(dt)
   View.update(self, dt)

   self.expandButtonShader:send("tocolor", colors.accent:asVec4())

   self.headerView.size.width = self.size.width
   self.headerView.origin = self.origin

   self.headerShadowView.origin.x = self.headerView.origin.x
   self.headerShadowView.origin.y = self.headerView.origin.y
      + self.headerView.size.height
   self.headerShadowView.size.width = self.headerView.size.width

   self.queueListView.size.width = self.size.width
   self.queueListView.size.height = self.size.height
      - self.headerView.size.height
   self.queueListView.origin.x = self.origin.x
   self.queueListView.origin.y = self.headerView.origin.y
      + self.headerView.size.height

   self.expandButton:centerX(self.headerView)
   self.expandButton.origin.y = self.headerView.origin.y + 5
end

---@param opts SongsQueueOpts
function SongsQueue:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = opts.interactor or self.interactor
   self.isExpanded = false

   self:updateQueueListViewOpts {
      dataSourceDelegate = self,
      backgroundColor = colors.clear,
   }
   self:updateHeaderShadowViewOpts {
      backgroundColor = colors.shadow,
      height = 2,
   }
   self:updateHeaderViewOpts {
      height = Config.lists.rows.height,
      backgroundColor = colors.background,
   }
   self:updateExpandButtonOpts {
      action = opts.expandAction,
      state = {
         normal = {
            backgroundColor = colors.clear,
         },
      },
      titleState = {
         type = "image",
         normal = {
            backgroundColor = colors.clear,
            width = 16 * 2,
            height = 6 * 2,
            shader = self.expandButtonShader,
            imageData = imageDataModule.imageData:new(
               Config.res.images.expandArrowUp,
               imageDataModule.imageDataType.PATH
            ),
         },
      },
   }
end

function SongsQueue:toString()
   return "SongsQueue"
end

---@param index integer
---@param sectionIndex integer
---@return Row
function SongsQueue:onRowCreate(index, sectionIndex)
   local song =
      assert(self.interactor:getSongInQueue(index), "Song shouldn't be nil")

   return songRowFactory(song)
end

---@param row Row
---@param index integer
---@param sectionIndex integer
function SongsQueue:onRowSetup(row, index, sectionIndex)
   local rowMinY = row.origin.y + row.size.height
   local minY = self.headerView.origin.y + self.headerView.size.height

   row.isHidden = rowMinY < minY
end

---@param sectionIndex integer
---@return integer
function SongsQueue:rowsCount(sectionIndex)
   return #self.interactor:getNextSongs()
end

---@private
---@param opts ListOpts
function SongsQueue:updateQueueListViewOpts(opts)
   if self.queueListView then
      self.queueListView:updateOpts(opts)
      return
   end

   self.queueListView = List(opts)
   self:addSubview(self.queueListView)
end

---@private
---@param opts ViewOpts
function SongsQueue:updateHeaderShadowViewOpts(opts)
   if self.headerShadowView then
      self.headerShadowView:updateOpts(opts)
      return
   end

   self.headerShadowView = View(opts)
   self:addSubview(self.headerShadowView)
end

---@private
---@param opts ViewOpts
function SongsQueue:updateHeaderViewOpts(opts)
   if self.headerView then
      self.headerView:updateOpts(opts)
      return
   end

   self.headerView = View(opts)
   self:addSubview(self.headerView)
end

---@private
---@param opts ButtonOpts
function SongsQueue:updateExpandButtonOpts(opts)
   if self.expandButton then
      self.expandButton:updateOpts(opts)
      return
   end

   self.expandButton = Button(opts)
   self.headerView:addSubview(self.expandButton)
end

return SongsQueue
