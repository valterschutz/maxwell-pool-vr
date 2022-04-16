complex = require "complex"
matrix = require "matrix"
FieldObject = require "fieldobj"
Particle = require "particle"
helper = require "helper"

function lovr.load()
  eps_0 = 8.8541878128*1e-12

  -- shader = lovr.graphics.newShader('standard', {
  --   flags = {
  --     normalMap = false,
  --     indirectLighting = true,
  --     occlusion = true,
  --     emissive = false,
  --     skipTonemap = false,
  --     uniformScale = true
  --   }
  -- })

  -- shader:send('lovrLightDirection', { 1, 2, 1 })
  -- shader:send('lovrLightColor', { .9, .9, .8, 1.0 })
  -- shader:send('lovrExposure', 2) -- 2

  -- lovr.graphics.setCullingEnabled(true)
  -- lovr.graphics.setBlendMode()

  -- Change this
  f = FieldObject:new('charge', false)

  particles = f:getparticles()

  t = 0
end

function lovr.draw()
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
  t = t + dt

  -- Adjust head position (for specular)
  -- if lovr.headset then
  --     hx, hy, hz = lovr.headset.getPosition()
  --     shader:send('viewPos', { hx, hy, hz } )
  -- end

  f:update(dt)

  for key,particle in pairs(particles) do
    particle:update(dt)
  end
end
