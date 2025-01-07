local Label = require("src.ui.label")
local View = require("src.ui.view")
local HStack = require("src.ui.hstack")
local tableutils = require("cluautils.table_utils")

---@class SelectionView : View
---@field selectedOpts LabelOpts
---@field deselectedOpts LabelOpts
---@field selected integer?
---@field private items string[]
---@field private stack HStack
local Selection = View()

---@class SelectionOpts : ViewOpts
---@field selectedLabelOpts LabelOpts?
---@field deselectedLabelOpts LabelOpts?
---@field container HStackOpts?
---@field items string[]?
---@field selected integer?
---@field onItemSelected fun(item: string, index: integer)?
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
      local opts = self.deselectedOpts

      if selected then
         opts = self.selectedOpts
      end

      subview:updateOpts(opts)
   end

   self.stack.origin = self.origin
   self.size.width = self.stack.size.width
   self.stack.size.height = self.size.height
end

---@param opts SelectionOpts
function Selection:updateOpts(opts)
   View.updateOpts(self, opts)

   self:updateStackOpts(opts.container or {})

   self.selectedOpts = opts.selectedLabelOpts or self.selectedOpts or {}
   self.deselectedOpts = opts.deselectedLabelOpts or self.deselectedOpts or {}
   self.selected = opts.selected or self.selected or nil

   self:createLabels(opts or {})
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
---@param opts SelectionOpts
function Selection:createLabels(opts)
   ---@type Label[]
   local labels = {}

   for index, item in ipairs(opts.items or {}) do
      local selected = index == self.selected
      local labelOpts = self.deselectedOpts

      if selected then
         labelOpts = self.selectedOpts
      end

      local l = tableutils.concat({
         title = item,
         isUserInteractionEnabled = true,
      }, labelOpts)

      local label = Label(l)

      label.handleMousePressed = function(x, y, mouse, isTouch)
         self.selected = index
         if opts.onItemSelected then
            opts.onItemSelected(item, index)
         end
      end

      table.insert(labels, label)
   end

   self:updateStackOpts { views = labels }
end

function Selection:toString()
   return "SelectionView"
end

return Selection
