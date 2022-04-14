local complex = require "complex"
local matrix = require "matrix"
local ElectricCharge = require "fieldobj"
local Particle = require "particle"

function lovr.load()
  WALL_THICKNESS = 0.01
  ORBITAL_RADIUS = 0.3
  ORBITAL_PERIOD = 5

  f = ElectricCharge:new(matrix{0,0,0}, matrix{0,0,0}, matrix{0,0,0}, 1)

  p = Particle:new(matrix{ORBITAL_RADIUS,0,0}, matrix{0,0,0},matrix{0.1,0,0}, 1)

  t = 0
end

function lovr.draw()
  lovr.graphics.setBackgroundColor(1,1,1)

  -- Draw box
  lovr.graphics.setColor(0,0,0)
  lovr.graphics.cube("line",0,0,0,1)

  -- Draw sun
  lovr.graphics.setColor(1,0,0)
  lovr.graphics.sphere(f.position[1], f.position[2], f.position[3], f.radius)

  -- Draw planet
  lovr.graphics.setColor(0,0,1)
  -- lovr.graphics.sphere(planet.position, planet.radius)
  lovr.graphics.sphere(p.position[1], p.position[2], p.position[3],p.radius)
end

function lovr.update(dt)
  t = t + dt

  p:update(dt)
  f:update(dt)
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
