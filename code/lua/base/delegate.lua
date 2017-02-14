--delegate.lua

--========================================================================
--事件代理者

Delegate = class();

--注册事件
function Delegate:constructor( obj, func, ... )
	self.obj = obj;
	self.func = func;
	self.arg = arg;
end

--回调
function Delegate:Callback( ... )
	if self.arg.n == 0 then
		self.func(self.obj, ...);
	elseif self.arg.n == 1 then
		local a1 = unpack(self.arg);
		self.func(self.obj, a1, ...);
	elseif self.arg.n == 2 then
		local a1, a2 = unpack(self.arg);
		self.func(self.obj, a1, a2, ...);
	elseif self.arg.n == 3 then
		local a1, a2, a3 = unpack(self.arg);
		self.func(self.obj, a1, a2, a3, ...);
	else
		self.func(self.obj, unpack(self.arg));
	end
end
