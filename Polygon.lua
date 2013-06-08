Polygon = {}
Polygon.__index = Polygon

--color will be boolean and loaded from config/level
function Polygon.new(world, position, color, friction, x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6, x7, y7, x8, y8)
	local self=setmetatable({}, Polygon)
	
	local body=love.physics.newBody(world, position.x, position.y, "static") --dynamic/static?
	local shape=love.physics.newPolygonShape(x1, y1, x2, y2, x3, y3--[[, x4, y4, x5, y5, x6, y6, x7, y7, x8, y8]]) --if Polygon.new arguments are empty this will create an error
	self.fixture=love.physics.newFixture(body, shape, 1)
	self.fixture:setFriction(friction)
	self.color=color
	return self
end

function Polygon.draw(self)
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.polygon("fill", self.fixture:getBody():getWorldPoints(self.fixture:getShape():getPoints()))
end