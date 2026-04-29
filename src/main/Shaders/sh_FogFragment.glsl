//
// Fog block shader
//
// Alpha of the planes themselves are still slightly off -- see HWR_FogBlockAlpha
//

// The floor fudges are used, but should the wall fudges be used instead? or something inbetween?
// or separate values for floors and walls? (need to change more than this shader for that)

#version 120

#define STARTMAP_FUDGE 1.06
#define SCALE_FUDGE 1.15

uniform vec4 tint_color;
uniform vec4 fade_color;
uniform float lighting;
uniform float fade_start;
uniform float fade_end;
uniform bool newfade;
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
	float endResolutionx = scr_resolution.x;
	float endResolutiony = scr_resolution.y;
	
	if (scr_resolution.x > 1280.0) {
		endResolutionx = scr_resolution.x * 0.5;
	}
	
	if (scr_resolution.y > 720.0) {
		endResolutiony = scr_resolution.y * 0.5;
	}
	
	float zFactor = clamp((z - 192.0) / (6144.0 - 192.0), 0.0, 1.0);
	int scaleFactor = int(mix(1.0, 8.0, zFactor));
	endResolutionx = endResolutionx * scaleFactor;
	endResolutiony = endResolutiony * scaleFactor;
	vec2 normalizedPosition = position * vec2(endResolutionx / scr_resolution.x, endResolutiony / scr_resolution.y);
	int x = int(mod(normalizedPosition.x, 4.0));
	int y = int(mod(normalizedPosition.y, 4.0));
	float bayerMatrix[4*4] = float[4*4](
	0.0, 8.0, 2.0, 10.0,
	12.0, 4.0, 14.0, 6.0,
	3.0, 11.0, 1.0, 9.0,
	15.0, 7.0, 13.0, 5.0
	);
	
#ifdef SRB2_PALETTE_RENDERING
	float threshold = (1.0 - pow(zFactor, 2.0)) * (bayerMatrix[y*4 + x] / 11.0);
#else
	float threshold = (1.0 - pow(zFactor, 2.0)) * (bayerMatrix[y*4 + x] / 16.0);
#endif
	return mix(baseValue + threshold - 0.5 / 16.0, baseValue, zFactor);
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
void main(void) {
	vec4 base_color = gl_Color;
	vec4 final_color = base_color;
	float brightmap_mix = 0.0;
	float light_gain = 0.0;
	float final_lighting = lighting + light_gain;
	
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
	
	gl_FragColor = final_color;
}