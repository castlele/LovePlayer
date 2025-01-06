extern number progress;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 p = Texel(tex, texture_coords);
    number avg = (p.r + p.g + p.b) / 3;
    p.r = p.r + (avg - p.r) * progress;
    p.g = p.g + (avg - p.g) * progress;
    p.b = p.b + (avg - p.b) * progress;
    vec4 c = color;
    c.r += c.r * progress;
    c.g += c.g * progress;
    c.b += c.b * progress;
    return c * p;
}

