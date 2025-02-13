local View = require("src.ui.view")
local sectionModule = require("src.ui.listsection")

---@class ListDataSourceDelegate
---@field onRowCreate fun(self: ListDataSourceDelegate, index: integer, sectionIndex: integer): Row
---@field onRowSetup fun(self: ListDataSourceDelegate, row: Row, index: integer, sectionIndex: integer)
---@field rowsCount fun(self: ListDataSourceDelegate, sectionIndex: integer): integer
---@field onSectionCreate (fun(self: ListDataSourceDelegate, index: integer): Section)?
---@field onSectionSetup (fun(self: ListDataSourceDelegate, section: Section, index: integer))?
---@field sectionsCount (fun(self: ListDataSourceDelegate): integer)?
---@field onItemSelected fun(self: ListDataSourceDelegate, index: integer, sectionIndex: integer)?

---@class List : View
---@field dataSourceDelegate ListDataSourceDelegate?
---@field private offset number
---@field private maxY number
---@field private sections Section[]
local List = View()

---@class ListOpts : ViewOpts
---@field dataSourceDelegate ListDataSourceDelegate?
---@param opts ListOpts
function List:init(opts)
   self.sections = {}
   self.offset = 0
   self.maxY = 0

   View.init(self, opts)
end

function List:wheelmoved(_, y)
   local cursorX, cursorY = love.mouse.getX(), love.mouse.getY()

   if not self:isPointInside(cursorX, cursorY) then
      return
   end

   local offset = self.offset + Config.lists.scrollingVelocity * y

   if offset >= 0 or self.maxY / self.size.height <= 1 then
      self.offset = 0
      return
   end

   if math.abs(offset + self.origin.y) < self.maxY - self.size.height then
      self.offset = offset
   end
end

function List:update(dt)
   View.update(self, dt)

   self:updateValueList()

   -- TODO: Is it possible to move this logic into `List:updateValueList()`
   for index, section in ipairs(self.sections) do
      section.origin.x = self.origin.x
      if index == 1 then
         section.origin.y = self.origin.y + self.offset
      else
         section.origin.y = self.sections[index - 1].origin.y + self.sections[index - 1].size.height
      end

      self.maxY = section.origin.y + section.size.height - self.offset
   end
end

function List:resetScrollState()
   self.offset = 0
end

---@param opts ListOpts
function List:updateOpts(opts)
   View.updateOpts(self, opts)

   self.dataSourceDelegate = opts.dataSourceDelegate
end

function List:addSubview(view, index)
   View.addSubview(self, view, index)

   local section = sectionModule.section.toString(sectionModule.section)

   if view:toString() == section then
      table.insert(self.sections, index, view)
   end
end

function List:toString()
   return "List"
end

---@private
function List:updateValueList()
   local d = self.dataSourceDelegate

   if not d then
      return
   end

   local sectionCreate = d.onSectionCreate or sectionModule.createEmpty

   for sectionIndex = 1, self:getSectionsCount() do
      if not self.sections[sectionIndex] then
         local section = sectionCreate(d, sectionIndex)

         self:addSubview(section, sectionIndex)
      end

      self.sections[sectionIndex].size.width = self.size.width

      self:updateRowsForSection(d, sectionIndex)

      if d.onSectionSetup then
         d:onSectionSetup(self.sections[sectionIndex], sectionIndex)
      end
   end
end

---@private
---@param d ListDataSourceDelegate
---@param sectionIndex integer
function List:updateRowsForSection(d, sectionIndex)
   local index = 1
   local section = self.sections[sectionIndex]

   for i = 1, d:rowsCount(sectionIndex) do
      index = i

      if i > #section.rows then
         local row = d:onRowCreate(i, sectionIndex)
         section:addSubview(row, i)
      else
         if d.onSectionSetup then
            d:onSectionSetup(section, sectionIndex)
         end

         d:onRowSetup(section.rows[i], i, sectionIndex)
      end

      section.rows[i].onRowTapped = function()
         if not d.onItemSelected then
            return
         end

         self.dataSourceDelegate:onItemSelected(i, sectionIndex)
      end

      section.rows[i].size.width = self.size.width
   end

   if index < #self.sections[sectionIndex].rows then
      table.remove(self.sections, sectionIndex)
      table.remove(self.subviews, sectionIndex)
   end
end

---@private
function List:getSectionsCount()
   local sectionsCount = 1

   if self.dataSourceDelegate and self.dataSourceDelegate.sectionsCount then
      sectionsCount = self.dataSourceDelegate:sectionsCount()
   end

   assert(sectionsCount >= 1, "Number of sections should be at leas one")

   return sectionsCount
end

return List
