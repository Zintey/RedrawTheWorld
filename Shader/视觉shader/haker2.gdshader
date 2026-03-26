shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // 黑色底
uniform vec4 grid_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // 绿色网格线

// 【重要】这里直接输入你的瓦片像素大小！例如 32x32 或 64x64
uniform vec2 grid_size = vec2(32.0, 32.0); 

// 线条粗细 (0.05 表示线条占格子的 5%)
uniform float line_thickness : hint_range(0.0, 0.5) = 0.05; 

// 呼吸效果控制
uniform float breathe_speed : hint_range(0.1, 5.0) = 2.0;  // 呼吸速度
uniform float min_brightness : hint_range(0.0, 1.0) = 0.2; // 最暗时保留一点点亮光
uniform float max_brightness : hint_range(1.0, 5.0) = 1.5; // 最亮时的发光强度

// 声明一个变量，用来从顶点着色器传递全局坐标给片段着色器
varying vec2 world_pos;

void vertex() {
    // 获取瓦片在世界空间中的绝对坐标，这是实现“无缝拼接”的魔法
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    // 1. 获取瓦片原本的颜色和透明度 (最关键的是 .a 透明度)
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 2. 使用世界坐标计算网格，确保完美跨越多个瓦片
    vec2 grid_uv = fract(world_pos / grid_size);
    
    // 3. 计算离格子边缘的距离
    vec2 edge = min(grid_uv, 1.0 - grid_uv);
    
    // 4. 生成平滑的网格线 (smoothstep 让线条边缘有一点点柔和，避免太锐利的锯齿)
    float line = 1.0 - smoothstep(line_thickness * 0.8, line_thickness, min(edge.x, edge.y));
    
    // 5. 计算呼吸波 (正弦波映射)
    float breathe = (sin(TIME * breathe_speed) + 1.0) * 0.5; // 变成 0.0 到 1.0
    breathe = mix(min_brightness, max_brightness, breathe);
    
    // 6. 合成颜色：黑色底 + (绿色线 * 呼吸亮度)
    vec3 final_color = mix(base_color.rgb, grid_color.rgb, line * breathe);
    
    // 7. 输出！重点：乘以 tex_color.a 确保只在有瓦片的地方显示
    COLOR = vec4(final_color, tex_color.a * base_color.a);
}