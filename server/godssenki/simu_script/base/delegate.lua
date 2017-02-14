
--========================================================================
--事件代理者

Delegate = class();

--注册事件
function Delegate:constructor( obj, func )
	self.obj = obj;
	self.func = func;
end

--回调
function Delegate:CallBack( ... )
	self.func(self.obj, ...);
end
