function lovr.load()
  SUN_RADIUS = 0.02
  PLANET_RADIUS = 0.01
  WALL_THICKNESS = 0.01

  sun = {}
  sun.position = {0,0,0}
  setmetatable(sun.position, metavector)
  sun.velocity = {0,0,0}
  setmetatable(sun.velocity, metavector)
  sun.radius = SUN_RADIUS

  planet = {}
  planet.position = {0.3,0,0}
  setmetatable(planet.position, metavector)
  planet.velocity = {0,0.3,0}
  setmetatable(planet.velocity, metavector)
  planet.radius = PLANET_RADIUS

  t = 0

  -- lovr.graphics.setBlendMode("add","alphamultiply")
end

function lovr.draw()
  lovr.graphics.setBackgroundColor(1,1,1)
  -- Draw box
  lovr.graphics.setColor(0,0,0)
  lovr.graphics.cube("line",0,0,0,1)

  -- Draw sun
  lovr.graphics.setColor(1,0,0)
  lovr.graphics.sphere(sun.position[1], sun.position[2], sun.position[3], sun.radius)

  -- Draw planet
  lovr.graphics.setColor(0,0,1)
  -- lovr.graphics.sphere(planet.position, planet.radius)
  lovr.graphics.cube("fill",planet.position[1], planet.position[2], planet.position[3],planet.radius)
end

function lovr.update(dt)
  t = t + dt

  planet.position = planet.position + dt*planet.velocity
  sun.position = sun.position + dt*sun.velocity

  planet = check_bounce(planet)
end

function check_bounce(body)
  local x,y,z = body.position[1], body.position[2], body.position[3]
  local vx,vy,vz = body.velocity[1], body.velocity[2], body.velocity[3]
  local radius = body.radius

  if (x+radius > 0.5 and vx > 0) or (x-radius < -0.5 and vx < 0) then
    vx = -vx
  elseif (y+radius > 0.5 and vy > 0) or (y-radius < -0.5 and vy < 0) then
    vy = -vy
  elseif (z+radius > 0.5 and vz > 0) or (z-radius < -0.5 and vz < 0) then
    vz = -vz
  end

  local newBody = {}
  newBody.position = {x,y,z}
  setmetatable(newBody.position, metavector)
  newBody.velocity = {vx,vy,vz}
  setmetatable(newBody.velocity, metavector)
  newBody.radius = radius
  return newBody

end

-- Helper methods for vectors
metavector = {}
function metavector.__add(v1,v2)
  return {v1[1]+v2[1], v1[2]+v2[2], v1[3]+v2[3]}
end

function metavector.__mul(c,v)
  return {c*v[1], c*v[2], c*v[3]}
end
