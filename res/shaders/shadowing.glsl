// 0 - not enabled
// 1 - enabled
extern number enabled;
extern vec4 tocolor;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 p = Texel(tex, texture_coords);

    if (enabled == 1) {
        return p * color;
    }

    return p * color * tocolor;
}

