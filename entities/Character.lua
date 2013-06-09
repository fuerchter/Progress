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
function Character:_init(level, position, light, friction, radius)
	Entity._init(self, level, "Character", position)
	
	local body=love.physics.newBody(level.world, position.x, position.y, "dynamic")
	local shape=love.physics.newCircleShape(radius)
	self.fixture=love.physics.newFixture(body, shape, 1) --density?
	self.fixture:setFriction(friction)
	self.fixture:getBody():setFixedRotation(true) --else no friction is applied to the circle
	self.fixture:setUserData(self)
	
	--jump related stuff
	self.foot=Sensor(level, {x=0, y=radius}, 10, 10, self)	
	self.jumpSpeed=1 --how fast we increase y when jumping
	self.maxAirTime=0.2 --how long (in seconds) we can jump
	self.airTime=0 --how long we are currently in the air already
	self.canJump=false
	
	
	self.speed=0.5
	self.segments=20
	
	self.level=level
	self:setLight(true)
	
	self.collected=0
	self.charge=0
	return self
end

function Character:update(dt)
	if(self.airTime>self.maxAirTime) --jump climax
	then
		self.canJump=false
	end
	
	if(self.foot.collisionCount>0) --touching ground
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
	
	self.foot:update(dt)
	
	--[[local velX, velY=self.fixture:getBody():getLinearVelocity()
	local posX, posY=self.fixture:getBody():getPosition()	
	love.graphics.setCaption("Velocity: " .. math.floor(velX) .. " " .. math.floor(velY) .. " Position: " .. math.floor(posX) .. " " .. math.floor(posY))]]
end

function Character:setLight(light)
	self.foot:setLight(light)
	
	self.light=light
	if(light)
	then
		-- setFilterData(x,y,z)
		-- first it is checked wether the two z values of colliding bodies are the same, if true - they collide (used for the platforms)
		-- if the z values are different, it is checked wether object1's x is the same as object2's y and the same in the opposite direction, if true - they collide (used for the checkpoint)
		self.fixture:setFilterData(1, 5, 1)
		self.color=self.level:getColorForType("light")
	else
		self.fixture:setFilterData(2, 5, 2)
		self.color=self.level:getColorForType("dark")
	end
	--self.fixture:setMask(3)
end

function Character:draw()
	local x, y=self.fixture:getBody():getPosition()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.circle("fill", x, y, self.fixture:getShape():getRadius(), segments)

	self.foot:draw()
end