local helper = require "helper"
local matrix = require "matrix"
local complex = require "complex"

local FieldObject = {_TYPE='module', _NAME='ElectricCharge'}

function FieldObject:new(variant)
  local newObj = {variant = variant}
  if variant == "charge" then
    newObj.position = matrix{0,0,0}
    newObj.charge = 1e-6
    newObj.radius = 0.02
  elseif variant == "edipole" then
  else
    print("Variant not detected")
  end
  self.__index = self
  return setmetatable(newObj, self)
end

function FieldObject:getfield(x)
  if self.variant == "charge" then
    -- x is a position where the field is to be calculated
    local y = self.position
    local eps_0 = 8.8541878128*1e-12
    local E = self.charge / (4*math.pi*eps_0) * (x-y)/matrix.scalar(x-y,x-y)^(3/2)
    -- print("E is " .. (E^'T'):tostring())
    return helper.vectortomultivector(eps_0^(1/2)*E)
  elseif self.variant == "edipole" then
    -- -- field_obj.p is the dipolemoment.
    -- d = vector_to_multivector(field_obj.d);
    -- R=vector_to_multivector(x-field_obj.x); %from dipole to testparticle
    -- A=d*R+R*d; % 2 * field_obj.p DOTPRODUCT R
    -- F=1/(4*pi*sqrt(epsilon_0)) * (3/2*(R)*(A)/((R^2).^(5/2))-d/((R^2).^(3/2)));
    print("hello")
  else
    -- print("Error! Variant was not charge but " .. self.variant)
    print("Table has " .. #self.variant .. " items")
    -- print("Item 1: .. " .. self.variant[1])
    for i,v in ipairs(self.variant) do
      print(i,v)
    end
  end
end

function FieldObject:update(dt)
  -- helper.checkbounce(self)
  local down = lovr.headset.isDown("right", "grip")
  if down then
    local x, y, z = lovr.headset.getPosition("right")
    self.position = matrix{x,y,z}
  end

  -- self.velocity = self.velocity + dt*self.acceleration
  -- self.position = self.position + dt*self.velocity
end

return FieldObject
