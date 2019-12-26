
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 texcolor = Texel(tex, texture_coords);

    return vec4(mix(vec3(0,0,0),texcolor.rgb, color.r).rgb,texcolor.a);
}
