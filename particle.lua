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

function Particle:RK_update(dt)
  -- S is the state, S = [x,y,z,vx,vy,vz]. D is dS/dt
  local S = matrix.concatv(self.position, self.velocity)
  local k1 = self:D(S)
  local k2 = self:D(S+(k1*(dt/2)))
  local k3 = self:D(S+(k2*(dt/2)))
  local k4 = self:D(S+(k3*dt))
  S = S + (k1 + k2*2 + k3*2 + k4) * (dt/6)
  self.position = matrix{S:getelement(1,1), S:getelement(2,1), S:getelement(3,1)}
  self.velocity = matrix{S:getelement(4,1), S:getelement(5,1), S:getelement(6,1)}
end

function Particle:D(S)
  -- print("In D(S)")
  -- print((S^'T'):tostring())

  -- Position and velocity of particle
  local x,y,z = S:getelement(1,1), S:getelement(2,1), S:getelement(3,1)
  local vx,vy,vz = S:getelement(4,1), S:getelement(5,1), S:getelement(6,1)

  local field = (eps_0)^(-1/2)*helper.multivectortovector(self.fieldobject:getfield(matrix{x,y,z}))
  local force = field*self.charge
  local acceleration = force/self.mass

  local v = matrix{vx,vy,vz}
  return matrix.concatv(v,acceleration)
end

return Particle
