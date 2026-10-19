shader_type canvas_item;
void fragment() {
	vec2 drift = vec2(0.0, floor(TIME * 5.0) / 64.0);
	COLOR = texture(TEXTURE, fract(UV + drift));
}
