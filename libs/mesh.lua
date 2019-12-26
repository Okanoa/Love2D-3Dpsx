function LoadFromObjFile(sFilename)
  local retmsh = {}

  local verts = {}
  local vtex = {}
  local vnorm = {}
  local previousmtl = 0

  for line in love.filesystem.lines(sFilename) do

    local vv = mysplit(line)

    if vv[1] == "v" then
      table.insert(verts, {x = tonumber(vv[2]), y = tonumber(vv[3]), z = tonumber(vv[4])})
    end

    if vv[1] == "vt" then
      table.insert(vtex, {u = tonumber(vv[2]), v = 1-tonumber(vv[3])})
    end

    if vv[1] == "vn" then
      table.insert(vnorm, {x = tonumber(vv[2]), y = tonumber(vv[3]), z = tonumber(vv[4])})
    end

    if vv[1] == "usemtl" then
      if tonumber(string.match(vv[2],"%d+")) then
        previousmtl = tonumber(string.match(vv[2],"%d+"))
      end
    end

    if vv[1] == "f" then

      poly = {}

      for i = 1,(tablelength(vv)-1)/3,1 do
        local cc = ((i-1)*3)+2
        vertex = {verts[tonumber(vv[cc])].x, verts[tonumber(vv[cc])].y, verts[tonumber(vv[cc])].z}
        texture = {vtex[tonumber(vv[cc+1])].u, vtex[tonumber(vv[cc+1])].v}
        normal = {vnorm[tonumber(vv[cc+2])].x, vnorm[tonumber(vv[cc+2])].y, vnorm[tonumber(vv[cc+2])].z}

        table.insert(poly,{vertex = vertex, uv = texture, normal = normal})
      end
      poly.mtl = previousmtl
      --print(poly[4].uv[1])
      table.insert(retmsh,poly)
    end

  end

  return retmsh
end

function TransformMesh(mesh,output)
  --print(tablelength(mesh))
  for i in pairs(mesh) do
    local mmesh = deepcopy(mesh[i])
    local polygon = {}
    local uv = {}
    local norm = {}

    if tablelength(mmesh) == 4 then
      polygon[1] = {mmesh[1].vertex,mmesh[2].vertex,mmesh[3].vertex}

      norm[1] = {mmesh[1].normal,mmesh[2].normal,mmesh[3].normal}

      uv[1] = {mmesh[1].uv,mmesh[2].uv,mmesh[3].uv}
    elseif tablelength(mesh[i]) == 5 then
      polygon[1] = {mmesh[1].vertex,mmesh[2].vertex,mmesh[3].vertex}
      polygon[2] = {mmesh[1].vertex,mmesh[3].vertex,mmesh[4].vertex}

      norm[1] = {mmesh[1].normal,mmesh[2].normal,mmesh[3].normal}
      norm[2] = {mmesh[1].normal,mmesh[3].normal,mmesh[4].normal}

      uv[1] = {mmesh[1].uv,mmesh[2].uv,mmesh[3].uv}
      uv[2] = {mmesh[1].uv,mmesh[3].uv,mmesh[4].uv}
    end

    depths = {}
    temp = {}

    for i in pairs(polygon) do

    local triProjected = {{0,0,0},{0,0,0},{0,0,0}};
    local triTransformed = {{0,0,0},{0,0,0},{0,0,0}};
    local triViewed = {{0,0,0},{0,0,0},{0,0,0}};

    triTransformed[1] = Matrix_MultiplyVector(matWorld, polygon[i][1])--tri[1])
    triTransformed[2] = Matrix_MultiplyVector(matWorld, polygon[i][2])--tri[2])
    triTransformed[3] = Matrix_MultiplyVector(matWorld, polygon[i][3])--tri[3])

    local vv = vCamera

    local d3 = {1-Vector_Distance(vv,triTransformed[1])/5,1-Vector_Distance(vv,triTransformed[2])/5,1-Vector_Distance(vv,triTransformed[3])/5}

    --local d2 = (Vector_Distance(vv,triTransformed[1])+Vector_Distance(vv,triTransformed[2])+Vector_Distance(vv,triTransformed[3]))/3

    local vcolor = {{1,1,1},{1,1,1},{1,1,1}}--{{d3[1],d3[1],d3[1]},{d3[2],d3[2],d3[2]},{d3[3],d3[3],d3[3]}}

    local normal, line1, line2

    line1 = Vector_Sub(triTransformed[2],triTransformed[1])
    line2 = Vector_Sub(triTransformed[3],triTransformed[1])

    normal = Vector_CrossProduct(line1, line2)
    normal = Vector_Normalise(normal)

    local vCameraRay = Vector_Sub(triTransformed[1], vCamera)

    if(Vector_DotProduct(normal, vCameraRay) < 0) then



      --world to view
      triViewed[1] = Matrix_MultiplyVector(matView, triTransformed[1])
      triViewed[2] = Matrix_MultiplyVector(matView, triTransformed[2])
      triViewed[3] = Matrix_MultiplyVector(matView, triTransformed[3])

      local nClippedTriangles = {1};
      local clipped = {{0,0,0},{0,0,0}}
      local uvc = {{0,0},{0,0}}
      --print(tablelength(norm[1][1][1]))
      local dp = {}

      local mm = Matrix_MultiplyMatrix(matProj,matWorld)
      for u in pairs(uv[i]) do



        --local

        --local light_direction = {0, .1, .1}
        --light_direction = Vector_Normalise(light_direction)

        dp[u] = 1--math.max(0, Vector_DotProduct(light_direction, transedn)+.5)

        local e = Vector_Normalise(triViewed[u]);
        local n = Vector_Normalise(Matrix_MultiplyVector(mm, norm[i][u]))

        local r = reflect( e, n )

        local m = 2. * math.sqrt(
          r[1]^2.+
          r[2]^2.+
          (r[3] + 1.)^2.
        )

        vN = {r[1]/m + .5, r[2]/m+.5}

        uv[i][u][1] = vN[1]
        uv[i][u][2] = 1-vN[2]
      end

      vcolor = {{dp[1],1,1},{dp[2],1,1},{dp[3],1,1}}

      nClippedTriangles = Triangle_ClipAgainstPlane({0,0,.1}, {0,0,1}, triViewed, uv[i])

      clipped[1] = nClippedTriangles[2]
      clipped[2] = nClippedTriangles[3]
      uvc[1] = nClippedTriangles[4]
      uvc[2] = nClippedTriangles[5]



      for n = 1,nClippedTriangles[1],1 do
        -- 3d --> 2d

        --if n == 3 then dp = .5 end

        triProjected[1] = Matrix_MultiplyVector(matProj, clipped[n][1])
        triProjected[2] = Matrix_MultiplyVector(matProj, clipped[n][2])
        triProjected[3] = Matrix_MultiplyVector(matProj, clipped[n][3])

        triProjected[1] = Vector_Div(triProjected[1], triProjected[1].w)
        triProjected[2] = Vector_Div(triProjected[2], triProjected[2].w)
        triProjected[3] = Vector_Div(triProjected[3], triProjected[3].w)

        local vOffsetView = {1,-1,0}

        triProjected[1] = Vector_Add(triProjected[1],vOffsetView)
        triProjected[2] = Vector_Add(triProjected[2],vOffsetView)
        triProjected[3] = Vector_Add(triProjected[3],vOffsetView)

        triProjected[1][1] = triProjected[1][1] * .5 * rWidth; triProjected[1][2] = triProjected[1][2] * .5 * -rHeight;
        triProjected[2][1] = triProjected[2][1] * .5 * rWidth; triProjected[2][2] = triProjected[2][2] * .5 * -rHeight;
        triProjected[3][1] = triProjected[3][1] * .5 * rWidth; triProjected[3][2] = triProjected[3][2] * .5 * -rHeight;


        local depth = (triProjected[1][3] + triProjected[2][3] + triProjected[3][3])/3
        table.insert(depths, depth)
        table.insert(temp, {triProjected[1][1], triProjected[1][2], triProjected[2][1], triProjected[2][2], triProjected[3][1], triProjected[3][2], vcolor, depth, uvc[n]})
      end

    end
    --print("---")
    local dpth = 0
    for j in pairs(depths) do
      dpth = (dpth + depths[j])/2
    end

    for j in pairs(temp) do
      temp[j][8] = dpth
      table.insert(output, temp[j])
    end

    end

  end


  return output
end
