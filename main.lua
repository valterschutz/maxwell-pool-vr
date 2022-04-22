complex = require "complex"
matrix = require "matrix"
FieldObject = require "fieldobj"
Particle = require "particle"
helper = require "helper"

function lovr.load(t)
  -- t is a table containing restart as a key if lovr.event.restart
  -- is called.
  eps_0 = 8.8541878128*1e-12

  -- Change this. Choose between 'charge', 'edipole', 'current' as a default
  -- field source.
  -- Boolean determines interactive mode
  local fieldobjecttype = t.restart or 'charge'
  f = FieldObject:new(fieldobjecttype, true)

  particles = f:getparticles()

  -- t = 0
end

function lovr.draw()
  lovr.graphics.translate(0,1,0)
  -- Reset shader
  -- lovr.graphics.setShader()

  lovr.graphics.setBackgroundColor(0,0,0)

  -- Draw box
  lovr.graphics.setColor(1,1,1)
  lovr.graphics.cube("line",0,0,0,1)

  -- Set shader
  -- lovr.graphics.setShader(shader)

  -- Draw field object
  f:draw()

  -- Draw particles
  lovr.graphics.setColor(0,0,1)
  for key,particle in pairs(particles) do
    particle:draw()
  end

end

function lovr.update(dt)
  -- t = t + dt

  -- Adjust head position (for specular)
  -- if lovr.headset then
  --     hx, hy, hz = lovr.headset.getPosition()
  --     shader:send('viewPos', { hx, hy, hz } )
  -- end

  f:update(dt)

  for key,particle in pairs(particles) do
    particle:update(dt)
  end

  if lovr.headset.isDown('right', 'trigger') then
    lovr.event.restart()
  end
end

function lovr.restart()
  if lovr.headset.isDown('right','a') and lovr.headset.isDown('right','b') then
    return 'mdipole'
  elseif lovr.headset.isDown('right', 'a') then
    return 'charge'
  elseif lovr.headset.isDown('right', 'b') then
    return 'edipole'
  elseif lovr.headset.isDown('right', 'thumbstick') then
    return 'current'
  end
end
