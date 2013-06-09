require "../Entity"

Battery = {}
Battery.__index = Battery

setmetatable(Battery, {
  __index = Entity,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Battery:_init(level, position, radius)
	Entity._init(self, level, "Battery", position)
	
	--color should automatically be lightcolor
	local body=love.physics.newBody(level.world, position.x, position.y, "static")
	local shape=love.physics.newCircleShape(radius)
	self.fixture=love.physics.newFixture(body, shape, 1)
	self.fixture:setSensor(true)
	self.fixture:setUserData(self)
	self.fixture:setFilterData(1, 1, 0)
	
	self.charge=30 --by how much the character's charge will be increased if this is gathered
	self.active=true
	
	self.segments=20
	
	return self
end

function Battery:update(dt)
	
end

function Battery:draw()
	local x, y=self.fixture:getBody():getPosition()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.circle("fill", x, y, self.fixture:getShape():getRadius(), segments)
end