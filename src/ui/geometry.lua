---@class Point
---@field x number
---@field y number
local Point = class()

---@param x number
---@param y number
function Point:init(x, y)
   self.x = x
   self.y = y
end

---@class Size
---@field wight number
---@field height number
local Size = class()

---@param w number
---@param h number
function Size:init(w, h)
   self.width = w
   self.height = h
end


return {
   Point = Point,
   Size = Size,
}
