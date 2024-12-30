local colors = require("src.ui.colors")
local geom = require("src.ui.geometry")

---@class Event
---@field name string
---@field predicate fun(): boolean
---@field event fun()


---@class View
---@field isHidden boolean
---@field subviews View[]
---@field origin Point
---@field size Size
---@field backgroundColor Color
local View = class()


---@diagnostic disable-next-line
function View:init()
   self:load()
end

---@param view View
---@param index integer?
function View:addSubview(view, index)
   table.insert(
      self.subviews,
      index or #self.subviews,
      view
   )
end

---@return boolean
function View:isUserInteractionEnabled()
   return false
end

---@param x number
---@param y number
---@return boolean
function View:isPointInside(x, y)
   local minX = self.origin.x
   local maxX = self.origin.x + self.size.width
   local minY = self.origin.y
   local maxY = self.origin.y + self.size.height

   local isInsideWidth = minX <= x and maxX >= x
   local isInsideHeight = minY <= y and maxY >= y

   return isInsideWidth and isInsideHeight
end

---@param x number
---@param y number
---@param mouse number: The button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
---@param isTouch boolean: True if the mouse button press originated from a touchscreen touch-press
---@diagnostic disable-next-line
function View:handleMousePressed(x, y, mouse, isTouch)
end

function View:load()
   self.subviews = {}
   self.isHidden = false
   self.backgroundColor = colors.white
   self.origin = geom.Point(0, 0)
   self.size = geom.Size(0, 0)
end

---@param x number
---@param y number
---@param mouse number: The button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
---@param isTouch boolean: True if the mouse button press originated from a touchscreen touch-press
---@return boolean
function View:mousepressed(x, y, mouse, isTouch)
   print(self:toString())
   if not self:isPointInside(x, y) then
      return false
   end

   if not self:isUserInteractionEnabled() then
      for _, subview in pairs(self.subviews) do
         if subview:mousepressed(x, y, mouse, isTouch) then
            return true
         end
      end
   else
      self:handleMousePressed(x, y, mouse, isTouch)
   end

   return true
end

---@param dt number
function View:update(dt)
   if self.isHidden then
      return
   end

   self:updateSubviews(dt)
end

function View:draw()
   if self.isHidden then
      return
   end

   love.graphics.push()
   love.graphics.setColor(
      self.backgroundColor.red,
      self.backgroundColor.green,
      self.backgroundColor.blue,
      self.backgroundColor.alpha
   )
   love.graphics.rectangle(
      "fill",
      self.origin.x,
      self.origin.y,
      self.size.width,
      self.size.height
   )
   love.graphics.pop()

   self:drawSubviews()
end

function View:toString()
   return "View"
end

---@private
function View:updateSubviews(dt)
   for _, subview in pairs(self.subviews) do
      subview:update(dt)
   end
end

---@private
function View:drawSubviews()
   for _, subview in pairs(self.subviews) do
      subview:draw()
   end
end


return View
