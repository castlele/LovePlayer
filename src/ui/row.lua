local View = require("src.ui.view")
local Label = require("src.ui.label")
local Image = require("src.ui.image")
local colors = require("src.ui.colors")
local VStack = require("src.ui.vstack")
local HStack = require("src.ui.hstack")

---@class Row : View
---@field private shouldHighlight boolean
---@field private leadingImage Image
---@field private leadingHStack HStack
---@field private titlesVStack VStack
---@field private titleLabel Label
---@field private subtitleLabel Label
---@field private sep Separator
---@field private contentPaddingLeft number?
---@field private contentPaddingRight number?
---@field private isTapped boolean
---@field private animState number
---@field onRowTapped fun()?
local Row = View()

---@class Separator : View
---@field updateOpts fun(self: Separator,o: SeparatorOpts)
---@field paddingLeft number
---@field paddingRight number

---@class SeparatorOpts
---@field isHidden boolean?
---@field height number?
---@field paddingLeft number?
---@field paddingRight number?
---@field color Color?
---@param opts SeparatorOpts
---@return Separator
local function initSeparator(opts)
   ---@type Separator
   local v = View()
   v.toString = function(_)
      return "RowSeparator"
   end

   v.updateOpts = function(self, o)
      self.isHidden = o.isHidden or false
      v.paddingLeft = o.paddingLeft or 0
      v.paddingRight = o.paddingRight or 0
      v.size.height = o.height or 2
      v.backgroundColor = o.color or colors.secondary
   end

   v:updateOpts(opts)

   return v
end

---@class RowOpts : ViewOpts
---@field shouldHighlight boolean?
---@field onItemSelected fun(index: integer)?
---@field contentPaddingLeft number?
---@field contentPaddingRight number?
---@field height number?
---@field sep SeparatorOpts?
---@field leadingImage ImageOpts?
---@field leadingHStack HStackOpts?
---@field titlesStack VStackOpts?
---@field title LabelOpts?
---@field subtitle LabelOpts?
---@param opts RowOpts?
function Row:init(opts)
   self.shader = Config.res.shaders.highlighting()

   View.init(self, opts)

   self.tapped = false
   self.animState = 0
end

function Row:load()
   View.load(self)

   self:addSubview(self.leadingImage)
   self:addSubview(self.leadingHStack)
   self:addSubview(self.sep)
end

function Row:update(dt)
   View.update(self, dt)

   self.leadingHStack.origin.x = self.origin.x + self.contentPaddingLeft

   self.sep.origin.x = self.sep.paddingLeft + self.origin.x
   self.sep.size.width = self.size.width
      - self.sep.paddingLeft
      - self.sep.paddingRight
   self.sep.origin.y = self.origin.y + self.size.height - self.sep.size.height

   self.leadingHStack.origin.y = self.origin.y
      + self.size.height / 2
      - self.leadingHStack.size.height / 2

   self:handleHighlighting(dt)
end

function Row:handleMousePressed(x, y, mouse, isTouch)
   self.tapped = true

   if self.onRowTapped then
      self.onRowTapped()
   end
end

---@param opts RowOpts
function Row:updateOpts(opts)
   View.updateOpts(self, opts)

   self:updateLeadingStack(
      opts.leadingHStack or {},
      opts.titlesStack or {},
      opts.leadingImage or {},
      opts.title or {},
      opts.subtitle or {}
   )
   self:updateSeparator(opts.sep or {})

   if opts.shouldHighlight ~= nil then
      self.shouldHighlight = opts.shouldHighlight
   elseif self.shouldHighlight ~= nil then
      self.shouldHighlight = self.shouldHighlight
   else
      self.shouldHighlight = true
   end
   self.onItemSelected = opts.onItemSelected or self.onItemSelected or nil
   self.size.height = opts.height or 0
   self.contentPaddingLeft = opts.contentPaddingLeft or self.contentPaddingLeft or 0
   self.contentPaddingRight = opts.contentPaddingRight or self.contentPaddingRight or 0
end

---@param opts HStackOpts
---@param stack VStackOpts
---@param title LabelOpts
---@param subtitle LabelOpts
function Row:updateLeadingStack(opts, stack, image, title, subtitle)
   opts.shader = self.shader
   image.shader = self.shader
   stack.shader = self.shader
   title.shader = self.shader
   subtitle.shader = self.shader

   self:updateTitlesStack(stack, title, subtitle)
   self:updateImage(image)

   if self.leadingHStack then
      self.leadingHStack:updateOpts(opts)
      return
   end

   if not opts.views then
      opts.views = {}
   end

   table.insert(opts.views, self.leadingImage)
   table.insert(opts.views, self.titlesVStack)

   self.leadingHStack = HStack(opts)
end

---@param opts VStackOpts
---@param title LabelOpts
---@param subtitle LabelOpts
function Row:updateTitlesStack(opts, title, subtitle)
   self:updateTitle(title)
   self:updateSubtitle(subtitle)

   if self.titlesVStack then
      self.titlesVStack:updateOpts(opts)
      return
   end

   if not opts.views then
      opts.views = {}
   end

   table.insert(opts.views, self.titleLabel)
   table.insert(opts.views, self.subtitleLabel)

   self.titlesVStack = VStack(opts)
end

---@param opts LabelOpts
function Row:updateTitle(opts)
   if self.titleLabel then
      self.titleLabel:updateOpts(opts)
      return
   end

   self.titleLabel = Label(opts)
end
---
---@param opts LabelOpts
function Row:updateSubtitle(opts)
   if self.subtitleLabel then
      self.subtitleLabel:updateOpts(opts)
      return
   end

   self.subtitleLabel = Label(opts)
end

---@param opts ImageOpts
function Row:updateImage(opts)
   if self.leadingImage then
      self.leadingImage:updateOpts(opts)
      return
   end

   self.leadingImage = Image(opts)
end

---@param opts SeparatorOpts
function Row:updateSeparator(opts)
   if self.sep then
      self.sep:updateOpts(opts)
      return
   end

   self.sep = initSeparator(opts)
end

function Row:toString()
   return "Row"
end

---@private
---@param dt number
function Row:handleHighlighting(dt)
   if self.tapped and love.mouse.isDown(1) then
      self.animState = 1
   elseif self.animState > 0 then
      self.tapped = false
      self.animState = self.animState - dt
   end

   self.shader:send("progress", self.animState)
end

return Row
