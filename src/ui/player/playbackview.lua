local View = require("src.ui.view")
local tableutils = require("src.utils.tableutils")
local colors = require("src.ui.colors")

---@class PlaybackView : View
---@field private interactor PlayerInteractor
---@field private timelineView View
local PlaybackView = View()

---@class PlaybackViewOpts : ViewOpts
---@field interactor PlayerInteractor
---@param opts PlaybackViewOpts
function PlaybackView:init(opts)
   local o = tableutils.concat({
      backgroundColor = colors.clear,
      height = 40,
   }, opts)

   View.init(self, o)
end

---@param opts PlaybackViewOpts
function PlaybackView:updateOpts(opts)
   View.updateOpts(self, opts)

   self.interactor = opts.interactor

   self:updateTimelineViewOpts {
      height = 20,
      shader = nil,
   }
end

---@param opts ViewOpts
function PlaybackView:updateTimelineViewOpts(opts)
   if self.timelineView then
      self.timelineView:updateOpts(opts)
      return
   end

   self.timelineView = View(opts)
   self:addSubview(self.timelineView)
end

return PlaybackView
