--game.lua

--========================================================================
--游戏类

Game =
	{
		curState		= nil;
		stateList		= {};
	};


--========================================================================
--状态管理

--添加状态
function Game:AddState( gameState, state )

	if self.stateList[gameState] == nil then
		state:Init();
		self.stateList[gameState] = state;
	end

end

--销毁状态
function Game:RemoveState( gameState )

	if curState == gameState then
		curState = nil;
	end

	self.stateList[gameState]:Destroy();
	self.stateList[gameState] = nil;

end

--销毁
function Game:Destroy()
	for k,v in pairs(self.stateList) do
		v:Destroy();
	end

	self.curState = nil;
	self.stateList = {};
end

--当前状态
function Game:GetCurState()
	return self.curState;
end

--状态切换
function Game:SwitchState( gameState , extraFlag)
	local extraFlag = extraFlag or false;

	if self.curState == gameState then
		return
	end

	if self.curState ~= nil then
		self.stateList[self.curState]:onLeave();
	end

  ---[[
  --清理显存

  for k, v in pairs(_G["fileImageMap"]) do 
    uiSystem.DestroyImage(k)
  end
  EventManager:FireEvent(EventType.RecoverDisplayMemory, true);	
  --]]

	self.curState = gameState;

	if self.curState ~= nil then
		self.stateList[self.curState]:onEnter(extraFlag);
	end

end

--========================================================================

--更新
function Game:Update( Elapse )
  if not _G['Game#UpdateCounter'] then
     _G['Game#UpdateCounter'] = 1;
  else
     _G['Game#UpdateCounter'] = _G['Game#UpdateCounter'] + 1;
  end
  if self.curState ~= nil then
     self.stateList[self.curState]:Update(Elapse);
  end
  -- call the delay callback functions
  if _G['cb_queue'] and #_G['cb_queue'] > 0 then
     local item = _G['cb_queue'][1];
     item.count = item.count - 1;
     if item.count <= 0 then
        item.fun();
        table.remove(_G['cb_queue'], 1);
     end
  end
end


