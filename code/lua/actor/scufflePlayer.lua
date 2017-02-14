--scufflePlayer.lua

--========================================================================
--依赖

LoadLuaFile("lua/actor/player.lua");

--========================================================================
--乱斗场玩家类

ScufflePlayer = class(Player)


function ScufflePlayer:constructor( id, resID )

end

--初始化数据
function ScufflePlayer:InitData( data )
	Player.InitData(self, data);
	self.uid = data.uid;
	self.winNum = data.n_win;
	self.conWinNum = data.n_con_win;
	self.inBattle = data.in_battle;
	self.level = data.level;
end	

--初始化头顶
function ScufflePlayer:InitHead()
	local t = uiSystem:CreateControl('scufflePlayerTemplate');
	self.uiHead = StackPanel(t:GetLogicChild(0));
	bottomDesktop:AddChild(self.uiHead);
	local arm = ArmatureUI( self.uiHead:GetLogicChild('headList'):GetLogicChild('effect'));
	arm:LoadArmature('zhandouzhong');
	arm:SetAnimation('play');
	self:UpdateScuffleHead();
	
end

--更新乱斗场玩家信息
function ScufflePlayer:UpdateScuffleInfo(n_win, n_con_win, in_battle)
	--胜利场次
	self.winNum = n_win;
	--连胜场次
	self.conWinNum = n_con_win;
	--战斗状态
	self.inBattle = in_battle;
	self:UpdateScuffleHead();
end

--是否点击玩家
function ScufflePlayer:Hit( PT )
	return self:GetBoundBox():Contain(PT);
end
