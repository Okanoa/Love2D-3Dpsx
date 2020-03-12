function Matrix_MultiplyVector(matrix, vector)
  local o = {x = 0, y = 0, z = 0, w = 1};
  local i = {x = vector[1], y = vector[2], z = vector[3]}
  local m = matrix

  o.x = i.x * m[1][1] + i.y * m[2][1] + i.z * m[3][1] + m[4][1]
  o.y = i.x * m[1][2] + i.y * m[2][2] + i.z * m[3][2] + m[4][2]
  o.z = i.x * m[1][3] + i.y * m[2][3] + i.z * m[3][3] + m[4][3]
  o.w = i.x * m[1][4] + i.y * m[2][4] + i.z * m[3][4] + m[4][4]

  return {o.x, o.y, o.z, w = o.w}
end


function Vector_Add(v1, v2)
  return {v1[1]+v2[1], v1[2]+v2[2], v1[3]+v2[3]}
end


function Vector_Sub(v1, v2)
  return {v1[1]-v2[1], v1[2]-v2[2], v1[3]-v2[3]}
end


function Vector_Mul(v1, k)
  return {v1[1]*k, v1[2]*k, v1[3]*k}
end


function Vector_Div(v1, k)
  return {v1[1]/k, v1[2]/k, v1[3]/k}
end


function Vector_DotProduct(v1, v2)
  return v1[1]*v2[1] + v1[2]*v2[2] + v1[3]*v2[3]
end


function Vector_Length(v)
  return math.sqrt(Vector_DotProduct(v,v))
end


function Vector_Normalise(v)
  local l = Vector_Length(v)
  return {v[1]/l, v[2]/l, v[3]/l}
end

function Vector_CrossProduct(v1, v2)
  v = {x = 0, y = 0, z = 0}
  v.x = v1[2] * v2[3] - v1[3] * v2[2]
  v.y = v1[3] * v2[1] - v1[1] * v2[3]
  v.z = v1[1] * v2[2] - v1[2] * v2[1]
  return {v.x,v.y,v.z}
end

function Vector_IntersectPlane(plane_p, plane_n, lineStart, lineEnd)
  plane_n = Vector_Normalise(plane_n)
  local plane_d = -Vector_DotProduct(plane_n, plane_p)
  local ad = Vector_DotProduct(lineStart, plane_n)
  local bd = Vector_DotProduct(lineEnd, plane_n)
  local t = (-plane_d - ad) / (bd - ad)
  local lineStartToEnd = Vector_Sub(lineEnd, lineStart)
  local lineToIntersect = Vector_Mul(lineStartToEnd, t)

  return {Vector_Add(lineStart, lineToIntersect),t}
end

function Vector_Distance(v1, v2)
local d = math.sqrt( (v2[1] - v1[1])^2 + (v2[2] - v1[2])^2 + (v2[3] - v1[3])^2)

return d
end

function Triangle_ClipAgainstPlane(plane_p, plane_n, in_tri, uv, vertc)
  plane_n = Vector_Normalise(plane_n)

  --print(uv[1][1])

  local emptytri = {{0,0,0},{0,0,0},{0,0,0}}
  local emptyuv = {{0,0},{0,0},{0,0}}
  local emptycolor = {{1,1,1,1},{1,1,1,1},{1,1,1,1}}

  local out_tri1 = {{0,0,0},{0,0,0},{0,0,0}}
  local out_tri2 = {{0,0,0},{0,0,0},{0,0,0}}

  local out_uv1 = {{0,0},{0,0},{0,0}}
  local out_uv2 = {{0,0},{0,0},{0,0}}

  local out_col1 = {{1,1,1,1},{1,1,1,1},{1,1,1,1}}
  local out_col2 = {{1,1,1,1},{1,1,1,1},{1,1,1,1}}

  function color_vtwe(outside,inside,tween)
    local color = {0,0,0,0}
      color[1] = tween * (outside[1] - inside[1]) + inside[1]
      color[2] = tween * (outside[2] - inside[2]) + inside[2]
      color[3] = tween * (outside[3] - inside[3]) + inside[3]
      color[4] = tween * (outside[4] - inside[4]) + inside[4]
    return color
  end

  function dist(p)
    local n = Vector_Normalise(p)
    return (plane_n[1] * p[1] + plane_n[2] * p[2] + plane_n[3] * p[3] - Vector_DotProduct(plane_n, plane_p))
  end

  inside_points = {}; nInsidePointCount = 0
  outside_points = {}; nOutsidePointCount = 0

  inside_tex = {};
  outside_tex = {};
  inside_col = {};
  outside_col = {};

  local d0 = dist(in_tri[1])
  local d1 = dist(in_tri[2])
  local d2 = dist(in_tri[3])

  if (d0 >= 0) then
    nInsidePointCount = nInsidePointCount+1; inside_points[nInsidePointCount] = in_tri[1];
    inside_tex[nInsidePointCount] = uv[1];
    inside_col[nInsidePointCount] = vertc[1];
  else
    nOutsidePointCount = nOutsidePointCount+1; outside_points[nOutsidePointCount] = in_tri[1];
    outside_tex[nOutsidePointCount] = uv[1];
    outside_col[nOutsidePointCount] = vertc[1];
  end

  if (d1 >= 0) then
    nInsidePointCount = nInsidePointCount+1; inside_points[nInsidePointCount] = in_tri[2];
    inside_tex[nInsidePointCount] = uv[2];
    inside_col[nInsidePointCount] = vertc[2];
  else
    nOutsidePointCount = nOutsidePointCount+1; outside_points[nOutsidePointCount] = in_tri[2];
    outside_tex[nOutsidePointCount] = uv[2];
    outside_col[nOutsidePointCount] = vertc[2];
  end

  if (d2 >= 0) then
    nInsidePointCount = nInsidePointCount+1; inside_points[nInsidePointCount] = in_tri[3];
    inside_tex[nInsidePointCount] = uv[3];
    inside_col[nInsidePointCount] = vertc[3];
  else
    nOutsidePointCount = nOutsidePointCount+1; outside_points[nOutsidePointCount] = in_tri[3];
    outside_tex[nOutsidePointCount] = uv[3];
    outside_col[nOutsidePointCount] = vertc[3];
  end

  if (nInsidePointCount == 0) then
    return {0,emptytri,emptytri,emptyuv,emptyuv,emptycolor,emptycolor};
  end

  if (nInsidePointCount == 3) then
    out_tri1 = in_tri
    out_uv1 = uv
    out_col1 = vertc
    return {1, out_tri1,emptytri,out_uv1,emptyuv,out_col1,emptycolor};
  end

  local intersector = {}
  local intersector2 = {}

  if (nInsidePointCount == 1 and nOutsidePointCount == 2) then
    --out_tri1 = in_tri
    --copy out the color?

    out_tri1[1] = inside_points[1]
    out_uv1[1] = inside_tex[1]
    out_col1[1] = inside_col[1]

    intersector = Vector_IntersectPlane(plane_p, plane_n, inside_points[1], outside_points[1])
    out_tri1[2] = intersector[1]

    out_uv1[2][1] = intersector[2] * (outside_tex[1][1] - inside_tex[1][1]) + inside_tex[1][1]
    out_uv1[2][2] = intersector[2] * (outside_tex[1][2] - inside_tex[1][2]) + inside_tex[1][2]

    out_col1[2] = color_vtwe(outside_col[1],inside_col[1],intersector[2])

    intersector = Vector_IntersectPlane(plane_p, plane_n, inside_points[1], outside_points[2])
    out_tri1[3] = intersector[1]

    out_uv1[3][1] = intersector[2] * (outside_tex[2][1] - inside_tex[1][1]) + inside_tex[1][1]
    out_uv1[3][2] = intersector[2] * (outside_tex[2][2] - inside_tex[1][2]) + inside_tex[1][2]

    out_col1[3] = color_vtwe(outside_col[2],inside_col[1],intersector[2])

    --print(out_uv1[1][1],":",out_uv1[1][2],"/",out_uv1[2][1],":",out_uv1[2][2],"/",out_uv1[3][1],":",out_uv1[3][2])

    return {1,out_tri1,emptytri,out_uv1,emptyuv,out_col1,emptycolor};
  end

  if (nInsidePointCount == 2 and nOutsidePointCount == 1) then
    --out_tri1 = in_tri
    --out_tri2 = in_tri
    --copy out the color?

    out_tri1[1] = inside_points[1]
    out_tri1[2] = inside_points[2]
    out_uv1[1] = inside_tex[1]
    out_uv1[2] = inside_tex[2]
    out_col1[1] = inside_col[1]
    out_col1[2] = inside_col[2]

    intersector = Vector_IntersectPlane(plane_p, plane_n, inside_points[1], outside_points[1])
    out_tri1[3] = intersector[1]
    out_uv1[3][1] = intersector[2] * (outside_tex[1][1] - inside_tex[1][1]) + inside_tex[1][1]
    out_uv1[3][2] = intersector[2] * (outside_tex[1][2] - inside_tex[1][2]) + inside_tex[1][2]
    out_col1[3] = color_vtwe(outside_col[1],inside_col[1],intersector[2])

    out_tri2[1] = inside_points[2]
    out_uv2[1] = inside_tex[2]
    out_col2[1] = inside_col[2]

    out_tri2[2] = out_tri1[3]
    out_uv2[2] = out_uv1[3]
    out_col2[2] = out_col1[3]

    intersector2 = Vector_IntersectPlane(plane_p, plane_n, inside_points[2], outside_points[1])
    out_tri2[3] = intersector2[1]
    out_uv2[3][1] = intersector2[2] * (outside_tex[1][1] - inside_tex[2][1]) + inside_tex[2][1]
    out_uv2[3][2] = intersector2[2] * (outside_tex[1][2] - inside_tex[2][2]) + inside_tex[2][2]
    out_col2[3] = color_vtwe(outside_col[1],inside_col[2],intersector2[2])

    return {2, out_tri1, out_tri2, out_uv1, out_uv2, out_col1, out_col2};
  end
end
