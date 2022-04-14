local helper = require "helper"
local matrix = require "matrix"
local complex = require "complex"

local ElectricCharge = {_TYPE='module', _NAME='ElectricCharge', _VERSION='0.3.3.20111212'}

function ElectricCharge:new(pos, v, a, Q)
  local newObj = {position = pos, velocity = v, acceleration = a, charge = Q, radius = 0.02}
  self.__index = self
  return setmetatable(newObj, self)
end

function ElectricCharge:getfield(x)
  -- x is a position where the field is to be calculated
  local y = self.position
  local eps_0 = 8.8541878128*1e-12
  local E = self.charge / (4*math.pi*eps_0) * (x-y)/matrix.scalar(x-y,x-y)^(3/2)
  return helper.vectortomultivector(eps_0^(1/2)*E)
end

function ElectricCharge:update(dt)
  helper.check_bounce(self)

  self.velocity = self.velocity + dt*self.acceleration
  self.position = self.position + dt*self.velocity
end

return ElectricCharge
