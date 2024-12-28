local View = require("src.ui.view")
local Color = require("src.ui.color")
local geom = require("src.ui.geometry")

---@class TabView : View
---@field private tabView View
local TabView = View()


function TabView:load()
   ---@diagnostic disable-next-line
   View.load(self)

   self.size = geom.Size(
      love.graphics.getWidth(),
      love.graphics.getHeight()
   )

   local tabView = View()

   tabView.origin = geom.Point(0, love.graphics.getHeight() - 80)
   tabView.size = geom.Size(love.graphics.getWidth(), 80)
   -- TODO: Move to constants
   tabView.backgroundColor = Color(200/255, 200/255, 200/255, 1)
   tabView.toString = function (...)
      return "Bottom tabView"
   end

   self:addSubview(tabView)
end

---@param view View
function TabView:push(view)
   self:addSubview(view, 1)

   view.size = self.size
   view.size.height = view.size.height - 80
end

function TabView:toString()
   return "TabView"
end


return TabView
