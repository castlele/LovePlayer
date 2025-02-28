--- Module is responsible for managing track queues and playing songs (managing player lifecycle)
--- Its main goal is to provide an interface for playing music.

local LoopMode = require("src.domain.player.loopmode")
local PlayerState = require("src.domain.player.playerstate")
local tableutils = require("lovekit.utils.tableutils")

---@class MusicPlayer
---@field play fun(self: MusicPlayer, song: Song?)
---@field pause fun(self: MusicPlayer)
---@field isPlaying fun(self: MusicPlayer): boolean
---@field setLoopMode fun(self: MusicPlayer, loopMode: LoopMode)
---@field getProgress fun(self: MusicPlayer): number
---@field setProgress fun(self: MusicPlayer, progress: number)
---@field getLength fun(self: MusicPlayer): number
---@field getVolume fun(self: MusicPlayer): number
---@field setVolume fun(self: MusicPlayer, volume: number)

---@class PlayerInteractor
---@field musicPlayer MusicPlayer
---@field private pastVolume number
---@field private loopMode LoopMode
---@field private queue Song[]
---@field private shuffledQueue Song[]
---@field private currentQueueIndex integer
---@field private state PlayerState
---@field private isShuffling boolean
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
   self.isShuffling = false
   self.shuffledQueue = {}

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
   local song

   if self.isShuffling then
      song = self.shuffledQueue[self.currentQueueIndex]
   else
      song = self.queue[self.currentQueueIndex]
   end

   self.musicPlayer:play(song)
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

   if not self:canPlayPrev() then
      self:stop()
      return
   end

   self:decreaseCurrentIndex()
   self:play()
end

function PlayerInteractor:next()
   if self:isQueueEmpty() then
      return
   end

   if not self:canPlayNext() then
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

   if self.isShuffling then
      return self.shuffledQueue[self.currentQueueIndex]
   else
      return self.queue[self.currentQueueIndex]
   end
end

---@param index integer
function PlayerInteractor:setCurrentIndex(index)
   assert(index >= 1, string.format("Index is less than 1. Got: %i", index))

   ---@type integer
   local queueLen

   if self:isShufflingEnabled() then
      queueLen = #self.shuffledQueue
   else
      queueLen = #self.queue
   end

   assert(
      index <= queueLen,
      string.format(
         "Index is grater than queue's len. Got: %i, while len is: %i",
         index,
         queueLen
      )
   )

   self.currentQueueIndex = index
end

function PlayerInteractor:isQueueEmpty()
   return #self.queue == 0
end

function PlayerInteractor:update()
   self.musicPlayer:setLoopMode(self.loopMode)

   if self.musicPlayer:isPlaying() or self.state == PlayerState.PAUSED then
      return
   end

   if self.loopMode == LoopMode.QUEUE then
      self:next()
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

---@return string: return time as stirng in format MM:SS
function PlayerInteractor:getFormattedDuration()
   local sec = self.musicPlayer:getLength()

   return self:formatTime(sec)
end

---@return string: return time as stirng in format MM:SS
function PlayerInteractor:getCurrentFormattedProgress()
   local sec = self.musicPlayer:getProgress()

   return self:formatTime(sec)
end

---@param progress number: progress of the playback from 0.0 to 1.0
function PlayerInteractor:setProgress(progress)
   local len = self.musicPlayer:getLength()

   self.musicPlayer:setProgress(progress * len)
end

---@return number: progress of the playback from 0.0 to 1.0
function PlayerInteractor:getProgress()
   local sec = self.musicPlayer:getProgress()
   local len = self.musicPlayer:getLength()

   return sec / len
end

---@return LoopMode
function PlayerInteractor:getLoopMode()
   return self.loopMode
end

---@return number: volume level from 0.0 to 1.0
function PlayerInteractor:getVolume()
   return self.musicPlayer:getVolume()
end

---@param volume number: volume level from 0.0 to 1.0
function PlayerInteractor:setVolume(volume)
   self.musicPlayer:setVolume(volume)
end

function PlayerInteractor:toggleMute()
   if self:getVolume() > 0 then
      self.pastVolume = self:getVolume()
      self:setVolume(0)
   else
      self:setVolume(self.pastVolume or 1.0)
   end
end

---@return boolean
function PlayerInteractor:isShufflingEnabled()
   return self.isShuffling
end

function PlayerInteractor:toggleShuffle()
   self.isShuffling = not self.isShuffling

   if self.isShuffling then
      local startIndex = 1

      if self:getCurrent() then
         startIndex = self:getNextIndex()
      end

      self.shuffledQueue = tableutils.shuffle(self.queue, startIndex)
   else
      self.shuffledQueue = {}
   end
end

---@return Song[]
function PlayerInteractor:getNextSongs()
   if self.isShuffling then
      return { unpack(self.shuffledQueue, self.currentQueueIndex) }
   else
      return { unpack(self.queue, self.currentQueueIndex) }
   end
end

---@param index integer
---@return Song?
function PlayerInteractor:getSongInQueue(index)
   local queue

   if self.isShuffling then
      queue = self.shuffledQueue
   else
      queue = self.queue
   end

   if index < 1 or index > #queue then
      return nil
   end

   return queue[index]
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
function PlayerInteractor:canPlayPrev()
   local index = self.currentQueueIndex - 1

   return index >= 1 or self.loopMode == LoopMode.QUEUE
end

---@private
function PlayerInteractor:canPlayNext()
   local index = self:getNextIndex()
   return index <= #self.queue or self.loopMode == LoopMode.QUEUE
end

---@private
---@return integer
function PlayerInteractor:getNextIndex()
   return self.currentQueueIndex + 1
end

---@private
---@param sec number
---@return string
function PlayerInteractor:formatTime(sec)
   local days = math.floor(sec / 86400)
   local remaining = sec % 86400
   local hours = math.floor(remaining / 3600)
   remaining = remaining % 3600
   local minutes = math.floor(remaining / 60)
   remaining = remaining % 60
   local seconds = remaining

   local time = string.format("%02d:%02d", minutes, seconds)

   if hours ~= 0 then
      time = string.format("%02d:%s", hours, time)
   end

   if days ~= 0 then
      time = string.format("%d:%s", days, time)
   end

   return time
end

return {
   state = PlayerState,
   interactor = PlayerInteractor,
}
