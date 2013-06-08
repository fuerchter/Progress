require "entities/Character"
require "entities/Checkpoint"
require "entities/Collectable"
require "entities/Battery"
require "Polygon"
require "Points"
require "Level"

local world
local character
local polygon
local checkpoint
local collectable

function love.load()
	love.graphics.setMode(800, 600, false, false, 0)
	
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)
	world:setAllowSleeping(false)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	
	character = Character(world, {x=300, y=000}, {r=100, g=100, b=255}, 0.2, 32)
	points = Points.new()
	points:insert({x=0, y=0})
	points:insert({x=200, y=0})
	points:insert({x=100, y=100})
	polygon = Polygon(world, {x=200, y=400}, {r=255, g=255, b=255}, 0.2, points)
	
	--checkpoint=Checkpoint(world, {x=200, y=350}, 32)
	collectable=Collectable(world, {x=200, y=350}, 32)


	level=Level(world, "test")
end

function love.update(dt)
	world:update(dt)
	
	character:update(dt)
end

function love.draw()
	polygon:draw()
	--checkpoint:draw()
	collectable:draw()
	character:draw()
	character:drawFoot()
	
	love.graphics.setCaption(character.collected)	
end

function beginContact(a, b, coll)
	if((a:getUserData()=="Foot" and b:getUserData()~="Character") --if foot is colliding but not with character
	or (a:getUserData()~="Character" and b:getUserData()=="Foot"))
	then
		character.groundCollisions=character.groundCollisions+1
	end

	
	if((a:getUserData()=="Character" and  b:getUserData()=="Checkpoint") --character and checkpoint are colliding
	or (a:getUserData()=="Checkpoint" and  b:getUserData()=="Character"))
	then
		character.light=false
		character.color={r=50, g=50, b=50, a=255}
		
		--TODO: destroy checkpoint (optional)
	end
	
	if((a:getUserData()=="Character" and  b:getUserData()=="Collectable")
	or (a:getUserData()=="Collectable" and  b:getUserData()=="Character"))
	then
		character.collected=character.collected+1
		
		--TODO: find out which collectable we have collided with and destroy it
	end
	
	if((a:getUserData()=="Character" and  b:getUserData()=="Battery")
	or (a:getUserData()=="Battery" and  b:getUserData()=="Character"))
	then
		--TODO: find out which battery we have collided with and destroy it, increase character.charge by an amount set in the corresponding battery
	end
end

function endContact(a, b, coll)
	if((a:getUserData()=="Foot" and b:getUserData()~="Character")
	or (a:getUserData()~="Character" and b:getUserData()=="Foot"))
	then
		character.groundCollisions=character.groundCollisions-1
	end
end