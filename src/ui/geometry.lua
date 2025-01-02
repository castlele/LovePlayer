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

---@return string
function Point:toString()
   return string.format("Point: (%i; %i)", self.x, self.y)
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

---@return string
function Size:toString()
   return string.format("Size (width: %i; height: %i)", self.width, self.height)
end

return {
   Point = Point,
   Size = Size,
}
