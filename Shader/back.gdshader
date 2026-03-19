shader_type canvas_item;


// --- 颜色配置 ---
uniform vec3 bg_color : source_color = vec3(0.01, 0.05, 0.07);    // 深渊最深处的暗色
uniform vec3 glow_color : source_color = vec3(0.6, 0.9, 0.9);     // 中间通道的亮光色
uniform vec3 box_color : source_color = vec3(0.0, 0.3, 0.35);     // 方块基础填充色
uniform vec3 line_color : source_color = vec3(0.2, 0.8, 0.9);     // 方块轮廓线发光色
uniform float alpha = 0.3;

// --- 结构与动画控制 ---
uniform float layers : hint_range(3.0, 10.0) = 4.0;               // 伪深度层数（层数越多越深邃）
uniform float scroll_speed : hint_range(0.0, 2.0) = 0.15;          // 向下坠落滚动的速度
uniform float center_gap_width : hint_range(0.0, 1.0) = 0.4;      // 中间深渊通道的宽度
uniform float line_thickness : hint_range(0.01, 0.1) = 0.05;      // 轮廓线粗细

// 伪随机函数
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // 修正纵横比 (假设宽屏 16:9)，防止方块变形
    vec2 uv = UV;
    uv.x = (uv.x - 0.5) * 1.77 + 0.5;

    // 1. 绘制中间的发光深渊背景
    // 基于距离中心的 X 轴距离和一定的 Y 轴偏移，做一个渐变光晕
    float dist_to_center = length(vec2(uv.x - 0.5, (UV.y - 0.3) * 0.5));
    vec3 final_color = mix(glow_color, bg_color, clamp(dist_to_center * 2.5, 0.0, 1.0));

    // 2. 多层建筑生成循环
    // i 从 0 到 layers，代表从“最远处”到“最前面”
    for (float i = 0.0; i < layers; i++) {
        // layer_z 范围是 [0.1 到 1.0]，数值越大代表离屏幕越近
        float layer_z = (i + 1.0) / layers; 
        
        // 核心透视逻辑：越近的层，网格越少（方块看起来越大）
        float density = mix(40.0, 8.0, layer_z); 

        // 让每一层以不同的速度垂直滚动，产生视差坠落感
        vec2 offset = vec2(0.0, TIME * scroll_speed * layer_z);
        vec2 st = (uv + offset) * density;

        vec2 grid_id = floor(st);
        vec2 local_uv = fract(st);

        // --- 建筑构图逻辑（峡谷约束） ---
        // 计算当前网格离中心轴的距离
        float grid_center_x = 0.5 * density; 
        float dist_x = abs(grid_id.x - grid_center_x);

        // 动态计算每一层留空的宽度：越近的层，留空的 gap 越大，形成一个倒梯形的隧道
        float current_gap = (center_gap_width * density) * layer_z;

        // 如果当前网格不在中间的“深渊”范围内，才允许生成方块
        if (dist_x > current_gap) {
            
            // 随机决定这里是否生成方块（靠近边缘的生成概率更高，填满墙壁）
            float spawn_prob = 0.3 + (dist_x / density) * 1.5;
            if (random(grid_id + i * 12.34) < spawn_prob) {
                
                // --- 方块形状咬合逻辑 ---
                // 为了像原图那样紧密排列，我们让大部分方块填满整个格子 (w=1, h=1)
                // 少部分方块有留白，形成高低错落的缝隙
                float w = (random(grid_id + 1.0) > 0.4) ? 1.0 : mix(0.4, 0.9, random(grid_id + 1.1));
                float h = (random(grid_id + 2.0) > 0.4) ? 1.0 : mix(0.4, 0.9, random(grid_id + 2.1));
                
                vec2 margin = vec2((1.0 - w) * 0.5, (1.0 - h) * 0.5);

                // 绘制带轮廓的矩形
                vec2 box_inner = step(margin + line_thickness, local_uv) * step(local_uv, 1.0 - margin - line_thickness);
                vec2 box_outer = step(margin, local_uv) * step(local_uv, 1.0 - margin);

                float fill = box_inner.x * box_inner.y;
                float outline = (box_outer.x * box_outer.y) - fill;

                // --- 颜色渲染 ---
                // 越靠近中心发光带的方块，颜色越亮
                float edge_glow = 1.0 - clamp((dist_x - current_gap) / (density * 0.2), 0.0, 1.0);
                vec3 cur_fill_color = mix(box_color, glow_color, edge_glow * 0.6) * layer_z;
                vec3 cur_line_color = line_color * mix(0.5, 1.5, layer_z);

                // 让方块有轻微的呼吸闪烁感
                float flicker = mix(0.7, 1.0, sin(TIME * 3.0 + random(grid_id) * 10.0));
                
                // 叠加颜色 (依靠透明度覆盖下层)
                if (fill > 0.0) {
                    final_color = mix(final_color, cur_fill_color, flicker * layer_z);
                }
                if (outline > 0.0) {
                    final_color = mix(final_color, cur_line_color, flicker);
                }
            }
        }
    }
	
    COLOR = vec4(final_color, alpha);
}