local complex = require "complex"
local matrix = require "matrix"
local ElectricCharge = require "fieldobj"
local Particle = require "particle"
local helper = require "helper"

function lovr.load()
  WALL_THICKNESS = 0.01
  ORBITAL_RADIUS = 0.3
  ORBITAL_PERIOD = 1
  PARTICLE_MASS = 1
  FIELD_OBJECT_CHARGE = 1
  eps_0 = 8.8541878128*1e-12

  f = ElectricCharge:new(matrix{0,0,0}, matrix{0,0,0}, matrix{0,0,0}, FIELD_OBJECT_CHARGE)

  vy = 2*math.pi*ORBITAL_RADIUS/ORBITAL_PERIOD;
  q = -PARTICLE_MASS*16*math.pi^3*eps_0*ORBITAL_RADIUS^3/(FIELD_OBJECT_CHARGE*ORBITAL_PERIOD^2);
  p = Particle:new(matrix{ORBITAL_RADIUS,0,0}, matrix{0,vy,0},matrix{0,0,0}, q, PARTICLE_MASS, f)

  t = 0
end

function lovr.draw()
  lovr.graphics.setBackgroundColor(1,1,1)

  -- Draw box
  lovr.graphics.setColor(0,0,0)
  lovr.graphics.cube("line",0,0,0,1)

  -- Draw field object
  lovr.graphics.setColor(1,0,0)
  lovr.graphics.sphere(f.position:getelement(1,1), f.position:getelement(2,1), f.position:getelement(3,1), f.radius)

  -- Draw particle
  lovr.graphics.setColor(0,0,1)
  lovr.graphics.sphere(p.position:getelement(1,1), p.position:getelement(2,1), p.position:getelement(3,1), p.radius)

  -- Draw circle of trajectory
  lovr.graphics.setColor(0.5,1,0.2)
  lovr.graphics.circle("line", 0, 0, 0, ORBITAL_RADIUS, 0, 0, 0, 0)
end

function lovr.update(dt)
  t = t + dt

  f:update(dt)
  p:RK_update(dt)
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

