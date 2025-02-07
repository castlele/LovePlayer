local nativefs = require("nativefs")
local LoopMode = require("src.domain.player.loopmode")

---@class Source
---@field source love.Source
---@field id string

---@class LoveAudioPlayer : MusicPlayer
---@field private currentSource Source?
local Player = class()

function Player:pause()
   love.audio.pause(self.currentSource.source)
end

---@param song Song?
function Player:play(song)
   if not song then
      self.currentSource = nil
      love.audio.stop()
      return
   end

   if self.currentSource and self.currentSource.id == song.file.path then
      love.audio.play(self.currentSource.source)
      return
   else
      love.audio.stop()
   end

   local fileData = nativefs.newFileData(song.file.path)

   -- TODO: Error handling!
   if fileData then
      self.currentSource = {
         source = love.audio.newSource(fileData, "static"),
         id = song.file.path,
      }
      love.audio.play(self.currentSource.source)
   end
end

---@param progress number: number in seconds
function Player:setProgress(progress)
   if not self.currentSource then
      return
   end

   self.currentSource.source:seek(progress, "seconds")
end

---@return number: seconds of played audio
function Player:getProgress()
   if not self.currentSource then
      return 0.0
   end

   return self.currentSource.source:tell("seconds")
end

---@return number: lenght in seconds of the current audio
function Player:getLength()
   if not self.currentSource then
      return 0.0
   end

   return self.currentSource.source:getDuration("seconds")
end

---@return boolean
function Player:isPlaying()
   if not self.currentSource then
      return false
   end

   return self.currentSource.source:isPlaying()
end

---@param loopMode LoopMode
function Player:setLoopMode(loopMode)
   if loopMode == LoopMode.NONE or loopMode == LoopMode.QUEUE then
      if self.currentSource then
         self.currentSource.source:setLooping(false)
      end
   elseif loopMode == LoopMode.SONG then
      if self.currentSource then
         self.currentSource.source:setLooping(true)
      end
   else
      assert(false, "Unknown LoopMode case: " .. loopMode)
   end
end

---@return number
function Player:getVolume()
   return love.audio.getVolume()
end

---@param volume number
function Player:setVolume(volume)
   love.audio.setVolume(volume)
end

return Player
