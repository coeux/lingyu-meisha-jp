--animatedSprite.lua

--========================================================================
--动画精灵类

AnimatedSprite = class();


--构造函数
function AnimatedSprite:constructor()

	--========================================================================
	--属性相关
	
	self.startFlag			= false;	--播放标志位
	
	--========================================================================
	--动画相关
	
	self.sprite				= nil;		--对应的显示Sprite
	self.curAnimation		= nil;		--当前动作
	self.curFrame			= 0;		--当前帧
	self.curAnimationTime	= 0;		--当前动画时间
	self.path				= '';		--动作路径

	self.animationList		= {};		--动作列表


	self.obj				= self;		--动作结束回调
	self.animationCallback	= AnimatedSprite.animationEnd;
	
	--========================================================================

end

--销毁
function AnimatedSprite:Destroy()

	--从父节点中移除
	local parent = self.sprite:GetParent();
	if parent ~= nil then
		Print(LANG_animatedSprite_1);
		parent:RemoveChild(self.sprite);
	end

	--主动释放C++对象（！！！但是内存还没有释放，直到lua执行垃圾回收！！！）
	self.sprite:DecRefCount();
    self.sprite = nil;

end

--更新
function AnimatedSprite:Update( Elapse )
	if not self.startFlag then
		--暂停
		return
	end

	if self.curFrame == 0 then
		return
	end
	
	while Elapse > Math.INFINITESIMAL do
		if self.curFrame >= self.curAnimation.n then
			--结束动画
			self.animationCallback(self.obj, self);
			return;
		end

		local nextFrame = self.curAnimation[self.curFrame];
		local nextFrameTime = nextFrame.index / GlobalData.FPS;

		if self.curAnimationTime + Elapse >= nextFrameTime then
			--消耗的帧数超过当前关键帧
			Elapse = self.curAnimationTime + Elapse - nextFrameTime;
			self.curAnimationTime = nextFrameTime;

			self.sprite:SetImage(self.path .. nextFrame.file, nextFrame.area);
			
			self.curFrame = self.curFrame + 1;
		else
			--还没有到达下一帧
			self.curAnimationTime = self.curAnimationTime + Elapse;
			Elapse = 0;
		end
	end
	
end

--========================================================================
--属性

--获取C++对象
function AnimatedSprite:GetCppObject()
	return self.sprite;
end

--设置动作回调
function AnimatedSprite:SetAnimationCallback( obj, arg )
	self.obj = obj
	self.animationCallback = arg
end

--========================================================================
--动作

--加载动作
function AnimatedSprite:LoadAnimation( fileName )

	local xfile = xmlParseFile( fileName );
	xfile = xfile[1];
	local animationNum = xfile.n;

	--加载动作数据
	for i = 1, animationNum do

		local animation = xfile[i];
		local attr = animation['attr'];
		local animationData = {}
		
		animationData.id = tonumber(attr.ID)
		animationData.transformPoint = Converter.String2Vector2(attr.TransformPoint)
		animationData.size = Converter.String2Size(attr.Size)
		animationData.lp = Converter.String2Bool(attr.Cycled)

		--加载帧数据
		animationData.n = animation.n;
		for j = 1, animationData.n do

			local keyFrameData = {}
			local keyFrame = animation[j]['attr'];
			
			keyFrameData.file = keyFrame.File;
			keyFrameData.index = Converter.String2Int(keyFrame.Index);
			keyFrameData.area = Converter.String2Rect(keyFrame.Area);
			
			animationData[j] = keyFrameData;

		end

		self.animationList[animationData.id] = animationData;

	end
	
	--路径
	_,_,self.path = string.find(fileName, "(.*/)");

	--创建对应的显示Sprite（！！！ 注意：这里使用智能指针 ！！！）
	self.sprite = sceneManager:CreateSceneNode('Sprite');
	self.sprite:IncRefCount();
	self.sprite.AutoSize = false;
	self.sprite.TransformPoint = Vector2(0.5, 0);

end

--获取动作ID
function AnimatedSprite:GetAnimation()
	return self.curAnimation.id
end

--设置动作ID
function AnimatedSprite:SetAnimation( id )

	self.curAnimation = self.animationList[id];
	if self.curAnimation == nil then
		Print(LANG_animatedSprite_2 .. id .. LANG_animatedSprite_3)
		return
	end

	self.sprite.Size = self.curAnimation.size;
	self:Replay();

end

--重新播放
function AnimatedSprite:Replay()

	self.startFlag = true

	--重新播放
	self.animationStartTime = appFramework:GetRunningTime();
	self.curFrame = 1;
	self.curAnimationTime = 0;

end

--暂停
function AnimatedSprite:Pause()
	self.startFlag = false
end

--继续
function AnimatedSprite:Continue()
	self.startFlag = true
end

--========================================================================

--动作结束
function AnimatedSprite.animationEnd( self, sprite )

	if sprite.curAnimation.lp then
		--循环动作
		sprite:Replay();
		return;
	end

end
