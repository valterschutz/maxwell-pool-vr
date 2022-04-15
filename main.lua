complex = require "complex"
matrix = require "matrix"
FieldObject = require "fieldobj"
Particle = require "particle"
helper = require "helper"
lovr.window = require "lovr-window"

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

function lovr.conf(t)
  -- additional window parameters
  t.window.fullscreentype = "desktop"	-- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
  t.window.x = nil			-- The x-coordinate of the window's position in the specified display (number)
  t.window.y = nil			-- The y-coordinate of the window's position in the specified display (number)
  t.window.minwidth = 1			-- Minimum window width if the window is resizable (number)
  t.window.minheight = 1			-- Minimum window height if the window is resizable (number)
  t.window.display = 1			-- Index of the monitor to show the window in (number)
  t.window.centered = false		-- Align window on the center of the monitor (boolean)
  t.window.topmost = false		-- Show window on top (boolean)
  t.window.borderless = false		-- Remove all border visuals from the window (boolean)
  t.window.resizable = false		-- Let the window be user-resizable (boolean)
  t.window.opacity = 1			-- Window opacity value (number)

  conf = t.window
end


function lovr.load()
  eps_0 = 8.8541878128*1e-12

  -- sets window opacity, resolution and title
	lovr.window.setMode(1280, 720, {title = "Hello, Window!", resizable = true, opacity = 1})

  shader = lovr.graphics.newShader(defaultVertex, defaultFragment, {})

  -- Set default shader values
  shader:send('liteColor', {1.0, 1.0, 1.0, 1.0})
  shader:send('ambience', {0.5, 0.5, 0.5, 1.0})
  shader:send('specularStrength', 0.1)
  shader:send('metallic', 24)

  -- Change this
  f = FieldObject:new('charge', false)

  particles = f:getparticles()

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
  if lovr.headset then
      hx, hy, hz = lovr.headset.getPosition()
      shader:send('viewPos', { hx, hy, hz } )
  end

  f:update(dt)

  for key,particle in pairs(particles) do
    particle:update(dt)
  end
end
