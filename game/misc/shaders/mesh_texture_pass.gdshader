shader_type spatial;

uniform sampler2D texture_albedo : source_color;
uniform vec2 area_size = vec2(400, 400);
uniform vec3 side_face_color : source_color = vec3(0.12, 0.06, 0.02); // Brown color for side faces

// for red tint
uniform vec4 tint: source_color = vec4(0,0,0,0);

varying vec3 baked_world_position;
varying vec3 normal;

void vertex() {
	// Pass the baked world position and normal to the fragment shader
	baked_world_position = VERTEX.xyz;
	baked_world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	normal = NORMAL;
}

void fragment() {
	// Determine if this fragment belongs to the top face
	if (abs(normal.y - 1.0) < 0.01) {
		// Calculate texture coordinates for the top face
		vec2 texture_pos = baked_world_position.xz / area_size * 0.5 + 0.5;
		vec4 tex_color = texture(texture_albedo, texture_pos);
		ALBEDO = tex_color.rgb;
		ALPHA = tex_color.a;
	} else {
		// Use a constant color for the side faces
		ALBEDO = side_face_color;
		ALPHA = 1.0;
	}
	ALBEDO += pow(abs(sin(TIME)),2) * tint.rgb * tint.a;
}



//shader_type spatial;
//
//// render_mode cull_back;
//
//uniform sampler2D texture_albedo : source_color;
//uniform vec2 area_size = vec2(400, 400);
//
//varying vec3 world_position;
//
//void vertex() {
    //world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
//}
//
//void fragment() {
	//// world_pos: (-area_size, -area_size) to (area_size, area_size_
	//// texture_pos: (0,0) to (1,1)
	//// vec2 world_position = NODE_POSITION_WORLD.xy + UV;
	 //
	//// Map from (-area_size, area_size) to (0, 1)
	//vec2 texture_pos = world_position.xz / area_size * 0.5 + 0.5;
	//vec4 tex_color = texture(texture_albedo, texture_pos);
	//ALBEDO = tex_color.rgb;
	//ALPHA = tex_color.a;
//}
