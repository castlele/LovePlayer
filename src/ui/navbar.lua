local View = require("src.ui.view")

---@class NavBar : View
---@field trailingView View
local NavBar = View()


function NavBar:load()
   View.load(self)

   self.size.height = Config.navBar.height
   self.trailingView = View()
   self:addSubview(self.trailingView)
end

function NavBar:update(dt)
   local padding = Config.navBar.horizontalPadding
   self.trailingView.origin.x = self.size.width - padding - self.trailingView.size.width

   View.update(self, dt)
end

---@return string
function NavBar:toString()
   return "NavBar"
end


return NavBar
