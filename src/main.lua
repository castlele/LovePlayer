function love.load()
   local mini = require("luaminiaudio")
   local player = mini.init()
   player:play("./res/animals.flac")
end

function love.draw()
   love.graphics.setBackgroundColor(1, 0, 1, 1)
end
