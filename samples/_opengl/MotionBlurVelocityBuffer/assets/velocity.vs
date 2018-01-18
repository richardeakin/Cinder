#version 330 core

in vec4 ciPosition;
in vec4 ciColor;
in vec3 ciNormal;
uniform mat3 ciNormalMatrix;

uniform mat4 uModelMatrix;
uniform mat4 uPrevModelMatrix;
uniform mat4 uViewProjection;
uniform mat4 uPrevViewProjection;

out vec4 vPosition;
out vec4 vPrevPosition;
out vec4 vColor;
out vec3 vNormal;

void main(void)
{
  vPosition = uViewProjection * uModelMatrix * ciPosition;
  vPrevPosition = uPrevViewProjection * uPrevModelMatrix * ciPosition;

  vColor = ciColor;
  vNormal = ciNormalMatrix * ciNormal;
  
  gl_Position = vPosition;
}
