local Row = require("lovekit.ui.row")
local colors = require("lovekit.ui.colors")

---@param song Song
local function createSongRow(song)
   local l = Config.lists
   local s = l.rows.sep
   ---@type ImageOpts?
   local leadingImage = nil

   if song.imageData then
      local imageData = song.imageData
      leadingImage = {
         imageData = imageData,
         width = 40,
         height = 40,
         autoResizing = false,
      }

      if imageData.id == "placeholder" then
         leadingImage.backgroundColor = colors.background
      end
   end

   return Row {
      isUserInteractionEnabled = true,
      backgroundColor = colors.background,
      height = l.rows.height,
      contentPaddingLeft = l.rows.padding.l,
      contentPaddingRight = l.rows.padding.r,
      sep = {
         height = s.height,
         paddingLeft = s.padding.l,
         paddingRight = s.padding.r,
         color = colors.secondary,
      },
      leadingImage = leadingImage,
      titlesStack = {
         backgroundColor = colors.background,
      },
      leadingHStack = {
         backgroundColor = colors.background,
         spacing = 10,
      },
      title = {
         backgroundColor = colors.background,
         title = song.title,
         fontPath = Config.res.fonts.bold,
         textColor = colors.white,
         fontSize = Config.res.fonts.size.header2,
      },
      subtitle = {
         backgroundColor = colors.background,
         title = song.artist.name,
         fontPath = Config.res.fonts.regular,
         textColor = colors.white,
         fontSize = Config.res.fonts.size.body,
      },
   }
end

return {
   factoryMethod = createSongRow
}
