require("lovekit.ext.loveext")

function love.toggleModeIfNeeded()
   local keys = love.getKeys(Config.keymap.toggleMode)

   if not love.keyboard.isAllDown(keys) then
      return
   end

   if Config.app.state == "normal" then
      Config.app.state = "miniplayer"
   else
      Config.app.state = "normal"
   end

   Config.app.isFlowChanged = true
end
