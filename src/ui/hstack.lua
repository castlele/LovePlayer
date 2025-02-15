local View = require("src.ui.view")

---@class HStack : View
---@field spacing number|"max"
---@field maxHeight number?
---@field alignment "center" | "top" | "bottom"
local HStack = View()

---@class HStackOpts : ViewOpts
---@field alignment ("center" | "top" | "bottom")?
---@field spacing number|"max"?
---@field maxHeight number?
---@field views View[]?
---@param opts HStackOpts
function HStack:init(opts)
   View.init(self, opts)
end

function HStack:update(dt)
   View.update(self, dt)

   local spacing = self:getSpacing()

   local maxH = self.maxHeight or 0
   local width = 0

   for index, subview in ipairs(self.subviews) do
      if maxH < subview.size.height then
         maxH = subview.size.height
      end

      local prevView = self.subviews[index - 1]
      local x = 0

      if prevView then
         x = prevView.size.width + prevView.origin.x + spacing
      else
         x = self.origin.x
      end

      subview.origin.x = x
      width = width + subview.size.width
   end

   if self.spacing ~= "max" then
      local offset = 0

      if #self.subviews > 0 then
         offset = (#self.subviews - 1) * spacing
      end

      width = width + offset

      self.size.width = width
   end

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

---@private
function HStack:getSpacing()
   if self.spacing ~= "max" then
      return self.spacing
   end

   if #self.subviews <= 1 then
      return 0
   end

   local viewsW = 0

   for _, subview in pairs(self.subviews) do
      viewsW = viewsW + subview.size.width
   end

   local allSpacing = self.size.width - viewsW

   if allSpacing + viewsW > self.size.width then
      return 0
   end

   return allSpacing / #self.subviews - 1
end

return HStack
