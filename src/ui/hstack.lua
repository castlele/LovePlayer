local View = require("src.ui.view")

---@class HStack : View
---@field spacing number
---@field maxHeight number?
---@field alignment "center" | "top" | "bottom"
local HStack = View()

---@class HStackOpts : ViewOpts
---@field alignment ("center" | "top" | "bottom")?
---@field spacing number?
---@field maxHeight number?
---@field views View[]?
---@param opts HStackOpts
function HStack:init(opts)
   View.init(self, opts)
end

function HStack:update(dt)
   View.update(self, dt)

   local maxH = self.maxHeight or 0
   local width = 0

   for index, subview in ipairs(self.subviews) do
      if maxH < subview.size.height then
         maxH = subview.size.height
      end

      local prevView = self.subviews[index - 1]
      local x = 0

      if prevView then
         x = prevView.size.width + prevView.origin.x + self.spacing
      else
         x = self.origin.x
      end

      subview.origin.x = x
      width = width + subview.size.width
   end

   local spacing = 0

   if #self.subviews > 0 then
      spacing = (#self.subviews - 1) * self.spacing
   end

   width = width + spacing

   self.size.width = width
   self.size.height = maxH

   for _, subview in ipairs(self.subviews) do
      local a = self.alignment

      if a == "top" then
         subview.origin.y = self.origin.y
      elseif self.alignment == "center" then
         subview.origin.y = self.origin.y + self.size.height / 2 - subview.size.height / 2
      else
         subview.origin.y = self.origin.y + self.size.height - subview.size.height
      end
   end
end

---@param opts HStackOpts
function HStack:updateOpts(opts)
   View.updateOpts(self, opts)

   self.spacing = opts.spacing or self.spacing or 0
   self.alignment = opts.alignment or self.alignment or "top"
   self.maxHeight = opts.maxHeight or self.maxHeight

   if opts.views then
      self.subviews = {}

      for _, view in pairs(opts.views) do
         self:addSubview(view)
      end
   end
end

function HStack:toString()
   return "HStack"
end

return HStack
