shader_type canvas_item;
varying vec4 tint;
void vertex() {
	tint = COLOR;
}
void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	// This pack sheet has two opaque colours. Keep the darker ripple marks only.
	pixel.a *= 1.0-step(0.8, pixel.g);
	COLOR = pixel*tint;
}
