//extern mat4 proj;

vec4 position(mat4 transform, vec4 vertex)
{
  return vertex * transform;
}
