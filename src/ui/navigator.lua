local MainView = require("src.ui.main")
local MiniPlayer = require("src.ui.player.miniplayer")
local View = require("lovekit.ui.view")
local geom = require("lovekit.ui.geometry")

---@class Navigator : View
---@field private currentView MainView
---@field private isFlowChanged boolean
local Navigator = View()

function Navigator:load()
   View.load(self)

   self.isFlowChanged = true
   self.currentView = MainView()
end

---@param dt number
function Navigator:update(dt)
   self.size = geom.Size(love.graphics.getWidth(), love.graphics.getHeight())

   if Config.app.state == "normal" then
      if self.isFlowChanged or Config.app.isFlowChanged then
         if #self.subviews >= 1 then
            table.remove(self.subviews, 1)
         end

         love.window.setMode(1024, 768, {
            resizable = true,
            highdpi = true,
            minwidth = 800,
            minheight = 600,
         })

         self:addSubview(self.currentView)
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
