local helper = require "helper"
local matrix = require "matrix"
local complex = require "complex"

eps_0 = 8.8541878128*1e-12

Particle = {}

function Particle:new(pos, v, a, Q, m, fieldobj)
  local newObj = {position = pos, velocity = v, acceleration = a, charge = Q, radius = 0.01, mass = m, fieldobject = fieldobj}
  self.__index = self
  return setmetatable(newObj, self)
end

function Particle:update(dt)
  local field = (eps_0)^(-1/2)*helper.multivectortovector(self.fieldobject:getfield(self.position))
  local force = field*self.charge
  self.acceleration = force/self.mass
  -- Euler forward
  self.velocity = self.velocity + dt*self.acceleration
  self.position = self.position + dt*self.velocity

  helper.check_bounce(self)
end


function Particle:print()
  print("Position: (" .. self.position:getelement(1,1) .. "," .. self.position:getelement(2,1) .. "," .. self.position:getelement(3,1) .. "), velocity: (" .. self.velocity:getelement(1,1) .. "," .. self.velocity:getelement(2,1) .. "," .. self.velocity:getelement(3,1) .. ")")
end

return Particle
