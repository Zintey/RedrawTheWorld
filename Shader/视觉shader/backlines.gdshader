shader_type canvas_item;

// --- 美术控制参数 ---
group_uniforms Colors;
uniform vec4 line_color : source_color = vec4(0.0, 0.2, 0.2, 1.0);  // 基础暗线
uniform vec4 pulse_color : source_color = vec4(0.5, 1.0, 1.0, 1.0); // 霓虹亮点

group_uniforms Shape_and_Speed;
uniform float grid_size : hint_range(1.0, 100.0) = 25.0;     // 网格密度
uniform float line_width : hint_range(0.01, 0.5) = 0.06;    // 线条宽度
uniform float speed : hint_range(0.1, 10.0) = 2.0;          // 亮点流转速度

group_uniforms Fix_Bleeding;
// 核心修复参数：控制亮点在边缘消失的范围（建议 0.1 到 0.2）
uniform float edge_fade : hint_range(0.01, 0.5) = 0.15; 

// 性能极佳的随机函数
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // 1. 网格化坐标
    vec2 uv = UV * grid_size;
    vec2 id = floor(uv);   // 格子ID
    vec2 g_uv = fract(uv); // 格子内坐标 (0.0 到 1.0)
    
    // 2. 随机方向
    float n = hash(id);
    float direction = step(0.5, n); // 0 为横，1 为纵
    
    // 3. 计算基础线条
    float dist = direction > 0.5 ? abs(g_uv.x - 0.5) : abs(g_uv.y - 0.5);
    float line_mask = smoothstep(line_width, 0.0, dist);
    
    // 4. 计算流动亮点
    float time_offset = n * 10.0;
    float pulse_pos = fract(TIME * speed * 0.1 + time_offset);
    
    // 亮点中心距离
    float pulse_dist = direction > 0.5 ? abs(g_uv.y - pulse_pos) : abs(g_uv.x - pulse_pos);
    
    // --- 【关键修复逻辑】 ---
    // 计算当前亮点位置距离格子边缘 (0.0 或 1.0) 的淡出系数
    // 当 pulse_pos 接近 0 或 1 时，fade_mask 会趋近于 0
    float fade_mask = smoothstep(0.0, edge_fade, pulse_pos) * smoothstep(1.0, 1.0 - edge_fade, pulse_pos);
    
    // 结合线条遮罩、亮点范围和边缘淡出
    float pulse_mask = smoothstep(0.15, 0.0, pulse_dist) * line_mask * fade_mask;
    
    // 5. 颜色合成
    // 基础暗线 (0.2 透明度) + 霓虹亮点 (1.0 透明度 + Glow)
    vec3 final_rgb = mix(vec3(0.0), line_color.rgb, line_mask * 0.2);
    final_rgb += pulse_color.rgb * pulse_mask * 2.0; // 这里的 2.0 是亮度增益
    
    // 输出 Alpha
    float final_alpha = (line_mask * 0.1 + pulse_mask) * pulse_color.a;
    COLOR = vec4(final_rgb, final_alpha);
}