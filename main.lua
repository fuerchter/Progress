require "Character"
require "Polygon"
require "Point"
require "Points"

local world
local character
local polygon

function love.load()
	love.graphics.setMode(800, 600, false, false, 0)
	
	love.physics.setMeter(64)
	world=love.physics.newWorld(0, 9.81*64, true)
	world:setAllowSleeping(false)
	
	character=Character.new	(world, {x=300, y=000}, {r=100, g=100, b=255}, 0.2, 32)
	points=Points.new()
	points:insert(Point.new(0, 0))
	points:insert(Point.new(200, 0))
	points:insert(Point.new(100, 100))
	polygon=Polygon.new		(world, {x=200, y=400}, {r=255, g=255, b=255}, 0.2, points)
	
	
	--[[x, y, x2, y2=points:getPoints()
	love.graphics.setCaption(x .. " " .. y .. " " .. x2 .. " " .. y2)]]
end

function love.update(dt)
	world:update(dt)
	
	character:update(dt)
end

function love.draw()
	character:draw()
	polygon:draw()
end