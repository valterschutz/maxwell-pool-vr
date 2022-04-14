local matrix = require "matrix"
local complex = require "complex"

local R = {}

function R.check_bounce(body)
  -- Make sure body has attributes [position, velocity, radius]
  local x,y,z = body.position:getelement(1,1), body.position:getelement(2,1), body.position:getelement(3,1)
  local vx,vy,vz = body.velocity:getelement(1,1), body.velocity:getelement(2,1), body.velocity:getelement(3,1)
  local radius = body.radius

  if (x+radius > 0.5 and vx > 0) or (x-radius < -0.5 and vx < 0) then
    -- vx = -vx
    body.velocity:setelement(1,1,-vx)
  elseif (y+radius > 0.5 and vy > 0) or (y-radius < -0.5 and vy < 0) then
    -- vy = -vy
    body.velocity:setelement(2,1,-vy)
  elseif (z+radius > 0.5 and vz > 0) or (z-radius < -0.5 and vz < 0) then
    -- vz = -vz
    body.velocity:setelement(3,1,-vz)
  end
end

function R.vectortomultivector(vector)
  sigma_1 = matrix{{0,1},{1,0}};
  sigma_2 = matrix{{0,"-i"},{"i",0}}:replace(complex)
  sigma_3 = matrix{{1,0},{0,-1}}

  return sigma_1 * vector:getelement(1,1) + sigma_2 * vector:getelement(2,1) + sigma_3 * vector:getelement(3,1);
end

return R
