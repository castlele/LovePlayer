local View = require("src.ui.view")
local colors = require("src.ui.colors")
local geom = require("src.ui.geometry")

local tabBarHeight = Config.tabBar.height

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

   tabView.origin = geom.Point(0, love.graphics.getHeight() - tabBarHeight)
   tabView.size = geom.Size(love.graphics.getWidth(), tabBarHeight)
   tabView.backgroundColor = colors.secondary
   tabView.toString = function (_)
      return "Bottom tabView"
   end

   self:addSubview(tabView)
end

---@param view View
function TabView:push(view)
   self:addSubview(view, 1)

   view.size = self.size
   view.size.height = view.size.height - tabBarHeight
end

function TabView:toString()
   return "TabView"
end


return TabView
