local miniaudio = require("libs.luaminiaudio")

---@class MiniaudioPlayer : MusicPlayer
---@field private queue Song[]
local Player = class()

function Player:init()
   self.queue = {}
end

function Player:play()
    miniaudio.play()
end

function Player:pause()
   print("paused")
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
