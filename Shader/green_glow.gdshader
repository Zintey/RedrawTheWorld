shader_type canvas_item;

// --- 抠绿幕参数 (这部分和上一版相同) ---
uniform vec4 key_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // 默认扣纯绿
uniform float tolerance : hint_range(0.0, 1.0) = 0.2; // 容差
uniform float smoothing : hint_range(0.0, 1.0) = 0.05; // 边缘平滑

// --- 【新增】赛博朋克发光参数 ---
// 用于提升亮色像素的强度。这是一个乘数，大于 1.0 的值将被 WorldEnvironment 捕捉并产生辉光。
// 通常在 2.0 - 50.0 之间效果最好。
uniform float emission_strength : hint_range(1.0, 100.0) = 5.0; 
// 用于设定亮色的阈值。只有比这个亮的像素才会被作为“发光区域”提升亮度。
uniform float brightness_threshold : hint_range(0.0, 1.0) = 0.8; 
// 这是一个偏色，如果你想让所有光晕都偏向某种霓虹色（比如粉色）
uniform vec4 glow_color : source_color = vec4(1.0); // 默认白色，即不改变亮色原色

void fragment() {
    // 1. 获取当前像素的原始图片颜色
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 2. 计算绿幕差异和透明度 (这部分没变)
    float diff = distance(tex_color.rgb, key_color.rgb);
    float alpha_factor = smoothstep(tolerance, tolerance + smoothing, diff);
    
    // 3. 【核心新增】识别亮色并提升亮度以产生辉光
    // 只有非抠绿区域（物品主体）才需要计算发光
    vec3 final_color_rgb;
    if (alpha_factor > 0.01) { 
        // 计算像素的亮度 (Luminance)。这是一个标准的灰度转换公式。
        float brightness = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
        
        // 识别“亮色像素”
        // 我们用 smoothstep 来平滑地让只有在 threshold 附近的像素才发光。
        // 如果亮度高于阈值，`is_bright` 会接近 1.0。
        float is_bright = smoothstep(brightness_threshold, brightness_threshold + 0.05, brightness);
        
        // 【关键修复】将图片原色乘以内置 COLOR (包含 Modulate 颜色)，
        // 然后对于识别出的“亮色”，大幅提升其亮度值，使其产生自发光效果。
        // 注意：我们把 tex_color * COLOR 作为基础，确保你依然可以通过 Modulate 改变建筑的颜色
        vec3 base_color = tex_color.rgb * COLOR.rgb;
        
        // 我们只提升识别出的亮色部分的亮度
        // 最终亮度 = 基础颜色 * (1.0 + 亮度识别 * 亮度提升强度 * 霓虹色偏)
        // 这里的 `mix` 或者 `max` 确保我们只提升而不降低。
        final_color_rgb = base_color + (is_bright * emission_strength * glow_color.rgb * base_color);

    } else {
        // 抠绿区域不需要发光，直接设为 0
        final_color_rgb = vec3(0.0);
    }
    
    // 4. 【关键修复】输出最终颜色，输出透明度
    // 最终 COLOR 的 Alpha 通道也需要应用我们计算出的 alpha_factor 抠图效果
    COLOR = vec4(final_color_rgb, tex_color.a * COLOR.a * alpha_factor);
}