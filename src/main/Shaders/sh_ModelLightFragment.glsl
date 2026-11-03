// same as sh_WallFragment but multiplies results with the lighting value from the
// accompanying vertex shader (stored in gl_Color)

#define STARTMAP_FUDGE 1.05
#define SCALE_FUDGE 2.2

uniform vec2 scr_resolution;

float R_DoomColormap(float light, float z, vec2 position)
{
	float lightnum = clamp(light / 17.0, 0.0, 15.0);
	float lightz = clamp(z / 16.0, 0.0, 127.0);
	float startmap = (15.0 - lightnum) * 4.0;
	float scale = 160.0 / (lightz + 1.0);
	float cap = (155.0 - light) * 0.26;
#ifdef SRB2_LIGHT_DITHER
	float baseValue = max(startmap * STARTMAP_FUDGE - scale * 0.5 * SCALE_FUDGE, cap);
	float patscale = min(scr_resolution.x / 1280.0, scr_resolution.y / 720.0);
	patscale = max(floor(patscale + 0.5), 1.0);
	patscale = 1.0 / patscale;
	ivec2 p = ivec2(mod(floor(position * patscale), 4.0));
	float depthfactor = clamp((z - 192.0) / (6144.0 - 192.0), 0.0, 1.0);
	float bayerMatrix[4*4] = float[4*4](
		0.0, 8.0, 2.0, 10.0,
		12.0, 4.0, 14.0, 6.0,
		3.0, 11.0, 1.0, 9.0,
		15.0, 7.0, 13.0, 5.0
	);
	float threshold = 16.0;

#ifdef SRB2_PALETTE_RENDERING
	threshold = 11.0;
#endif

	threshold = (1.0 - pow(depthfactor, 2.0)) * (bayerMatrix[p.y*4 + p.x] / threshold);
	return mix(baseValue + threshold - 0.5 / 16.0, baseValue, depthfactor);
#else
	return max(startmap * STARTMAP_FUDGE - scale * 0.5 * SCALE_FUDGE, cap);
#endif
}

float R_DoomLightingEquation(float light)
{
	float z = gl_FragCoord.z / gl_FragCoord.w;
	float colormap = floor(R_DoomColormap(light, z, gl_FragCoord.xy)) + 0.5;
	return clamp(colormap, 0.0, 31.0) / 32.0;
}

#ifdef SRB2_PALETTE_RENDERING
	uniform sampler2D tex;
	uniform sampler2D brightmap;
	uniform sampler3D palette_lookup_tex;
	uniform sampler2D lighttable_tex;
	uniform vec4 poly_color;
	uniform float lighting;
	
	void main(void) {
		vec4 final_color;
		vec4 texel = texture2D(tex, gl_TexCoord[0].st);
	#ifdef SRB2_MODEL_LIGHTING
		texel *= gl_Color;
	#endif
		float brightmap_mix = floor(texture2D(brightmap, gl_TexCoord[0].st).r);
		if (brightmap_mix > 0.5) {
			final_color.rgb = texel.rgb;
		} else {
			float final_lighting = gl_Color.r * 255.0;
			float tex_pal_idx = texture3D(palette_lookup_tex, vec3((texel * 63.0 + 0.5) / 64.0))[0] * 255.0;
			float z = gl_FragCoord.z / gl_FragCoord.w;
			float light_y = clamp(floor(R_DoomColormap(final_lighting, z, gl_FragCoord.xy)), 0.0, 31.0);
			vec2 lighttable_coord = vec2((tex_pal_idx + 0.5) / 256.0, (light_y + 0.5) / 32.0);
			final_color = texture2D(lighttable_tex, lighttable_coord);
		}
		final_color.a = texel.a * poly_color.a;
		gl_FragColor = final_color;
	}
#else
	uniform sampler2D tex;
	uniform sampler2D brightmap;
	uniform vec4 poly_color;
	uniform vec4 tint_color;
	uniform vec4 fade_color;
	uniform float fade_start;
	uniform float fade_end;
	uniform bool newfade;

	void main(void) {
		vec4 texel = texture2D(tex, gl_TexCoord[0].st);
		vec4 base_color = texel * poly_color;
		vec4 final_color = base_color;
		float final_lighting = gl_Color.r * 255.0;
		float brightmap_mix = floor(texture2D(brightmap, gl_TexCoord[0].st).r);
		float light_gain = (255.0 - final_lighting) * brightmap_mix;
		final_lighting += light_gain;
		
		if (mix(tint_color.a, 0.0, brightmap_mix) > 0.0) {
			float color_bright = sqrt((base_color.r * base_color.r) + (base_color.g * base_color.g) + (base_color.b * base_color.b));
			float strength = sqrt(mix(9.0 * tint_color.a, 0.0, brightmap_mix));
			final_color.r = clamp((color_bright * (tint_color.r * strength)) + (base_color.r * (1.0 - strength)), 0.0, 1.0);
			final_color.g = clamp((color_bright * (tint_color.g * strength)) + (base_color.g * (1.0 - strength)), 0.0, 1.0);
			final_color.b = clamp((color_bright * (tint_color.b * strength)) + (base_color.b * (1.0 - strength)), 0.0, 1.0);
		}
		
		float darkness = R_DoomLightingEquation(final_lighting);
		
		if (fade_start > 0.0 || fade_end < 31.0) {
			float fs = fade_start / 31.0;
			float fe = fade_end / 31.0;
			float fd = fe - fs;
			darkness = clamp((darkness - fs) * (1.0 / fd), 0.0, 1.0);
		}
		
		if (newfade)
		{
			float colorBrightness = sqrt((final_color.r * final_color.r) + (final_color.g * final_color.g) + (final_color.b * final_color.b));
			float fogBrightness = sqrt((fade_color.r * fade_color.r) + (fade_color.g * fade_color.g) + (fade_color.b * fade_color.b));
			float colorIntensity = 0.0;
			if (colorBrightness < fogBrightness) {
				colorIntensity = 1.0 - min(final_color.r, min(final_color.g, final_color.b));
				colorIntensity = abs(colorIntensity - (1.0 - max(fade_color.r, max(fade_color.g, fade_color.b))));
			} else {
				colorIntensity = max(final_color.r, max(final_color.g, final_color.b));
				colorIntensity = abs(colorIntensity - min(fade_color.r, min(fade_color.g, fade_color.b)));
			}
			
			colorIntensity *= darkness;
			colorIntensity *= fade_color.a * 10.0;
			
			if (abs(final_color.r - fade_color.r) <= colorIntensity) {
				final_color.r = fade_color.r;
			} else if (final_color.r < fade_color.r) {
				final_color.r += colorIntensity;
			} else {
				final_color.r -= colorIntensity;
			}
			
			if (abs(final_color.g - fade_color.g) <= colorIntensity) {
				final_color.g = fade_color.g;
			} else if (final_color.g < fade_color.g) {
				final_color.g += colorIntensity;
			} else {
				final_color.g -= colorIntensity;
			}
			
			if (abs(final_color.b - fade_color.b) <= colorIntensity) {
				final_color.b = fade_color.b;
			} else if (final_color.b < fade_color.b) {
				final_color.b += colorIntensity;
			} else {
				final_color.b -= colorIntensity;
			}
		} else {
			final_color = mix(final_color, fade_color, darkness);
		}
		
		final_color.a = texel.a * poly_color.a;
		gl_FragColor = final_color;
	}
#endif
