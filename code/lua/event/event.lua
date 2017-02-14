--event.lua

--========================================================================
--事件类

Event =
	{
	};

--========================================================================
--加载
--========================================================================

--开始加载
function Event:OnStartLoad()
	--隐藏自动任务
	UserGuidePanel:HideAutoTaskGuide();
end


--========================================================================
--其他
--========================================================================

--回收显存
function Event:OnRecoverDisplayMemory( force )

	if force then
		--强制回收
	else
		--总量超过80M就进行回收
		local memorySize = memoryManager.CurMemorySize;
		local renderSize = renderer.CurDisplayMemorySize;
		local luaSize = collectgarbage('count') * 1024;
	
		if renderer.CurDisplayMemorySize + memoryManager.CurMemorySize + luaSize < 83886080 then
			return;
		end
	end
	
	--清除一次纹理缓存
	imageManager:ReleaseUnusedImageFile();

end
