// reinterpretation of sprite lighting for models
// it's a combination of how it works for normal sprites & papersprites

uniform float lighting;
uniform vec3 light_dir;
uniform float light_contrast;
uniform float light_backlight;

void main()
{
	gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
	float light = lighting;
	
	if (length(light_dir) > 0.000001) {
		mat4 m4 = gl_ProjectionMatrix * gl_ModelViewMatrix;
		mat3 m3 = mat3( m4[0].xyz, m4[1].xyz, m4[2].xyz );
		float extralight = -dot(normalize(gl_Normal * m3), normalize(light_dir));
		extralight *= light_contrast - light_backlight;
		extralight *= lighting / 255.0;
		light += extralight * 2.5;
	}
	
	light = clamp(light / 255.0, 0.0, 1.0);
	gl_FrontColor = vec4(light, light, light, 1.0);
	gl_TexCoord[0].xy = gl_MultiTexCoord0.xy;
	gl_ClipVertex = gl_ModelViewMatrix * gl_Vertex;
}
