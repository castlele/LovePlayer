local log = require("src.domain.logger.init")
local FM = require("cluautils.file_manager")

---@class Parser
local Parser = {}


---@param path string
---@return string[]
function Parser.parse(path)
   local content = FM.get_dir_content {
      dir_path = path,
      file_type = "f",
   }

   log.logger.default.log(content)

   return content
end


return Parser
