local ListRow = require("src.ui.list.list_row_view")
local View = require("src.ui.view")
local log = require("src.domain.logger")

---@class SongsList : View
---@field private rows ListRow[]
---@field private songs Song[]
---@field private offset number
---@field private maxY number
local SongsList = View()

function SongsList:init()
   View.init(self)
   self.songs = {}
   self.rows = {}
   self.offset = 0
   self.maxY = 0
end

function SongsList:wheelmoved(_, y)
   local cursorX, cursorY = love.mouse.getX(), love.mouse.getY()

   if not self:isPointInside(cursorX, cursorY) then
      return
   end

   self.offset = self.offset + Config.lists.scrollingVelocity * y

   if self.offset > 0 then
      self.offset = 0
   end

   local n = self.maxY / self.size.height

   if math.abs(self.offset * n) > self.maxY then
      self.offset = -1 * self.size.height
   end
end

function SongsList:update(dt)
   self:updateSongsList()

   for index, row in pairs(self.rows) do
      row.origin.y = self.origin.y * index + self.offset
      local maxY = row.origin.y + row.size.height

      if self.maxY < maxY then
         self.maxY = maxY
      end
   end

   View.update(self, dt)
end

function SongsList:draw()
   View.draw(self)
end

---@param songs Song[]
function SongsList:addSongs(songs)
   self.songs = songs
end

function SongsList:addSubview(view, index)
   View.addSubview(self, view, index)

   if view:toString() == "ListRow" then
      table.insert(self.rows, view)
   end
end

---@private
function SongsList:updateSongsList()
   local index = 1

   for i = 1, self:rowsLen() do
      index = i

      if i > #self.rows then
         self:addSubview(ListRow(self.songs[i].title), i)
      else
         self.rows[i].title = self.songs[i].title
      end

      self.rows[i].size.width = self.size.width
   end

   if index < #self.rows then
      for i = index, #self.rows do
         table.remove(self.rows, i)
         table.remove(self.subviews, i)
      end
   end
end

---@private
function SongsList:rowsLen()
   return #self.songs
end

return SongsList
