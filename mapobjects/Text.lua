Text = {}
Text.__index = Text

setmetatable(Text, {
	__call = function (cls, ...)
				return cls.new(...)
			end,
})

function Text.new(position, text)
	local self = setmetatable({}, Text)

	self.text = text
	self.position = position
	
	return self
end

function Text:draw()
	love.graphics.setColor(100, 100, 100, 255)
	love.graphics.print(self.text, self.position.x, self.position.y)
end