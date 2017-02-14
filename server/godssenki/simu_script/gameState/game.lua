
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

	state:Init();
	self.stateList[gameState] = state;
	
end

--销毁状态
function Game:RemoveState( gameState )

	if curState == gameState then
		curState = nil;
	end

	self.stateList[gameState]:Destroy();
	self.stateList[gameState] = nil;

end

--状态切换
function Game:SwitchState( gameState )

	if self.curState == gameState then
		return
	end

	if self.curState ~= nil then
		self.stateList[self.curState]:onLeave();
	end

	self.curState = gameState;

	if self.curState ~= nil then
		self.stateList[self.curState]:onEnter();
	end

end

--========================================================================

--更新
function Game:Update( Elapse )
	self.stateList[self.curState]:Update(Elapse);
end
