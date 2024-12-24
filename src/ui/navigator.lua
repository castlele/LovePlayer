local EmptyView = require("src.ui.list.empty")
local TabView = require("src.ui.tabview")

---@enum (key) Flow
local Flow = {
   INITIAL = 0,
}

---@class Navigator
---@field private tabView TabView
---@field private currentView View
---@field private currentFlow Flow
---@field private isFlowChanged boolean
local Navigator = class()


---@param flow Flow
function Navigator:startFlow(flow)
   self.currentFlow = flow
   self.isFlowChanged = true
end

function Navigator:load()
   self.tabView = TabView()
end

---@param dt number
function Navigator:update(dt)
   if self.isFlowChanged then
      if self.currentFlow == Flow.INITIAL then
         self:startInitialFlow()
      end

      self.tabView:push(self.currentView)
   end

   self.tabView:update(dt)

   self.isFlowChanged = false
end

function Navigator:draw()
   self.tabView:draw()
end


---@private
function Navigator:startInitialFlow()
   self.currentView = EmptyView()
end


return {
   navigator = Navigator,
   flow = Flow,
}
