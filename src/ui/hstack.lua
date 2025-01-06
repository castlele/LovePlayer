local View = require("src.ui.view")

---@class HStack : View
---@field spacing number
local HStack = View()

---@class HStackOpts : ViewOpts
---@field spacing number?
---@field views View[]?
---@param opts HStackOpts
function HStack:init(opts)
   View.init(self, opts)
end

function HStack:update(dt)
   View.update(self, dt)

   local maxH = 0
   local width = 0

   for index, subview in ipairs(self.subviews) do
      if maxH < subview.size.height then
         maxH = subview.size.height
      end

      subview.origin.y = self.origin.y
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
end

---@param opts HStackOpts
function HStack:updateOpts(opts)
   View.updateOpts(self, opts)

   self.spacing = opts.spacing or self.spacing or 0

   if opts.views then
      for _, view in pairs(opts.views) do
         self:addSubview(view)
      end
   end
end

function HStack:toString()
   return "HStack"
end

return HStack
