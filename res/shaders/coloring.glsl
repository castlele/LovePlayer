extern vec4 tocolor;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 p = Texel(tex, texture_coords);
    vec4 localToColor = tocolor;

    localToColor.a *= p.a;

    return localToColor;
}

