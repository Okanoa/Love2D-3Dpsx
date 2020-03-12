uniform int blend_mode;
uniform bool finalpass;
uniform sampler2D underlay;
uniform sampler2D overlay;

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 d = Texel(underlay, texture_coords);

    vec4 s = Texel(overlay, texture_coords);

    vec3 retcolor = vec3(0,0,0);

  if (s.a != 1 || s.a != 0) {
    if (blend_mode == 0) {
      retcolor = vec3(d+s)/2;
    }

    if (blend_mode == 1) {
      retcolor = vec3(d+s);
    }

    if (blend_mode == 2) {
      retcolor = vec3(d-s);
    }

    if (blend_mode == 3) {
        retcolor = vec3(d+(s/4));
    }
  }

  if (finalpass && vec3(0,0,0) == s.rgb) {
    retcolor.rgb = d.rgb;
  }

  if (s.a == 0 && !finalpass) {
    retcolor = d.rgb;
  }

  if (s.a == 1 && !finalpass) {
    retcolor = s.rgb;
  }

  return vec4(retcolor.rgb,1);
}
