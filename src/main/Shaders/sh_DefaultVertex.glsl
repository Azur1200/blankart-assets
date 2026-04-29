//
// Generic vertex shader
//

void main()
{
	gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
	gl_FrontColor = gl_Color;
	gl_TexCoord[0].xy = gl_MultiTexCoord0.xy;
	gl_ClipVertex = gl_ModelViewMatrix * gl_Vertex;
}