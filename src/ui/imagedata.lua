---@enum (value) ImageDataType
local ImageDataType = {
   PATH = 0,
   DATA = 1,
}

---@class image.ImageData
---@field type ImageDataType
---@field data any
local ImageData = {}

---@param data any
---@param type ImageDataType
---@return image.ImageData
function ImageData:new(data, type)
   ---@type image.ImageData
   local this = {
      type = type,
      data = data,
   }

   setmetatable(this, { __index = self })

   return this
end

---@return love.Image?
function ImageData:getImage()
   if self.type == ImageDataType.PATH then
      assert(
         type(self.data) == "string",
         "ImageData's data should be string aka path"
      )
      return love.graphics.newImage(self.data)
   elseif self.type == ImageDataType.DATA then
      assert(
         type(self.data) == "string",
         "ImageData's data should be string aka bytes"
      )
      local byteData = love.data.newByteData(self.data)
      ---@diagnostic disable-next-line
      local imageData = love.image.newImageData(byteData)

      return love.graphics.newImage(imageData)
   end
end

return {
   imageDataType = ImageDataType,
   imageData = ImageData,
}
