--particleEffect.lua

--========================================================================
--粒子特效类

ParticleEffect = class();


function ParticleEffect:constructor( fileName )

	--========================================================================
	--属性相关

	--创建对应的显示ParticleSystem（！！！ 注意：这里使用智能指针 ！！！）
	self.particleSystem = sceneManager:CreateSceneNode('ParticleSystem');
	self.particleSystem:IncRefCount();
	self.particleSystem:LoadFromFile(fileName);
	self.particleSystem:Start();
end

--销毁
function ParticleEffect:Destroy()
	
	--从父节点中移除
	local parent = self.particleSystem:GetParent();
	if parent ~= nil then
		Print(LANG_particleEffect_1);
		parent:RemoveChild(self.particleSystem);
	end

	--主动释放C++对象（！！！但是内存还没有释放，直到lua执行垃圾回收！！！）
	self.particleSystem:DecRefCount();
    self.particleSystem = nil;

end

--更新
function ParticleEffect:Update( Elapse )
end

--========================================================================
--属性

--获取C++对象
function ParticleEffect:GetCppObject()
	return self.particleSystem;
end
