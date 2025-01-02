local Label = require("src.ui.label")
local View = require("src.ui.view")
local colors = require("src.ui.colors")

---@class ListRow : View
---@field title string
---@field private label Label
local ListRow = View()

---@param title string
function ListRow:init(title)
   View.init(self)
   self.title = title
end

function ListRow:load()
   View.load(self)

   self.label = Label(self.title)
   self.label.textColor = colors.black
   self.size.height = Config.lists.rows.height
   self.label.size.height = self.size.height

   self:addSubview(self.label)
end

function ListRow:update(dt)
   self.label.title = self.title
   self.label.size.width = self.size.width
   self.label.origin = self.origin
   View.update(self, dt)
end

function ListRow:toString()
   return "ListRow"
end

return ListRow
