local View = require("src.ui.view")

---@class Label : View
---@field title string
---@field textColor Color
---@field font love.Font
local Label = View()

---@param title string
function Label:init(title)
   View.init(self)

   self.title = title
   self.font = love.graphics.newFont(Config.res.fonts.regular)
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

return Label
