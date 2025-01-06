local FPSView = {}

---@param drawing boolean
---@param x number
---@param y number
---@param r number
---@param g number
---@param b number
---@param a number
function FPSView.draw(drawing, x, y, r, g, b, a)
   if not drawing then
      return
   end

   love.graphics.push()

   love.graphics.setColor(r, g, b, a)
   love.graphics.print(love.timer.getFPS(), x, y)

   love.graphics.pop()
end

return {
   fpsView = FPSView,
}
