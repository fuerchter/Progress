Map = {}
Map.__index = Map

setmetatable(Map, {
	__call = function (cls, ...)
				return cls.new(...)
			end,
})

--creates a map
function Map.new()
	local self = setmetatable({}, Map)

	self.platforms = {}
	self.texts = {}
	
	return self
end

--register new platform
function Map:registerPlatform(world, position, points, color)
	self.platforms[#self.platforms+1] = Polygon.new(world, position, color, 0.2, points)
end

--register new text
function Map:registerText()
	
end

function Map:draw()
	--platforms
	for plat = 1, #self.platforms do
		self.platforms[plat]:draw()
	end
	
	--text needs to be in front of the platforms
	for text = 1, #self.texts do
		self.texts[text]:draw()
	end
end