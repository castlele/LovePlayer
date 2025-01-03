local ToolTip = {
   text = "",
   font = love.graphics.newFont(Config.res.fonts.regular),
   x = 0,
   y = 0,
}

function ToolTip.draw()
   if #Tooltip.text == 0 or not Config.debug.isDebugTooltip then
      return
   end

   local width = Tooltip.font:getWidth(Tooltip.text)

   love.graphics.push()
   love.graphics.setColor(0, 0, 0, 1)
   love.graphics.rectangle("fill", Tooltip.x, Tooltip.y, width + 20, 20)
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.print(Tooltip.text, Tooltip.x, Tooltip.y)
   love.graphics.pop()
end

return ToolTip
