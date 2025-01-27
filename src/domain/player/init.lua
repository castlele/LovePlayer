--- Module is responsible for managing track queues and playing songs (managing player lifecycle)
--- Its main goal is to provide an interface for playing music.

---@enum (value) PlayerState
local PlayerState = {
   PAUSED = 0,
   PLAYING = 1,
}

---@enum (value) LoopMode
local LoopMode = {
   NONE = 0,
   SONG = 1,
   QUEUE = 2,
}

---@class MusicPlayer
---@field play fun(self: MusicPlayer, song: Song?)
---@field pause fun(self: MusicPlayer)

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

   self.musicPlayer:play(self.queue[self.currentQueueIndex])
   self.state = PlayerState.PLAYING
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
   loopMode = LoopMode,
   interactor = PlayerInteractor,
}
