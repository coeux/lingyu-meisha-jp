
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
	else
		self.func( self.obj, unpack(self.arg) );
	end
end
