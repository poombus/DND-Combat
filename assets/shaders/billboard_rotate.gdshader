shader_type spatial;

uniform sampler2D texture2D;
uniform float size = 1;
uniform float angle = 0;

const float simple_pi = 3.14159265359;
 
varying vec2 tex_position;

mat2 rotate2d(float _angle){
	return mat2(vec2(cos(_angle),sin(_angle)),
				vec2(sin(_angle),-cos(_angle)));
}

void fragment () {
	tex_position = VERTEX.xy / size / 2.0 + 0.5;
	tex_position -= vec2(0.5);
	tex_position = rotate2d(angle) * tex_position; //in radians
//	tex_position = rotate2d(angle / 180.0 * PI) * tex_position; //in degrees
	tex_position += vec2(0.5);
	
	ALBEDO = texture(texture2D, tex_position).xyz;
}