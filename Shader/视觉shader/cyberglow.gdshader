shader_type canvas_item;

// --- 全息基础设置 ---
group_uniforms holographic;
uniform vec4 base_color : source_color = vec4(0.0, 1.0, 1.0, 1.0); // 默认全息青色
uniform float alpha : hint_range(0.0, 1.0) = 0.65;              // 基础透明度

// --- 扫描线设置 ---
group_uniforms scan_lines;
uniform float line_density : hint_range(0.0, 100.0) = 50.0;     // 扫描线密度
uniform float line_speed : hint_range(0.0, 10.0) = 2.0;       // 扫描线滚动速度
uniform float line_intensity : hint_range(0.0, 1.0) = 0.5;   // 扫描线亮度比例

// --- 故障设置 ---
group_uniforms glitch;
uniform float aberration_intensity : hint_range(0.0, 0.2) = 0.03; // 色差强度 (参考图中的色彩分离)
uniform float glitch_tear_frequency : hint_range(0.0, 1.0) = 0.05; // 故障撕裂频率
uniform float glitch_tear_intensity : hint_range(0.0, 1.0) = 0.1;  // 故障撕裂幅度
uniform float glitch_speed : hint_range(0.0, 10.0) = 4.0;          // 故障更新速度

// --- 辉光设置 (Shader内部) ---
group_uniforms glow;
uniform float inner_glow_spread : hint_range(0.0, 50.0) = 15.0; // 内部柔光扩散范围 (像素)
uniform float inner_glow_intensity : hint_range(0.0, 5.0) = 1.5; // 内部柔光亮度
uniform float bloom_trigger : hint_range(1.0, 10.0) = 2.0;     // 触发 WorldEnvironment Bloom 的亮度阀值

// 一个简单的确定性伪随机函数
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;

    // --- 1. 故障数据撕裂 ---
    // 这个部分控制水平方向的数据切片和偏移
    float glitch_rnd = random(vec2(floor(TIME * glitch_speed), floor(uv.y * 30.0)));
    float is_glitch = step(1.0 - glitch_tear_frequency, glitch_rnd); // 故障发生的条件

    // 计算一个随机的水平偏移量
    float tear_offset = (random(vec2(is_glitch, floor(uv.y * 15.0))) - 0.5) * glitch_tear_intensity;
    uv.x += is_glitch * tear_offset;

    // --- 2. 色差偏移 (色彩分离) ---
    // 此步骤基于故障量偏移采样 UV。参考图中的红/蓝/绿偏移
    vec2 offset = vec2(aberration_intensity * is_glitch, 0.0);
    vec4 col_r = texture(TEXTURE, uv - offset); // R通道偏移
    vec4 col_g = texture(TEXTURE, uv);          // G通道默认
    vec4 col_b = texture(TEXTURE, uv + offset); // B通道偏移

    // 组合色差颜色，并乘上全息基础颜色
    vec4 final_color;
    final_color.r = col_r.r;
    final_color.g = col_g.g;
    final_color.b = col_b.b;
    final_color.a = texture(TEXTURE, uv).a; // 保持透明度

    final_color *= base_color;

    // --- 3. 全息扫描线 ---
    // 使用正弦波基于 UV.y 计算周期性的透明度变化
    float scan_line = sin((uv.y - TIME * line_speed * 0.01) * line_density * PI * 2.0);
    // 将扫描线应用为亮度的增加，使其更像发光体
    final_color.rgb += base_color.rgb * max(0.0, scan_line) * line_intensity;

    // --- 4. 内部柔光效果 (叠加模糊) ---
    // 为了防止在 Shader 中进行多重纹理采样导致性能下降，我们使用一个简易的、内部的模糊来实现
    // 这种效果在 2D 场景中非常有效，能产生柔和的内部辉光感。
    vec4 blurred_col = vec4(0.0);
    // 简单的 3x3 叠加模糊
    float sample_dist = inner_glow_spread * SCREEN_PIXEL_SIZE.x;
    blurred_col += texture(TEXTURE, uv + vec2(-sample_dist, 0.0));
    blurred_col += texture(TEXTURE, uv + vec2(sample_dist, 0.0));
    blurred_col += texture(TEXTURE, uv + vec2(0.0, -sample_dist));
    blurred_col += texture(TEXTURE, uv + vec2(0.0, sample_dist));
    blurred_col += texture(TEXTURE, uv + vec2(-sample_dist, sample_dist));
    blurred_col += texture(TEXTURE, uv + vec2(sample_dist, sample_dist));
    blurred_col += texture(TEXTURE, uv + vec2(-sample_dist, -sample_dist));
    blurred_col += texture(TEXTURE, uv + vec2(sample_dist, -sample_dist));
    blurred_col /= 8.0;

    // 将模糊结果应用为叠加，增加亮度和柔和度
    vec3 glow_color = blurred_col.rgb * inner_glow_intensity;
    final_color.rgb += glow_color;

    // --- 5. 设置透明度和 Bloom 触发 ---
    // 应用基础透明度
    final_color.a *= alpha;

    // 如果启用了 Bloom 触发，输出高亮度颜色，超出 1.0
    if (bloom_trigger > 1.0) {
        final_color.rgb *= bloom_trigger;
    }

    COLOR = final_color;
}