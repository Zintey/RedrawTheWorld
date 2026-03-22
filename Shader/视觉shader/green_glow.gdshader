shader_type canvas_item;

// --- 抠绿幕参数 ---
uniform vec4 key_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); 
uniform float tolerance : hint_range(0.0, 1.0) = 0.2; 
uniform float smoothing : hint_range(0.0, 1.0) = 0.05; 

// --- 赛博朋克发光参数 ---
// 基础建筑暗部偏色（建议选一个中等亮度的深青蓝色，用于提供夜间氛围）
uniform vec4 building_night_tint : source_color = vec4(0.1, 0.1, 0.2, 1.0);
// 基础环境亮度：控制建筑墙面细节的可见度 (中等值: 0.2-0.5)
uniform float ambient_intensity : hint_range(0.0, 1.0) = 0.35; 

// 霓虹发光参数 (这些值必须够大，配合Glow)
uniform float emission_strength : hint_range(1.0, 100.0) = 15.0; 
uniform float brightness_threshold : hint_range(0.0, 1.0) = 0.8; 
uniform vec4 glow_color : source_color = vec4(1.0); 

// --- 【核心优化：整体亮度推升】 ---
// 最终整体增益：用于直接推升所有可见部分的亮度 (1.0 为无增益)
uniform float final_gain : hint_range(0.0, 5.0) = 1.3; 

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 1. 抠图逻辑
    float diff = distance(tex_color.rgb, key_color.rgb);
    float alpha_factor = smoothstep(tolerance, tolerance + smoothing, diff);
    
    // 2. 核心优化：亮度分层逻辑
    // A. 提取基础墙面和纹理细节，并应用 Modulate (COLOR)
    vec3 base_color = tex_color.rgb * COLOR.rgb;
    
    // B. 计算像素的相对亮度，用于识别窗户
    float brightness = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    
    // C. 识别发光区域 (霓虹灯)
    float is_bright = smoothstep(brightness_threshold, brightness_threshold + 0.05, brightness);
    
    // D. 核心修改：分层计算最终颜色
    vec3 final_color_rgb;
    
    // 只有非抠绿区域才进行亮度计算
    if (alpha_factor > 0.01) {
        // 墙面层：我们将基础颜色乘以环境亮度，并叠加夜间偏色
        // 这里我们不再用 mix，而是直接将环境光叠加在墙面上，确保细节可见
        vec3 dark_part = base_color * ambient_intensity + building_night_tint.rgb * ambient_intensity;

        // 霓虹层：只有极亮的部分才产生自发光
        vec3 neon_part = (base_color + is_bright * emission_strength * glow_color.rgb * base_color);

        // 分层混合：墙面和霓虹灯
        // 我们用 max 混合，确保墙面即使被霓虹灯照亮，细节也是可见的
        final_color_rgb = max(dark_part, neon_part);
        
        // E. 【重点修复】最后，应用整体亮度推升。
        // 这个参数能立刻把场景亮度整体“提起来”，而不仅仅是让发光体变亮。
        final_color_rgb *= final_gain;

    } else {
        final_color_rgb = vec3(0.0);
    }
    
    // 3. 输出最终颜色
    COLOR = vec4(final_color_rgb, tex_color.a * COLOR.a * alpha_factor);
}