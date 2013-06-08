require "entities/Character"
require "entities/Checkpoint"
require "Polygon"
require "Points"
require "Level"

local world
local character
local polygon
local checkpoint

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
	
	checkpoint=Checkpoint(world, {x=200, y=350}, 32)

	level=Level(world, "test")
end

function love.update(dt)
	world:update(dt)
	
	character:update(dt)
end

function love.draw()
	polygon:draw()
	checkpoint:draw()
	character:draw()
	character:drawFoot()
	
end

function beginContact(a, b, coll)
	if((a:getUserData()=="foot" and b:getUserData()~="character") --if foot is colliding but not with character
	or (a:getUserData()~="character" and b:getUserData()=="foot"))
	then
		character.groundCollisions=character.groundCollisions+1
	end
	
	if((a:getUserData()=="character" and  b:getUserData()=="checkpoint") --character and checkpoint are colliding
	or (a:getUserData()=="checkpoint" and  b:getUserData()=="character"))
	then
		character.color={r=50, g=50, b=50, a=255}
	end
end

function endContact(a, b, coll)
	if((a:getUserData()=="foot" and b:getUserData()~="character")
	or (a:getUserData()~="character" and b:getUserData()=="foot"))
	then
		character.groundCollisions=character.groundCollisions-1
	end
end