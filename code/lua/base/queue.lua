--queue.lua

Queue = { frontNode = 0, backNode = -1 }

function Queue:new( o )
	o = o or {}
	setmetatable(o, self)

	self.__index = self
	
	return o
end

function Queue:front()
	return self[frontNode];
end

function Queue:back()
	return self[backNode];
end

function Queue:pushfront( value )
	local front = self.frontNode - 1
	self.frontNode = front

	self[front] = value
end

function Queue:pushback( value )
	local back = self.backNode + 1
	self.backNode = back

	self[back] = value
end

function Queue:popfront()
	local front = self.frontNode

	if front > self.backNode then
		 error("Queue is empty")
	end

	local value = self[front]
	self[front] = nil    -- to allow garbage collection
	self.frontNode = front + 1

	return value
end

function Queue:popback()
	local back = self.backNode

	if self.frontNode > back then
		error("Queue is empty")
	end

	local value = self[back]
	self[back] = nil     -- to allow garbage collection
	self.backNode = back - 1

	return value
end

function Queue:num()
	return self.backNode - self.frontNode + 1;
end
