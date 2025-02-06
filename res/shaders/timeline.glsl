extern vec4 onColor;
extern vec4 offColor;
extern number progress;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
   if (texture_coords.x <= progress) {
      return onColor;
   } else {
      return offColor;
   }
}
