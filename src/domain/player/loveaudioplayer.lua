local nativefs = require("nativefs")
local LoopMode = require("src.domain.player.loopmode")

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

---@return boolean
function Player:isPlaying()
   if not self.currentSource then
      return false
   end

   return self.currentSource:isPlaying()
end

---@param loopMode LoopMode
function Player:setLoopMode(loopMode)
   if loopMode == LoopMode.NONE or loopMode == LoopMode.QUEUE then
      if self.currentSource then
         self.currentSource:setLooping(false)
      end
   elseif loopMode == LoopMode.SONG then
      if self.currentSource then
         self.currentSource:setLooping(true)
      end
   else
      assert(false, "Unknown LoopMode case: " .. loopMode)
   end
end

function Player:pause()
   love.audio.pause()
end

return Player
