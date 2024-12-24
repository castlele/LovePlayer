---@class Color
---@field red number: 0..1
---@field green number: 0..1
---@field blue number: 0..1
---@field alpha number: 0..1
local Color = class()


---@param r number
---@param g number
---@param b number
---@param a number
function Color:init(r, g, b, a)
   self.red = r
   self.green = g
   self.blue = b
   self.alpha = a
end


return Color
