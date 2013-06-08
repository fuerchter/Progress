Character = {}
Character.__index = Character

--color will be boolean and loaded from config/level
function Character.new(world, position, color, radius)
	local self=setmetatable({}, Character)
	
	local body=love.physics.newBody(world, position.x, position.y, "dynamic")
	local shape=love.physics.newCircleShape(radius)
	self.fixture=love.physics.newFixture(body, shape, 1) --density?
	self.fixture:getBody():setMass(0) --slows force???
	self.color=color
	return self
end

function Character.update(self, dt)
	--[[if(love.keyboard.isDown("up"))
	then
		self.fixture:getBody():applyLinearImpulse(0, -50*dt)
	end]]
	if(love.keyboard.isDown("left"))
	then
		self.fixture:getBody():applyForce(-2, 0)
	end
	if(love.keyboard.isDown("right"))
	then
		self.fixture:getBody():applyForce(2, 0)
	end
	
	local velX, velY=self.fixture:getBody():getLinearVelocity()
	local posX, posY=self.fixture:getBody():getPosition()
	love.graphics.setCaption("Velocity: " .. math.floor(velX) .. " " .. math.floor(velY) .. " Position: " .. math.floor(posX) .. " " .. math.floor(posY))
end

function Character.draw(self)
	local segments=20
	local x, y=self.fixture:getBody():getPosition()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.circle("fill", x, y, self.fixture:getShape():getRadius(), segments)
end