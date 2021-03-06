local helper = require "helper"
local matrix = require "matrix"
local complex = require "complex"
local Particle = require 'particle'

local FieldObject = {_TYPE='module', _NAME='FieldObject'}

function FieldObject:new(variant,interactive)
  -- Variant can be: 'charge', 'edipole' or 'current'
  -- VR is a boolean
  local newObj = {variant = variant, interactive = interactive}
  NPARTICLES = 100
  if variant == "charge" then
    newObj.position = matrix{0,0,0}
    if interactive then
      newObj.velocity = matrix{0,0,0}
    else
      newObj.velocity = matrix{0.1,0,0}
    end
    newObj.charge = 1e-6
    newObj.radius = 0.02
  elseif variant == "edipole" then
    newObj.position = matrix{0,0,0}
    if interactive then
      newObj.velocity = matrix{0,0,0}
    else
      newObj.velocity = matrix{0.1,0,0}
    end
    newObj.dipolemoment = matrix{0,0,1}*1e-7
    newObj.radius = 0.02
  elseif variant == "current" then
    -- Position meaning intersection in xy-plane
    if interactive then
      newObj.position = matrix{0,0,0}
      newObj.velocity = matrix{0,0,0}
    else
      newObj.position = matrix{-0.5,0,0}
      newObj.velocity = matrix{0.1,0,0}
    end
    -- newObj.current = 4e10
    newObj.current = 4e13
    newObj.radius = 0.01
  elseif variant == 'mdipole' then
    newObj.position = matrix{0,0,0}
    if interactive then
      newObj.velocity = matrix{0,0,0}
    -- else
    --   newObj.velocity = matrix{0.1,0,0}
    end
    local e1 = matrix{{0,1},{1,0}}
    local e2 = matrix{{0,"-i"},{"i",0}}:replace(complex)
    newObj.dipolemoment = 5e12 * e1 * e2;
    newObj.radius = 0.02
  end
    self.__index = self
    return setmetatable(newObj, self)
end

function FieldObject:getparticles()
  local particles = {}
  if self.variant == 'charge' then
    if self.interactive then
      local pos = matrix{0.2,0,0}
      local v = matrix{0,0,0}
      local particle = Particle:new(pos, v, self)
      table.insert(particles,particle)
    else
      local r = 0.3
      for k=1,NPARTICLES do
        -- local theta = lovr.math.random() * math.pi
        local phi = lovr.math.random() * 2*math.pi
        local x = r*math.cos(phi)
        local y = r*math.sin(phi)
        -- local z = r*math.cos(theta)
        local pos = matrix{x,y,0}
        local particle = Particle:new(pos, matrix{0,0,0}, self)
        table.insert(particles,particle)
      end
    end
  elseif self.variant == 'edipole' then
    if self.interactive then
      local pos = matrix{0.2,0,0}
      local v = matrix{0,0,0}
      local particle = Particle:new(pos, v, self)
      table.insert(particles,particle)
    else
      local r = 0.3
      for k=1,NPARTICLES do
        -- local theta = lovr.math.random() * math.pi
        local phi = lovr.math.random() * 2*math.pi
        local x = r*math.cos(phi)
        local y = r*math.sin(phi)
        -- local z = r*math.cos(theta)
        local pos = matrix{x,y,0}
        local particle = Particle:new(pos, matrix{0,0,0}, self)
        table.insert(particles,particle)
      end
    end
  elseif self.variant == 'current' then
    if self.interactive then
      local pos = matrix{0.2,0,0}
      local v = matrix{0,0,0.2}
      local particle = Particle:new(pos, v, self)
      table.insert(particles,particle)
    else
      local pos = matrix{-0.4,0,0}
      local v = matrix{0.1,0,0}
      local particle = Particle:new(pos, v, self)
      table.insert(particles,particle)
    end
  elseif self.variant == 'mdipole' then
    if self.interactive then
      local pos = matrix{0,-0.25,0}
      local v = matrix{0,0.1,0}
      local particle = Particle:new(pos, v, self)
      table.insert(particles,particle)
    else
      local r = 0.3
      for k=1,NPARTICLES do
        -- local theta = lovr.math.random() * math.pi
        local phi = lovr.math.random() * 2*math.pi
        local x = r*math.cos(phi)
        local y = r*math.sin(phi)
        -- local z = r*math.cos(theta)
        local pos = matrix{x,y,0}
        local particle = Particle:new(pos, matrix{0,0,0}, self)
        table.insert(particles,particle)
      end
    end
  end

  return particles
end

function FieldObject:getfield(x)
  if self.variant == "charge" then
    -- x is a position where the field is to be calculated
    local y = self.position
    local eps_0 = 8.8541878128*1e-12
    local E = self.charge / (4*math.pi*eps_0) * (x-y)/matrix.scalar(x-y,x-y)^(3/2)
    -- If the charge moves there is also a B-field but it is many magnitudes
    -- smaller for velocities << c
    return helper.vectortomultivector(eps_0^(1/2)*E)
  elseif self.variant == "edipole" then
    -- -- field_obj.p is the dipolemoment.
    local d = helper.vectortomultivector(self.dipolemoment);
    local R = helper.vectortomultivector(x-self.position)
    local A=d*R+R*d  -- 2 * field_obj.p DOTPRODUCT R
    return 1/(4*math.pi*math.sqrt(eps_0)) * (3/2*(R)*(A)/((R^2):elempow(5/2))-d/((R^2):elempow(3/2)));
  elseif self.variant == 'current' then
    -- First calculate where particle position is in xy-plane, call this xp
    local a,b = x:getelement(1,1), x:getelement(2,1)
    local xp = helper.vectortomultivector(matrix{a,b,0});
    local y = helper.vectortomultivector(self.position);
    local e3 = matrix{{1,0}, {0,-1}};
    local I = self.current;

    -- Define the outer product for a vector u and vector v
    local outerproduct = function(u,v) return 1/2*(u*v-v*u) end

    local F = math.sqrt(mu_0)*I/(2*math.pi)*outerproduct(e3,xp-y)/((xp-y)^2):getelement(1,1)

    -- If the current moves we get another contributing term
    R = y - xp;
    vcurrent = helper.vectortomultivector(self.velocity);
    F = F + math.sqrt(eps_0)*(mu_0*I)/(4*math.pi) * (vcurrent * R + R * vcurrent)/(R^2):getelement(1,1) * e3;
    return F
  elseif self.variant == "mdipole" then
    local D = self.dipolemoment
    local r = x-self.position
    local R = helper.vectortomultivector(r)
    local innerproduct = function(u,v) return 1/2*(u*v+v*u) end
    local outerproduct = function(u,v) return 1/2*(u*v+v*u) end
    local B = mu_0/(4*math.pi) * (3*innerproduct(R, outerproduct(R,D))/matrix.scalar(r,r)^(5/2) - D/matrix.scalar(r,r)^(3/2));
    local F = B/math.sqrt(mu_0);
    return F
  end
end

function FieldObject:update(dt)
  if not self.interactive then
    self.position = self.position + dt*self.velocity
    helper.checkbounce(self)
  else
    if self.variant == 'charge' or self.variant == 'edipole' or self.variant == 'mdipole' then
      local down = lovr.headset.isDown("right", "grip")
      if down then
        local x, y, z = lovr.headset.getPosition("right")
        self.position = matrix{x,y-1,z}
      end
    elseif self.variant == 'current' then
      local down = lovr.headset.isDown("right", "grip")
      if down then
        local x, y, _ = lovr.headset.getPosition("right")
        self.position = matrix{x,y-1,0}
      end
    end
  end
end

function FieldObject:draw()
  lovr.graphics.setColor(1,0,0)
  if self.variant == 'charge' then
    lovr.graphics.sphere(f.position:getelement(1,1), f.position:getelement(2,1), f.position:getelement(3,1), f.radius)
  elseif self.variant == 'edipole' or self.variant == 'mdipole' then
    local length = 0.1
    local radius = 0.01
    lovr.graphics.cylinder(f.position:getelement(1,1), f.position:getelement(2,1), f.position:getelement(3,1), length, 0, 0, 0, 1, radius, radius, true, nil)
    lovr.graphics.cylinder(f.position:getelement(1,1), f.position:getelement(2,1), f.position:getelement(3,1)+length/2, radius*2, 0, 0, 0, 1, radius*2, 0, true, nil)
  elseif self.variant == 'current' then
    x,y = self.position:getelement(1,1), self.position:getelement(2,1)
    lovr.graphics.cylinder(x,y,0,1,0,0,0,0,self.radius,self.radius)
  end
end

return FieldObject
