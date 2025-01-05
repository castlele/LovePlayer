local View = require("src.ui.view")

---@class ListDataSourceDelegate
---@field onRowCreate fun(self: ListDataSourceDelegate, index: integer): Row
---@field onRowSetup fun(self: ListDataSourceDelegate, row: Row, index: integer)
---@field rowsCount fun(self: ListDataSourceDelegate): integer

---@class List : View
---@field private rows Row[]
---@field private offset number
---@field private maxY number
---@field dataSourceDelegate ListDataSourceDelegate?
local List = View()

---@class ListOpts : ViewOpts
---@field dataSourceDelegate ListDataSourceDelegate?
---@param opts ListOpts
function List:init(opts)
   View.init(self)
   self.rows = {}
   self.offset = 0
   self.maxY = 0

   self:updateOpts(opts or {})
end

-- BUG: this method produces from offset with different window/row sizes
function List:wheelmoved(_, y)
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

function List:update(dt)
   self:updateValueList()

   -- TODO: Is it possible to move this logig into `List:updateValueList()`
   for index, row in ipairs(self.rows) do
      row.origin.y = self.origin.y + (row.size.height * (index - 1)) + self.offset
      local maxY = row.origin.y + row.size.height

      if self.maxY < maxY then
         self.maxY = maxY
      end
   end

   View.update(self, dt)
end

function List:draw()
   View.draw(self)
end

---@param opts ListOpts
function List:updateOpts(opts)
   View.updateOpts(self, opts)

   self.dataSourceDelegate = opts.dataSourceDelegate
end

function List:toString()
   return "List"
end

function List:addSubview(view, index)
   View.addSubview(self, view, index)

   if view:toString() == "Row" then
      table.insert(self.rows, view)
   end
end

---@private
function List:updateValueList()
   local d = self.dataSourceDelegate
   local index = 1

   if not d then
      return
   end

   for i = 1, d:rowsCount() do
      index = i

      if i > #self.rows then
         local row = d:onRowCreate(i)
         self:addSubview(row, i)
      else
         d:onRowSetup(self.rows[i], i)
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

return List
