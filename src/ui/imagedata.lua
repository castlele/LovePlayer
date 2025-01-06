---@enum (value) ImageDataType
local ImageDataType = {
   PATH = 0,
   DATA = 1,
}

---@class image.ImageData
---@field type ImageDataType
---@field data any
---@field id string
local ImageData = {}

---@param data any
---@param type ImageDataType
---@param id string?
---@return image.ImageData
function ImageData:new(data, type, id)
   ---@type image.ImageData
   local this = {
      type = type,
      data = data,
      id = id or "", -- TODO: UUID Module should exist btw :)
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

ImageData.placeholder =
   ImageData:new(Config.res.images.audioPlaceholder, ImageDataType.PATH, "placeholder")

return {
   imageDataType = ImageDataType,
   imageData = ImageData,
}
