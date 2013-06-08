require "../Entity"

Checkpoint = {}
Checkpoint.__index = Checkpoint

setmetatable(Checkpoint, {
  __index = Entity,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Checkpoint:_init(world, position, color, radius)
	Entity._init(self, "checkpoint", position)
	--color should automatically be darkcolor
	local body=love.physics.newBody(world, position.x, position.y, "static")
	local shape=love.physics.newCircleShape(radius)
	self.fixture=love.physics.newFixture(body, shape, 1)
	self.fixture:setSensor(true)
	self.fixture:setUserData("checkpoint")
	
	self.segments=20
	self.color=color
	
	return self
end

function Checkpoint.update(self, dt)
	
end

function Checkpoint.draw(self)
	local x, y=self.fixture:getBody():getPosition()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.circle("fill", x, y, self.fixture:getShape():getRadius(), segments)
end