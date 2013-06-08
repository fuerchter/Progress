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
	Entity._init(self, "character", position)
	
	local body=love.physics.newBody(world, position.x, position.y, "dynamic")
	local shape=love.physics.newCircleShape(radius)
	self.fixture=love.physics.newFixture(body, shape, 1) --density?
	self.fixture:setFriction(friction)
	self.fixture:getBody():setFixedRotation(true) --else no friction is applied to the circle
	self.color=color
	return self
end

function Character.update(self, dt)
	if(love.keyboard.isDown("left"))
	then
		self.fixture:getBody():applyLinearImpulse(-0.5, 0)
	end
	if(love.keyboard.isDown("right"))
	then
		self.fixture:getBody():applyLinearImpulse(0.5, 0)
	end
	
	local velX, velY=self.fixture:getBody():getLinearVelocity()
	local posX, posY=self.fixture:getBody():getPosition()
	--love.graphics.setCaption("Velocity: " .. math.floor(velX) .. " " .. math.floor(velY) .. " Position: " .. math.floor(posX) .. " " .. math.floor(posY))
end

function Character.draw(self)
	local segments=20
	local x, y=self.fixture:getBody():getPosition()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	love.graphics.circle("fill", x, y, self.fixture:getShape():getRadius(), segments)
end