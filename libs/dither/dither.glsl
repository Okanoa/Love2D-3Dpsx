uniform sampler2D bayer;
uniform int scale;


//24 bit color
#define RGB888 vec3(8,8,8)
//16 bit color
#define RGB565 vec3(5,6,5)
#define RGB664 vec3(6,6,4)
//8 bit color
#define RGB332 vec3(3,3,2)
#define RGB242 vec3(2,4,2)
#define RGB222 vec3(2,2,2)
#define RGB111 vec3(1,1,1)

vec3 dither(vec3 colo, vec3 bits, vec2 pixel)
{
    vec3 cmax = exp2(bits)-1.0;

    vec3 dithfactor = mod(colo, 1.0 / cmax) * cmax;
    float dithlevel = texture2D(bayer,(vec2(mod(pixel.x,8.0), mod(pixel.y,8.0)) / vec2(8,8))).r;

    vec3 cl = floor(colo * cmax)/cmax;
    vec3 ch = ceil(colo * cmax)/cmax;

    return mix(cl, ch, step(dithlevel, dithfactor));
    //vec3 n = ;
}

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 original = color * texture2D( tex, texture_coords );

    //if (original.rgb == vec3(0,0,0)) {
      //discard;
    //}

    vec3 col = dither(original.rgb, RGB565, screen_coords/scale);

    if (scale == 0) {
      col = original.rgb;
    }

    return vec4(col.rgb,original.a);
}
