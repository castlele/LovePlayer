extern number animProgress;
extern number volumeState;
extern vec4 offColor;
extern vec4 onColor;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
   if (texture_coords.y <= animProgress) {
      if (volumeState < texture_coords.y) {
         return offColor;
      } else {
         return onColor;
      }
   }

   return vec4(0, 0, 0, 0);
}
