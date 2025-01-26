local nativefs = require("nativefs")

---@class LoveAudioPlayer : MusicPlayer
---@field private queue Song[]
local Player = class()

function Player:init()
   self.queue = {}
end

function Player:play()
   if self:isQueueEmpty() then
      return
   end

   if self.currentSource then
      love.audio.play(self.currentSource)
      return
   end

   local song = self.queue[1]
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

---@param queue Song[]
function Player:setQueue(queue)
   self.queue = queue
end

---@return boolean
function Player:isQueueEmpty()
   return #self.queue == 0
end

return Player
