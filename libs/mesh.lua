function LoadFromObjFile(sFilename,uvf)
  local retmsh = {}
  if uvf == nil then uvf = 1 end
  local ext = love.filesystem.newFileData(sFilename):getExtension()
  print(ext)

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
      table.insert(vtex, {u = tonumber(vv[2]), v = tonumber(vv[3])})
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
        texture = {vtex[tonumber(vv[cc+1])].u, uvf-vtex[tonumber(vv[cc+1])].v}
        normal = {vnorm[tonumber(vv[cc+2])].x, vnorm[tonumber(vv[cc+2])].y, vnorm[tonumber(vv[cc+2])].z}

        table.insert(poly,{vertex = vertex, uv = texture, normal = normal})
      end

      poly.mtl = previousmtl
      poly.len = tablelength(poly);

      --finished format
--{ {vertex={0,0,0}, uv={0,0}, normal={0,0,0}},{vertex={0,0,0}, uv={0,0}, normal={0,0,0}},{vertex={0,0,0}, uv={0,0}, normal={0,0,0}},{vertex={0,0,0}, uv={0,0}, normal={0,0,0}}, mtl=0, len=5}

      table.insert(retmsh,poly)
    end

  end

  return retmsh
end

function TweenMesh(tweenmesh,meshstart,meshend,tween)
  --tweenmesh will be overwritten! if any of the three meshes don't contain all the data they need it will crash!
  --a selective tween will soon be available this will allow only changed parts to well change so you can mix arms and head anim!
  --a skeleton system may also come
  for i in pairs(tweenmesh) do
    local stms = meshstart[i]
    local enms = meshend[i]

    for c = 1,stms.len-1,1 do
      for v = 1,3,1 do
        tweenmesh[i][c].vertex[v] = math.lerp(stms[c].vertex[v],enms[c].vertex[v],tween)
        tweenmesh[i][c].normal[v] = math.lerp(stms[c].normal[v],enms[c].normal[v],tween)
      end
      for u = 1,2,1 do
        tweenmesh[i][c].uv[u] = math.lerp(stms[c].uv[u],enms[c].uv[u],tween)
      end
    end

  end
end

--TransformMesh(mesh,modeltransform,cull,textureposit,reflective)
function TransformMesh(mesh,texcoords,options)

  local ops = {worldmat = gpu.MATWORLD,viewmat = gpu.MATVIEW,projmat = gpu.MATPROJECTION, depthaddto = 0, cull = true, reflect = false, sorttype = "normal", bm=0}

  if options ~= nil then
    if options.worldmatrix~=nil then ops.worldmat = options.worldmatrix end
    if options.viewmatrix~=nil then ops.viewmat = options.viewmatrix end
    if options.projectionmatrix~=nil then ops.projmat = options.projectionmatrix end
    if options.cull~=nil then ops.cull = false end
    if options.reflect~=nil then ops.reflect = true end
    if options.depthadd~=nil then ops.depthaddto = options.depthadd end
    if options.sorttype~=nil then ops.sorttype = options.sorttype end
    if options.blend~=nil then ops.bm = options.blend end
  end

  local modelviewinverse = Matrix_TranposeMatrix(Matrix_QuickInverse(Matrix_MultiplyMatrix(ops.worldmat,ops.viewmat)))
  local modelinverse = Matrix_TranposeMatrix(Matrix_QuickInverse(ops.worldmat))

  for i in pairs(mesh) do
    local order = i
    local mmesh = mesh[i]

    local polygon = {}
    local uv = {}
    local norm = {}

    local temp = {} --poly storage
    local alldepth = {}
    local depthcount = 0

    if mmesh.len == 4 then -- reg tri
      polygon[1] = {mmesh[1].vertex,mmesh[2].vertex,mmesh[3].vertex}
      norm[1] = {mmesh[1].normal,mmesh[2].normal,mmesh[3].normal}
      uv[1] = {mmesh[1].uv,mmesh[2].uv,mmesh[3].uv}
    elseif mmesh.len == 5 then -- quad
      polygon[1] = {mmesh[1].vertex,mmesh[2].vertex,mmesh[3].vertex}
      polygon[2] = {mmesh[1].vertex,mmesh[3].vertex,mmesh[4].vertex}

      norm[1] = {mmesh[1].normal,mmesh[2].normal,mmesh[3].normal}
      norm[2] = {mmesh[1].normal,mmesh[3].normal,mmesh[4].normal}

      uv[1] = {mmesh[1].uv,mmesh[2].uv,mmesh[3].uv}
      uv[2] = {mmesh[1].uv,mmesh[3].uv,mmesh[4].uv}
    end -- end poly if

    for i in pairs(polygon) do
      local pid = i
      local utex = {{uv[i][1][1],uv[i][1][2]},{uv[i][2][1],uv[i][2][2]},{uv[i][3][1],uv[i][3][2]}}
      local triTransformed = {{0,0,0},{0,0,0},{0,0,0}}; -- empty transform
      local vcolor = {{1,1,1,1},{1,1,1,1},{1,1,1,1}}

      triTransformed[1] = Matrix_MultiplyVector(ops.worldmat, polygon[i][1]) --world space transform
      triTransformed[2] = Matrix_MultiplyVector(ops.worldmat, polygon[i][2])
      triTransformed[3] = Matrix_MultiplyVector(ops.worldmat, polygon[i][3])



      local pp = {vCamera[1],0,vCamera[3]-3}
      local vdist = {
        1-(Vector_Distance(pp,triTransformed[1])/3),
        1-(Vector_Distance(pp,triTransformed[2])/3),
        1-(Vector_Distance(pp,triTransformed[3])/3)}



      local dp = -1;

      if ops.cull then --if cull enabled do cull math otherwise ignore!
        local normal, line1, line2
        local vCameraRay = Vector_Sub(triTransformed[1], vCamera)
        line1 = Vector_Sub(triTransformed[2],triTransformed[1])
        line2 = Vector_Sub(triTransformed[3],triTransformed[1])

        normal = Vector_CrossProduct(line1, line2)
        normal = Vector_Normalise(normal)

        dp = Vector_DotProduct(normal, vCameraRay)
      else
        dp = -1
      end


      if(dp < 0) then

        --world to view
        local triViewed = {{0,0,0},{0,0,0},{0,0,0}}; -- empty view
        triViewed[1] = Matrix_MultiplyVector(ops.viewmat, triTransformed[1])
        triViewed[2] = Matrix_MultiplyVector(ops.viewmat, triTransformed[2])
        triViewed[3] = Matrix_MultiplyVector(ops.viewmat, triTransformed[3])

        local snap = 96
        for c = 1,3,1 do
          triViewed[c][1] = math.floor(triViewed[c][1]*snap)/snap
          triViewed[c][2] = math.floor(triViewed[c][2]*snap)/snap
          triViewed[c][3] = math.floor(triViewed[c][3]*snap)/snap
        end

        local dp = {1,1,1}

        for u in pairs(utex) do

          local light_direction = Vector_Normalise({-1, 1, 1})
          local lnorm = Matrix_MultiplyVector(modelinverse,norm[i][u])

          dp[u] =1-- math.max(.1, Vector_DotProduct(light_direction,lnorm))--*vdist[u]

          if ops.reflect then
            local e = Vector_Normalise(triViewed[u]);
            local n = Vector_Normalise(Matrix_MultiplyVector(modelviewinverse, norm[i][u]))

            local r = reflect(e, n)

            local m = 2. * math.sqrt(
              r[1]^2.+
              r[2]^2.+
              r[3]^2.
            )

            vN = {r[1]/m+.5, r[2]/m+.5}

            utex[u][1] = vN[1]
            utex[u][2] = vN[2]
          end

          utex[u][1] = math.lerp(texcoords.u,texcoords.ul,utex[u][1])
          utex[u][2] = math.lerp(texcoords.v,texcoords.vl,utex[u][2])
        end

        -- delete fucking space ants with this hack of code :ewo:
        local tmin = {math.min(utex[1][1],utex[2][1],utex[3][1]), math.min(utex[1][2],utex[2][2],utex[3][2]) }
        local tmax = {math.max(utex[1][1],utex[2][1],utex[3][1]), math.max(utex[1][2],utex[2][2],utex[3][2]) }
        local offsetuv = 0.001

        for u in pairs(utex) do
          if utex[u][1] == tmin[1] then utex[u][1] = utex[u][1]+offsetuv end
          if utex[u][1] == tmax[1] then utex[u][1] = utex[u][1]-offsetuv end

          if utex[u][2] == tmin[2] then utex[u][2] = utex[u][2]+offsetuv end
          if utex[u][2] == tmax[2] then utex[u][2] = utex[u][2]-offsetuv end
        end

        vcolor = {{1,1,1,dp[1]},{1,1,1,dp[2]},{1,1,1,dp[3]}}

        local nClippedTriangles = {1};
        local clipped = {{0,0,0},{0,0,0}}
        local uvc = {{0,0},{0,0}}
        local clipc = {{1,1,1,1},{1,1,1,1}} --clipcolor

        nClippedTriangles = Triangle_ClipAgainstPlane({0,0,.1}, {0,0,1}, triViewed, utex, vcolor) --nlag

        clipped[1] = nClippedTriangles[2]
        clipped[2] = nClippedTriangles[3]
        uvc[1] = nClippedTriangles[4]
        uvc[2] = nClippedTriangles[5]
        clipc[1] = nClippedTriangles[6]
        clipc[2] = nClippedTriangles[7]

        for n = 1,nClippedTriangles[1],1 do -- for the triangles that clipping makes
          -- 3d --> 2d
          local triProjected = {{0,0,0},{0,0,0},{0,0,0}}; -- empty projection

          triProjected[1] = Matrix_MultiplyVector(ops.projmat, clipped[n][1])
          triProjected[2] = Matrix_MultiplyVector(ops.projmat, clipped[n][2])
          triProjected[3] = Matrix_MultiplyVector(ops.projmat, clipped[n][3])

          triProjected[1] = Vector_Div(triProjected[1], triProjected[1].w)
          triProjected[2] = Vector_Div(triProjected[2], triProjected[2].w)
          triProjected[3] = Vector_Div(triProjected[3], triProjected[3].w)

          local vOffsetView = {-1,-1,0}

          triProjected[1] = Vector_Add(triProjected[1],vOffsetView)
          triProjected[2] = Vector_Add(triProjected[2],vOffsetView)
          triProjected[3] = Vector_Add(triProjected[3],vOffsetView)

          triProjected[1][1] = triProjected[1][1] * .5 * -rWidth; triProjected[1][2] = triProjected[1][2] * .5 * -rHeight;
          triProjected[2][1] = triProjected[2][1] * .5 * -rWidth; triProjected[2][2] = triProjected[2][2] * .5 * -rHeight;
          triProjected[3][1] = triProjected[3][1] * .5 * -rWidth; triProjected[3][2] = triProjected[3][2] * .5 * -rHeight;

          local clipper = {{0,0,0},{0,0,0}} --test for culling

          local snap = 1
            for c = 1,3,1 do
              triProjected[c][1] = math.floor(triProjected[c][1]/snap)*snap
              triProjected[c][2] = math.floor(triProjected[c][2]/snap)*snap

              if (triProjected[c][1] > 320) then
                clipper[1][c] = 1
              end
              if (triProjected[c][1] < 0) then
                clipper[1][c] = -1
              end
              if (triProjected[c][2] > 240) then
                clipper[2][c] = 1
              end
              if (triProjected[c][2] < 0) then
                clipper[2][c] = -1
              end
            end

            local lclip = true;
            if (clipper[1][1] == 1 and clipper[1][2] == 1 and clipper[1][3] == 1) or (clipper[2][1] == 1 and clipper[2][2] == 1 and clipper[2][3] == 1) or
               (clipper[1][1] == -1 and clipper[1][2] == -1 and clipper[1][3] == -1) or (clipper[2][1] == -1 and clipper[2][2] == -1 and clipper[2][3] == -1) then
               lclip = false;
            end

            local depth = (triProjected[1][3] + triProjected[2][3] + triProjected[3][3])/3

            table.insert(alldepth,depth)
            depthcount = depthcount+1

            if lclip then -- x,y,x,y,x,y, color, depth, uv, mtl
              table.insert(temp, {triProjected[1][1], triProjected[1][2], triProjected[2][1], triProjected[2][2], triProjected[3][1], triProjected[3][2], clipc[n], depth, uvc[n], mmesh.mtl})
            end
        end
      end

    end -- end polygon

    local depthadd = 0

    for j in pairs(alldepth) do
      depthadd = depthadd+alldepth[j]
    end

    depthadd = depthadd/depthcount

    for j in pairs(temp) do
      temp[j][8] = depthadd+ops.depthaddto
      if temp[j][8] < 1 then
        temp[j][8] = math.floor(temp[j][8]*1000000)+i
        table.insert(gpu.MeshTable, temp[j])
      end
    end

  end -- all pairs in mesh
end -- transform mesh end
