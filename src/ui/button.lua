local Label = require("src.ui.label")
local Image = require("src.ui.image")
local View = require("src.ui.view")

---@class Button : View
---@field action fun()?
---@field private label Label?
---@field private image Image?
---@field private state ViewState
---@field private titleState TitleState
local Button = View()
---@enum (value) ButtonState
local State = {
   NORMAL = 0,
   HIGHLIGHTED = 1,
}

---@param state ButtonState
local function getStateName(state)
   if state == State.NORMAL then
      return "normal"
   elseif state == State.HIGHLIGHTED then
      return "highlighted"
   end

   assert(false, "Unknown state")
end

---@class TitleState
---@field type "label"|"image"?
---@field normal (LabelOpts|ImageOpts)?
---@field highlighted (LabelOpts|ImageOpts)?

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

   if self.size.width == 0 and self.label then
      self.size.width = self.label.size.width
   end

   if self.size.height == 0 and self.image then
      self.size.height = self.image.size.height
   end

   if self.size.width == 0 and self.label then
      self.size.width = self.label.size.width
   end

   if self.size.height == 0 and self.image then
      self.size.height = self.image.size.height
   end

   if self.label then
      self.label.size = self.size
      self.label.origin = self.origin
   end

   if self.image then
      self.image.size = self.size
      self.image.origin = self.origin
   end

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

   self:updateTitleOpts(self.titleState, State.NORMAL)
end

function Button:toString()
   return "Button"
end

---@private
---@param state ButtonState
function Button:updateState(state)
   if state == State.NORMAL then
      View.updateOpts(self, self.state.normal or {})
   elseif state == State.HIGHLIGHTED then
      View.updateOpts(self, self.state.highlighted or {})
   end

   self:updateTitleOpts(self.titleState, state)
end

---@private
---@param opts TitleState
---@param state ButtonState
function Button:updateTitleOpts(opts, state)
   if opts.type == "label" then
      ---@type LabelOpts
      ---@diagnostic disable-next-line
      local labelOpts = self.titleState[getStateName(state)]
         or { isHidden = false }
      self:updateLabelOpts(labelOpts)
   elseif opts.type == "image" then
      ---@type ImageOpts
      ---@diagnostic disable-next-line
      local imageOpts = self.titleState[getStateName(state)]
         or { isHidden = false }
      self:updateImageOpts(imageOpts)
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

---@private
---@param opts ImageOpts
function Button:updateImageOpts(opts)
   if self.image then
      self.image:updateOpts(opts)
      return
   end

   self.image = Image(opts)
   self:addSubview(self.image)
end

return Button
