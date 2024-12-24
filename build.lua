---@diagnostic disable

local love = "/Applications/love.app/Contents/MacOS/love"

conf = {
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
   run = love .. " .",
}
