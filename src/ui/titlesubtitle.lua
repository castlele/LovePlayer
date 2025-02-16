local VStack = require("src.ui.vstack")
local Label = require("src.ui.label")
local tableutils = require("src.utils.tableutils")

---@class TitleSubtitle : VStack
---@field private titlesGetter (fun(): string?, string?)?
---@field private title Label
---@field private subtitle Label
local TitleSubtitle = VStack()

---@class TitleSubtitleOpts : VStackOpts
---@field update (fun(): string?, string?)?
---@field titleOpts LabelOpts?
---@field subtitleOpts LabelOpts?
---@param opts TitleSubtitleOpts
function TitleSubtitle:init(opts)
   VStack.init(self, opts)
end

function TitleSubtitle:update(dt)
   VStack.update(self, dt)

   local getter = self.titlesGetter

   if getter then
      local t, s = getter()

      self:updateTitleOpts {
         title = t,
      }
      self:updateSubtitleOpts {
         title = s,
      }
   end

   self.title.size.width = self.size.width
   self.subtitle.size.width = self.size.width
end

---@param opts TitleSubtitleOpts
function TitleSubtitle:updateOpts(opts)
   VStack.updateOpts(self, opts)

   self.titlesGetter = opts.update or self.titlesGetter

   self:updateTitleOpts(tableutils.concat({
      autoResizing = false,
   }, opts.titleOpts))
   self:updateSubtitleOpts(tableutils.concat({
      autoResizing = false,
   }, opts.subtitleOpts))
end

---@private
---@param opts LabelOpts
function TitleSubtitle:updateTitleOpts(opts)
   if self.title then
      self.title:updateOpts(opts)
      return
   end

   self.title = Label(opts)
   self:addSubview(self.title)
end

---@private
---@param opts LabelOpts
function TitleSubtitle:updateSubtitleOpts(opts)
   if self.subtitle then
      self.subtitle:updateOpts(opts)
      return
   end

   self.subtitle = Label(opts)
   self:addSubview(self.subtitle)
end

return TitleSubtitle
