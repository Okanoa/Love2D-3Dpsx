gpu = {};

love.graphics.setDefaultFilter("nearest", "nearest", 0)

gpu.FFONT = love.graphics.newFont("PSXBASIC.ttf",8)
love.graphics.setFont(gpu.FFONT)

gpu.DITHERPATTERN = love.graphics.newImage("libs/dither/dither.png")
gpu.DITHER = love.graphics.newShader("libs/dither/dither.glsl")
gpu.DITHERENABLE = 1
gpu.DITHER:send("bayer",gpu.DITHERPATTERN); gpu.DITHER:send("scale",gpu.DITHERENABLE);

gpu.MeshTable = {}--none
--blend tables

gpu.MATWORLD = Matrix_MakeIdentity();
gpu.MATVIEW = Matrix_MakeIdentity();
gpu.MATPROJECTION = Matrix_MakeIdentity();

gpu.ALPHA_VERT = love.graphics.newShader("libs/vertex_alpha.glsl")

gpu.VRAM = love.graphics.newCanvas(1024, 512)

gpu.WriteMesh = TransformMesh

gpu.WriteVRAM = function(texture,x,y,dither)
  if dither ~= 1 then dither = 0 end

  love.graphics.setCanvas(gpu.VRAM)
  if dither then gpu.DITHER:send("scale", dither) end

  love.graphics.setShader(gpu.DITHER)
    love.graphics.draw(texture,x,y)
  love.graphics.setShader()
  love.graphics.setCanvas()
  local texturenorm = {}

  texturenorm.u = x
  texturenorm.v = y

  texturenorm.ul = x+texture:getWidth()
  texturenorm.vl = y+texture:getHeight()

  return texturenorm
end

gpu.PutText = function(string,x,y,dither)
  if dither ~= 1 then dither = 0 end

  love.graphics.setCanvas(gpu.VRAM)
  if dither then gpu.DITHER:send("scale", dither) end
  love.graphics.setShader(gpu.DITHER)
    love.graphics.print(string,x,y)
  love.graphics.setShader()
  love.graphics.setCanvas()
end

gpu.VIDEOBUFFER = love.graphics.newCanvas(320, 240,{format="normal"})
gpu.VIDEONOCOMP = love.graphics.newCanvas(320, 240,{format="normal"})

gpu.DrawScene = function()
  table.sort(gpu.MeshTable, function(a, b) return a[8] > b[8] end)

  local format = {{"VertexPosition", "float", 2}, {"VertexTexCoord", "float", 2}, {"VertexColor", "byte", 4}, {"BlendMode", "float", 1}}

  local NoBlend = {{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0}} -- fill with empty data to prevent crash! --actual verticies

  if gpu.MeshTable[1] ~= nil then --MAKE SURE SOME MESHES EXIST!

    for k,v in ipairs(gpu.MeshTable) do --BUILD TRIS FOR MESH
        table.insert(NoBlend,{v[1],v[2],v[9][1][1],v[9][1][2],v[7][1][1],v[7][1][2],v[7][1][3],v[7][1][4],v[10]%5})
        table.insert(NoBlend,{v[3],v[4],v[9][2][1],v[9][2][2],v[7][2][1],v[7][2][2],v[7][2][3],v[7][2][4],v[10]%5})
        table.insert(NoBlend,{v[5],v[6],v[9][3][1],v[9][3][2],v[7][3][1],v[7][3][2],v[7][3][3],v[7][3][4],v[10]%5})
    end

  end

  local mesh = love.graphics.newMesh(format,NoBlend,"triangles")
  mesh:setTexture(gpu.VRAM)

  --begin draw!

  love.graphics.setCanvas(gpu.VIDEONOCOMP)
    love.graphics.draw(gpu.VIDEOBUFFER) --previous frame

  love.graphics.setCanvas({gpu.VIDEOBUFFER, depth=false})

    love.graphics.clear(1,1,1,1)
    love.graphics.setShader(gpu.ALPHA_VERT)
    love.graphics.setBlendMode("alpha","premultiplied") --DRAW NO BLENDING
    love.graphics.draw(mesh) -- needs a+b a-b a+(b/4) and (a*.5)+(b*.5)
    -- 1 = noblend     0 = discard     1/5 = add     2/5 = sub     3/5 = add/4     4/5 = /2
    --bm formula = res.r = dst.r * (1 - src.a) + src.r

    love.graphics.setBlendMode("alpha","alphamultiply")
    love.graphics.setShader()

    mesh:release()

  love.graphics.setCanvas(gpu.VRAM)
    gpu.videocoord = gpu.WriteVRAM(gpu.VIDEOBUFFER,0,0,1)
    gpu.prepasscoord = gpu.WriteVRAM(gpu.VIDEONOCOMP,0,240,1)
  love.graphics.setCanvas()

  gpu.MeshTable = {} --clear out the mesh table for next call

end

return gpu
