//
// Sky fragment shader
// Modulates poly_color with gl_Color
//

uniform sampler2D tex;
uniform vec4 poly_color;

void main(void) {
	gl_FragColor = texture2D(tex, gl_TexCoord[0].st) * gl_Color * poly_color;
}