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
local progress=1
local levelCount=3
local saveFile

function love.load()
	--initialise graphics
	love.graphics.setMode(800, 600, false, false, 0)
	
	saveFile=love.filesystem.newFile("save.txt")
	if(not love.filesystem.isFile("save.txt"))
	then
		saveFile:open("w")
		saveFile:write(progress)
		saveFile:close()
	else
		saveFile:open("r")
		contents, size=saveFile:read()
		if(size>0)
		then
			--love.graphics.setCaption(tonumber(contents) .. " " .. contents)
			if(tonumber(contents)<=levelCount)
			then
				progress=tonumber(contents)
			end
		end
		saveFile:close()
	end
	
	--load level
	level=Level(progress)

end

function love.update(dt)
	level:update(dt)
	
	local x,y = level.character.fixture:getBody():getPosition()
	
	if y > 600 then
		if level.character.light then
			level = level:fullReset()
		else
			level = level:backToCheckpoint()
		end
	end
	
	if(level:entityTypeCount("Collectable")==0 and progress<levelCount)
	then
		progress=progress+1
		level=Level(progress)
		
		saveFile:open("w")
		saveFile:write(progress)
		saveFile:close()
	end
	
	if love.keyboard.isDown("r") then
		level = level:fullReset()
	end
end

function love.draw()
	level:draw()
	love.graphics.setColorMode("modulate")
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.print("Collectables left: " .. level:entityTypeCount("Collectable") .. " Charge left: " .. level.character.charge, 0, 0)
	--love.graphics.setCaption(level.character.lastLight .. " " .. tostring(level.character.canPlace))
	--love.graphics.setCaption(level.character.airTime .. " " .. tostring(level.character.canJump) .. " " .. level.character.foot.collisionCount)
	--love.graphics.setCaption("Collected: " .. level.character.collected .. " Collectables: " .. level:entityTypeCount("Collectable") .. " Charge: " .. level.character.charge)
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
			if(a:getUserData().type=="Collectable" and a:getUserData().active)
			then
				level:removeEntity(a:getUserData())
				a:getUserData().active=false
				level.character.collected=level.character.collected+1
			elseif(b:getUserData().type=="Collectable" and b:getUserData().active)
			then
				level:removeEntity(b:getUserData())
				b:getUserData().active=false
				level.character.collected=level.character.collected+1
			end
		end
		
		if((a:getUserData().type=="Character" and  b:getUserData().type=="Battery")
		or (a:getUserData().type=="Battery" and  b:getUserData().type=="Character"))
		then
			if(a:getUserData().type=="Battery" and a:getUserData().active)
			then
				b:getUserData().charge=b:getUserData().charge+a:getUserData().charge
				level:removeEntity(a:getUserData())
				a:getUserData().active=false
			elseif(b:getUserData().type=="Battery" and b:getUserData().active)
			then
				a:getUserData().charge=a:getUserData().charge+b:getUserData().charge
				level:removeEntity(b:getUserData())
				b:getUserData().active=false
			end
		end
		
		if((a:getUserData().type=="Character" and  b:getUserData().type=="Enemy")
		or (a:getUserData().type=="Enemy" and  b:getUserData().type=="Character"))
		then
			if(a:getUserData().type=="Character" and not a:getUserData().light)
			then
				level=level:backToCheckpoint()
			elseif(b:getUserData().type=="Character" and not b:getUserData().light)
			then
				level=level:backToCheckpoint()
			end
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