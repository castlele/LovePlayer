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
         height = 60,
         padding = {
            l = 10,
            r = 0,
         },
         sep = {
            height = 2,
            padding = {
               l = 10,
               r = 0,
            }
         }
      },
   },

   res = {
      images = {
         noFolder = "res/no_folder.png",
      },
      fonts = {
         regular = "res/fonts/ubuntu-regular.ttf",
         italic = "res/fonts/ubuntu-italic.ttf",
         bold = "res/fonts/ubuntu-bold.ttf",
         boldItalic = "res/fonts/ubuntu-bold-italic.ttf",

         size = {
            header1 = 24,
            header2 = 16,
            header3 = 14,
            body = 8,
         }
      }
   },

   debug = {
      isDebug = false,
      isRainbowBorders = false,
      isDebugTooltip = true,

      mock = {
         isMocking = true,
         folderPath = "$HOME/Music/"
      },
   },
}
