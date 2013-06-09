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
	self.jumpSpeed=1000 --how fast we increase y when jumping
	self.maxAirTime=0.3 --how long (in seconds) we can jump
	self.airTime=0 --how long we are currently in the air already
	self.canJump=false
	
	
	self.speed=500
	self.segments=20
	
	self.level=level
	self:setLight(light)
	
	self.collected=0
	self.charge=0
	
	self.currentLight=nil --the character creates a local light
	self.lightSpacing=0.1 --how many points of the light we create in seconds
	self.lastLight=0
	self.canPlace=true
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
		self.fixture:getBody():applyLinearImpulse(0, -self.jumpSpeed*dt)
		self.airTime=self.airTime+dt
	end
	
	
	if(love.keyboard.isDown("left"))
	then
		self.fixture:getBody():applyLinearImpulse(-self.speed*dt, 0)
	end
	if(love.keyboard.isDown("right"))
	then
		self.fixture:getBody():applyLinearImpulse(self.speed*dt, 0)
	end
	
	
	
	local posX, posY=self.fixture:getBody():getPosition()	
	
	if(not self.canPlace)
	then
		self.lastLight=self.lastLight+dt
	end
	
	if(self.lastLight>self.lightSpacing)
	then
		self.canPlace=true
		self.lastLight=0
	end
	
	if(self.light and self.charge>0 and self.canPlace and love.keyboard.isDown("lctrl"))
	then
		if(self.currentLight==nil)
		then
			self.currentLight=Light(self.level, {x=posX, y=posY})
			
		else
			self.currentLight:registerSource({x=posX, y=posY})
		end
		self.canPlace=false --initiates the lastLight counter
		self.charge=self.charge-1
	end
	if(not love.keyboard.isDown("lctrl") and self.currentLight~=nil) --if the character contains a light but ctrl is not pressed we hand the light to the level
	then
		self.level:addEntity(self.currentLight)
		self.currentLight=nil
	end
	
	
	
	
	self.foot:update(dt)
	
	--[[local velX, velY=self.fixture:getBody():getLinearVelocity()	
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

	--self.foot:draw()
	
	if(self.currentLight~=nil)
	then
		self.currentLight:draw()
	end
end