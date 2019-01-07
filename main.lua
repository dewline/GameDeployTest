
-- gets called only once when the game is started
function love.load()
   -- set up overall window attributes
   love.window.setMode(800, 600, {highdpi=true})
   love.graphics.setBackgroundColor(0.15, 0.1, 0.12)
   
   -- some state variables for image and time tracking
   imgx = 400-8; imgy = 300-9;
   delta = 300
   
   -- sprite image, see: https://love2d.org/wiki/Tutorial:Animation
   animation = newAnimation(love.graphics.newImage("oldHero.png"),
			    16, 18, 1)
   
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
   -- move image position based on arrow keys
   if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
      imgy = imgy - delta * dt
   elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
      imgy = imgy + delta * dt
   elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
      imgx = imgx - delta * dt
   elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
      imgx = imgx + delta * dt
   end

   if imgx > 800 then
       imgx = 0
   elseif imgx < 0 then
       imgx = 800
   elseif imgy > 600 then
       imgy = 0
   elseif imgy < 0 then
       imgy = 600
   end

   -- update animation time
   animation.currentTime = animation.currentTime + dt
   if animation.currentTime >= animation.duration then
      animation.currentTime = animation.currentTime - animation.duration
   end
end

-- all the drawing happens here
function love.draw()
   local animfrac = animation.currentTime / animation.duration * #animation.quads
   local spriteNum = math.floor(animfrac) + 1
   love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum],
		      imgx - 8, imgy - 9, 0, 2)
   love.graphics.print("Click to move the sprite or use arrow/WASD keys", 0, 0)
end

-- on mouse press
function love.mousepressed(x, y, button, istouch)
   if button == 1 then
      imgx = x
      imgy = y
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
