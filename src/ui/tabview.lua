local View = require("src.ui.view")
local colors = require("src.ui.colors")

local tabBarHeight = Config.tabBar.height

---@class TabView : View
---@field private tabView View
local TabView = View()

function TabView:load()
   ---@diagnostic disable-next-line
   View.load(self)

   local tabView = View()
   self.tabView = tabView

   tabView.size.height = tabBarHeight
   tabView.backgroundColor = colors.secondary
   tabView.toString = function(_)
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

function TabView:update(dt)
   View.update(self, dt)

   self.size.width = love.graphics.getWidth()
   self.size.height = love.graphics.getHeight()

   self.tabView.size.width = self.size.width
   self.tabView.size.height = tabBarHeight
   self.tabView.origin.y = self.origin.y + self.size.height - tabBarHeight
end

function TabView:toString()
   return "TabView"
end

return TabView
