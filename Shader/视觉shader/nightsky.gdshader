shader_type canvas_item;

// 背景基础色（顶部深色）
uniform vec3 top_color : source_color = vec3(0.01, 0.02, 0.05);
// 地平线霓虹色（底部亮色，参考图1的青紫色）
uniform vec3 bottom_color : source_color = vec3(0.05, 0.1, 0.2);
// 霓虹溢出强度
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.5;
// 雾气密度
uniform sampler2D noise_tex;
uniform float fog_speed : hint_range(0.0, 0.5) = 0.02;

void fragment() {
    // 1. 创建垂直渐变背景
    float gradient = 1.0 - UV.y;
    // 使用 smoothstep 让地平线附近的亮色更有层次感
    float glow_mask = smoothstep(0.0, 0.8, gradient);
    vec3 sky_color = mix(top_color, bottom_color, glow_mask * glow_intensity);

    // 2. 模拟图1那种“空气质感”（动态雾气）
    vec2 moving_uv = UV + TIME * fog_speed;
    float noise = texture(noise_tex, moving_uv).r;

    // 让雾气只在底部明显，模仿城市上空的雾霾
    float haze = noise * glow_mask * 0.15;

    // 3. 最终颜色混合
    vec3 final_color = sky_color + haze;

    COLOR = vec4(final_color, 1.0);
}