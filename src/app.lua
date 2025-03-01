require("src.loveext")
require("lovekit.utils.class")
require("src.configfile")

local debugView
local PlayerState
local playerModule
---@type MusicPlayer
local audioPlayer

---@type PlayerInteractor
PlayerInteractor = nil

---@type Navigator
local navigator

function love.load()
   debugView = require("lovekit.ui.debugview")
   PlayerState = require("src.domain.player.playerstate")
   playerModule = require("src.domain.player")

   if Config.backend == "love" then
      audioPlayer = require("src.domain.player.loveaudioplayer")
   elseif Config.backend == "miniaudio" then
      audioPlayer = require("src.domain.player.miniaudioplayer")
   else
      assert(false, "Unsupported backend: " .. Config.backend)
   end

   PlayerInteractor = playerModule.interactor {
      initialState = PlayerState.PAUSED,
      player = audioPlayer(),
   }

   navigator = require("src.ui.navigator")()
end

---@param x number
---@param y number
---@param mouse number: The button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
---@param isTouch boolean: True if the mouse button press originated from a touchscreen touch-press
function love.mousepressed(x, y, mouse, isTouch)
   navigator:mousepressed(x, y, mouse, isTouch)
end

---@param key love.KeyConstant
---@param code love.Scancode
---@param isrepeat boolean
function love.keypressed(key, code, isrepeat)
   love.toggleRainbowBorders(Config)
   love.toggleModeIfNeeded()
   love.quitIfNeeded(Config.keymap.quit)
end

---@param x number
---@param y number
function love.wheelmoved(x, y)
   navigator:wheelmoved(x, y)
end

function love.update(dt)
   PlayerInteractor:update()

   navigator:update(dt)
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
