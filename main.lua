require "libs/vector"
require "libs/matrix"
require "libs/mesh"
require "libs/basics"
require "libs/run"

function love.load()

  shader = love.graphics.newShader("libs/color_shader.glsl")

  love.graphics.setDefaultFilter("nearest", "nearest", 1) --disable texture blur
  rWidth = 320;
  rHeight = 240;

	rZoom = 2;
  rFullscreen = false;

  canv = love.graphics.newCanvas(rWidth, rHeight, {format="rgb5a1"})

  love.window.setTitle("3D eng test")
	flags = {fullscreen=rFullscreen,vsync=false}
	love.window.setMode( rWidth*rZoom, rHeight*rZoom, flags )

  vCamera = {-5,3,0}
  vLookDir = {0,0,1}

  fYaw = math.rad(-90)
  fPitch = math.rad(30)

  tyaw = fYaw
  tpitch = fPitch

  vel = 0

  globmesh = {}

  bg = love.graphics.newImage("assets/scroll1.png")

    image = love.graphics.newImage("assets/sonicr.png")

    --image:setWrap("repeat", "repeat")
    meshs = LoadFromObjFile("assets/borng.obj")
    local vcolor = {{0,0,0},{1,1,1},{1,1,1}}
    --xyz,xyz,xyz,xyz
    --table.insert(meshs, {-1,2,0, 1,2,0, 1,0,0, -1,0,0, 0,0, 1,0, 1,.5, 0,.5,type = "quad"})
    mesh2 = LoadFromObjFile("assets/sort_test.obj")

  matProj = Matrix_MakeProjection(90, rHeight/rWidth, 0.1, 1000)



  --curs = love.mouse.newCursor("cover.png",0, 0)
  --love.mouse.setCursor(curs)

  timer = 0;

  source = love.audio.newSource("assets/song.mp3", "stream")
  source:play()

  min_dt = 1/30
  next_time = love.timer.getTime()
end

function love.update(dt)
timer = timer+1
  next_time = next_time + min_dt

  if love.keyboard.isDown("up") then
      fPitch = fPitch-.05
  end

  if love.keyboard.isDown("down") then
      fPitch = fPitch+.05
  end

  if love.keyboard.isDown("left") then
      vCamera[1] = vCamera[1]+.1
  end

  if love.keyboard.isDown("right") then
      vCamera[1] = vCamera[1]-.1
  end

  if love.keyboard.isDown(",") then
      vCamera[3] = vCamera[3]+.1
  end

  if love.keyboard.isDown(".") then
      vCamera[3] = vCamera[3]-.1
  end

  local vForward = Vector_Mul(vLookDir, .1)

  if love.keyboard.isDown("w") then
      vel = vel + ((1 -vel) * .10);
  elseif love.keyboard.isDown("s") then
      vel = vel + ((-1 -vel) * .10);
  else
    vel = vel + ((0 -vel) * .10);
  end

  local spd = Vector_Mul(vForward,vel)

  vCamera = Vector_Add(vCamera, spd)

  if love.keyboard.isDown("a") then
      fYaw = fYaw+.05
  end

  if love.keyboard.isDown("d") then
      fYaw = fYaw-.05
  end

  fPitch = clamp(fPitch,math.rad(-89.999),math.rad(89.999))

  tyaw = tyaw + ((fYaw -tyaw) * .10);

  tpitch = tpitch + ((fPitch -tpitch) * .10);

  matRotY = Matrix_MakeRotationY(timer/30)
  matRotX = Matrix_MakeRotationX(0)

  matTrans = Matrix_MakeTranslation(vCamera[1]+5, 0, vCamera[3])

  matWorld = Matrix_MakeIdentity()
  matWorld = Matrix_MultiplyMatrix(matRotX,matRotY)

  --matWorld = Matrix_MakeIdentity() --Matrix_MultiplyMatrix(matWorld, matTrans)

--  matWorld = Matrix_ScaleVector(matWorld,{.021,.021,.021})

  --print(matWorld[4][1],matWorld[4][2],matWorld[4][3])

  --matWorld = Matrix_ScaleValue(matWorld,.5)
  local vUp = {0,1,0}
  local vTarget = {0,0,1}
  matCameraRot = Matrix_MakeRotationY(tyaw)
  matCameraPitch = Matrix_MakeRotationX(tpitch)

  matCameraRot = Matrix_MultiplyMatrix(matCameraPitch,matCameraRot)



  vLookDir = Matrix_MultiplyVector(matCameraRot, vTarget)
  vTarget = Vector_Add(vCamera, vLookDir)

  local matCamera = Matrix_PointAt(vCamera, vTarget, vUp)

  matView = Matrix_QuickInverse(matCamera)
end

function love.draw()
  rZoom = love.graphics.getPixelWidth()/rWidth --get canvscale even in fullscreen
  love.graphics.setCanvas(canv)
  love.graphics.clear()
  tristo = {}
  --TransformMesh(mesh,matWorld,tristo)
  --TransformMesh(mesh2,tristo)
  TransformMesh(meshs,tristo)
  --draw_tiled(bg,timer)
  --draw tris

  --table.insert(tristo, {0, 0, 320, 0, 320, 240, nil, 1+(math.sin(tyaw)*.15), {{0,0},{1,0},{1,1}}})
  --table.insert(tristo, {0, 0, 0, 240, 320, 240, nil, 1+(math.sin(tyaw)*.15), {{0,0},{0,1},{1,1}}})
  local vcolor = {{0,0,0},{1,1,1},{1,1,1}}
  --table.insert(tristo, {0, 0, 320, 0, 320, 240, vcolor, 1+(math.sin(tyaw)*.15), {{0,0},{1,0},{1,1}}})
  --table.insert(tristo, {0, 0, 0, 240, 320, 240, vcolor, 1+(math.sin(tyaw)*.15), {{0,0},{0,1},{1,1}}})

  local cc = 0
  table.sort(tristo, function(a, b) return a[8] > b[8] end)
  local mtable = {}

  for k,v in ipairs(tristo) do
      for c = 1,6,1 do
        v[c] = math.floor(v[c])
      end
      table.insert(mtable,{v[1],v[2],v[9][1][1],v[9][1][2],v[7][1][1],v[7][1][2],v[7][1][3],v[7][1][4]})
      table.insert(mtable,{v[3],v[4],v[9][2][1],v[9][2][2],v[7][2][1],v[7][2][2],v[7][2][3],v[7][2][4]})
      table.insert(mtable,{v[5],v[6],v[9][3][1],v[9][3][2],v[7][3][1],v[7][3][2],v[7][3][3],v[7][3][4]})
      cc = cc+1
  end

  love.graphics.setShader( shader )
  if mtable[1] ~= nil then
    local tris = love.graphics.newMesh(mtable,"triangles")
    tris:setTexture(image)
    love.graphics.draw(tris)
    tris:release()
  end

  love.graphics.setShader()
  love.graphics.setCanvas()

  love.graphics.draw(canv, 0, 0, 0, rZoom, rZoom)

  fpp = love.timer.getFPS( )

  love.graphics.print(love.graphics.getStats().drawcalls,2,2)
  love.graphics.print(globmesh,2,32)


  local cur_time = love.timer.getTime()
   if next_time <= cur_time then
      next_time = cur_time
      return
   end
   love.timer.sleep(next_time - cur_time)
end
