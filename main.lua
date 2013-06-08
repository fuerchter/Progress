require "Character"
require "Polygon"

local world
local character
local polygon

function love.load()
	love.graphics.setMode(1280, 720, false, false, 0)
	
	love.physics.setMeter(64)
	world=love.physics.newWorld(0, 9.81*64, true)
	character=Character.new(world, {x=300, y=200}, {r=100, g=100, b=255}, 10)
	polygon=Polygon.new(world, {x=200, y=400}, {r=255, g=255, b=255}, 0, 0, 100, -10, 200, 0, 100, 100)
end

function love.update(dt)
	world:update(dt)
	
	character:update(dt)
end

function love.draw()
	character:draw()
	polygon:draw()
end