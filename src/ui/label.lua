local View = require("src.ui.view")
local colors = require("src.ui.colors")

---@class Label : View
---@field title string
---@field textColor Color
---@field font love.Font?
---@field private fontPath string?
local Label = View()

---@class LabelOpts : ViewOpts
---@field title string?
---@field fontPath string?
---@field fontSize number?
---@param opts LabelOpts
function Label:init(opts)
   View.init(self, opts)
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

   if self.font then
      love.graphics.setFont(self.font)
   end

   love.graphics.print(self.title, self.origin.x, self.origin.y)
   love.graphics.pop()
end

function Label:toString()
   return "Label"
end

---@param opts LabelOpts
function Label:updateOpts(opts)
   View.updateOpts(self, opts)

   self.title = opts.title or ""
   self.fontPath = opts.fontPath

   if self.fontPath then
      local f = love.graphics.newFont(self.fontPath, opts.fontSize)
      self.size.width = f:getWidth(self.title)
      self.size.height = f:getHeight()
      self.font = f
   end
end

---@protected
function Label:debugInfo()
   local info = View.debugInfo(self)

   return info
      .. string.format("text=%s; fontPath=%s", self.title, self.fontPath)
end

return Label
