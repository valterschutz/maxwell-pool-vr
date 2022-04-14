local helper = require "helper"

local ElectricCharge = {_TYPE='module', _NAME='ElectricCharge', _VERSION='0.3.3.20111212'}

function ElectricCharge:new(pos, v, a, Q)
  local newObj = {position = pos, velocity = v, acceleration = a, charge = Q, radius = 0.02}
  self.__index = self
  return setmetatable(newObj, self)
end

function ElectricCharge:getField(x)
  -- x is a position where the field is to be calculated
  local K = 8.988*1e9  -- Coulomb's constant
end

function ElectricCharge:update(dt)
  helper.check_bounce(self)

  self.velocity = self.velocity + dt*self.acceleration
  self.position = self.position + dt*self.velocity
end

return ElectricCharge
