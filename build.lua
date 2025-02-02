---@diagnostic disable

---@return string
local function getCurrentFileName()
   local filePath = vim.fn.expand("%")
   local pathComponents = vim.fn.split(filePath, "/")
   return pathComponents[#pathComponents]
end

local function getLove()
   local osname = require("cluautils.os").getName()

   if osname == "Linux" then
      return "~/Downloads/love-11.5-x86_64.AppImage"
   elseif osname == "MacOS" then
      return "/Applications/love.app/Contents/MacOS/love"
   end

   assert(false, "Unsupported OS type")
end

local function getOpenCmd()
   local osname = require("cluautils.os").getName()

   if osname == "Linux" then
      return "xdg-open"
   elseif osname == "MacOS" then
      return "open"
   end
end

conf = {
   install = "make install",
   miniaudiosample = [[
      bear -- make build_miniaudiosample
      make run_miniaudiosample
   ]],
   bindings = [[
      make clean
      bear -- make build_luaminiaudio
   ]],
   poc = [[
      bear -- make build_luaminiaudio
      lua ./src/main.lua
   ]],
   testAll = "./run_tests.sh \"*\"",
   testListsInteractor = "./run_tests.sh \"listsinteractor_tests\"",
   run = getLove() .. " .",
   currentTest = string.format("./run_tests.sh \"%s\"", getCurrentFileName()),
   docs = getOpenCmd() .. " obsidian://vault/docs",
}
