shader_type canvas_item;

// --- Uniform 变量，可在 Inspector 中调整 ---

// 整体速度缩放 (用于调节所有动画的速度)
uniform float time_scale = 1.0;

// 全图像不稳定性（扭曲）参数
// intensity 控制扭曲的幅度，freq 控制频率
uniform float waver_intensity : hint_range(0.0, 0.05) = 0.003;
uniform float waver_freq = 0.35;

// 亮度脉动参数
uniform float pulse_intensity : hint_range(0.0, 0.3) = 0.04;
uniform float pulse_freq = 11.5;

void fragment() {
    // 获取当前的 UV 坐标和时间（乘以时间缩放）
    vec2 uv = UV;
    float t = TIME * time_scale;

    // --- 1. 全图像不稳定性扭曲 ---
    // 使用 sin 和 cos 函数，并结合 UV 坐标，创建一个微小的、随时间变化的偏移量
    // 偏移量不应该太大，以保持像素清晰度，只产生“不稳定”的视觉效果。
    vec2 final_uv = uv;
    final_uv.x += sin(t * waver_freq + uv.y * 20.0) * waver_intensity;
    final_uv.y += cos(t * (waver_freq * 1.1) + uv.x * 20.0) * waver_intensity;

    // --- 2. 采样扭曲后的纹理 ---
    vec4 tex_color = texture(TEXTURE, final_uv);

    // --- 3. 全图像亮度脉动 ---
    // 基于 sin 函数计算一个脉动值
    float pulse_val = sin(t * pulse_freq) * pulse_intensity;
    // 将脉动应用于原始 RGB 颜色，使其整体闪烁
    vec3 pulsed_rgb = tex_color.rgb * (1.0 + pulse_val);

    // --- 4. 颜色“呼吸”效果（可选，但增加魔法感） ---
    // 在原始颜色基础上增加一个微小的、随时间变化的颜色偏移（例如，向更亮或更偏黄的方向偏移）
    vec3 color_breath = vec3(0.02 * sin(t * 1.5 + uv.y * 5.0), 0.0, 0.0);
    vec3 breath_rgb = pulsed_rgb + color_breath;

    // --- 5. 像素艺术清晰度处理 ---
    // 确保纯黑色和极暗的像素不被混色影响，保持其清晰和背景透明。
    // step 函数用于阈值判断：如果原始颜色亮度小于 0.01，则 breaht_rgb 乘 0.0。
    float min_brightness = step(0.01, (tex_color.r + tex_color.g + tex_color.b) / 3.0);
    vec3 final_rgb = breath_rgb * min_brightness;

    // 将最终颜色和采样后的 Alpha 赋予 COLOR 变量
    // 使用 tex_color.a 保持原本透明度。
    COLOR = vec4(final_rgb, tex_color.a);
}