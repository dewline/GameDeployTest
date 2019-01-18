-- Global variables
platform = {} -- a table that stores the bottom platform
player = {}   -- a table that stores the player position
viewport = {} -- a table that stores the current viewport for sprites
map = {}      -- a table that stores coordinates for the bg map
tiles = {}    -- stores an array of tiles

-- gets called only once when the game is started
function love.load()
   -- set up overall window attributes
   local w = 800
   local h = 640
   love.window.setMode(w, h, {highdpi=true})
   love.graphics.setBackgroundColor(0.15, 0.1, 0.12)

   -- map dimensions and coordinates
   map.w = 2 * w
   map.h = 2 * h
   map.x = 0
   map.y = (-1 * map.h) + h

   -- setting up the platform (bottom half of the screen)
   platform.x = map.x
   platform.height = h/5
   platform.y = map.h - platform.height
   platform.width = map.w

   -- set up the viewport and bg images
   viewport.bg1 = love.graphics.newImage("texture0.png")
   viewport.bg2 = love.graphics.newImage("texture1.png")
   viewport.bg1:setWrap('repeat', 'repeat')
   viewport.bg2:setWrap('repeat', 'repeat')
   viewport.quad1 = love.graphics.newQuad(platform.x, platform.y,
					  platform.width, platform.height,
					  viewport.bg1:getWidth(),
					  viewport.bg1:getHeight())
   viewport.quad2 = love.graphics.newQuad(0, 0,
					  w, h - platform.height,
					  viewport.bg2:getWidth(),
					  viewport.bg2:getHeight())
   
   -- sprite image, see: https://love2d.org/wiki/Tutorial:Animation
   player.imgw = 16
   player.imgh = 18
   player.img = newAnimation(love.graphics.newImage("oldHero.png"),
			     player.imgw, player.imgh, 1)
   -- some state variables for image and time tracking
   player.scale = 2
   player.w = player.scale * player.imgw
   player.h = player.scale * player.imgh
   player.x = love.graphics.getWidth() / 2;
   player.y = (platform.y + map.y)
      - player.scale * player.img.spriteSheet:getHeight()
   player.speed = player.scale * 300
   -- gravity-based properties for the player sprite
   player.ground = h -- player.y + player.h -- Landing height
   player.y_velocity = 0
   player.jump_height = -500 * player.scale
   player.gravity = -1100 * player.scale
   player.direction = true; -- true for positive x, false for negative x

   -- imagefont, see: https://love2d.org/wiki/Tutorial:Fonts_and_Text
   font = love.graphics.newImageFont("Imagefont.png",
				     " abcdefghijklmnopqrstuvwxyz" ..
					"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
					"123456789.,!?-+/():;%&`'*#=[]\"")
   love.graphics.setFont(font)
   
   -- sound (ahahahah)
   source = love.audio.newSource("Table_hit.ogg", "stream")
   love.audio.play(source)

   -- background tiles
   for i=0,3 do
      tiles[i] = love.graphics.newImage("tile"..i..".png")
   end
   tiles.scale = 1
   tiles.w = tiles[0]:getWidth()   -- 64 px
   tiles.h = tiles[0]:getHeight()

   tiles.map = {
      {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, 
      {0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,0}, 
      {0,0,0,0,1,1,0,0,0,2,2,0,0,0,0,0,0,0,0,0,0,2,3,3,0}, 
      {0,0,0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,0}, 
      {0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,2,2,0,0,0}, 
      {0,2,1,1,1,0,0,0,0,0,0,0,0,3,0,0,1,1,1,1,2,2,0,0,0}, 
      {0,2,0,0,1,0,0,0,0,0,0,0,0,3,0,0,1,1,1,1,2,2,3,3,0}, 
      {0,2,0,0,1,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0}, 
      {0,1,1,1,1,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,0,0,0}, 
      {0,0,0,0,0,0,0,0,3,1,0,2,2,2,2,3,0,0,0,1,1,1,1,0,0}, 
      {0,0,0,0,0,0,0,3,3,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, 
      {0,0,0,0,0,0,3,0,3,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,3}, 
      {0,0,0,0,0,3,3,3,3,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,3}, 
      {0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,2,0,0,0,0,3,0}, 
      {0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,3,0,0,3,0,0}, 
      {0,2,0,0,0,0,0,1,1,1,0,0,0,0,0,0,2,0,2,0,0,3,0,0,0}, 
      {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0}, 
      {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
      {3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3}, -- floor
      {3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
   }
   tiles.findground = function (tiles, player)
      -- find x-th tile
      x, y = player.x - map.x, (player.y + player.h) - map.y
      xindex = math.ceil(x / tiles.w)
      yindex = math.ceil(y / tiles.h)
      if xindex == 0 then xindex = 1 end
      if yindex == 0 then yindex = 1 end
      for yindex=yindex+1,#tiles.map do
	 if tiles.map[yindex][xindex] > 0 then
	    return (yindex-1)*tiles.h -- top edge of box
	 end
      end
      return 10000 - map.y
   end
end

-- called continuously, where the math is done
function love.update(dt)

   -- calculate sprite texture width and height properties
   local sw, sh = player.imgw, player.imgh
   sw, sh = sw * player.scale, sh * player.scale -- rescale!

   local w = love.graphics.getWidth()
   local h = love.graphics.getHeight()
   local limitfrac = 0.5
   if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
      if player.x > w*limitfrac then
	 player.x = player.x - player.speed * dt
      else
	 if map.x < 0 then
	    map.x = map.x + player.speed * dt
	 elseif player.x > 0 then
	    player.x = player.x - player.speed * dt
	 end
      end
      player.direction = false
   elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
      if player.x < w*(1 - limitfrac) -sw then
	 player.x = player.x + player.speed * dt
      else
	 if map.x > (w - map.w) then
	    map.x = map.x - player.speed * dt
	 elseif player.x < w - sw then
	    player.x = player.x + player.speed * dt
	 end
      end
      player.direction = true
   end

   -- move map y coordinates
   yfrac = 0.2
   if player.y < yfrac * h then
      map.y = map.y + ((yfrac * h) - player.y)
      player.y = yfrac * h
   elseif player.y > (1-yfrac)*h then
      map.y = map.y + (((1-yfrac)*h) - player.y)
      player.y = (1-yfrac) * h
   end

   -- jump! physics
   if love.keyboard.isDown('space') then
      if player.y_velocity == 0 then
	 player.y_velocity = player.jump_height
      end
   end
   
   -- recalculate ground based on (x,y)
   newground = tiles:findground(player)
   -- update current position and velocity
   if (player.y_velocity ~= 0) then
      possible_y = player.y + player.y_velocity * dt
      player.y = possible_y
      player.y_velocity = player.y_velocity - player.gravity * dt
   elseif player.y - map.y < newground then
      player.y_velocity = player.y_velocity - player.gravity * dt
   end
   -- ground collision
   if (player.y + player.h) - map.y > newground then
      player.y_velocity = 0
      player.y = newground + map.y - player.h
   end
   -- ceiling collision
   if player.y - map.y < 0 then
      player.y_velocity = 0
      player.y = map.y
   end

   -- update current time
   player.img.currentTime = player.img.currentTime + dt
   if player.img.currentTime >= player.img.duration then
      player.img.currentTime = player.img.currentTime - player.img.duration
   end
end

-- all the drawing happens here
function love.draw()
   love.graphics.push("all")
   love.graphics.translate(map.x, map.y)
   -- draw the background tile map
   for y=0,(map.h/(tiles.h*tiles.scale))-1 do
       for x=0,(map.w/(tiles.w*tiles.scale))-1 do
           love.graphics.draw(tiles[tiles.map[y+1][x+1]],
                              (x*tiles.scale*tiles.w),
                              (y*tiles.scale*tiles.h))
       end
   end

   -- draw the platform
   love.graphics.draw(viewport.bg1, viewport.quad1, platform.x, platform.y)
   love.graphics.pop()

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
      -- debug.debug()
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
