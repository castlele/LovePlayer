local M = {}

---@generic T
---@param lhs T[]
---@param rhs T[]
---@return T[]
function M.concat(lhs, rhs)
   local result = lhs

   for key, value in pairs(rhs) do
      if type(value) == "table" and result[key] then
         lhs[key] = M.concat(result[key], value)
      else
         lhs[key] = value
      end
   end

   return result
end

return M
