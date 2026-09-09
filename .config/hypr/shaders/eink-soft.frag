#version 300 es
precision mediump float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

// E-INK paper simulation (SOFT - easy on eyes, default)
// light grayscale + gentle contrast + warm paper
void main() {
    vec4 pixColor = texture(tex, v_texcoord);

    // Luminance (BT.709)
    float lum = dot(pixColor.rgb, vec3(0.2126, 0.7152, 0.0722));

    // Gentle contrast (was 1.45 - too crunchy)
    lum = (lum - 0.5) * 1.18 + 0.5;

    // Lift blacks slightly like e-ink
    lum = lum * 0.90 + 0.05;
    lum = clamp(lum, 0.0, 1.0);

    // Very light paper tint (warming mostly done by 4500K night filter)
    vec3 paper = vec3(1.0, 0.98, 0.94);
    vec3 outColor = vec3(lum) * paper;

    fragColor = vec4(clamp(outColor, 0.0, 1.0), pixColor.a);
}
