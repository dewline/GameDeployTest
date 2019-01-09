platform = {}
player = {}

-- gets called only once when the game is started
function love.load()
   -- set up overall window attributes
   love.window.setMode(800, 600, {highdpi=true})
   love.graphics.setBackgroundColor(0.15, 0.1, 0.12)

   -- sprite image, see: https://love2d.org/wiki/Tutorial:Animation
   player.img = newAnimation(love.graphics.newImage("oldHero.png"),
			     16, 18, 1)   
   -- some state variables for image and time tracking
   player.scale = 2
   player.x = love.graphics.getWidth() / 2;
   player.y = (love.graphics.getHeight() / 2)
      - player.scale * player.img.spriteSheet:getHeight();
   player.speed = player.scale * 300
   -- gravity-based properties for the player sprite
   player.ground = player.y -- Landing height
   player.y_velocity = 0
   player.jump_height = -500 * player.scale
   player.gravity = -1100 * player.scale
   player.direction = true; -- true for positive x, false for negative x

   -- setting up the platform (bottom half of the screen)
   platform.width = love.graphics.getWidth()
   platform.height = love.graphics.getHeight()
   platform.x = 0
   platform.y = platform.height / 2
      
   -- imagefont, see: https://love2d.org/wiki/Tutorial:Fonts_and_Text
   font = love.graphics.newImageFont("Imagefont.png",
				     " abcdefghijklmnopqrstuvwxyz" ..
					"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
					"123456789.,!?-+/():;%&`'*#=[]\"")
   love.graphics.setFont(font)
   
   -- sound (ahahahah)
   source = love.audio.newSource("Table_hit.ogg", "stream")
   love.audio.play(source)
end

-- called continuously, where the math is done
function love.update(dt)

   -- calculate sprite texture width and height properties
   local _, _, sw, sh = player.img.quads[1]:getViewport()
   sw, sh = sw * player.scale, sh * player.scale -- rescale!
   
   -- move image position based on arrow keys
   -- if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
   --    if player.y > 0 then
   -- 	 player.y = player.y - player.speed * dt
   --    end
   -- elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
   --    if player.y < love.graphics.getHeight() - sh then
   -- 	 player.y = player.y + player.speed * dt
   --    end
   -- end
   if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
      if player.x > 0 then
	 player.x = player.x - player.speed * dt
      end
      player.direction = false
   elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
      if player.x < love.graphics.getWidth() - sw then
	 player.x = player.x + player.speed * dt
      end
      player.direction = true
   end

   -- jump! physics
   if love.keyboard.isDown('space') then
      if player.y_velocity == 0 then
	 player.y_velocity = player.jump_height
      end
   end
   -- update current position and velocity
   if player.y_velocity ~= 0 then
      player.y = player.y + player.y_velocity * dt
      player.y_velocity = player.y_velocity - player.gravity * dt
   end
   -- ground collision
   if player.y > player.ground then
      player.y_velocity = 0
      player.y = player.ground
   end

   -- update current time
   player.img.currentTime = player.img.currentTime + dt
   if player.img.currentTime >= player.img.duration then
      player.img.currentTime = player.img.currentTime - player.img.duration
   end
end

-- all the drawing happens here
function love.draw()
   -- draw the platform
   oldColor = { love.graphics.getColor() }
   love.graphics.setColor(0.1, 0.32, 0.2) -- set platform color to green
   love.graphics.rectangle('fill', platform.x, platform.y,
			   platform.width, platform.height)
   love.graphics.setColor(oldColor) -- reset previous color

   -- draw the sprite
   local animfrac = player.img.currentTime / player.img.duration
      * #player.img.quads
   local spriteNum = math.floor(animfrac) + 1
   local quad = player.img.quads[spriteNum]
   -- flip direction if player is facing to the left
   local xdelta = 0
   local xdirmult = 1
   if not player.direction then
      local vp = { quad:getViewport() }
      xdelta = vp[3]
      xdirmult = -1
   end
   love.graphics.draw(player.img.spriteSheet, quad,
		      player.x + (player.scale * xdelta), player.y,
		      0, 2*xdirmult, 2, 0)
   
   -- draw text
   love.graphics.print("Use left/right arrow keys or space to move...", 0, 0)
end

-- on mouse press
function love.mousepressed(x, y, button, istouch)
   if button == 1 then
      player.x = x
      player.y = y
   end
end

-- debug mode
function love.keypressed(key, u)
   -- Debug
   if key == "lctrl" then
      debug.debug()
   end
end

-- animation tutorial
function newAnimation(image, width, height, duration)
   local animation = {}
   animation.spriteSheet = image
   animation.quads = {}

   for y = 0, image:getHeight() - height, height do
      for x = 0, image:getWidth() - width, width do
	 table.insert(animation.quads,
		      love.graphics.newQuad(x, y,
					    width, height,
					    image:getDimensions()))
      end
   end

   animation.duration = duration or 1
   animation.currentTime = 0
   
   return animation
end
