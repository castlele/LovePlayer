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
      shaders = {
         highlighting = function()
            return love.graphics.newShader("res/shaders/highlighting.glsl")
         end,
      },
      images = {
         noFolder = "res/images/no_folder.png",
         audioPlaceholder = "res/images/audio_placeholder.png",
      },
      fonts = {
         regular = "res/fonts/ubuntu-regular.ttf",
         italic = "res/fonts/ubuntu-italic.ttf",
         bold = "res/fonts/ubuntu-bold.ttf",
         boldItalic = "res/fonts/ubuntu-bold-italic.ttf",

         size = {
            header1 = 30,
            header2 = 24,
            header3 = 18,
            body = 12,
         }
      }
   },

   debug = {
      isDebug = true,
      isRainbowBorders = false,
      isDebugTooltip = true,
      isDrawFPS = true,

      mock = {
         isMocking = true,
         folderPath = "$HOME/Music/"
      },
   },
}
