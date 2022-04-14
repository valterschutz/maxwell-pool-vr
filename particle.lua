Particle = {}

function Particle:new(pos, v, a, Q)
  local newObj = {position = pos, velocity = v, acceleration = a, charge = Q, radius = 0.01, mass = 0.001}
  self.__index = self
  return setmetatable(newObj, self)
end

function Particle:update(dt)
  -- Euler forward
  self.velocity = self.velocity + dt*self.acceleration
  self.position = self.position + dt*self.velocity
end

return Particle
