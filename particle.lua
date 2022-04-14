local helper = require "helper"

Particle = {}

function Particle:new(pos, v, a, Q)
  local newObj = {position = pos, velocity = v, acceleration = a, charge = Q, radius = 0.01, mass = 0.001}
  self.__index = self
  return setmetatable(newObj, self)
end

function Particle:update(dt)
  helper.check_bounce(self)
  -- Euler forward
  self.velocity = self.velocity + dt*self.acceleration
  self.position = self.position + dt*self.velocity
end

function Particle:print()
  print("Position: (" .. self.position:getelement(1,1) .. "," .. self.position:getelement(2,1) .. "," .. self.position:getelement(3,1) .. "), velocity: (" .. self.velocity:getelement(1,1) .. "," .. self.velocity:getelement(2,1) .. "," .. self.velocity:getelement(3,1) .. ")")
end

return Particle
