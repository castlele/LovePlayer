local View = require("src.ui.view")
local Label = require("src.ui.label")
local Image = require("src.ui.image")
local colors = require("src.ui.colors")

---@class Row : View
---@field leadingImage Image
---@field private label Label
---@field private sep Separator
---@field private contentPaddingLeft number?
---@field private contentPaddingRight number?
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
---@field contentPaddingLeft number?
---@field contentPaddingRight number?
---@field height number?
---@field sep SeparatorOpts?
---@field leadingImage ImageOpts?
---@field title LabelOpts?
---@param opts RowOpts?
function Row:init(opts)
   local o = opts or {}
   self:updateImage(o.leadingImage or {})
   self:updateLabel(o.title or {})
   self:updateSeparator(o.sep or {})

   View.init(self, opts)
end

function Row:load()
   View.load(self)

   self.label.textColor = colors.black

   self:addSubview(self.leadingImage)
   self:addSubview(self.label)
   self:addSubview(self.sep)
end

function Row:update(dt)
   View.update(self, dt)

   self.leadingImage.origin = self.origin

   self.label.size.width = self.size.width
      - self.contentPaddingLeft
      - self.contentPaddingRight
   self.label.origin.x = self.origin.x + self.contentPaddingLeft

   self.sep.origin.x = self.sep.paddingLeft + self.origin.x
   self.sep.size.width = self.size.width
      - self.sep.paddingLeft
      - self.sep.paddingRight
   self.sep.origin.y = self.origin.y + self.size.height - self.sep.size.height

   self.label.origin.y = self.origin.y
      + self.size.height / 2
      - self.label.size.height / 2
end

function Row:toString()
   return "Row"
end

---@param opts RowOpts
function Row:updateOpts(opts)
   View.updateOpts(self, opts)
   self:updateImage(opts.leadingImage or {})
   self:updateLabel(opts.title or {})
   self:updateSeparator(opts.sep or {})

   self.size.height = opts.height or 0
   self.contentPaddingLeft = opts.contentPaddingLeft or 0
   self.contentPaddingRight = opts.contentPaddingRight or 0
end

---@param opts LabelOpts
function Row:updateLabel(opts)
   if self.label then
      self.label:updateOpts(opts)
      return
   end

   self.label = Label(opts)
end

---@param opts ImageOpts
function Row:updateImage(opts)
   if self.leadingImage then
      self.leadingImage:updateOpts(opts)
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

return Row
