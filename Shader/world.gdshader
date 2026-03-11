shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float curvature : hint_range(0.0, 1.0) = 0.2;
uniform float scanline_count : hint_range(0.0, 1000.0) = 200.0;
uniform float scanline_speed : hint_range(0.0, 10.0) = 1.0;

uniform bool is_hit = false;
uniform float aberration : hint_range(0.0, 0.1) = 0.000; // 色散强度

uniform float noise_strength : hint_range(0.0, 10) = 1; // 噪点强度
uniform float scan_line_width = 0.005;


// 一个简单的随机函数，用于生成噪点
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123 );
}

void fragment() {
    // 1. 屏幕弯曲
    vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
    vec2 offset = centered_uv.yx / 3.0;
    centered_uv += centered_uv * dot(offset, offset) * curvature;
    vec2 curved_uv = (centered_uv + 1.0) * 0.5;


	float scan_line_noise_strength = 0.005;
	float scan_speed = 10.0;
	curved_uv.x -= (1.0 - step(scan_line_width / 2.0,abs(SCREEN_UV.y - fract(TIME * 1.0 / scan_speed) * 2.0)) )
	* scan_line_noise_strength;

    // 2. 色散效果 (Chromatic Aberration)
    // 分别采样红、绿、蓝三个通道，并在坐标上做微小偏移
	float aberration_offset = 0.005 * float(is_hit) * (sin(TIME * 10.0) + 1.0) / 2.0;
    float r = texture(screen_texture, curved_uv + vec2(aberration + aberration_offset, 0.0)).r;
    float g = texture(screen_texture, curved_uv).g;
    float b = texture(screen_texture, curved_uv - vec2(aberration + aberration_offset, 0.0)).b;
    vec4 col = vec4(r, g, b, 1.0);

    // 3. 边界裁剪
    if (curved_uv.x < 0.0 || curved_uv.x > 1.0 || curved_uv.y < 0.0 || curved_uv.y > 1.0) {
        col = vec4(0.0, 0.0, 0.0, 1.0);
    }


    // 4. 动态扫描线 (Moving Scanlines)
    float scanline = sin(curved_uv.y * scanline_count + TIME * scanline_speed) * 0.04;
    col.rgb -= scanline;


    // 5. 动态噪点 (Static Noise)
    // 利用随机函数和时间，给画面加一层淡淡的“雪花”
    //float n = (random(curved_uv + TIME) - 0.5) * noise_strength;
    //col.rgb += n;

    // 6. 边缘暗角 (Vignette)
    float vignette = length(centered_uv * 0.5);
    col.rgb *= smoothstep(1.0, 0.3, vignette);

	col.a -= float(is_hit) * 0.1 * fract(TIME);

	float noise_grid = 200.0;
	float hurt_uv = fract(random(ceil(curved_uv * noise_grid) / noise_grid) * TIME);
	col.a -= hurt_uv * 0.45 * (float(is_hit) + 0.1);
	col.r += hurt_uv * 0.1 * float(is_hit);
	//col.g *= hit_uv * 0.8 * float(is_hit);
	//col.b *= hit_uv * 0.8 * float(is_hit);
    COLOR = col;
}