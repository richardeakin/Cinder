#version 330 core

smooth in vec4 vPosition;
smooth in vec4 vPrevPosition;
smooth in vec4 vColor;
smooth in vec3 vNormal;

layout (location = 0) out vec4 fColor;
layout (location = 1) out vec4 fVelocity;

void main(void)
{
	// Place each position in range [0.0,1.0].
	vec2 a = (vPosition.xy / vPosition.w) * 0.5 + 0.5;
	vec2 b = (vPrevPosition.xy / vPrevPosition.w) * 0.5 + 0.5;

	// Store velocity in range [-1.0,1.0].
	// Observed strange behavior on OSX+AMD when outputting an xy vec2.
	// Using vec4 and writing 1.0 to unused channels fixes the issue.
	fVelocity = vec4(a - b, 1.0, 1.0);

	// Perform directional lighting on the objects.
	const vec3 L = vec3( 0.5, 1, 1 );
	float lambert = max( 0.0, dot( normalize( vNormal ), normalize( L ) ) );
	fColor = vec4( vColor.rgb * lambert + vColor.rgb * 0.1, 1.0 );
}