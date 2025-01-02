local View = require("src.ui.view")

---@class NavBar : View
---@field trailingView View
local NavBar = View()

---@param trailingView View
function NavBar:init(trailingView)
   View.init(self)
   self.trailingView = trailingView

   self:addSubview(self.trailingView)
end

function NavBar:load()
   View.load(self)

   self.size.height = Config.navBar.height
end

function NavBar:update(dt)
   local padding = Config.navBar.horizontalPadding
   self.trailingView.origin.x = self.size.width
      - padding
      - self.trailingView.size.width

   View.update(self, dt)
end

---@return string
function NavBar:toString()
   return "NavBar"
end

return NavBar
