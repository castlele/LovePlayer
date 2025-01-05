---@diagnostic disable

---@return string
local function getCurrentFileName()
   local filePath = vim.fn.expand("%")
   local pathComponents = vim.fn.split(filePath, "/")
   return pathComponents[#pathComponents]
end

local love = "/Applications/love.app/Contents/MacOS/love"

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
   run = love .. " .",
   currentTest = string.format("./run_tests.sh \"%s\"", getCurrentFileName()),
   docs = "open obsidian://vault/docs"
}
