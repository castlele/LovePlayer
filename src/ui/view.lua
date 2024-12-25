local Color = require("src.ui.color")
local geom = require("src.ui.geometry")

---@class Event
---@field name string
---@field predicate fun(): boolean
---@field event fun()


---@class View
---@field subviews View[]
---@field origin Point
---@field size Size
---@field backgroundColor Color
---@field private events Event[]
local View = class()


---@diagnostic disable-next-line
function View:init()
   self:load()
end

function View:startFlow(flow)
   self.currentFlow = flow
   self.isFlowChanged = true
end

---@param view View
function View:addSubview(view)
   table.insert(self.subviews, view)
end

function View:subcribe(name, predicate, event)
   table.insert(self.events, {
      name = name,
      predicate = predicate,
      event = event,
   })
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

function View:load()
   self.subviews = {}
   self.backgroundColor = Color(1, 1, 1, 1)
   self.origin = geom.Point(0, 0)
   self.size = geom.Size(0, 0)
   self.events = {}
end

---@param dt number
function View:update(dt)
   for _, event in pairs(self.events) do
      if event.predicate() then
         event.event()
      end
   end

   self:updateSubviews(dt)
end

function View:draw()
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
