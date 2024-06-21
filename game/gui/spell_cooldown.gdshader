shader_type canvas_item;

uniform float cooldown = 5.0;
uniform float current_cooldown = 0.0;

uniform bool is_atlas;

void vertex() {
}

void fragment() {
	// float current_cooldown = mod(-TIME, cooldown);
	vec4 tex_color = texture(TEXTURE, UV);
	
	if (current_cooldown > 0.0) {
		// Grayscale the atlas texture
		if (is_atlas){
			float mean = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
			mean *= 0.3; // make darker
			tex_color = vec4(mean, mean, mean, 0.8);
		} else { // Radially darken the overlay
			// dark, almost opaque gray
			tex_color = vec4(0.05, 0.05, 0.05, 0.9);
			
			float percentage = current_cooldown / cooldown;
			float angle = percentage * 2.0 * PI;
			
			vec2 center = vec2(0.5, 0.5); // Center of the texture
			vec2 dir = UV - center;
			float dist = length(dir);
			// atan2 to get angle in radians (0 to 2π)
			float current_angle = -atan(dir.y, dir.x);
			
			current_angle = mod(current_angle - PI/2.0, 2.0 * PI);
			
			if (current_angle > angle) {
				tex_color.a = 0.0;
			}
		}
	} else {
		if (!is_atlas){
			tex_color.a = 0.0;
		}
	}
	
	COLOR = tex_color;
}
