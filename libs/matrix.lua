function mat4x4()
  local m = {{0,0,0,0},
             {0,0,0,0},
             {0,0,0,0},
             {0,0,0,0}}
  return m
end


function Matrix_MakeIdentity()
  matrix = mat4x4()
  matrix[1][1] = 1
  matrix[2][2] = 1
  matrix[3][3] = 1
  matrix[4][4] = 1
  return matrix
end


function Matrix_MakeRotationX(fAngleRad)
  matrix = mat4x4()
  matrix[1][1] = 1
  matrix[2][2] = math.cos(fAngleRad)
  matrix[2][3] = math.sin(fAngleRad)
  matrix[3][2] = -math.sin(fAngleRad)
  matrix[3][3] = math.cos(fAngleRad)
  matrix[4][4] = 1
  return matrix
end


function Matrix_MakeRotationY(fAngleRad)
  matrix = mat4x4()
  matrix[1][1] = math.cos(fAngleRad)
  matrix[1][3] = math.sin(fAngleRad)
  matrix[3][1] = -math.sin(fAngleRad)
  matrix[2][2] = 1
  matrix[3][3] = math.cos(fAngleRad)
  matrix[4][4] = 1
  return matrix
end


function Matrix_MakeRotationZ(fAngleRad)
  matrix = mat4x4()
  matrix[1][1] = math.cos(fAngleRad)
  matrix[1][2] = math.sin(fAngleRad)
  matrix[2][1] = -math.sin(fAngleRad)
  matrix[2][2] = math.cos(fAngleRad)
  matrix[3][3] = 1
  matrix[4][4] = 1
  return matrix
end


function Matrix_MakeTranslation(x, y, z)
  matrix = mat4x4()
  matrix[1][1] = 1
  matrix[2][2] = 1
  matrix[3][3] = 1
  matrix[4][4] = 1
  matrix[4][1] = x
  matrix[4][2] = y
  matrix[4][3] = z
  return matrix
end


function Matrix_MakeProjection(fFovDegrees, fAspectRatio, fNear, fFar)
  matrix = mat4x4()

  local fFovRad = 1 / math.tan(fFovDegrees * 0.5 / 180 * math.pi);

  matrix[1][1] = fAspectRatio * fFovRad
	matrix[2][2] = fFovRad
	matrix[3][3] = fFar / (fFar - fNear)
	matrix[4][3] = (-fFar * fNear) / (fFar - fNear)
	matrix[3][4] = 1;
	matrix[4][4] = 0;
  return matrix
end


function Matrix_MultiplyMatrix(m1, m2)
  matrix = mat4x4()
  for c = 1,4,1 do
    for r = 1,4,1 do
      matrix[r][c] = m1[r][1] * m2[1][c] + m1[r][2] * m2[2][c] + m1[r][3] * m2[3][c] + m1[r][4] * m2[4][c];
    end
  end
  return matrix
end


function Matrix_ScaleVector(m, v)
  matrix = m
  for c = 1,4,1 do
    for r = 1,4,1 do
      if r == 4 then
      matrix[r][c] = m[r][c];
      else
      matrix[r][c] = m[r][c] * v[r];
      end
    end
  end
  return matrix
end


function Matrix_PointAt(pos, target, up)
  local newForward = Vector_Sub(target, pos)
  newForward = Vector_Normalise(newForward)

  local a = Vector_Mul(newForward, Vector_DotProduct(up, newForward))
  local newUp = Vector_Sub(up, a)
  newUp = Vector_Normalise(newUp)

  local newRight = Vector_CrossProduct(newUp, newForward)

  matrix = mat4x4();
	matrix[1][1] = newRight[1];	matrix[1][2] = newRight[2];	matrix[1][3] = newRight[3];	matrix[1][4] = 0;
	matrix[2][1] = newUp[1];		matrix[2][2] = newUp[2];		matrix[2][3] = newUp[3];		matrix[2][4] = 0;
	matrix[3][1] = newForward[1];	matrix[3][2] = newForward[2];	matrix[3][3] = newForward[3];	matrix[3][4] = 0;
	matrix[4][1] = pos[1];			matrix[4][2] = pos[2];			matrix[4][3] = pos[3];			matrix[4][4] = 1;
	return matrix;
end


function Matrix_QuickInverse(m)
  matrix = mat4x4();
  matrix[1][1] = m[1][1]; matrix[1][2] = m[2][1]; matrix[1][3] = m[3][1]; matrix[1][4] = 0;
	matrix[2][1] = m[1][2]; matrix[2][2] = m[2][2]; matrix[2][3] = m[3][2]; matrix[2][4] = 0;
	matrix[3][1] = m[1][3]; matrix[3][2] = m[2][3]; matrix[3][3] = m[3][3]; matrix[3][4] = 0;
	matrix[4][1] = -(m[4][1] * matrix[1][1] + m[4][2] * matrix[2][1] + m[4][3] * matrix[3][1]);
	matrix[4][2] = -(m[4][1] * matrix[1][2] + m[4][2] * matrix[2][2] + m[4][3] * matrix[3][2]);
	matrix[4][3] = -(m[4][1] * matrix[1][3] + m[4][2] * matrix[2][3] + m[4][3] * matrix[3][3]);
	matrix[4][4] = 1;
  return matrix;
end
