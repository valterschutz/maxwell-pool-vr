local complex = require "complex"
local matrix = require "matrix"
local ElectricCharge = require "fieldobj"
local Particle = require "particle"
local helper = require "helper"

function lovr.load()
  PARTICLE_MASS = 1e-3
  PARTICLE_CHARGE = 1e-8
  FIELD_OBJECT_CHARGE = 1e-6
  NPARTICLES = 100
  eps_0 = 8.8541878128*1e-12

  -- set up shader
    defaultVertex = [[
        out vec3 FragmentPos;
        out vec3 Normal;

        vec4 position(mat4 projection, mat4 transform, vec4 vertex) { 
            Normal = lovrNormal;
            FragmentPos = (lovrModel * vertex).xyz;
        
            return projection * transform * vertex;
        }
    ]]
    defaultFragment = [[
        uniform vec4 liteColor;

        uniform vec4 ambience;
    
        in vec3 Normal;
        in vec3 FragmentPos;
        uniform vec3 lightPos;

        uniform vec3 viewPos;
        uniform float specularStrength;
        uniform float metallic;
        
        vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
        {    
            //diffuse
            vec3 norm = normalize(Normal);
            vec3 lightDir = normalize(lightPos - FragmentPos);
            float diff = max(dot(norm, lightDir), 0.0);
            vec4 diffuse = diff * liteColor;
            
            //specular
            vec3 viewDir = normalize(viewPos - FragmentPos);
            vec3 reflectDir = reflect(-lightDir, norm);
            float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
            vec4 specular = specularStrength * spec * liteColor;
            
            vec4 baseColor = graphicsColor * texture(image, uv);            
            //vec4 objectColor = baseColor * vertexColor;

            return baseColor * (ambience + diffuse + specular);
        }
    ]]
    shader = lovr.graphics.newShader(defaultVertex, defaultFragment, {})
    
    -- Set default shader values
    shader:send('liteColor', {1.0, 1.0, 1.0, 1.0})
    shader:send('ambience', {0.5, 0.5, 0.5, 1.0})
    shader:send('specularStrength', 0.5)
    shader:send('metallic', 32.0)

  f = ElectricCharge:new(matrix{0,0,0}, matrix{0,0,0}, matrix{0,0,0}, FIELD_OBJECT_CHARGE)

  particles = {}
  r = 0.3
  for k=1,NPARTICLES do
    local theta = lovr.math.random() * math.pi
    local phi = lovr.math.random() * 2*math.pi
    local x = r*math.sin(theta)*math.cos(phi)
    local y = r*math.sin(theta)*math.sin(phi)
    local z = r*math.cos(theta)
    local pos = matrix{x,y,z}
    local particle = Particle:new(pos, matrix{0,0,0}, PARTICLE_CHARGE, PARTICLE_MASS, f)
    table.insert(particles,particle)
  end

  t = 0
end

function lovr.draw()
  -- Reset shader
  lovr.graphics.setShader()

  lovr.graphics.setBackgroundColor(0,0,0)

  -- Draw box
  lovr.graphics.setColor(1,1,1)
  lovr.graphics.cube("line",0,0,0,1)

  -- Set shader
  lovr.graphics.setShader(shader)

  -- Draw field object
  lovr.graphics.setColor(1,0,0)
  lovr.graphics.sphere(f.position:getelement(1,1), f.position:getelement(2,1), f.position:getelement(3,1), f.radius)

  -- Draw particles
  lovr.graphics.setColor(0,0,1)
  for key,particle in pairs(particles) do
    lovr.graphics.sphere(particle.position:getelement(1,1), particle.position:getelement(2,1), particle.position:getelement(3,1), particle.radius)
  end
end

function lovr.update(dt)
  t = t + dt

  -- Adjust head position (for specular)
  if lovr.headset then
      hx, hy, hz = lovr.headset.getPosition()
      shader:send('viewPos', { hx, hy, hz } )
  end

  f:update(dt)

  for key,particle in pairs(particles) do
    particle:update(dt)
  end
end
