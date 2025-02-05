---@class Config
Config = {
   backend = "love", -- "love"|"miniaudio"
   app = {
      state = "normal", -- "normal"|"miniplayer"
      isFlowChanged = false,
   },
   logging = {
      minLevel = "DEBUG",
   },
   buttons = {
      play = {
         width = 30,
         height = 30,
      },
      next_prev = {
         width = 25,
         height = 20,
      },
      loop = {
         width = 25,
         height = 20,
      },
      minimize = {
         width = 25,
         height = 20,
      },
      expand = {
         width = 30,
         height = 30,
      },
   },
   navBar = {
      height = 50,
      horizontalPadding = 10,
   },
   tabBar = {
      height = 80,
   },
   lists = {
      scrollingVelocity = 20,
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

   keymap = {
      quit = "lctrl+q",
      toggleMode = "lctrl+m",
      rainbowBorders = "lctrl+d"
   },

   res = {
      shaders = {
         highlighting = function()
            return love.graphics.newShader("res/shaders/highlighting.glsl")
         end,
         coloring = function()
            return love.graphics.newShader("res/shaders/coloring.glsl")
         end,
      },
      images = {
         noFolder = "res/images/no_folder.png",
         pause = "res/images/pause.png",
         prev = "res/images/prev.png",
         play = "res/images/play.png",
         next = "res/images/next.png",
         loop_none = "res/images/loop_none.png",
         loop_queue = "res/images/loop_queue.png",
         loop_song = "res/images/loop_song.png",
         minimize = "res/images/minimize.png",
         expand = "res/images/expand.png",
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
