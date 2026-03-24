shader_type canvas_item;

uniform vec4 aura_color : source_color = vec4(0.1, 1.0, 0.9, 1.0); 

// === 1. 形状与核心 ===
// 控制半月形有多厚，值越大越像巨斧的重劈，值越小越像风刃
uniform float blade_thickness : hint_range(0.0, 1.0) = 0.3;
// 控制纯白色核心的大小，越小越锋利
uniform float core_intensity : hint_range(0.0, 0.2) = 0.05;

// === 2. 拖影与乱流 ===
// 向后拉伸的长度，值越大，尾巴拖得越长（彗星感）
uniform float trail_length : hint_range(0.0, 2.0) = 0.5;
// 尾部边缘的撕裂/毛躁程度
uniform float trail_distortion : hint_range(0.0, 1.0) = 0.3;
// 乱流翻滚的速度，决定了狂暴感
uniform float turbulence_speed = 15.0;

// === 3. 边缘与泛光 ===
// 决定前刃有多平滑。值越大，平滑的区域越多，噪点只集中在最后面
uniform float front_smoothness : hint_range(0.0, 0.5) = 0.1;
// 青色光晕的扩散范围
uniform float glow_spread : hint_range(0.0, 1.0) = 0.25;

void fragment() {
    // 1. 扩展坐标系，防止剑气被方框边缘切断
    vec2 uv = (UV - 0.5) * 3.0; 

    // 2. 尾部非对称拉伸 (极简空气动力学)
    vec2 shape_uv = uv;
    if (shape_uv.x < 0.0) {
        // 只有当 x < 0（左侧尾部）时，压缩 X 轴坐标。
        // 在 SDF 里压缩坐标，视觉上就是把尾巴拉长！
        shape_uv.x /= (1.0 + trail_length); 
    }

    // 3. 构建半月 SDF (外侧圆减去内侧圆)
    float d1 = length(shape_uv + vec2(blade_thickness, 0.0)) - 0.9; 
    float d2 = length(shape_uv + vec2(blade_thickness + 0.6, 0.0)) - 1.0; 
    float sdf = max(d1, -d2);

    // 4. 方向性遮罩 (Directional Mask) - 核心魔法！
    // 计算一个从右到左平滑过渡的权重。
    // x > front_smoothness 时值为 0（完全无噪点），向左逐渐变成 1（噪点拉满）。
    float noise_mask = smoothstep(front_smoothness, -0.3, uv.x);

    // 5. 狂暴乱流噪声 (由三个不同频率的波叠加)
    float t = TIME * turbulence_speed;
    float noise = sin(uv.y * 10.0 + t) * 0.4
                + cos(uv.y * 23.0 - t * 1.3) * 0.3
                + sin(uv.y * 45.0 + t * 0.8) * 0.3;

    // 6. 将噪声乘以遮罩，只叠加在尾部！
    sdf += noise * trail_distortion * noise_mask;

    // 7. 视觉分层渲染 (白心青边)
    float core = smoothstep(core_intensity, -0.01, sdf + 0.05);
    float glow = smoothstep(glow_spread, -0.1, sdf);

    // 8. 颜色合成与极速脉动
    vec3 final_color = mix(aura_color.rgb, vec3(1.0), core);
    float pulse = 0.9 + 0.1 * sin(TIME * 30.0); // 极速微小闪烁，增加高能感
    float final_alpha = clamp(glow * aura_color.a * pulse, 0.0, 1.0);

    COLOR = vec4(final_color, final_alpha);
}