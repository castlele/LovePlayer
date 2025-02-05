local MainView = require("src.ui.main")
local MiniPlayer = require("src.ui.player.miniplayer")
local View = require("src.ui.view")
local TabView = require("src.ui.tabview")
local geom = require("src.ui.geometry")

---@class Navigator : View
---@field private tabView TabView
---@field private isFlowChanged boolean
local Navigator = View()

function Navigator:load()
   View.load(self)
   self.isFlowChanged = true
   self.tabView = TabView()
   self.tabView:push(MainView())
end

---@param dt number
function Navigator:update(dt)
   self.size = geom.Size(love.graphics.getWidth(), love.graphics.getHeight())

   if Config.app.state == "normal" then
      if self.isFlowChanged or Config.app.isFlowChanged then
         if #self.subviews >= 1 then
            table.remove(self.subviews, 1)
         end

         -- This means that flow was changed from the outside of the "normal" flow
         if Config.app.isFlowChanged then
            love.window.setMode(1024, 768, nil)
         end

         self:addSubview(self.tabView)
      end
   else
      if self.isFlowChanged or Config.app.isFlowChanged then
         if #self.subviews >= 1 then
            table.remove(self.subviews, 1)
         end

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

return Navigator
