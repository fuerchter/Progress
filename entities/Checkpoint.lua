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

function Checkpoint:_init(level, position, radius)
	Entity._init(self, level, "Checkpoint", position)
	
	--color should automatically be darkcolor
	local body=love.physics.newBody(level.world, position.x, position.y, "static")
	local shape=love.physics.newCircleShape(radius)
	self.fixture=love.physics.newFixture(body, shape, 1)
	self.fixture:setSensor(true)
	self.fixture:setUserData(self)
	self.fixture:setFilterData(1, 1, 0)
	
	self.image = love.graphics.newImage("assets/blob.png")
	
	self.segments=20
	
	return self
end

function Checkpoint:update(dt)
	
end

function Checkpoint:draw()
	local x, y=self.fixture:getBody():getPosition()
	love.graphics.setColor(self.level.colorScheme.dark.r, self.level.colorScheme.dark.g, self.level.colorScheme.dark.b, 100)

	love.graphics.setColorMode("modulate")
	love.graphics.draw(self.image, x, y, 0, self.direction, 1, 12, 12)
end