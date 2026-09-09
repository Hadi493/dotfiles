#version 300 es
precision mediump float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

// E-INK paper simulation (STRONG - max crisp)
// grayscale + contrast boost + lifted blacks + warm paper tint
void main() {
    vec4 pixColor = texture(tex, v_texcoord);

    // Luminance (BT.709 - best for LCD -> paper)
    float lum = dot(pixColor.rgb, vec3(0.2126, 0.7152, 0.0722));

    // Boost contrast like e-ink (crisp text)
    lum = (lum - 0.5) * 1.45 + 0.5;

    // Lift blacks / compress whites: e-ink blacks are dark-gray, whites are off-white
    lum = lum * 0.88 + 0.06;
    lum = clamp(lum, 0.0, 1.0);

    // Warm paper tint (subtle - pair with 4000K night mode for full effect)
    vec3 paper = vec3(1.0, 0.965, 0.88);
    vec3 outColor = vec3(lum) * paper;

    fragColor = vec4(clamp(outColor, 0.0, 1.0), pixColor.a);
}
