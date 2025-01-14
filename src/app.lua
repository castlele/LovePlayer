require("src.loveext")
require("src.utils.class")
require("src.configfile")
local debugView = require("src.ui.debugView")

local navigatorModule = require("src.ui.navigator")
---@type Navigator
local navigator = navigatorModule.navigator()

function love.load()
   love.graphics.setDefaultFilter("nearest", "nearest")
   navigator:startFlow(navigatorModule.flow.INITIAL)
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
