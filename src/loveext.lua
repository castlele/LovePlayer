---@param keyComb string
---@return string[]
function love.getKeys(keyComb)
   return require("cluautils.string_utils").split(keyComb, "+")
end

---@param keys string[]
function love.keyboard.isAllDown(keys)
   if #keys == 0 then
      return false
   end

   local isAllDown = true

   for _, key in pairs(keys) do
      isAllDown = isAllDown and love.keyboard.isDown(key)
   end

   return isAllDown
end

function love.quitIfNeeded()
   local keys = love.getKeys(Config.keymap.quit)

   if not love.keyboard.isAllDown(keys) then
      return
   end

   love.event.quit(0)
end

function love.toggleRainbowBorders()
   if not Config.debug.isDebug then
      return
   end

   local keys = love.getKeys(Config.keymap.rainbowBorders)

   if not love.keyboard.isAllDown(keys) then
      return
   end

   Config.debug.isRainbowBorders = not Config.debug.isRainbowBorders
end

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
