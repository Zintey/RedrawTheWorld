shader_type canvas_item;

// 像素化程度，值越小像素块越大（马赛克感越强）
uniform float pixel_size : hint_range(8.0, 64.0) = 32.0;

// 复古三色调
uniform vec4 color_front : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // 白热化尖端
uniform vec4 color_mid : source_color = vec4(1.0, 0.6, 0.0, 1.0);    // 亮橙色中段
uniform vec4 color_back : source_color = vec4(0.6, 0.0, 0.0, 1.0);   // 暗红色尾巴

// 闪烁频率
uniform float flicker_speed = 30.0;

void fragment() {
    // 1. 强行像素化 UV 坐标 (将平滑坐标降维成马赛克方块)
    vec2 uv = floor(UV * pixel_size) / pixel_size;
    
    // 2. 雕刻形状 (前圆后尖的能量束)
    float y_dist = abs(uv.y - 0.5) * 2.0; // 距离中心线的高度
    // 尾部收缩
    float thickness = mix(0.1, 0.8, smoothstep(0.0, 0.4, uv.x));
    // 头部圆润
    thickness *= 1.0 - smoothstep(0.8, 1.0, uv.x);
    
    // 生成坚硬的像素边缘（非 0 即 1）
    float mask = step(y_dist, thickness);
    
    // 3. 强行划分色彩块（拒绝平滑渐变）
    vec3 color = color_back.rgb;
    if (uv.x > 0.4) color = color_mid.rgb;
    if (uv.x > 0.8) color = color_front.rgb;
    
    // 4. 边缘高频躁动与掉帧闪烁
    // 用极高频的时间函数制造不稳定感
    float jitter = fract(sin(dot(uv + TIME, vec2(12.9898, 78.233))) * 43758.5453);
    if (y_dist > thickness - 0.2 && jitter > 0.6) {
        mask = 0.0; // 随机吃掉边缘的像素块
    }
    
    float pulse = step(0.5, fract(TIME * flicker_speed));
    float final_alpha = mask * (0.7 + 0.3 * pulse); // 剧烈频闪

    COLOR = vec4(color, final_alpha);
}