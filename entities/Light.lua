require "../Entity"

Light = {}
Light.__index = Light

setmetatable(Light, {
  __index = Entity,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Light:_init(level, position)
	Entity._init(self, level, "Light", position)
	
	self.body = love.physics.newBody(level.world, position.x, position.y, "static")
	self.chainShape = nil
	self.sources = {}
	self.vertex = {}
	self.sources[1] = {x = 0, y = 0}
	self.vertex[1] = 0
	self.vertex[2] = 0
end

function Light:registerSource(point)
	self.sources[#self.sources+1] = { x = point.x - self.position.x, y = point.y - self.position.y}
	self.vertex[#self.vertex+1] = point.x - self.position.x
	self.vertex[#self.vertex+1] = point.y - self.position.y
	
	if fixture ~= nil then
		self.fixture:destroy()
	end
	
	self.chainShape = love.physics.newChainShape(false, unpack(self.vertex))
	self.fixture = love.physics.newFixture(self.body, self.chainShape, 1)
	self.fixture:setFriction(0.2)
	self.fixture:setFilterData(4, 4, 2)
end

function Light:update(dt)
	
end

function Light:draw()
	love.graphics.setColor(self.level.colorScheme.light.r, 
							self.level.colorScheme.light.g, 
							self.level.colorScheme.light.b, 
							self.level.colorScheme.light.a)
	
	for pos = 1, #self.sources-1 do
		love.graphics.line(self.sources[pos].x + self.position.x, self.sources[pos].y + self.position.y,
							self.sources[pos+1].x + self.position.x,self.sources[pos+1].y + self.position.y) 
	end
end