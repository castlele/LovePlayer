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

---@generic T
---@param arr T[]
---@param from integer
---@return T[]
function M.shuffle(arr, from)
   local result = M.concat({}, arr)

   for i = from, #result - 1 do
      local j = math.random(i, #result)

      if j ~= from then
         result[i], result[j] = result[j], result[i]
      end
   end

   return result
end

return M
