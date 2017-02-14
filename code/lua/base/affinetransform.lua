--affinetransform.lua

--========================================================================
--仿射变换类

AffineTransform = {};

function AffineTransform:new()

	local o = {};
	setmetatable(o,self);
	self.__index = self

	--========================================================================
	--属性相关
	
	o.a = 1;
	o.b = 0;
	o.c = 0;
	o.d = 1;
	o.tx = 0;
	o.ty = 0;
	
	return o;
	
end

--仿射变换相乘
function AffineTransform:Concat( other )

	local o = AffineTransform:new();
	o.a = self.a * other.a + self.b * other.c;
	o.b = self.a * other.b + self.b * other.d;
	o.c = self.c * other.a + self.d * other.c;
	o.d = self.c * other.b + self.d * other.d;
	o.tx = self.tx * other.a + self.ty * other.c + other.tx;
	o.ty = self.tx * other.b + self.ty * other.d + other.ty;
	
	return o;
	
end

--仿射变换顶点
function AffineTransform:TransformPT2Vector2( pt )

	local x = self.a * pt.x + self.c * pt.y + self.tx;
	local y = self.b * pt.x + self.d * pt.y + self.ty;
	
	return Vector2(x, y);

end


--仿射变换顶点
function AffineTransform:TransformPT( pt )

	local x = self.a * pt.x + self.c * pt.y + self.tx;
	local y = self.b * pt.x + self.d * pt.y + self.ty;
	
	return x, y;

end
