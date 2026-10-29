shader_type canvas_item;
uniform bool reflected = false;
varying vec4 tint;

void vertex() {
 tint = COLOR;
}

void fragment() {
 vec4 pixel = texture(TEXTURE, UV);
 if (reflected) {
  float brightness = (pixel.r + pixel.g + pixel.b) / 3.0;
  pixel.rgb = mix(vec3(0.20, 0.65, 0.61), vec3(0.82, 1.0, 0.96), brightness);
 }
 COLOR = tint * pixel;
}
