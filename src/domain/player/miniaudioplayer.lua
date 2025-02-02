---@class MiniaudioPlayer : MusicPlayer
---@field private queue Song[]
local Player = class()

function Player:init()
   self.queue = {}
   self.audio = require("libs.luaminiaudio").init()
end

function Player:play()
   if self:isQueueEmpty() then
      return
   end

   local song = self.queue[1]
   self.audio:play(song.file.path)
end

function Player:pause()
   self.audio:pause()
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
