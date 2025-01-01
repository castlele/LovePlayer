require("cluautils.string_utils")
local ext = require("src.domain.audioext")
local flac = require("luaflac")


local M = {
   parsers = {
      ---@type fun(media: MediaFile): MediaFileMetadata?
      flac = function(media)
         local file = io.open(media.path, "rb")

         if not file then
            return nil
         end

         ---@diagnostic disable-next-line
         local fileComponents = string.split(media.path, "%/")
         local metadata = {
            title = fileComponents[#fileComponents]
         }

         local decoder = flac.FLAC__stream_decoder_new()
         ---@type MediaFileMetadata

         decoder:set_metadata_respond(flac.FLAC__METADATA_TYPE_VORBIS_COMMENT)

         local function decoder_read_callback(_, size)
            return file:read(size)
         end

         local function decoder_metadata_callback(_, meta)
            if meta.type ~= flac.FLAC__METADATA_TYPE_VORBIS_COMMENT then
               return
            end

            for _, value in ipairs(meta.vorbis_comment.comments) do
               local keyValue = string.split(value, "=")

               metadata[keyValue[1]] = keyValue[2]
            end
         end

         decoder:init_stream {
            read = decoder_read_callback,
            write = function(...) end,
            metadata = decoder_metadata_callback,
            error = function(...)
               file:close()
            end,
         }

         decoder:process_until_end_of_metadata()
         file:close()

         return metadata
      end,

      ---@type fun(media: MediaFile): MediaFileMetadata
      default = function(media)
         ---@diagnostic disable-next-line
         local fileComponents = string.split(media.path, "%/")
         local file = fileComponents[#fileComponents]
         local fileName = string.split(file, "%.")[1]
         ---@type MediaFileMetadata
         local metadata = {
            title = fileName
         }

         return metadata
      end,
   },
}

---@param media MediaFile
---@return MediaFileMetadata?
function M.parse(media)
   local parsers = M.parsers

   if media.type == ext.FLAC then
      return parsers.flac(media)
   end

   return parsers.default(media)
end

return M
