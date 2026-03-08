shader_type canvas_item;

// 外部可调参数
uniform vec2 size = vec2(200.0, 150.0); // 矩形的尺寸（像素）
uniform float radius = 20.0;           // 圆角半径（像素）
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.0, 0.5); // 颜色

void fragment() {
    // 1. 将 UV 坐标转换为以中心为原点的像素坐标系
    // UV 范围是 0~1，减去 0.5 变成 -0.5~0.5，再乘以实际尺寸
    vec2 center_rel = (UV - 0.5) * size;

    // 2. 计算到“内缩矩形”边界的距离
    // 逻辑：将坐标取绝对值，减去 (矩形半径 - 圆角半径)
    vec2 q = abs(center_rel) - (size * 0.5) + radius;

    // 3. 计算距离场 (SDF)
    // 如果像素在圆角内或直边内，dist 会小于等于 0
    float dist = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;

    // 4. 利用 smoothstep 处理抗锯齿，并设置 Alpha
    float mask = smoothstep(0.5, -0.5, dist);

    COLOR = vec4(bg_color.rgb, bg_color.a * mask);
}