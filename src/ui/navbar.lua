local View = require("src.ui.view")

---@class NavBar : View
---@field trailingView View
local NavBar = View()


function NavBar:load()
   View.load(self)

   self.trailingView = View()
   self:addSubview(self.trailingView)
end

function NavBar:update(dt)
   -- TODO: Move to properties
   local padding = 5
   self.trailingView.origin.x = self.size.width - padding - self.trailingView.size.width

   View.update(self, dt)
end

---@rerturn string
function NavBar:toString()
   return "NavBar"
end


return NavBar
