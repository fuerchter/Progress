require "../Entity"

Character = {}
Character.__index = Character

setmetatable(Character, {
	__index = Entity,
	__call = function (cls, ...)
				local self = setmetatable({}, cls)
				self:_init(...)
				return self
			end,
})

--color will be boolean and loaded from config/level
--color expects {r=rval, g=gval, b=bval, a=aval} (currently), points expects object of type Points
function Character:_init(world, position, color, friction, radius)
	Entity._init(self, "Character", position)
	
	local body=love.physics.newBody(world, position.x, position.y, "dynamic")
	local shape=love.physics.newCircleShape(radius)
	self.fixture=love.physics.newFixture(body, shape, 1) --density?
	self.fixture:setFriction(friction)
	self.fixture:getBody():setFixedRotation(true) --else no friction is applied to the circle
	self.fixture:setUserData(self.type)
	
	--jupmp related stuff
	local footBody=love.physics.newBody(world, position.x, position.y+radius, "dynamic")
	local footShape=love.physics.newRectangleShape(10, 10) --10 by 10 foot at the bottom of our circle
	self.foot=love.physics.newFixture(footBody, footShape, 1)
	self.foot:setSensor(true)
	self.foot:setUserData("Foot")
	
	self.groundCollisions=0 --current amount of foot collisions
	self.jumpSpeed=1 --how fast we increase y when jumping
	self.maxAirTime=0.2 --how long (in seconds) we can jump
	self.airTime=0 --how long we are currently in the air already
	self.canJump=true
	
	
	self.speed=0.5
	self.segments=20
	self.color=color	
	self.light=true
	self.collected=0
	self.charge=0
	return self
end

function Character:update(dt)
	if(self.airTime>self.maxAirTime) --jump climax
	then
		self.canJump=false
	end
	
	if(self.groundCollisions>0) --touching ground
	then
		self.canJump=true
		self.airTime=0
	end
	
	if(self.canJump and love.keyboard.isDown("up"))
	then
		self.fixture:getBody():applyLinearImpulse(0, -self.jumpSpeed)
		self.airTime=self.airTime+dt
	end
	if(love.keyboard.isDown("left"))
	then
		self.fixture:getBody():applyLinearImpulse(-self.speed, 0)
	end
	if(love.keyboard.isDown("right"))
	then
		self.fixture:getBody():applyLinearImpulse(self.speed, 0)
	end
	
	local velX, velY=self.fixture:getBody():getLinearVelocity()
	local posX, posY=self.fixture:getBody():getPosition()
	self.foot:getBody():setPosition(posX, posY+self.fixture:getShape():getRadius()) --makes foot follow the character
	
	--love.graphics.setCaption("Velocity: " .. math.floor(velX) .. " " .. math.floor(velY) .. " Position: " .. math.floor(posX) .. " " .. math.floor(posY))
end

function Character:draw()
	local x, y=self.fixture:getBody():getPosition()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.circle("fill", x, y, self.fixture:getShape():getRadius(), segments)
end

function Character:drawFoot()
	love.graphics.setColor(255, 0, 0, 122)
	love.graphics.polygon("fill", self.foot:getBody():getWorldPoints(self.foot:getShape():getPoints()))
end