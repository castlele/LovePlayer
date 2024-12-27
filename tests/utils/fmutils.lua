local M = {}


M.MockData = {
   emptyFolderPath = "tests/empty_folder",
   musicFolderPath = "tests/music_folder",
}


function M.prepareEmptyFolder()
   os.execute("mkdir " .. M.MockData.emptyFolderPath)
end

function M.cleanEmptyFolder()
   os.execute("rm -rf " .. M.MockData.emptyFolderPath)
end

function M.prepareOnlyMusicFolder()
end

function M.cleanOnlyMusicFolder()
end

---@class Env
---@field cwd string?
---@field prepare fun()?
---@field clean fun()?
---@param env Env
---@param callback fun(cwd: string)
function M.runInEnvironment(env, callback)
   local cwd = env.cwd or M.MockData.emptyFolderPath
   local prepare = env.prepare or M.prepareEmptyFolder
   local clean = env.clean or M.cleanEmptyFolder

   prepare()
      callback(cwd)
   clean()
end


return M
