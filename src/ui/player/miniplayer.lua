local View = require("src.ui.view")
local Image = require("src.ui.image")
local Label = require("src.ui.label")
local VStack = require("src.ui.vstack")
local PlayerControlsView = require("src.ui.player.playercontrolsview")
local colors = require("src.ui.colors")

---@class MiniPlayer : View
---@field private imageView Image
---@field private titlesContainer VStack
---@field private songNameLabel Label
---@field private artistNameLabel Label
---@field private playerControlsView PlayerControlsView
local MiniPlayer = View()

local w = 400
local h = 600

function MiniPlayer:init()
   love.window.setMode(w, h, {
      resizable = false,
      borderless = false,
      centered = true,
   })

   View.init(self, {
      backgroundColor = colors.background,
      width = w,
      height = h,
   })
end

---@param opts ViewOpts
function MiniPlayer:updateOpts(opts)
   View.updateOpts(self, opts)

   self:updateImageOpts {}
   self:updateSongNameLabelOpts {}
   self:updateArtistNameLabelOpts {}
   self:updateTitlesContainerOpts()
   self:updatePlayerControlsViewOpts()
end

function MiniPlayer:toString()
   return "MiniPlayer"
end

---@private
---@param opts ImageOpts
function MiniPlayer:updateImageOpts(opts)
   if self.imageView then
      self.imageView:updateOpts(opts)
      return
   end

   self.imageView = Image(opts)
   self:addSubview(self.imageView)
end

---@private
---@param opts LabelOpts
function MiniPlayer:updateSongNameLabelOpts(opts)
   if self.songNameLabel then
      self.songNameLabel:updateOpts(opts)
      return
   end

   self.songNameLabel = Label(opts)
end

---@private
---@param opts LabelOpts
function MiniPlayer:updateArtistNameLabelOpts(opts)
   if self.artistNameLabel then
      self.artistNameLabel:updateOpts(opts)
      return
   end

   self.artistNameLabel = Label(opts)
end

---@private
function MiniPlayer:updateTitlesContainerOpts()
   if self.titlesContainer then
      return
   end

   self.titlesContainer = VStack {
      views = {
         self.songNameLabel,
         self.artistNameLabel,
      },
   }
   self:addSubview(self.titlesContainer)
end

---@private
function MiniPlayer:updatePlayerControlsViewOpts() end

return MiniPlayer
