Points = {}
Points.__index = Points

--color will be boolean and loaded from config/level
function Points.new()
	local self=setmetatable({}, Points)
	return self
end

function Points.insert(self, point)
	table.insert(self, point)
end

function Points.getPoints(self, i)
	if(i==nil) --e.g. no i was given
	then
		i=1
	end
	if(i>#self) --out of range
	then
		return
	end
	
	--returns the i-th x and y and calls itself
	return self[i].x, self[i].y, self:getPoints(i+1)
end