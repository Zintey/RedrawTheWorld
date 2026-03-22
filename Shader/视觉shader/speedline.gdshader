shader_type canvas_item;

// --- 独立控制台 ---
uniform vec4 line_color : source_color = vec4(0.0, 1.0, 1.0, 0.4);

// 1. 密度 (Density): 屏幕横向被切成多少条隐形的“轨道”。
// 轨道越多，同屏能容纳的线最多；但不影响线的粗细。
uniform float track_count : hint_range(10.0, 800.0) = 200.0;

// 2. 粗细 (Thickness): 线条在自己轨道里占据的比例。
// 设为 0.1，就是极细的线；设为 1.0，就会填满轨道变成粗条。这完全独立于密度！
uniform float line_thickness : hint_range(0.001, 1.0) = 0.05;

// 3. 随机分布概率 (Sparsity): 决定屏幕有多空旷。
// 设为 0.02，代表屏幕上 98% 的地方都是空的，只有极少数地方随机刷出线。彻底告别“满屏瞎眼”。
uniform float spawn_chance : hint_range(0.001, 1.0) = 0.03;

// 4. 线条长度 (Length): 控制水平方向的切割。数值越小，线条越长。
uniform float segment_length : hint_range(0.5, 20.0) = 3.0;

// 5. 移动速度 (Speed)
uniform float speed : hint_range(0.1, 50.0) = 15.0;


// 纯粹的随机函数
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;

    // --- 1. Y轴：密度与粗细彻底分离 ---
    // 计算当前属于第几条隐形轨道
    float track_id = floor(uv.y * track_count);
    // 计算在当前轨道内的局部 Y 坐标 (0.0 到 1.0)
    float track_uv_y = fract(uv.y * track_count);

    // 只在轨道的正中心，画出你指定粗细的线。绝对不会变成粗方块！
    float half_thickness = line_thickness * 0.5;
    float is_line_y = step(0.5 - half_thickness, track_uv_y) * step(track_uv_y, 0.5 + half_thickness);

    // --- 2. X轴：水平分段与高速滚动 ---
    // 每一行给一个随机的初始偏移，防止线条像斑马线一样对齐
    float x_offset = random(vec2(track_id, 0.0)) * 100.0;

    // 场景向前，线条向后滚动
    float scrolled_x = uv.x * segment_length - TIME * speed + x_offset;
    float segment_id = floor(scrolled_x);
    float segment_uv_x = fract(scrolled_x);

    // --- 3. 真正的随机散布 ---
    // 掷骰子：这条轨道的这一段，到底要不要画线？
    // 配合 spawn_chance 极低的概率，实现稀疏的随机分布
    float is_active = step(1.0 - spawn_chance, random(vec2(track_id, segment_id)));

    // --- 4. 消除矩形感 (拖尾渐隐) ---
    // 把硬邦邦的矩形两端，做成类似流星或残影的渐隐效果
    // 头部锐利一点，尾部拖长一点
    float fade_x = smoothstep(0.0, 0.05, segment_uv_x) * smoothstep(1.0, 0.4, segment_uv_x);

    // --- 输出 ---
    // 只有在细线范围内、被随机选中、且带渐隐效果的才显示
    float final_mask = is_line_y * is_active * fade_x;

    COLOR = line_color;
    COLOR.a *= final_mask;
}