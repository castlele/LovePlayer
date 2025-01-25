local View = require("src.ui.view")

---@class NavBar : View
---@field trailingView View?
---@field centerView View?
---@field leadingView View?
local NavBar = View()

---@class NavBarOpts : ViewOpts
---@field leadingView View?
---@field centerView View?
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

   if self.centerView then
      self:addSubview(self.centerView)
   end

   if self.trailingView then
      self:addSubview(self.trailingView)
   end
end

function NavBar:update(dt)
   View.update(self, dt)

   local padding = Config.navBar.horizontalPadding

   if self.leadingView then
      self.leadingView.origin.x = self.origin.x + padding
      self.leadingView.origin.y = self.origin.y + self.size.height / 2 - self.leadingView.size.height / 2
   end

   if self.centerView then
      self.centerView.origin.x = self.origin.x + self.size.width / 2 - self.centerView.size.width / 2
      self.centerView.origin.y = self.origin.y + self.size.height / 2 - self.centerView.size.height / 2
   end

   if self.trailingView then
      self.trailingView.origin.x = self.size.width
      - padding
      - self.trailingView.size.width
      self.trailingView.origin.y = self.origin.y + self.size.height / 2 - self.trailingView.size.height / 2
   end
end

---@param opts NavBarOpts
function NavBar:updateOpts(opts)
   View.updateOpts(self, opts)

   if opts.leadingView then
      self.leadingView = opts.leadingView
   end

   if opts.centerView then
      self.centerView = opts.centerView
   end

   if opts.trailingView then
      self.trailingView = opts.trailingView
   end
end

---@return string
function NavBar:toString()
   return "NavBar"
end

return NavBar
