varying vec4 vPosition;
//varying float depth;
varying float blend;

#ifdef VERTEX
    attribute float BlendMode;

    vec4 position(mat4 transform_projection, vec4 vertex_position) {
        vPosition = transform_projection * vertex_position;

        blend = int(BlendMode);
        //depth = vertex_position.z;

        return vPosition;
    }
#endif

#ifdef PIXEL
  vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
  {
      float colorarry[6];

      colorarry[0] = 0;
      colorarry[1] = 1/5;
      colorarry[2] = 2/5;
      colorarry[3] = 3/5;
      colorarry[4] = 4/5;
      colorarry[5] = 1;

      vec3 colormul = vec3(1,1,1);

      texture_coords.x = floor(texture_coords.x)/1024;
      texture_coords.y = floor(texture_coords.y)/512;

      vec4 texcolor = Texel(tex, texture_coords);

      //bm formula = res.r = dst.r * (1 - src.a) + src.r

      if(blend==0) {
        texcolor=vec4(texcolor.rgb,floor(texcolor.a));
      } /*else if(blend==1) {
        texcolor=vec4(texcolor.rgb,0); //add
      } else if(blend==2) {
        texcolor=vec4(-texcolor.rgb,0); //sub
      } else if(blend==3) {
       texcolor=vec4(texcolor.rgb/4,0); //a+(b/4)
      } else if(blend==4) {
       texcolor=vec4(texcolor.rgb*.5,.5); //a+(b/4)
      }*/

      vec3 fogcol = vec3(0,0,0);

      return vec4( mix(fogcol, texcolor.rgb*color.rgb, color.a).rgb, texcolor.a );

  }
#endif
