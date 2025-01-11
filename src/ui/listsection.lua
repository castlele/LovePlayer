local View = require("src.ui.view")
local colors = require("src.ui.colors")

---@class Section : View
---@field rows Row[]
---@field private header View
local Section = View()

---@class ListSectionOpts : ViewOpts
---@field header View
---@param opts ListSectionOpts
function Section:init(opts)
   self.rows = {}

   View.init(self, opts)
end

function Section:update(dt)
   View.update(self, dt)

   self.header.origin = self.origin
   self.header.size.width = self.size.width

   self.size.height = self.header.size.height

   for index, row in ipairs(self.rows) do
      row.origin.x = self.origin.x
      row.origin.y = self.header.origin.y
         + self.header.size.height
         + (row.size.height * (index - 1))

      self.size.height = self.size.height + row.size.height
   end
end

function Section:addSubview(view, index)
   View.addSubview(self, view, index)

   if view:toString() == "Row" then
      table.insert(self.rows, index, view)
   end
end

---@param opts ListSectionOpts
function Section:updateOpts(opts)
   View.updateOpts(self, opts)

   self.header = opts.header or self.header or View()

   local isInSubviews = false
   for _, subview in pairs(self.subviews) do
      if subview.addr == self.header.addr then
         isInSubviews = true
         break
      end
   end

   if not isInSubviews then
      self:addSubview(self.header)
   end
end

---@param opts ViewOpts
function Section:updateHeaderOpts(opts)
   if self.header then
      self.header:updateOpts(opts)
      return
   end
end

function Section:toString()
   return "ListSection"
end

return {
   section = Section,
   createEmpty = function()
      return Section {
         backgroundColor = colors.clear,
      }
   end,
}
