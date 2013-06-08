require "entities/Character"
require "entities/Checkpoint"
require "entities/Collectable"
require "entities/Battery"
require "entities/Sensor"
require "entities/Enemy"
require "Polygon"
require "Points"
require "Level"

local level

function love.load()
	love.graphics.setMode(800, 600, false, false, 0)
	
	
	
	--character = Character(world, {x=300, y=000}, {r=100, g=100, b=255}, 0.2, 32)

	level=Level("test")
	
	character = Character(level, {x=300, y=000}, {r=100, g=100, b=255}, 0.2, 32)
	level:addEntity(character)
end

function love.update(dt)
	--character:update(dt)
	level:update(dt)
end

function love.draw()
	level:draw()
	--character:draw()
	
	love.graphics.setCaption(character.collected)
end

function beginContact(a, b, coll)
	if(a:getUserData()~=nil and b:getUserData()~=nil) --both are entities
	then
		if((a:getUserData().type=="Character" and  b:getUserData().type=="Checkpoint") --character and checkpoint are colliding
		or (a:getUserData().type=="Checkpoint" and  b:getUserData().type=="Character"))
		then
			character.light=false
			character.color={r=50, g=50, b=50, a=255}
			
			--TODO: destroy checkpoint (optional)
		end
		
		if((a:getUserData().type=="Character" and  b:getUserData().type=="Collectable")
		or (a:getUserData().type=="Collectable" and  b:getUserData().type=="Character"))
		then
			character.collected=character.collected+1
			
			--TODO: find out which collectable we have collided with and destroy it
		end
		
		if((a:getUserData().type=="Character" and  b:getUserData().type=="Battery")
		or (a:getUserData().type=="Battery" and  b:getUserData().type=="Character"))
		then
			--TODO: find out which battery we have collided with and destroy it, increase character.charge by an amount set in the corresponding battery
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