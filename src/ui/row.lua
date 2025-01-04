local View = require("src.ui.view")
local Label = require("src.ui.label")
local colors = require("src.ui.colors")

---@class Row : View
---@field title string
---@field private label Label
---@field private sep View
local Row = View()

---@return View
local function initSeparator()
   local v = View()
   v.toString = function (_) return "RowSeparator" end

   v.size.height = 2
   v.backgroundColor = colors.red

   return v
end

---@param title string?
function Row:init(title)
   View.init(self)
   self.title = title or ""
end

function Row:load()
   View.load(self)

   self.label = Label(self.title)
   self.label.textColor = colors.black
   self.label.backgroundColor = colors.clear
   self.size.height = Config.lists.rows.height
   self.label.size.height = self.size.height

   self.sep = initSeparator()

   self:addSubview(self.label)
   self:addSubview(self.sep)
end

function Row:update(dt)
   self.label.title = self.title
   self.label.size.width = self.size.width
   self.label.origin = self.origin

   self.sep.size.width = self.size.width - Config.lists.rows.sep.padding.x
   self.sep.origin.x = Config.lists.rows.sep.padding.x + self.origin.x
   self.sep.origin.y = self.origin.y + self.size.height - self.sep.size.height

   View.update(self, dt)
end

function Row:toString()
   return "Row"
end

return Row
