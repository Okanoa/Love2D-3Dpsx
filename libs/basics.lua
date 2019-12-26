function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(string.gsub(inputstr, "/", " "), "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function tableclone(org)
  return {table.unpack(org)}
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function clamp(val,minn,maxx)
  if val < minn then
    return minn
  elseif val > maxx then
    return maxx
  else
    return val
  end
end

function math.sign(value)
  if value > 0 then
    return 1
  elseif value < 0 then
    return -1
  else
    return 0
  end
end

function draw_tiled(texture, scroll)
  scroll = (math.abs(scroll)%texture:getWidth())*math.sign(scroll)
  for i = 0, (love.graphics.getWidth() / texture:getWidth())+1 do
      for j = 0, love.graphics.getHeight() / texture:getHeight() do
          love.graphics.draw(texture, scroll+(i-1) * texture:getWidth(), j * texture:getHeight())
      end
  end
end

function color_tween(c1,c2,tween)
  local color = {0,0,0}
    color[1] = (c2[1] - c1[1]) * tween + c1[1]
    color[2] = (c2[2] - c1[2]) * tween + c1[2]
    color[3] = (c2[3] - c1[3]) * tween + c1[3]
    color[4] = (c2[4] - c1[4]) * tween + c1[4]
  return color
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function reflect(e, n)
return {e[1] - 2. * Vector_DotProduct( n, e ) * n[1], e[2] - 2. * Vector_DotProduct( n, e ) * n[2],e[3] - 2. * Vector_DotProduct( n, e ) * n[3]};
end
