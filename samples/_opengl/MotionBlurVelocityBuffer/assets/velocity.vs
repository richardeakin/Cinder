#version 330 core

in vec4 ciPosition;
in vec4 ciColor;
in vec3 ciNormal;

uniform mat4 uModelMatrix;
uniform mat4 uPrevModelMatrix;
uniform mat4 uViewProjection;
uniform mat4 uPrevViewProjection;

smooth out vec4 vPosition;
smooth out vec4 vPrevPosition;
smooth out vec4 vColor;
smooth out vec3 vNormal;

void main(void) {
  vPosition = uViewProjection * uModelMatrix * ciPosition;
  vPrevPosition = uPrevViewProjection * uPrevModelMatrix * ciPosition;

  vColor = ciColor;

  // Let's assume the model matrix is homogenous, so we can
  // use it to bring our normal to world space.
  vNormal = vec3( uModelMatrix * vec4( ciNormal, 0.0 ) );
  
  gl_Position = vPosition;
}
