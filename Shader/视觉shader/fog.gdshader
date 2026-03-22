shader_type canvas_item;

// --- 基础参数 ---
uniform sampler2D noise_texture : repeat_enable; // 噪声贴图
uniform vec4 fog_color : source_color = vec4(0.0, 1.0, 1.0, 0.3); // 霓虹青色雾
uniform vec2 scroll_speed = vec2(0.03, 0.01); // 雾气流动的速度

// --- 【核心新增】边缘消隐参数 ---
// 垂直（上下）消隐
uniform float top_fade_start : hint_range(0.0, 1.0) = 0.4; // 顶部雾气开始变透明的位置
uniform float top_fade_end : hint_range(0.0, 1.0) = 0.1; // 顶部雾气完全变透明的位置
uniform float bottom_fade_start : hint_range(0.0, 1.0) = 0.8; // 底部雾气开始变透明的位置 (1.0是底部)
uniform float bottom_fade_end : hint_range(0.0, 1.0) = 0.95; // 底部雾气完全变透明的位置

// 水平（左右）消隐
uniform float side_fade_start : hint_range(0.0, 1.0) = 0.1; // 左右两侧雾气开始变透明的距离 (从边缘算起，0.0-0.5)
uniform float side_fade_end : hint_range(0.0, 1.0) = 0.02; // 左右两侧雾气完全变透明的距离 (小于 start)

void fragment() {
    // 1. 获取流动的噪声值
    vec2 moving_uv = UV + (TIME * scroll_speed);
    float noise_val = texture(noise_texture, moving_uv).r;

    // 2. 计算垂直（上下）渐变蒙版
    // 顶部消隐
    float v_mask = smoothstep(top_fade_end, top_fade_start, UV.y);
    // 底部消隐 (UV.y > bottom_fade_start 时开始变透明)
    v_mask *= smoothstep(bottom_fade_end, bottom_fade_start, UV.y);

    // 3. 【核心修复】计算水平（左右）渐变蒙版
    // 左侧消隐 (UV.x < side_fade_start 时开始变透明)
    float h_mask = smoothstep(side_fade_end, side_fade_start, UV.x);
    // 右侧消隐 (UV.x > (1.0 - side_fade_start) 时开始变透明)
    // 我们用 1.0 - UV.x 将右侧边缘映射到 0.0-1.0 区间，方便计算
    h_mask *= smoothstep(side_fade_end, side_fade_start, 1.0 - UV.x);

    // 4. 组合最终蒙版：垂直蒙版 * 水平蒙版
    float final_mask = v_mask * h_mask;

    // 5. 输出最终颜色：原颜色 * 噪声值 * 四周渐变蒙版
    COLOR = vec4(fog_color.rgb, fog_color.a * noise_val * final_mask);
}