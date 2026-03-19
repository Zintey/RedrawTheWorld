shader_type canvas_item;

// --- 自定义参数面板 ---
uniform vec4 filter_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); 
uniform float filter_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float brightness_limit : hint_range(0.0, 1.0) = 0.9;

void fragment() {
    // 获取原图像素
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 颜色混合逻辑
    vec3 mixed_rgb = mix(tex_color.rgb, filter_color.rgb, filter_intensity);
    
    // 限制亮度防止辉光刺眼
    vec3 safe_rgb = clamp(mixed_rgb, vec3(0.0), vec3(brightness_limit));
    
    // --- 核心修复：保持物体不透明 ---
    // 我们直接使用原图的透明度 tex_color.a
    // 这样无论你选什么颜色，物体的形状都会保持原来的实心状态
    float final_alpha = tex_color.a;
    
    COLOR = vec4(safe_rgb, final_alpha);
}