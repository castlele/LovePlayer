local colors = require("src.ui.colors")
local geom = require("src.ui.geometry")
local log = require("src.domain.logger")
local memory = require("cluautils.memory")

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
---@field cornerRadius number
---@field private userIteractions boolean
---@field private addr string
---@field private debugBorderColor Color
local View = class()

---@class ViewOpts
---@field cornerRadius number?
---@field isUserInteractionEnabled boolean?
---@field backgroundColor Color?
---@field width number?
---@field height number?
---@param opts ViewOpts?
function View:init(opts) ---@diagnostic disable-line
   self.addr = memory.get(self)
   self.origin = geom.Point(0, 0)
   self.isHidden = false
   self.backgroundColor = nil
   self.debugBorderColor =
      colors.color(math.random(), math.random(), math.random(), 1)
   self.subviews = {}
   self:updateOpts(opts or {})

   self:load()
end

function View:load() end

---@return boolean
function View:isUserInteractionEnabled()
   return self.userIteractions
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
function View:handleMousePressed(x, y, mouse, isTouch) end

---@param x number
---@param y number
---@param mouse number: The button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
---@param isTouch boolean: True if the mouse button press originated from a touchscreen touch-press
---@return boolean
function View:mousepressed(x, y, mouse, isTouch)
   log.logger.default.log(
      string.format("Touch: %s", self:debugInfo()),
      log.level.DEBUG
   )

   if not self:isPointInside(x, y) or self.isHidden then
      return false
   end

   if not self:isUserInteractionEnabled() then
      for _, subview in pairs(self.subviews) do
         if subview:mousepressed(x, y, mouse, isTouch) then
            return true
         end
      end

      return false
   else
      self:handleMousePressed(x, y, mouse, isTouch)
   end

   return true
end

---@param x number
---@param y number
---
function View:wheelmoved(x, y)
   for _, subview in pairs(self.subviews) do
      subview:wheelmoved(x, y)
   end
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

   if self.cornerRadius > 0 then
      love.graphics.roundedRectangle(
         "fill",
         self.origin.x,
         self.origin.y,
         self.size.width,
         self.size.height,
         self.cornerRadius
      )
   else
      love.graphics.rectangle(
         "fill",
         self.origin.x,
         self.origin.y,
         self.size.width,
         self.size.height
      )
   end

   if Config.debug.isDebug and Config.debug.isRainbowBorders then
      love.graphics.setColor(
         self.debugBorderColor.red,
         self.debugBorderColor.green,
         self.debugBorderColor.blue,
         self.debugBorderColor.alpha
      )
      love.graphics.rectangle(
         "line",
         self.origin.x,
         self.origin.y,
         self.size.width,
         self.size.height
      )
   end
   love.graphics.pop()

   self:drawSubviews()
end

---@param opts ViewOpts
function View:updateOpts(opts)
   if not self.size or not self.size.width or not self.size.height then
      self.size = geom.Size(opts.width or 0, opts.height or 0)
   else
      self.size.height = opts.height or self.size.height
      self.size.width = opts.width or self.size.width
   end
   self.cornerRadius = opts.cornerRadius or self.cornerRadius or 0
   self.userIteractions = opts.isUserInteractionEnabled
      or self.userIteractions
      or false
   self.backgroundColor = opts.backgroundColor
      or self.backgroundColor
      or colors.white
end

---@param view View
---@param index integer?
function View:addSubview(view, index)
   local i = 1

   if index then
      i = index
   elseif #self.subviews ~= 0 then
      i = #self.subviews + 1
   end

   table.insert(self.subviews, i, view)
end

function View:toString()
   return "View"
end

---@protected
---@return string
function View:debugInfo()
   local o = self.origin
   local s = self.size

   return string.format(
      "(%s:%s); origin: (%i;%i); size: (%i;%i)",
      self:toString(),
      self.addr,
      o.x,
      o.y,
      s.width,
      s.height
   )
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
