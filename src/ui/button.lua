local Label = require("src.ui.label")
local View = require("src.ui.view")

---@class Button : View
---@field action fun()?
---@field private label Label
---@field private state ViewState
---@field private titleState TitleState
local Button = View()
---@enum (value) ButtonState
local State = {
   NORMAL = 0,
   HIGHLIGHTED = 1,
}

---@class TitleState
---@field normal LabelOpts?
---@field highlighted LabelOpts?

---@class ViewState
---@field normal ViewOpts?
---@field highlighted ViewOpts?

---@class ButtonOpts : ViewOpts
---@field action fun()?
---@field state ViewState
---@field titleState TitleState
---@param opts ButtonOpts?
function Button:init(opts)
   View.init(self, opts)
end

function Button:update(dt)
   View.update(self, dt)

   if self.size.width == 0 then
      self.size.width = self.label.size.width
   end

   if self.size.height == 0 then
      self.size.height = self.label.size.height
   end

   self.label.size = self.size
   self.label.origin = self.origin

   if not love.mouse.isDown(1) then
      self:updateState(State.NORMAL)
   end
end

---@return boolean
function Button:isUserInteractionEnabled()
   return true
end

---@diagnostic disable-next-line
function Button:handleMousePressed(x, y, mouse, isTouch)
   if self.action then
      self.action()
   end

   self:updateState(State.HIGHLIGHTED)
end

---@param callback fun()
function Button:addTapAction(callback)
   self.action = callback
end

---@param opts ButtonOpts
function Button:updateOpts(opts)
   self.state = opts.state or self.state or {}
   View.updateOpts(self, self.state.normal or {})

   self.action = opts.action or self.action or nil
   self.titleState = opts.titleState or self.titleState or {}

   local labelOpts = self.titleState.normal or { isHidden = false }
   self:updateLabelOpts(labelOpts)
end

function Button:toString()
   return "Button"
end

---@private
---@parma state ButtonState
function Button:updateState(state)
   if state == State.NORMAL then
      View.updateOpts(self, self.state.normal or {})
      self:updateLabelOpts(self.titleState.normal or {})
   elseif state == State.HIGHLIGHTED then
      View.updateOpts(self, self.state.highlighted or {})
      self:updateLabelOpts(self.titleState.highlighted or {})
   end
end

---@private
---@param opts LabelOpts
function Button:updateLabelOpts(opts)
   if self.label then
      self.label:updateOpts(opts)
      return
   end

   self.label = Label(opts)
   self:addSubview(self.label)
end

return Button
