shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float curvature : hint_range(0.0, 1.0) = 0.2; // 屏幕弯曲度
uniform float scanline_count : hint_range(0.0, 1000.0) = 300.0;

void fragment() {
    // 1. 屏幕弯曲 (Fish-eye)
    vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
    vec2 offset = centered_uv.yx / 3.0; // 这里的系数控制变形轴向
    centered_uv += centered_uv * dot(offset, offset) * curvature;
    vec2 curved_uv = (centered_uv + 1.0) * 0.5;

    // 2. 采样并限制边界 (防止弯曲溢出)
    vec4 col = texture(screen_texture, curved_uv);
    if (curved_uv.x < 0.0 || curved_uv.x > 1.0 || curved_uv.y < 0.0 || curved_uv.y > 1.0) {
        col = vec4(0.0, 0.0, 0.0, 1.0);
    }

    // 3. 添加扫描线 (Scanlines)
    float scanline = sin(curved_uv.y * scanline_count) * 0.04;
    col.rgb -= scanline;

    // 4. 边缘暗角 (Vignette)
    float vignette = length(centered_uv * 0.5);
    col.rgb *= smoothstep(1.0, 0.3, vignette);

    COLOR = col;
}