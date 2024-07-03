gameWidth, gameHeight = 480, 270
love.window.setFullscreen(true)

raquete = {}
raquete[1] = {x = 10, y = gameHeight/2 - 25, w = 10, h = 50, score = 0, scorex = gameWidth/2 - 100}
raquete[2] = {x = gameWidth - 20, y = gameHeight/2 - 25, w = 10, h = 50, score = 0, scorex = gameWidth/2}

math.randomseed(os.time())

state = "pause"
ballx = gameWidth/2 - 2
bally = gameHeight/2 - 2
ballw = 4
ballh = 4
speedx = math.random(2) == 1 and 600 or -600
speedy = 0

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	love.graphics.setNewFont("Pixeled.ttf", 12, "mono")
	
	sound_hit = love.audio.newSource("hit.ogg", "static")
	sound_lose = love.audio.newSource("lose.ogg", "static")
	sound_win = love.audio.newSource("win.ogg", "static")
end

function love.update(dt)
	screenWidth, screenHeight = love.graphics.getDimensions()
	scalaX = screenWidth/gameWidth
	scalaY = screenHeight/gameHeight
	
	if screenWidth/screenHeight > 16/9 then
		shift = 35 * scalaX
		scalaX = (screenWidth - shift * 2)/gameWidth
	else
		shift = 0
	end
	
	toques = love.touch.getTouches()
	for i, id in ipairs(toques) do
		x, y = love.touch.getPosition(id)
		x = (x - shift)/scalaX
		y = y/scalaY

		for i, player in ipairs(raquete) do
			if x > player.x - 10 and x < player.x + player.w + 10 and y > player.y - 10 and y < player.y + player.h + 10 then
				player.y = y - player.h/2
			end
			
			if player.y < 0 then
				player.y = 0
			elseif player.y + player.h > gameHeight then
				player.y = gameHeight - player.h
			end
		end
	end
	
	if state == "playing" then
		bally = bally + speedy * dt
		ballx = ballx + speedx * dt
	end
	
	if ball_collision(raquete[1]) then
		speedx = -speedx
		ballx = raquete[1].x + raquete[1].w
		sound_hit:stop()
		sound_hit:play()
		if speedy < 0 then
			speedy = -math.random(150, 300)
		else
			speedy = math.random(150, 300)
		end
	end

	if ball_collision(raquete[2]) then
		speedx = -speedx
		ballx = raquete[2].x - ballw
		sound_hit:stop()
		sound_hit:play()
		if speedy < 0 then
			speedy = -math.random(150, 300)
		else
			speedy = math.random(150, 300)
		end
	end
	
	if bally + ballh > gameHeight then
		speedy = -speedy
		bally = gameHeight - ballh
		sound_hit:stop()
		sound_hit:play()
	elseif bally < 0 then
		speedy = -speedy
		bally = 0
		sound_hit:stop()
		sound_hit:play()
	end
	
	if ballx < 0 then
		ball_reset()
		raquete[2].score = raquete[2].score + 1
		if raquete[2].score < 5 then
			sound_lose:play()
		else
			sound_win:play()
		end
	elseif ballx + ballw > gameWidth then
		ball_reset()
		raquete[1].score = raquete[1].score + 1
		if raquete[1].score < 5 then
			sound_lose:play()
		else
			sound_win:play()
		end
	end
end

function love.draw()
	love.graphics.translate(shift, 0)
	love.graphics.scale(scalaX, scalaY)
	love.graphics.setColor(65/255, 52/255, 84/255)
	love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
	love.graphics.setColor(1,1,1)
	for i, player in ipairs(raquete) do
		love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
		love.graphics.printf(player.score, player.scorex, 80, 100, "center")
	end
	-- bola
	love.graphics.rectangle("fill", ballx, bally, ballw, ballh)

	if state == "pause" then
		love.graphics.printf("- TOQUE NA BOLA PARA COMEÇAR -", 0, gameHeight - 30, gameWidth/0.5, "center", 0, 0.5, 0.5)
	end
	
	if raquete[1].score == 5 then
		state = "victory"
		love.graphics.printf("FIM DE PARTIDA\nJOGADOR 1 É O VENCEDOR!", 0, 15, gameWidth/0.5, "center", 0, 0.5, 0.5)
		love.graphics.printf("- TOQUE NA BOLA PARA REINICIAR -", 0, gameHeight - 30, gameWidth/0.5, "center", 0, 0.5, 0.5)
	elseif raquete[2].score == 5 then
		state = "victory"
		love.graphics.printf("FIM DE PARTIDA\nJOGADOR 2 É O VENCEDOR!", 0, 15, gameWidth/0.5, "center", 0, 0.5, 0.5)
		love.graphics.printf("- TOQUE NA BOLA PARA REINICIAR -", 0, gameHeight - 30, gameWidth/0.5, "center", 0, 0.5, 0.5)
	end
end

function love.touchreleased(id, x, y)
	x = (x - shift)/scalaX
	y = y/scalaY

	if state == "pause" and x > gameWidth/2 - 40 and x < gameWidth/2 + 40 and y > gameHeight/2 - 40 and y < gameHeight/2 + 40 then
		state = "playing"
	elseif state == "victory" and x > gameWidth/2 - 40 and x < gameWidth/2 + 40 and y > gameHeight/2 - 40 and y < gameHeight/2 + 40 then
		state = "pause"
		raquete[1].y = gameHeight/2 - 25
		raquete[2].y = gameHeight/2 - 25
		raquete[1].score = 0
		raquete[2].score = 0
	end
end

function ball_collision(player)
	if ballx < player.x + player.w and ballx + ballw > player.x and bally < player.y + player.h and bally + ballh > player.y then
		return true
	end
	
	return false
end

function ball_reset()
	state = "pause"
	speedy = 0
	ballx = gameWidth/2 - 2
	bally = gameHeight/2 - 2
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.quit()
	end
end