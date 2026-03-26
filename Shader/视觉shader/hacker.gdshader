shader_type canvas_item;

// --- Uniforms (在编辑器右侧面板可直接调的参数) ---
uniform vec4 base_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // 黑色背景
uniform vec4 matrix_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // 绿色代码 (改这里换主题色！)
uniform float speed : hint_range(0.1, 5.0) = 1.0; // 代码下落速度
uniform float density : hint_range(0.1, 10.0) = 5.0; // 代码列的密度
uniform float brightness : hint_range(1.0, 5.0) = 2.0; // 代码发光强度

// --- 生成随机数的函数 ---
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// --- 生成像素风“伪字符” ---
float pseudo_char(vec2 uv) {
    vec2 grid_uv = fract(uv * 10.0 + random(vec2(floor(uv.y))) * 0.1);
    float val = random(floor(uv * 10.0));

    if (val > 0.5) {
        return step(0.3, grid_uv.x) * step(0.3, grid_uv.y);
    } else {
        return step(0.6, grid_uv.x) * step(0.6, grid_uv.y) * 0.5;
    }
}

void fragment() {
    // 1. 获取基础 UV，并进行横向缩放控制密度
    vec2 scaled_uv = UV * vec2(density * 10.0, 1.0);

    // 2. 切割成列，让每一列有不同的速度和初始位置
    float col_id = floor(scaled_uv.x);
    float col_offset = random(vec2(col_id)) * 10.0;
    float col_speed_mod = random(vec2(col_id, 1.0)) * 0.5 + 0.5;

    // 3. 计算随时间往下掉的坐标
    float fall_time = (TIME * speed * col_speed_mod) + col_offset;
    float y_pos = fract(scaled_uv.y - fall_time);

    // 4. 亮度控制 (修正了这里的 pow)
    float head_brightness = pow(y_pos, 10.0);
    float tail_brightness = pow(y_pos, 2.0) * 0.5;

    // 5. 结合字符图案和亮度
    float char_val = pseudo_char(scaled_uv);
    float final_brightness = (head_brightness + tail_brightness) * char_val * brightness;

    // 6. 混合背景底色和矩阵线条色
    vec3 final_color = mix(base_color.rgb, matrix_color.rgb, final_brightness);

    // 7. 输出给屏幕
    COLOR = vec4(final_color, base_color.a);
}