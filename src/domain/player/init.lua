--- Module is responsible for managing track queues and playing songs (managing player lifecycle)
--- Its main goal is to provide an interface for playing music.

-- local miniaudio = package.loadlib(
--    "./src/miniaudio/luaminiaudio.so",
--    "_luaopen_luaminiaudio"
-- )()


---@enum (value) PlayerState
local PlayerState = {
   PAUSED = 0,
   PLAYING = 1,
}

---@class MusicPlayer
---@field play fun(self: MusicPlayer)
---@field pause fun(self: MusicPlayer)

---@class PlayerInteractor
---@field MusicPlayer MusicPlayer
---@field private state PlayerState
local PlayerInteractor = class()

---@class PlayerInteractorOpts
---@field player MusicPlayer?
---@field initialState PlayerState?
---@param opts PlayerInteractorOpts
function PlayerInteractor:init(opts)
   self.musicPlayer = opts.player
   self.state = opts.initialState or PlayerState.PAUSED

   if self.state == PlayerState.PLAYING then
      self:play()
   end
end

---@return PlayerState
function PlayerInteractor:getState()
   return self.state
end

function PlayerInteractor:play()
   self.musicPlayer:play()
   self.state = PlayerState.PLAYING
end

function PlayerInteractor:pause()
   self.musicPlayer:pause()
   self.state = PlayerState.PAUSED
end

return {
   state = PlayerState,
   interactor = PlayerInteractor,
}
