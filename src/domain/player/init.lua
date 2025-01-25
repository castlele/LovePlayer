--- Module is responsible for managing track queues and playing songs (managing player lifecycle)
--- Its main goal is to provide an interface for playing music.

---@enum (value) PlayerState
local PlayerState = {
   PAUSED = 0,
   PLAYING = 1,
}

---@class MusicPlayer
---@field play fun(self: MusicPlayer)
---@field pause fun(self: MusicPlayer)
---@field setQueue fun(self: MusicPlayer, queue: Song[])
---@field isQueueEmpty fun(self: MusicPlayer): boolean
---

---@class PlayerInteractor
---@field musicPlayer MusicPlayer
---@field private state PlayerState
local PlayerInteractor = class()

---@class PlayerInteractorOpts
---@field player MusicPlayer?
---@field initialState PlayerState?
---@param opts PlayerInteractorOpts
function PlayerInteractor:init(opts)
   self.musicPlayer = opts.player
   self.state = opts.initialState or PlayerState.PAUSED
   self.queue = {}

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
   self.musicPlayer:play()
   self.state = PlayerState.PLAYING
end

function PlayerInteractor:pause()
   self.musicPlayer:pause()
   self.state = PlayerState.PAUSED
end

---@param queue Song[]
function PlayerInteractor:setQueue(queue)
   if self.musicPlayer then
      self.musicPlayer:setQueue(queue)
   end
end

function PlayerInteractor:isQueueEmpty()
   if self.musicPlayer then
      return self.musicPlayer:isQueueEmpty()
   end

   return false
end

return {
   state = PlayerState,
   interactor = PlayerInteractor,
}
