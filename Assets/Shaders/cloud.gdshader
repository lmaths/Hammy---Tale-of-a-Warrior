shader_type canvas_item;

uniform float movement_speed = 0.5;

void fragment() {
	COLOR = texture(TEXTURE, vec2(UV.x + TIME * movement_speed, UV.y));
}
