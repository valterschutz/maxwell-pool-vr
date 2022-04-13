function lovr.load()
  SUN_RADIUS = 0.02
  PLANET_RADIUS = 0.01
  WALL_THICKNESS = 0.01
  PLANET_MASS = 1
  ORBITAL_RADIUS = 0.3
  ORBITAL_PERIOD = 5
  G = 1

  sun = {}
  sun.position = {0,0,0}
  setmetatable(sun.position, metavector)
  sun.velocity = {0,0,0}
  setmetatable(sun.velocity, metavector)
  sun.radius = SUN_RADIUS
  sun.mass = 4*math.pi^2*ORBITAL_RADIUS^3/(ORBITAL_PERIOD^2*G)

  planet = {}
  planet.position = {ORBITAL_RADIUS,0,0}
  setmetatable(planet.position, metavector)
  planet.velocity = {0,-2*math.pi*ORBITAL_RADIUS/ORBITAL_PERIOD,0}
  setmetatable(planet.velocity, metavector)
  planet.radius = PLANET_RADIUS
  planet.mass = PLANET_MASS

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
  lovr.graphics.sphere(planet.position[1], planet.position[2], planet.position[3],planet.radius)
end

function lovr.update(dt)
  t = t + dt

  -- planet.position = planet.position + dt*planet.velocity

  planet = EF_update(planet,sun,dt)
  planet = check_bounce(planet)
end


function EF_update(particle,field_obj,dt)
  -- Calculate distance between sun and planet
  dist = ((particle.position[1]-field_obj.position[1])^2 + (particle.position[2]-field_obj.position[2])^2 + (particle.position[3]-field_obj.position[3])^2)^(1/2)

  -- Force vector
  F = {-G*particle.mass*field_obj.mass*(particle.position[1]-field_obj.position[1])/dist^3, -G*particle.mass*field_obj.mass*(particle.position[2]-field_obj.position[2])/dist^3, -G*particle.mass*field_obj.mass*(particle.position[3]-field_obj.position[3])/dist^3}

  -- Acceleration vector from F=ma
  a = {F[1]/particle.mass, F[2]/particle.mass, F[3]/particle.mass}

  -- v = {v[1]+a[1]*dt, v[2]+a[2]*dt}
  newParticle = {}
  newParticle.velocity = {particle.velocity[1] + dt*a[1], particle.velocity[2] + dt*a[2], particle.velocity[3] + dt*a[3]}
  newParticle.position = {particle.position[1] + dt*particle.velocity[1], particle.position[2] + dt*particle.velocity[2], particle.position[3] + dt*particle.velocity[3]}
  newParticle.mass = particle.mass
  newParticle.radius = particle.radius
  return newParticle
end

function check_bounce(body)
  local x,y,z = body.position[1], body.position[2], body.position[3]
  local vx,vy,vz = body.velocity[1], body.velocity[2], body.velocity[3]
  local radius = body.radius
  local mass = body.mass

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
  newBody.mass = mass
  return newBody

end

-- Helper methods for vectors
metavector = {}
function metavector.__add(v1,v2)
  res = {v1[1]+v2[1], v1[2]+v2[2], v1[3]+v2[3]}
  return setmetatable(res, metavector)
end

function metavector.__mul(c,v)
  res = {c*v[1], c*v[2], c*v[3]}
  return setmetatable(res, metavector)
end
