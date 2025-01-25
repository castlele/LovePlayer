---@see https://love2d.org/forums/viewtopic.php?p=163209#p163209
function love.graphics.roundedRectangle(mode, x, y, w, h, rx, ry)
   ry = ry or rx
   local pts = {}
   local precision = math.floor(0.2 * (rx + ry))
   local hP = math.pi / 2
   rx = rx >= w / 2 and w / 2 - 1 or rx
   ry = ry >= h / 2 and h / 2 - 1 or ry
   local sin, cos = math.sin, math.cos
   for i = 0, precision do -- upper right
      local a = (i / precision - 1) * hP
      pts[#pts + 1] = x + w - rx * (1 - cos(a))
      pts[#pts + 1] = y + ry * (1 + sin(a))
   end
   for i = 2 * precision + 2, 1, -2 do -- lower right
      pts[#pts + 1] = pts[i - 1]
      pts[#pts + 1] = 2 * y - pts[i] + h
   end
   for i = 1, 2 * precision + 2, 2 do -- lower left
      pts[#pts + 1] = -pts[i] + 2 * x + w
      pts[#pts + 1] = 2 * y - pts[i + 1] + h
   end
   for i = 2 * precision + 2, 1, -2 do -- upper left
      pts[#pts + 1] = -pts[i - 1] + 2 * x + w
      pts[#pts + 1] = pts[i]
   end
   love.graphics.polygon(mode, pts)
end

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
