#version 330 core

uniform sampler2D uTex0;

smooth in vec2 vTexCoord;

out vec4 fColor;


void main()
{
  vec2 vel = texture( uTex0, vTexCoord ).xy;

  const float velScale = 8.0;
  const float velThreshold = 0.01;

  vec4 color = vec4( 0.08, 0.08, 0.08, 1.0 );
  
  if( vel.x > velThreshold )
  	color.r += vel.x * velScale;
  else if( vel.x < - velThreshold )
  	color.g += - vel.x * velScale;
  
  if( vel.y > velThreshold )
  	color.b += vel.y * velScale;
  else if( vel.y < - velThreshold )
  	color.rg += - vel.y * velScale;  	

  fColor = color;
}
