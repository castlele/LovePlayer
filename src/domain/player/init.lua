--- Module is responsible for managing track queues and playing songs (managing player lifecycle)
--- Its main goal is to provide an interface for playing music.

local LoopMode = require("src.domain.player.loopmode")
local PlayerState = require("src.domain.player.playerstate")

---@class MusicPlayer
---@field play fun(self: MusicPlayer, song: Song?)
---@field pause fun(self: MusicPlayer)
---@field isPlaying fun(self: MusicPlayer): boolean
---@field setLoopMode fun(self: MusicPlayer, loopMode: LoopMode)

---@class PlayerInteractor
---@field musicPlayer MusicPlayer
---@field private loopMode LoopMode
---@field private queue Song[]
---@field private currentQueueIndex integer
---@field private state PlayerState
local PlayerInteractor = class()

---@class PlayerInteractorOpts
---@field player MusicPlayer?
---@field initialState PlayerState?
---@field loopMode LoopMode?
---@field currentQueueIndex integer?
---@field queue Song[]?
---@param opts PlayerInteractorOpts
function PlayerInteractor:init(opts)
   self.musicPlayer = opts.player
   self.state = opts.initialState or PlayerState.PAUSED
   self.loopMode = opts.loopMode or LoopMode.NONE
   self.queue = opts.queue or {}
   self.currentQueueIndex = opts.currentQueueIndex or -1

   if self.state == PlayerState.PLAYING then
      self:play()
   end
end

---@return PlayerState
function PlayerInteractor:getState()
   return self.state
end

function PlayerInteractor:toggle()
   if self.state == PlayerState.PAUSED then
      self:play()
   else
      self:pause()
   end
end

function PlayerInteractor:play()
   if self:isQueueEmpty() then
      return
   end

   if self.currentQueueIndex == -1 then
      self.currentQueueIndex = 1
   end

   self.state = PlayerState.PLAYING
   self.musicPlayer:play(self.queue[self.currentQueueIndex])
end

function PlayerInteractor:pause()
   self.musicPlayer:pause()
   self.state = PlayerState.PAUSED
end

function PlayerInteractor:stop()
   self.currentQueueIndex = -1
   self.state = PlayerState.PAUSED
   self.musicPlayer:play(nil)
end

function PlayerInteractor:prev()
   if self:isQueueEmpty() then
      return
   end

   self:decreaseCurrentIndex()
   self:play()
end

function PlayerInteractor:next()
   if self:isQueueEmpty() then
      return
   end

   if not self:canPlayNext(self.currentQueueIndex + 1) then
      self:stop()
      return
   end

   self:increaseCurrentIndex()
   self:play()
end

---@param queue Song[]
function PlayerInteractor:setQueue(queue)
   self.currentQueueIndex = -1
   self.queue = queue
end

---@return Song?
function PlayerInteractor:getCurrent()
   if self.currentQueueIndex == -1 then
      return nil
   end

   return self.queue[self.currentQueueIndex]
end

function PlayerInteractor:isQueueEmpty()
   return #self.queue == 0
end

function PlayerInteractor:update()
   self.musicPlayer:setLoopMode(self.loopMode)

   if self.musicPlayer:isPlaying() then
      return
   end

   if self.loopMode == LoopMode.QUEUE then
      self:next()
      self:play()
   else
      self:stop()
   end
end

---@return LoopMode
function PlayerInteractor:nextLoopMode()
   local m = self.loopMode

   if m == LoopMode.NONE then
      self.loopMode = LoopMode.QUEUE
   elseif m == LoopMode.QUEUE then
      self.loopMode = LoopMode.SONG
   elseif m == LoopMode.SONG then
      self.loopMode = LoopMode.NONE
   else
      assert(false, "Unknown LoopMode case: " .. m)
   end

   return self:getLoopMode()
end

---@return LoopMode
function PlayerInteractor:getLoopMode()
   return self.loopMode
end

---@private
function PlayerInteractor:decreaseCurrentIndex()
   if self.currentQueueIndex - 1 <= 0 then
      self.currentQueueIndex = #self.queue
   else
      self.currentQueueIndex = self.currentQueueIndex - 1
   end
end

---@private
function PlayerInteractor:increaseCurrentIndex()
   if self.currentQueueIndex + 1 > #self.queue then
      self.currentQueueIndex = 1
   else
      self.currentQueueIndex = self.currentQueueIndex + 1
   end
end

---@private
---@param index integer
function PlayerInteractor:canPlayNext(index)
   return index <= #self.queue or self.loopMode == LoopMode.QUEUE
end

return {
   state = PlayerState,
   interactor = PlayerInteractor,
}
