Polygon = {}
Polygon.__index = Polygon

setmetatable(Polygon, {
	__call = function (cls, ...)
				return cls.new(...)
			end,
})

--color will be boolean and loaded from config/level
--color expects {r=rval, g=gval, b=bval, a=aval} (currently), points expects object of type Points
function Polygon.new(world, position, color, friction, points)
	local self = setmetatable({}, Polygon)
	
	local body=love.physics.newBody(world, position.x, position.y, "static")
	local shape=love.physics.newPolygonShape(points:getPoints())
	self.fixture=love.physics.newFixture(body, shape, 1)
	self.fixture:setFriction(friction)
	self.color=color
	
	self.light=true
	return self
end

function Polygon.draw(self)
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.polygon("fill", self.fixture:getBody():getWorldPoints(self.fixture:getShape():getPoints()))
end