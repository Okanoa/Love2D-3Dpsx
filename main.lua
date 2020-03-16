timer = 0;

require "libs/vector"
require "libs/matrix"
require "libs/mesh"
require "libs/basics"
require "libs/run"
require "libs/drawing"
require "libs/controller"

function love.load()
  rWidth = 320;
  rHeight = 240;
	rZoom = 1;
  rFullscreen = true;

  love.window.setTitle("PSX ENGINE v1.0.0")
	flags = {fullscreen=rFullscreen,vsync=false,display=3}
	love.window.setMode( rWidth*rZoom, rHeight*rZoom, flags )
  vCamera = {4.5,2,5}
  vLookDir = {0,0,1}

  fYaw = math.rad(180)
  fPitch = math.rad(18)

  crot = math.rad(180);

  acc = {0,0}

  tyaw = fYaw
  tpitch = fPitch

  vel = 0

  bg = love.graphics.newImage("assets/scroll1.png")

  dc = 0


    image = love.graphics.newImage("assets/scaryguy.png")
    steve = love.graphics.newImage("assets/sort_test.png")
    sort = love.graphics.newImage("assets/workzone_tiles4.png")
    grass = love.graphics.newImage("assets/spr_grass_0.png")

    meshs = LoadFromObjFile("assets/cortex.obj")
    meshse = deepcopy(meshs)
    meshs333 = LoadFromObjFile("assets/cortex2.obj")
    mesh3 = LoadFromObjFile("assets/workzone_int.ply")
    mesh4 = LoadFromObjFile("assets/gras.obj")

    charc = {{
    {vertex={-1,-1,0}, uv={1,1}, normal={0,0,0}, color={1,1,1}},
    {vertex={1,-1,0}, uv={0,1}, normal={0,0,0}, color={1,1,1}},
    {vertex={1,1,0}, uv={0,0}, normal={0,0,0}, color={1,1,1}},
    {vertex={-1,1,0}, uv={1,0}, normal={0,0,0}, color={1,1,1}},
    mtl=0, len=5}}

  matProj = Matrix_MakeProjection(90, rHeight/rWidth, 0.1, 16)

  tex_s = gpu.WriteVRAM(steve,320,0)
  tex_c = gpu.WriteVRAM(image,tex_s.ul,0)
  tex_sort = gpu.WriteVRAM(sort,320,tex_s.vl,0)

  timer = 0;
  source = love.audio.newSource("nowwith.wav", "stream")

  ltv = {0,0,1}
end

function love.update(dt)
timer = timer+1

  if love.keyboard.isDown("up") then
      fPitch = fPitch-.05
  end

  if love.keyboard.isDown("down") then
      fPitch = fPitch+.05
  end



  fPitch = fPitch+(input.axiszy*.1)
  fYaw = fYaw+(input.axiszx*.1)


  if input.axisy <= -.2 then
      acc[2] = acc[2] + ((-input.axisy -acc[2]) * .10);
      --crot = math.lerp(math.rad(0),crot,.5)
      crot = math.atan2((input.axisx-0), (-input.axisy-0))
      ltv = {-input.axisx,0,-input.axisy}
  elseif input.axisy >= .2 then
      acc[2] = acc[2] + ((-input.axisy -acc[2]) * .10);
      crot = math.atan2((input.axisx-0), (-input.axisy-0))
      ltv = {-input.axisx,0,-input.axisy}
      --crot = math.lerp(math.rad(180),crot,.5)
  else
    acc[2] = acc[2] + ((0 -acc[2]) * .10);
  end

  if input.axisx <= -.2 then
      acc[1] = acc[1] + ((input.axisx -acc[1]) * .10);
      crot = math.atan2((input.axisx-0), (-input.axisy-0))
      ltv = {-input.axisx,0,-input.axisy}
      --crot = math.lerp(math.rad(90),crot,.5)
  elseif input.axisx >= .2 then
      acc[1] = acc[1] + ((input.axisx -acc[1]) * .10);

      --crot = crot + ((math.rad(180+90) -crot) * .10);
      --crot = math.lerp(math.rad(180+90),crot,.5)
      ltv = {-input.axisx,0,-input.axisy}
      crot = math.atan2((input.axisx-0), (-input.axisy-0))
  else
    acc[1] = acc[1] + ((0 -acc[1]) * .10);
  end

  vCamera[1] = vCamera[1]+acc[1]*.2

  vCamera[3] = vCamera[3]-acc[2]*.2

  --]]--

  if love.keyboard.isDown("left") then
      --vCamera[1] = vCamera[1]-.1
  end

  if love.keyboard.isDown("right") then
      --vCamera[1] = vCamera[1]+.1
  end

  if love.keyboard.isDown(",") then
      vCamera[3] = vCamera[3]+.1
  end

  if love.keyboard.isDown(".") then
      vCamera[3] = vCamera[3]-.1
  end

  local vForward = Vector_Mul(vLookDir, .1)

  if love.keyboard.isDown("w") or input[1] then
      vel = vel + ((1 -vel) * .10);
  elseif love.keyboard.isDown("s") or input[3] then
      vel = vel + ((-1 -vel) * .10);
  else
    vel = vel + ((0 -vel) * .10);
  end

  local spd = Vector_Mul(vForward,vel)

  vCamera = Vector_Add(vCamera, spd)

  if love.keyboard.isDown("a") then
      fYaw = fYaw-.05
  end

  if love.keyboard.isDown("d") then
      fYaw = fYaw+.05
  end

  fPitch = clamp(fPitch,math.rad(-90),math.rad(90))

  tyaw = tyaw + ((fYaw -tyaw) * .10);

  tpitch = tpitch + ((fPitch -tpitch) * .10);

  local vUp = {0,1,0}
  local vTarget = {0,0,1}
  matCameraRot = Matrix_MakeRotationY(tyaw)
  matCameraPitch = Matrix_MakeRotationX(tpitch)

  matCameraRot = Matrix_MultiplyMatrix(matCameraPitch,matCameraRot)

  vLookDir = Matrix_MultiplyVector(matCameraRot, vTarget)
  vUp = Matrix_MultiplyVector(matCameraRot, vUp)
  vTarget = Vector_Add(vCamera, vLookDir)

  local matCamera = Matrix_PointAt(vCamera, vTarget, vUp)

  matView = Matrix_QuickInverse(matCamera)
end

function love.draw()
  rZoom = love.graphics.getPixelWidth()/rWidth --get canvscale even in fullscreen



  local cort = Matrix_MultiplyMatrix(matCameraRot,Matrix_MakeTranslation(vCamera[1],1,vCamera[3]-3))

  TweenMesh(meshse,meshs,meshs333,math.abs(math.sin(timer/10)))

  gpu.WriteMesh(charc,tex_c,{worldmatrix=cort,projectionmatrix=matProj,viewmatrix=matView,depthtype=-1,cull=false})---.01})--cort,true,tex_c,false)
  gpu.WriteMesh(mesh3,tex_sort,{worldmatrix=Matrix_MakeRotationX(math.rad(-90)),projectionmatrix=matProj,viewmatrix=matView,depthtype=1,cull=true})--Matrix_MakeIdentity(),false,tex_sort,false)

  fpp = love.timer.getFPS( )

  gpu.DrawScene()
  local stt = "V-BLNK("..timer..")"
  gpu.PutText(stt,0,0,1)

love.audio.setPosition(vCamera[1], vCamera[2], vCamera[3])
  out = love.graphics.newCanvas(320, 240, {format="rgb565"})

  love.graphics.setCanvas(out)

  love.graphics.draw(gpu.VRAM,0,0,0,1,1)

  love.graphics.setCanvas()
  love.graphics.draw(out,0,0,0,love.graphics.getPixelWidth()/rWidth,love.graphics.getPixelHeight()/rHeight)

end
