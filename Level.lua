require "Map"

Level = {}
Level.__index = Level

setmetatable(Level, {
	__call = function (cls, ...)
				return cls.new(...)
			end,
})

--creates a level
function Level.new(name)
	local self = setmetatable({}, Level)

	--load file and parse
	local xmlParser = require("xml/xmlSimple").newParser()
	
	local xmlFile = love.filesystem.newFile("levels/" .. name .. "/level.xml")
	xmlFile:open('r')
	local fileContents = xmlFile:read()
	
	local xml = xmlParser:ParseXmlText(fileContents)
	
	--physics
	love.physics.setMeter(64)
	self.world = love.physics.newWorld(0, 9.81*64, true)
	self.world:setAllowSleeping(false)
	self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	
	--extract info
	self.title = xml.level.info.title:value()
	self.description = xml.level.info.description:value()
	self.author = xml.level.info.author:value()
	
	--extract config
	self.colorScheme = { 
							light = {
										r = xml.level.config.colorscheme.colorLight["@r"], 
										g = xml.level.config.colorscheme.colorLight["@g"], 
										b = xml.level.config.colorscheme.colorLight["@b"],
										a = xml.level.config.colorscheme.colorLight["@a"]
									}, 
							dark = {
										r = xml.level.config.colorscheme.colorDark["@r"], 
										g = xml.level.config.colorscheme.colorDark["@g"], 
										b = xml.level.config.colorscheme.colorDark["@b"],
										a = xml.level.config.colorscheme.colorLight["@a"]
									}, 
							back = {
										r = xml.level.config.colorscheme.colorBack["@r"], 
										g = xml.level.config.colorscheme.colorBack["@g"], 
										b = xml.level.config.colorscheme.colorBack["@b"],
										a = xml.level.config.colorscheme.colorLight["@a"]
									}
						}
	
	love.graphics.setBackgroundColor(self.colorScheme.back.r, self.colorScheme.back.g, self.colorScheme.back.b)
	
	self.music = xml.level.config.music["@file"]
	
	--extract entities
	self.entities = {}
	
    for index = 1, #xml.level.entities:children() do
		
		local entity = xml.level.entities:children()[index]
		
		if entity["@type"] == "checkpoint" then 
			self.entities[index] = Checkpoint(self, { x = entity["@x"], y = entity["@y"]}, 32)
		elseif entity["@type"] == "battery" then
			self.entities[index] = Battery(self, { x = entity["@x"], y = entity["@y"]}, 32)
		elseif entity["@type"] == "enemy" then
			self.entities[index] = Enemy(self, { x = entity["@x"], y = entity["@y"]}, 0.2, 32)
		elseif entity["@type"] == "collectable" then
			self.entities[index] = Collectable(self, { x = entity["@x"], y = entity["@y"]}, 32)
		end
		
    end
	
	--extract map
	self.spawn = { x = xml.level.map["@spawnX"], y = xml.level.map["@spawnY"]}
	
	self.character = Character(self, self.spawn, true, 0.2, 32)
	
	self.map = Map()

	for poly = 1, #xml.level.map:children() do
	
		if xml.level.map:children()[poly]:name() == "polygon" then
	
			local polygon = xml.level.map:children()[poly]
			local points = Points()
			
			for vert = 1, #polygon:children() do
				local vertex = polygon:children()[vert]
				points.insert(points, { x = vertex["@x"], y = vertex["@y"]})
			end
			
			if(polygon["@type"]=="light")
			then
				self.map:registerPlatform(self, { x = polygon["@x"], y = polygon["@y"]}, points, true)
			else
				self.map:registerPlatform(self, { x = polygon["@x"], y = polygon["@y"]}, points, false)
			end
		
		elseif xml.level.map:children()[poly]:name() == "text" then
			local text = xml.level.map:children()[poly]
			
			self.map:registerText({ x = text["@x"], y = text["@y"]}, text:value())
		end
	end
	
	return self
end

function Level:getPhysicsWorld()
	return self.world
end

function Level:getColorForType(colorType)
	return self.colorScheme[colorType]
end

function Level:removeEntity(entity)
	pos=self:findEntity(entity)
	if(pos~=-1)
	then
		table.remove(self.entities, pos)
	end
end

function Level:findEntity(entity)
	for i=1, #self.entities
	do
		if(self.entities[i]==entity)
		then
			return i
		end
	end
	return -1
end

function Level:addEntity(entity)
	table.insert(self.entities, entity)
end

function Level:update(dt)
	for ent = 1, #self.entities do
		self.entities[ent]:update(dt)
	end
	
	self.character:update(dt)
	self.world:update(dt)
end

function Level:draw()
	--first draw map
	self.map:draw()
	
	--now draw entities
	for ent = 1, #self.entities do
		self.entities[ent]:draw()
	end
	
	self.character:draw()
end