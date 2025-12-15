shader_type canvas_item;

uniform float outline_size = 1.0;
uniform vec4 outline_color : source_color = vec4(0, 0, 0, 1);
uniform bool hit;
uniform vec4 hit_color : source_color = vec4(1, 1, 1, 1.0);

void fragment() {
	if(hit)
	{
		if(COLOR.a > 0.0)
		{
			COLOR = mix(COLOR, hit_color, 0.8);
		}
	}


    // 获取贴图大小（Godot 4 需要这样写）
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    vec2 pixel = outline_size / tex_size;

    // 周围 8 方向采样 alpha
    float alpha =
        texture(TEXTURE, UV + vec2(pixel.x, 0)).a +
        texture(TEXTURE, UV + vec2(-pixel.x, 0)).a +
        texture(TEXTURE, UV + vec2(0, pixel.y)).a +
        texture(TEXTURE, UV + vec2(0, -pixel.y)).a +
        texture(TEXTURE, UV + vec2(pixel.x, pixel.y)).a +
        texture(TEXTURE, UV + vec2(-pixel.x, pixel.y)).a +
        texture(TEXTURE, UV + vec2(pixel.x, -pixel.y)).a +
        texture(TEXTURE, UV + vec2(-pixel.x, -pixel.y)).a;
    if (COLOR.a <= 0.0 && alpha > 0.0)
        COLOR = outline_color;
}
