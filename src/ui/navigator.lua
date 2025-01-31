local MainView = require("src.ui.main")
local MiniPlayer = require("src.ui.player.miniplayer")
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
end

---@param dt number
function Navigator:update(dt)
   self.size = geom.Size(love.graphics.getWidth(), love.graphics.getHeight())

   if Config.app.state == "normal" then
      if self.isFlowChanged or Config.app.isFlowChanged then
         table.remove(self.subviews, 1)

         self:addSubview(self.tabView)
         if self.currentFlow == Flow.INITIAL then
            self:startInitialFlow()
         end

         --BUG: Here will be a bug when view will start to actually change :)
         self.tabView:push(self.currentView)
      end
   else
      if self.isFlowChanged or Config.app.isFlowChanged then
         table.remove(self.subviews, 1)

         self:addSubview(MiniPlayer())
      end
   end

   self.isFlowChanged = false
   Config.app.isFlowChanged = false

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
