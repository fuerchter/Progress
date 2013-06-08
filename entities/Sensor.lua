require "../Entity"

Sensor = {}
Sensor.__index = Sensor

setmetatable(Sensor, {
  __index = Entity,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Sensor:_init(level, offset, width, height, parent)
	Entity._init(self, level, "Sensor", position)
	
	--color should automatically be lightcolor
	local posX, posY=parent.fixture:getBody():getPosition()
	
	local body=love.physics.newBody(level.world, posX+offset.x, posY+offset.y, "dynamic")
	local shape=love.physics.newRectangleShape(width, height)
	self.fixture=love.physics.newFixture(body, shape, 1)
	self.fixture:setSensor(true)
	self.fixture:setUserData(self)
	self.offset=offset
	self.parent=parent
	self.collisionCount=0
	
	return self
end

function Sensor.update(self, dt)
	local posX, posY=self.parent.fixture:getBody():getPosition()
	self.fixture:getBody():setPosition(posX+self.offset.x, posY+self.offset.y)
end

function Sensor.draw(self)
	love.graphics.setColor(255, 0, 0, 122)
	love.graphics.polygon("fill", self.fixture:getBody():getWorldPoints(self.fixture:getShape():getPoints()))
end