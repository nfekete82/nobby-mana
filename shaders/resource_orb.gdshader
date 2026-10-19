shader_type canvas_item;
render_mode unshaded;

uniform float amount : hint_range(0.0, 1.0) = 1.0;
uniform vec4 liquid : source_color = vec4(0.65, 0.14, 0.18, 1.0);
uniform vec4 light_liquid : source_color = vec4(0.88, 0.28, 0.29, 1.0);
uniform vec4 dark_liquid : source_color = vec4(0.38, 0.07, 0.13, 1.0);

void fragment() {
	// A functional 64px progress control, with hard pixel steps and flat shades.
	vec2 pixel = floor(UV * 64.0) + vec2(0.5) - vec2(32.0);
	float radius = length(pixel);
	vec4 color = vec4(0.0);
	if (radius < 31.0) {
		color = vec4(0.16, 0.21, 0.27, 1.0);
		if (radius < 29.0) {
			color = pixel.x + pixel.y < 0.0 ? vec4(0.82, 0.68, 0.40, 1.0) : vec4(0.43, 0.34, 0.24, 1.0);
		}
		if (radius < 26.0) {
			color = vec4(0.055, 0.075, 0.10, 1.0);
			float surface = 26.0 - clamp(amount, 0.0, 1.0) * 52.0;
			if (amount > 0.0 && pixel.y >= surface) {
				color = pixel.x + pixel.y < -6.0 ? light_liquid : liquid;
				if (pixel.x + pixel.y > 18.0) {
					color = dark_liquid;
				}
				if (pixel.y < surface + 2.0) {
					color = light_liquid;
				}
			}
		}
	}
	COLOR = color;
}
