require("src.utils.class")

local navigatorModule = require("src.ui.navigator")
local navigator = navigatorModule.navigator()

function love.load()
   navigator:startFlow(navigatorModule.flow.INITIAL)
   navigator:load()
end

function love.update(dt)
   navigator:update(dt)
end

function love.draw()
   navigator:draw()
end
