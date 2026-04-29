// Shader for the palette rendering postprocess step

uniform sampler2D tex;
uniform sampler3D palette_lookup_tex;
uniform sampler1D palette_tex;

void main(void) {
	vec4 texel = texture2D(tex, gl_TexCoord[0].st);
	float tex_pal_idx = texture3D(palette_lookup_tex, vec3((texel * 63.0 + 0.5) / 64.0))[0] * 255.0;
	float palette_coord = (tex_pal_idx + 0.5) / 256.0;
	vec4 final_color = texture1D(palette_tex, palette_coord);
	gl_FragColor = final_color;
}