// Applies a palettized colormap fade to tex

uniform sampler2D tex;
uniform float lighting;
uniform sampler3D palette_lookup_tex;
uniform sampler2D lighttable_tex;

void main(void) {
	vec4 texel = texture2D(tex, gl_TexCoord[0].st);
	float tex_pal_idx = texture3D(palette_lookup_tex, vec3((texel * 63.0 + 0.5) / 64.0))[0] * 255.0;
	vec2 lighttable_coord = vec2((tex_pal_idx + 0.5) / 256.0, (lighting + 0.5) / 32.0);
	gl_FragColor = texture2D(lighttable_tex, lighttable_coord);
}
