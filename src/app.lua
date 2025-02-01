require("src.loveext")
require("src.utils.class")
require("src.configfile")
local debugView = require("src.ui.debugview")
local PlayerState = require("src.domain.player.playerstate")
local playerModule = require("src.domain.player")
---@type MusicPlayer
local audioPlayer

if Config.backend == "love" then
   audioPlayer = require("src.domain.player.loveaudioplayer")
elseif Config.backend == "miniaudio" then
   audioPlayer = require("src.domain.player.miniaudioplayer")
else
   assert(false, "Unsupported backend: " .. Config.backend)
end

---@type PlayerInteractor
PlayerInteractor = playerModule.interactor {
   initialState = PlayerState.PAUSED,
   player = audioPlayer(),
}

---@type Navigator
local navigator = require("src.ui.navigator")()

function love.load()
   love.graphics.setDefaultFilter("nearest", "nearest")
end

---@param x number
---@param y number
---@param mouse number: The button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
---@param isTouch boolean: True if the mouse button press originated from a touchscreen touch-press
function love.mousepressed(x, y, mouse, isTouch)
   navigator:mousepressed(x, y, mouse, isTouch)
end

---@param x number
---@param y number
function love.wheelmoved(x, y)
   navigator:wheelmoved(x, y)
end

function love.update(dt)
   navigator:update(dt)

   PlayerInteractor:update()

   love.quitIfNeeded()
end

function love.draw()
   navigator:draw()

   debugView.fpsView.draw(
      Config.debug.isDrawFPS,
      0,
      love.graphics.getHeight() - 20,
      1,
      1,
      1,
      1
   )
end
