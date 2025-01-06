local Label = require("src.ui.label")
local View = require("src.ui.view")
local HStack = require("src.ui.hstack")
local colors = require("src.ui.colors")

---@class SelectionView : View
---@field selectedColor Color
---@field deselectedColor Color
---@field selected integer?
---@field private items string[]
---@field private stack HStack
local Selection = View()

---@class SelectionOpts : ViewOpts
---@field container HStackOpts?
---@field selectedColor Color?
---@field deselectedColor Color?
---@field items string[]?
---@field selected integer?
---@param opts SelectionOpts?
function Selection:init(opts)
   View.init(self, opts)
end

function Selection:load()
   self:addSubview(self.stack)
end

function Selection:update(dt)
   View.update(self, dt)
   for index, subview in ipairs(self.stack.subviews) do
      local selected = index == self.selected
      local backgroundColor = self.deselectedColor

      if selected then
         backgroundColor = self.selectedColor
      end

      subview:updateOpts {
         backgroundColor = backgroundColor
      }
   end

   self.stack.origin = self.origin
   self.size.width = self.stack.size.width
   self.size.height = self.stack.size.height
end

---@param opts SelectionOpts
function Selection:updateOpts(opts)
   View.updateOpts(self, opts)

   self:updateStackOpts(opts.container or {})

   self.selectedColor = opts.selectedColor or self.selectedColor or colors.blue
   self.deselectedColor = opts.deselectedColor
      or self.deselectedColor
      or colors.white
   self.selected = opts.selected or self.selected or nil

   self:createLabels(opts.items)
end

---@param opts HStackOpts
function Selection:updateStackOpts(opts)
   if self.stack then
      self.stack:updateOpts(opts)
      return
   end

   self.stack = HStack(opts)
end

---@private
---@param items string[]?
function Selection:createLabels(items)
   if not items then
      return
   end

   ---@type Label[]
   local labels = {}

   for index, item in ipairs(items) do
      local selected = index == self.selected
      local backgroundColor = self.deselectedColor

      if selected then
         backgroundColor = self.selectedColor
      end

      local label = Label {
         title = item,
         backgroundColor = backgroundColor,
         fontPath = Config.res.fonts.regular,
         isUserInteractionEnabled = true,
      }

      label.handleMousePressed = function(x, y, mouse, isTouch)
         self.selected = index
      end

      table.insert(labels, label)
   end

   self:updateStackOpts { views = labels }
end

function Selection:toString()
   return "SelectionView"
end

return Selection
