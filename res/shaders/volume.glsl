// 0 if progress is on y axis (aka portrait)
// 1 if progress is on x axis (aka landscape)
extern number orientation;
extern number animProgress;
extern number volumeState;
extern vec4 offColor;
extern vec4 onColor;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    if (orientation == 0) {
        if (texture_coords.y <= animProgress) {
            if (volumeState < texture_coords.y) {
                return offColor;
            } else {
                return onColor;
            }
        }

    } else if (orientation == 1) {
        if (texture_coords.x <= animProgress) {
            if (volumeState < texture_coords.x) {
                return offColor;
            } else {
                return onColor;
            }
        }
    }

    return vec4(0, 0, 0, 0);
}
