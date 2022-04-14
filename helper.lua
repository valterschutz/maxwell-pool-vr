local matrix = require "matrix"

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

  -- local newBody = {}
  -- newBody.position = matrix{x,y,z}
  -- newBody.velocity = matrix{vx,vy,vz}
  -- newBody.acceleration = body.acceleration
  -- newBody.radius = radius
  -- newBody.mass = body.mass
  -- return newBody
end

return R
