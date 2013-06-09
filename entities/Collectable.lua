require "../Entity"

Collectable = {}
Collectable.__index = Collectable

setmetatable(Collectable, {
  __index = Entity,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Collectable:_init(level, position, radius)
	Entity._init(self, level, "Collectable", position)
	
	--color should automatically be lightcolor
	local body=love.physics.newBody(level.world, position.x, position.y, "static")
	local shape=love.physics.newCircleShape(radius)
	self.fixture=love.physics.newFixture(body, shape, 1)
	self.fixture:setSensor(true)
	self.fixture:setUserData(self)
	self.fixture:setFilterData(1, 2, 0)
	
	self.active=true
	
	self.image = love.graphics.newImage("assets/collect.png")
	
	self.segments=20
	
	return self
end

function Collectable:update(dt)
	
end

function Collectable:draw()
	local x, y=self.fixture:getBody():getPosition()
	love.graphics.setColorMode("replace")
	love.graphics.draw(self.image, x, y, 0, 1, 1, 12, 12)
end