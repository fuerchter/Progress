require "../Entity"

Enemy = {}
Enemy.__index = Enemy

setmetatable(Enemy, {
  __index = Entity,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Enemy:_init(world, position, friction, radius)
	Entity._init(self, "Enemy", position)
	
	--color should automatically be lightcolor
	local body=love.physics.newBody(world, position.x, position.y, "dynamic")
	local shape=love.physics.newCircleShape(radius)
	self.fixture=love.physics.newFixture(body, shape, 1) --density?
	self.fixture:setFriction(friction)
	self.fixture:getBody():setFixedRotation(true) --else no friction is applied to the circle
	self.fixture:setUserData(self)
	
	self.facingRight=true
	self.leftFoot=Sensor(world, {x=-radius+10, y=radius}, 10, 10, self)
	self.rightFoot=Sensor(world, {x=radius-10, y=radius}, 10, 10, self)
	
	self.speed=0.25
	self.segments=20
	return self
end

function Enemy:update(dt)
	self.leftFoot:update(dt)
	self.rightFoot:update(dt)
	
	if(self.facingRight and self.rightFoot.collisionCount==0)
	then
		self.facingRight=false
		self.fixture:getBody():setLinearVelocity(0, 0)
	end
	if(not self.facingRight and self.leftFoot.collisionCount==0)
	then
		self.facingRight=true
		self.fixture:getBody():setLinearVelocity(0, 0)
	end
	
	if(not self.facingRight)
	then
		self.fixture:getBody():applyLinearImpulse(-self.speed, 0)
	end
	if(self.facingRight)
	then
		self.fixture:getBody():applyLinearImpulse(self.speed, 0)
	end
	--love.graphics.setCaption(self.leftFoot.collisionCount .. " " .. self.rightFoot.collisionCount .. "Facing right? " .. tostring(self.facingRight))
end

function Enemy:draw()
	local x, y=self.fixture:getBody():getPosition()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.circle("fill", x, y, self.fixture:getShape():getRadius(), segments)
	
	self.leftFoot:draw()
	self.rightFoot:draw()
end