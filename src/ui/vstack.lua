local View = require("src.ui.view")

---@class VStack : View
---@field spacing number
local VStack = View()

---@class VStackOpts : ViewOpts
---@field spacing number?
---@field views View[]?
---@param opts VStackOpts
function VStack:init(opts)
   View.init(self, opts)
end

function VStack:update(dt)
   View.update(self, dt)

   local maxW = 0
   local height = 0

   for index, subview in ipairs(self.subviews) do
      if maxW < subview.size.width then
         maxW = subview.size.width
      end

      subview.origin.x = self.origin.x
      local prevView = self.subviews[index - 1]
      local y = 0

      if prevView then
         y = prevView.size.height + prevView.origin.y + self.spacing
      else
         y = self.origin.y
      end

      subview.origin.y = y
      height = height + subview.size.height
   end

   local spacing = 0

   if #self.subviews > 0 then
      spacing = (#self.subviews - 1) * self.spacing
   end

   height = height + spacing

   self.size.height = height
   self.size.width = maxW
end

---@param opts VStackOpts
function VStack:updateOpts(opts)
   View.updateOpts(self, opts)

   self.spacing = opts.spacing or self.spacing or 0

   if opts.views then
      self.subviews = {}

      for _, view in ipairs(opts.views) do
         self:addSubview(view)
      end
   end
end

function VStack:toString()
   return "VStack"
end

return VStack
