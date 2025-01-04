local MainView = require("src.ui.main")
local View = require("src.ui.view")
local TabView = require("src.ui.tabview")
local geom = require("src.ui.geometry")

---@enum (value) Flow
local Flow = {
   INITIAL = 0,
}

---@class Navigator : View
---@field private tabView TabView
---@field private currentView View
---@field private currentFlow Flow
---@field private isFlowChanged boolean
local Navigator = View()

---@param flow Flow
function Navigator:startFlow(flow)
   self.currentFlow = flow
   self.isFlowChanged = true
end

function Navigator:load()
   View.load(self)
   self.tabView = TabView()
   self:addSubview(self.tabView)
end

---@param dt number
function Navigator:update(dt)
   self.size = geom.Size(love.graphics.getWidth(), love.graphics.getHeight())

   if self.isFlowChanged then
      if self.currentFlow == Flow.INITIAL then
         self:startInitialFlow()
      end

      --BUG: Here will be a bug when view will start to actually change :)
      self.tabView:push(self.currentView)
   end

   self.isFlowChanged = false

   View.update(self, dt)
end

function Navigator:toString()
   return "Navigator"
end

---@private
function Navigator:startInitialFlow()
   self.currentView = MainView()
end

return {
   navigator = Navigator,
   flow = Flow,
}
