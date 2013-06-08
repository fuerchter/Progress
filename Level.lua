require "Map"

Level = {}
Level.__index = Level

setmetatable(Level, {
	__call = function (cls, ...)
				return cls.new(...)
			end,
})

--creates a level
function Level.new(world, name)
	local self = setmetatable({}, Level)

	--load file and parse
	local xmlParser = require("xml/xmlSimple").newParser()
	
	local xmlFile = love.filesystem.newFile("levels/" .. name .. "/level.xml")
	xmlFile:open('r')
	local fileContents = xmlFile:read()
	
	local xml = xmlParser:ParseXmlText(fileContents)
	
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
	
	self.music = xml.level.config.music["@file"]
	
	--extract entities
	self.entities = {}
	
    for index = 1, #xml.level.entities:children() do
		
		local entity = xml.level.entities:children()[index]
		
		if entity["@type"] == "checkpoint" then 
			self.entities[index] = Checkpoint(world, { x = entity["@x"], y = entity["@y"]}, 32)
		elseif entity["@type"] == "battery" then
			self.entities[index] = Checkpoint(world, { x = entity["@x"], y = entity["@y"]}, 32)
		elseif entity["@type"] == "enemy" then
			-- waiting for implementation of class
		elseif entity["@type"] == "collectable" then
			self.entities[index] = Collectable(world, { x = entity["@x"], y = entity["@y"]}, 32)
		end
		
    end
	
	--extract map
	self.spawn = { x = xml.level.map["@spawnX"], y = xml.level.map["@spawnY"]}
	self.map = Map()

	for poly = 1, #xml.level.map:children() do
	
		if xml.level.map:children()[poly]:name() == "polygon" then
	
			local polygon = xml.level.map:children()[poly]
			local points = Points()
			
			for vert = 1, #polygon:children() do
				local vertex = polygon:children()[vert]
				points.insert(points, { x = vertex["@x"], y = vertex["@y"]})
			end
			
			self.map:registerPlatform(world, { x = polygon["@x"], y = polygon["@y"]}, points, self.colorScheme[polygon["@type"]])
		
		elseif xml.level.map:children()[poly]:name() == "text" then
			-- waiting for implementation of class
		end
	end
	
	return self
end

function Level:update(dt)
	for ent = 1, #self.entities do
		self.entities[ent]:update(dt)
	end
end

function Level:draw()
	--first draw map
	self.map:draw()
	
	--now draw entities
	for ent = 1, #self.entities do
		self.entities[ent]:draw()
	end
end