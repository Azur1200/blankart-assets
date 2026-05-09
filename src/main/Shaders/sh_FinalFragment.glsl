// Final Post-Process fragment shader
// Runs during the drawing of the final OGL screen texture.
// This is not used for anything. Could be cool for modding tho

uniform sampler2D tex;

void main(void) {
    gl_FragColor = texture2D(tex, gl_TexCoord[0].st);
}
