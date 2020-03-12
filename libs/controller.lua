--       Tri     Circ    cros    squr    L1      R1      L2      R2      select  start   Lstick  Rstick analog left stick        right stick
input = {false , false , false , false , false , false , false , false , false , false , false , false, false, axisx=0, axisy=0, axiszx=0, axiszy=0}
--       1       2       3       4       5       6       7       8       9       10      11      12     13

--ps2 control mappings may work with dualshock3 too or ps1 analog

function love.joystickpressed(joystick, button)
  input[button] = true
end

function love.joystickreleased(joystick, button)
  input[button] = false;
end

function love.joystickaxis(joystick, axis, value)
  if axis == 1 then
    input.axisx=value
  end
  if axis == 2 then
    input.axisy=value
  end
  if axis == 3 then
    input.axiszx=value
  end
  if axis == 4 then
    input.axiszy=value
  end
  if math.sqrt((input.axisy - 0)^2 + (input.axisx - 0)^2) < .2 then --fix deadzone!
    input.axisx=0
    input.axisy=0
  end
  if math.sqrt((input.axiszy - 0)^2 + (input.axiszx - 0)^2) < .2 then --fix deadzone!
    input.axiszx=0
    input.axiszy=0
  end
end

return input
