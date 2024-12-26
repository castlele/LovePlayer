local View = require("src.ui.view")

---@class Button : View
---@field action fun()?
local Button = View()


function Button:load()
   View.load(self)

   self.action = nil
end

---@return boolean
function Button:isUserInteractionEnabled()
   return true
end

---@diagnostic disable-next-line
function Button:handleMousePressed(x, y, mouse, isTouch)
   if self.action then
      self.action()
   end
end

---@param callback fun()
function Button:addTapAction(callback)
   self.action = callback
end

function Button:toString()
   return "Button"
end


return Button
