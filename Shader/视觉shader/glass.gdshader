shader_type canvas_item;

// 屏幕纹理
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// 关键：法线贴图，决定玻璃表面的物理凹凸（可以用Godot自带的NoiseTexture2D生成NormalMap）
uniform sampler2D normal_map : hint_normal;
// 表面划痕或脏污
uniform sampler2D dirt_texture : source_color;

uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float specular_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float glass_tint_opacity : hint_range(0.0, 1.0) = 0.1;
uniform vec4 glass_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);

void fragment() {
    // 1. 获取法线信息
    vec3 normal_data = texture(normal_map, UV).rgb * 2.0 - 1.0;
    
    // 2. 利用法线对 SCREEN_UV 进行偏移（模拟折射）
    // 加上 SCREEN_UV 随相机移动的特性，折射感会非常强
    vec2 refracted_uv = SCREEN_UV + normal_data.xy * distortion_strength;
    
    // 3. 采样背景（带模糊）
    // 注意：lod 参数在 Godot 4.x 中需要开启 mipmap 才有效果
    vec4 screen_color = textureLod(screen_texture, refracted_uv, blur_amount);
    
    // 4. 模拟简单的 2D 高光 (假定光从实验室上方照下来)
    float spec = max(0.0, dot(normal_data, vec3(0.0, -1.0, 1.0)));
    spec = pow(spec, 32.0) * specular_intensity;
    
    // 5. 混合划痕和脏污
    vec4 dirt = texture(dirt_texture, UV);
    
    // 最终颜色合成
    vec4 final_color = mix(screen_color, glass_color, glass_tint_opacity);
    final_color.rgb += spec; // 叠加高光
    final_color.rgb += dirt.rgb * 0.2; // 叠加淡淡的划痕
    
    COLOR = final_color;
}