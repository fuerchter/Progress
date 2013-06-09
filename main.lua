require "entities/Character"
require "entities/Checkpoint"
require "entities/Collectable"
require "entities/Battery"
require "entities/Sensor"
require "entities/Enemy"
require "entities/Light"
require "mapobjects/Polygon"
require "mapobjects/Points"
require "mapobjects/Text"
require "Level"

local level

function love.load()
	--initialise graphics
	love.graphics.setMode(800, 600, false, false, 0)
	
	--load level
	level=Level("test")
	
	light = Light(level, {x = 100, y = 300})
	light:registerSource({x = 200, y = 320})
	light:registerSource({x = 300, y = 280})
	
	level:addEntity(light)
end

function love.update(dt)
	level:update(dt)
	
	if love.keyboard.isDown("r") then
		level = level:fullReset()
	end
	
	if love.keyboard.isDown("t") then
		level = level:backToCheckpoint()
	end
end

function love.draw()
	level:draw()
	love.graphics.setCaption(level.character.foot.collisionCount .. " " .. level.character.airTime)
end

function beginContact(a, b, coll)
	if(a:getUserData()~=nil and b:getUserData()~=nil) --both are entities
	then
		if((a:getUserData().type=="Character" and  b:getUserData().type=="Checkpoint") --character and checkpoint are colliding
		or (a:getUserData().type=="Checkpoint" and  b:getUserData().type=="Character"))
		then
			level.character:setLight(false)
			
			if(a:getUserData().type=="Checkpoint")
			then
				level:removeEntity(a:getUserData())
			else
				level:removeEntity(b:getUserData())
			end
		end
		
		if((a:getUserData().type=="Character" and  b:getUserData().type=="Collectable")
		or (a:getUserData().type=="Collectable" and  b:getUserData().type=="Character"))
		then
			level.character.collected=level.character.collected+1
			
			if(a:getUserData().type=="Collectable")
			then
				level:removeEntity(a:getUserData())
			else
				level:removeEntity(b:getUserData())
			end
		end
		
		if((a:getUserData().type=="Character" and  b:getUserData().type=="Battery")
		or (a:getUserData().type=="Battery" and  b:getUserData().type=="Character"))
		then
			if(a:getUserData().type=="Battery")
			then
				b:getUserData().charge=b:getUserData().charge+a:getUserData().charge
				level:removeEntity(a:getUserData())
			else
				a:getUserData().charge=a:getUserData().charge+b:getUserData().charge
				level:removeEntity(b:getUserData())
			end
		end
		
		if((a:getUserData().type=="Character" and  b:getUserData().type=="Enemy")
		or (a:getUserData().type=="Enemy" and  b:getUserData().type=="Character"))
		then
			--reset to checkpoint
		end
	elseif(a:getUserData()~=nil and b:getUserData()==nil) --a is entity
	then
		if(a:getUserData().type=="Sensor") --if a sensor is colliding
		then
			a:getUserData().collisionCount=a:getUserData().collisionCount+1
		end
	elseif(a:getUserData()==nil and b:getUserData()~=nil) --b is entity
	then 
		if(b:getUserData().type=="Sensor")
		then
			b:getUserData().collisionCount=b:getUserData().collisionCount+1
		end
	end
	--both are not entities: not a single fuck was given that day
end

function endContact(a, b, coll)
	if(a:getUserData()~=nil and b:getUserData()==nil) --a is entity
	then
		if(a:getUserData().type=="Sensor")
		then
			a:getUserData().collisionCount=a:getUserData().collisionCount-1
		end
	elseif(a:getUserData()==nil and b:getUserData()~=nil) --b is entity
	then 
		if(b:getUserData().type=="Sensor")
		then
			b:getUserData().collisionCount=b:getUserData().collisionCount-1
		end
	end
end