shader_type canvas_item;

const float speed = 0.1;

void fragment() {
	vec2 new_uv = vec2(UV.x, UV.y - TIME * speed);
	COLOR = texture(TEXTURE, new_uv);
}