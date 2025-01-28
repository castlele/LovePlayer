local nativefs = require("nativefs")

---@class LoveAudioPlayer : MusicPlayer
---@field private currentSource love.Source
local Player = class()

---@param song Song?
function Player:play(song)
   if not song then
      self.currentSource = nil
      love.audio.stop()
      return
   end

   if self.currentSource and not song then
      love.audio.play(self.currentSource)
      return
   elseif self.currentSource and song then
      self:play(nil)
   end

   local fileData = nativefs.newFileData(song.file.path)

   -- TODO: Error handling!
   if fileData then
      self.currentSource = love.audio.newSource(fileData, "static")
      love.audio.play(self.currentSource)
   end
end

function Player:pause()
   love.audio.pause()
end

return Player
