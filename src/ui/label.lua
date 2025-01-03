local View = require("src.ui.view")

---@class Label : View
---@field title string
---@field textColor Color
---@field font love.Font
---@field private fontPath string
local Label = View()

---@param title string
function Label:init(title)
   View.init(self)

   self.title = title
   self.fontPath = Config.res.fonts.regular
   self.font = love.graphics.newFont(self.fontPath)
end

function Label:draw()
   View.draw(self)

   love.graphics.push()
   love.graphics.setColor(
      self.textColor.red,
      self.textColor.green,
      self.textColor.blue,
      self.textColor.alpha
   )
   love.graphics.setFont(self.font)
   love.graphics.print(self.title, self.origin.x, self.origin.y)
   love.graphics.pop()
end

function Label:toString()
   return "Label"
end

---@protected
function Label:debugInfo()
   local info = View.debugInfo(self)

   return info .. string.format("text=%s; fontPath=%s", self.title, self.fontPath)
end

return Label
