
function matrixToQuat(M)
  local Q = {}
  local w,w4,x,y,z
  sum = M[1] + M[6] + M[11]
  --print("sum:", sum) --Only works if sum > -1
	w = math.sqrt(1.0 + sum) / 2.0
	w4 = (4.0 * w)
	x = (M[10] - M[7]) / w4
	y = (M[3] - M[9]) / w4
  z = (M[5] - M[2]) / w4
  Q = {x,y,z,w}
  return Q
end

function quatToMatrix(Q)
  local xx, xy, xz, xw, yy, yz, yw, zz, zw
  local m00, m01, m02, m10, m11, m12, m20, m21, m22
  xx = Q[1] * Q[1]; xy = Q[1] * Q[2]; xz = Q[1] * Q[3]; xw = Q[1] * Q[4];
  yy = Q[2] * Q[2]; yz = Q[2] * Q[3]; yw = Q[2] * Q[4];
  zz = Q[3] * Q[3]; zw = Q[3] * Q[4];

  m00 = 1-2*(yy+zz); m01 = 2*(xy-zw);   m02 = 2*(xz+yw);
  m10 = 2*(xy+zw);   m11 = 1-2*(xx+zz); m12 = 2*(yz-xw);
  m20 = 2*(xz-yw);   m21 = 2*(yz+xw);   m22 = 1-2*(xx+yy);

  return {m00, m01, m02, 0,   m10, m11, m12, 1.5,   m20, m21, m22, 0,  0, 0, 0, 1}
end

function quatToString(Q)
  return string.format("%.3fi + %.3fj + %.3fk + %.3f", Q[1], Q[2], Q[3], Q[4])
end