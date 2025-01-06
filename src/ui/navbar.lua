local View = require("src.ui.view")

---@class NavBar : View
---@field trailingView View?
---@field leadingView View?
local NavBar = View()

---@class NavBarOpts : ViewOpts
---@field leadingView View?
---@field trailingView View?
---@param opts NavBarOpts?
function NavBar:init(opts)
   View.init(self, opts)
end

function NavBar:load()
   View.load(self)

   self.size.height = Config.navBar.height

   if self.leadingView then
      self:addSubview(self.leadingView)
   end

   if self.trailingView then
      self:addSubview(self.trailingView)
   end
end

function NavBar:update(dt)
   View.update(self, dt)

   local padding = Config.navBar.horizontalPadding

   self.leadingView.origin.x = self.origin.x + padding

   self.trailingView.origin.x = self.size.width
      - padding
      - self.trailingView.size.width
end

---@param opts NavBarOpts
function NavBar:updateOpts(opts)
   View.updateOpts(self, opts)

   if opts.leadingView then
      self.leadingView = opts.leadingView or self.leadingView
   end

   if opts.trailingView then
      self.trailingView = opts.trailingView or self.trailingView
   end
end

---@return string
function NavBar:toString()
   return "NavBar"
end

return NavBar
