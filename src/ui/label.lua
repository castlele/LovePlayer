local View = require("src.ui.view")
local colors = require("src.ui.colors")

---@class Label : View
---@field title string
---@field textColor Color
---@field font love.Font?
---@field align love.AlignMode
---@field private fontPath string?
---@field private paddingTop number?
---@field private paddingBottom number?
---@field private paddingLeft number?
---@field private paddingRight number?
local Label = View()

---@class LabelOpts : ViewOpts
---@field title string?
---@field textColor Color?
---@field fontPath string?
---@field fontSize number?
---@field align love.AlignMode?
---@field paddingTop number?
---@field paddingBottom number?
---@field paddingLeft number?
---@field paddingRight number?
---@param opts LabelOpts
function Label:init(opts)
   View.init(self, opts)
end

function Label:update(dt)
   View.update(self, dt)

   self.size.width = 0
   self.size.height = 0

   if self.font then
      self.size.width = self.font:getWidth(self.title)
      self.size.height = self.font:getHeight()
   end

   self.size.width = self.size.width + self.paddingLeft + self.paddingRight
   self.size.height = self.size.height + self.paddingTop + self.paddingBottom
   self.origin.x = self.origin.x + self.paddingLeft + self.paddingRight
end

function Label:draw()
   View.draw(self)

   love.graphics.setShader(self.shader)
   love.graphics.push()

   love.graphics.setColor(
      self.textColor.red,
      self.textColor.green,
      self.textColor.blue,
      self.textColor.alpha
   )

   if self.font then
      love.graphics.setFont(self.font)
   end

   love.graphics.printf(
      self.title,
      -- this doesn't work in update(dt) method
      self.origin.x + self.paddingLeft,
      self.origin.y + self.paddingTop,
      self.size.width,
      self.align
   )
   love.graphics.pop()
   love.graphics.setShader()
end

---@param opts LabelOpts
function Label:updateOpts(opts)
   View.updateOpts(self, opts)

   self.title = opts.title or self.title or ""
   self.fontPath = opts.fontPath or self.fontPath or nil
   self.textColor = opts.textColor or self.textColor or colors.black
   self.align = opts.align or self.align or "left"
   self.paddingTop = opts.paddingTop or self.paddingTop or 0
   self.paddingBottom = opts.paddingBottom or self.paddingBottom or 0
   self.paddingLeft = opts.paddingLeft or self.paddingLeft or 0
   self.paddingRight = opts.paddingRight or self.paddingRight or 0

   if self.fontPath and not self.font then
      local f = love.graphics.newFont(self.fontPath, opts.fontSize)
      self.font = f
   end
end

---@protected
function Label:debugInfo()
   local info = View.debugInfo(self)

   return info
      .. string.format("text=%s; fontPath=%s", self.title, self.fontPath)
end

function Label:toString()
   return "Label"
end

return Label
