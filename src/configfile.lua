---@class Config
Config = {
   logging = {
      minLevel = "DEBUG",
   },
   navBar = {
      height = 50,
      horizontalPadding = 10,
   },
   tabBar = {
      height = 80,
   },
   lists = {
      scrollingVelocity = 15,
      rows = {
         height = 50,
         sep = {
            padding = {
               x = 10,
            }
         }
      },
   },

   res = {
      fonts = {
         regular = "res/fonts/ubuntu-regular.ttf",
      }
   },

   debug = {
      isDebug = true,
      isRainbowBorders = false,
      isDebugTooltip = true,

      mock = {
         isMocking = true,
         folderPath = "$HOME/Music/"
      },
   },
}
