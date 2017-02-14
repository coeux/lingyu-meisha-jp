--scufflePanel.lua
--=================================================================================
--乱斗场面板
ScufflePanel =
	{
		reviveState = false;
		scuffleState;	--1.开, 2.关
		isScuffleWin;	--乱斗场是否胜利
		isScuffleFightEnd;
		selfState;
		startPosX;
		startPosy;
		reviveX;
		reviveY;
		score; 
		morale;
		scuffleTime;
		fightOtherWinCount; --敌方连胜次数
		timerScuffleTime = 0;--timer里面用的时间
	};
--控件
local recordPanel; 	
local scoreValueLabel; 	
local winValueLabel;		
local rowWinValueLabel;	
local moraleValueLabel;	
local rankPanel;		
local rankScrollPanel; 
local rankStackPanel;	
local homePageBtn;		
local endPageBtn;		
local pageAfterBtn;	
local pageNextBtn;		
local pageLabel;
local revivePanel;		
local reviveTimeLabel;	
local reviveBtn;
local reviveBG;
local roleInfoPanel;	
local roleName;		
local zhandouli;		
local moneyButton;		
local jinbi;			
local touxiang;		
local vip;				
local shuijing;		
local chongzhiButton;	
local armature;		
local level;			
local marqueePanel; 	
local marqueeLine;
local rankBtn;
local timeLabel;		
local timeValueLabel;	
local timeEndLabel;	

--变量
local isRunning;
local marqueeTimer;
local updateMarqueeTimer;
local reviveTimer;
local reviveCD;
local oneMarqueeDistance;
local marqueeMoveMaxDistance;
local marqueeSpeed;
local isFailLeave;
local isFinishLeave;
local tRowWinCount;
local localDataState;
local marqueeInfo = {};
local listColor = {};
listColor[1] = Color(182, 212, 208, 255);
listColor[2] = Color(226, 202, 238, 255);
listColor[3] = Color(185, 213, 237, 255);
listColor[4] = Color(242, 215, 178, 255);
function ScufflePanel:InitPanel( desktop )
	tRowWinCount = 0;
	marqueeTimer = 0;
	updateMarqueeTimer = 0;
	reviveTimer = 0;
	marqueeMoveMaxDistance = -1200;
	marqueeSpeed = 70;
	marqueeInfo = {};
	self.scuffleState = 0;
	self.selfState	= 0;
	self.scuffleTime = 0;
	localDataState = true;
	self.fightOtherUid = -1;
	--控件初始化
	mainDesktop = desktop;
	scufflePanel = desktop:GetLogicChild('scufflePanel1');
	scufflePanel.ZOrder = 1;
	scufflePanel.Visibility = Visibility.Hidden;
	scufflePanel:IncRefCount();
	
	--战绩
	recordPanel 	= scufflePanel:GetLogicChild('recordPanel');
	scoreValueLabel = recordPanel:GetLogicChild('scoreValueLabel');
	winValueLabel	= recordPanel:GetLogicChild('winValueLabel');
	rowWinValueLabel= recordPanel:GetLogicChild('rowWinValueLabel');
	moraleValueLabel= recordPanel:GetLogicChild('moraleValueLabel');
	timeLabel		= recordPanel:GetLogicChild('timeLabel');
	timeValueLabel	= recordPanel:GetLogicChild('timeValueLabel');
	timeEndLabel	= recordPanel:GetLogicChild('timeEndLabel');
	timeEndLabel.Visibility = Visibility.Hidden;
	--recordPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','ScufflePanel:reqScuffleRank');
	--排行
	rankPanel		= scufflePanel:GetLogicChild('rankPanel');
	rankScrollPanel = rankPanel:GetLogicChild('rankScrollPanel');
	rankStackPanel	= rankScrollPanel:GetLogicChild('rankStackPanel');
	homePageBtn		= rankPanel:GetLogicChild('homePageBtn');
	endPageBtn		= rankPanel:GetLogicChild('endPageBtn');
	pageAfterBtn	= rankPanel:GetLogicChild('pageAfterBtn');
	pageNextBtn		= rankPanel:GetLogicChild('pageNextBtn');
	pageLabel		= rankPanel:GetLogicChild('pageLabel');
	closeBtn		= rankPanel:GetLogicChild('closeBtn');
	rankBtn			= scufflePanel:GetLogicChild('rankBtn');
	rankBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','ScufflePanel:showRank');
	closeBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','ScufflePanel:closeRank');
	
	--复活
	revivePanel			= scufflePanel:GetLogicChild('revivePanel');
	reviveTimeLabel		= revivePanel:GetLogicChild('reviveTimeLabel');
	reviveBtn			= revivePanel:GetLogicChild('reviveBtn');
	reviveBG			= scufflePanel:GetLogicChild('explainBG');
	--reviveBtn:SubscribeScriptedEvent('Button::ClickEvent','ScufflePanel:reviveBtnClick')
	revivePanel.Visibility = Visibility.Hidden
	
	--头像信息
	roleInfoPanel		= scufflePanel:GetLogicChild('roleInfoPanel');
	roleName			= roleInfoPanel:GetLogicChild('name');
	zhandouli			= roleInfoPanel:GetLogicChild('zhanliValue');
	moneyButton			= roleInfoPanel:GetLogicChild('moneyButton');
	jinbi				= roleInfoPanel:GetLogicChild('jinbi');
	touxiang			= roleInfoPanel:GetLogicChild('touxiang');
	vip					= roleInfoPanel:GetLogicChild('vip');
	shuijing			= roleInfoPanel:GetLogicChild('shuijing');
	chongzhiButton		= roleInfoPanel:GetLogicChild('ChongzhiButton');
	armature			= chongzhiButton:GetLogicChild('armature');
	level				= roleInfoPanel:GetLogicChild('level');
	touxiang.Image = GetPicture('navi/' .. ActorManager.user_data.role.headImage .. '.ccz');
	moneyButton:SubscribeScriptedEvent('UIControl::MouseClickEvent','MainUI:onBuyGold');
	chongzhiButton:SubscribeScriptedEvent('UIControl::MouseClickEvent','RechargePanel:onShowRechargePanel');
	self:bind()
	uiSystem:UpdateDataBind();
	
	--乱斗场走马灯
	marqueePanel 	= scufflePanel:GetLogicChild('marquee');
	marqueeLine 	= marqueePanel:GetLogicChild('infomation');
	
	--商城
    local shopBtn = scufflePanel:GetLogicChild('menuPanel'):GetLogicChild('shopPanel'):GetLogicChild('shopbutton');
    shopBtn:SubscribeScriptedEvent('Button::ClickEvent', 'MainUI:onShopClick');
    shopBtn.Visibility = Visibility.Visible;
    --回家
    btnHome = scufflePanel:GetLogicChild('menuPanel'):GetLogicChild('homebutton');
    btnHome:SubscribeScriptedEvent('Button::ClickEvent', 'HomePanel:onEnterHomePanel');

end
--战绩刷新
function ScufflePanel:refreshRecord(msg)
	--print('score->'..tostring(msg.score)..' -morale->'..tostring(msg.morale)..' -win->'..tostring(msg.n_win)..' -rowWin->'..tostring(msg.n_con_win));
	if localDataState then
		tRowWinCount = msg.n_con_win;
		localDataState = false;
	end
	self.morale = msg.morale;
	scoreValueLabel.Text = tostring(msg.score);
	moraleValueLabel.Text = tostring(msg.morale);
	winValueLabel.Text = tostring(msg.n_win);	
	rowWinValueLabel.Text = tostring(msg.n_con_win);
end
function ScufflePanel:refreshTime(endTime)
	timeValueLabel.Text = tostring(Time2HMSStr(endTime));
end
function ScufflePanel:scuffleEndTimeTip()
	timeLabel.Visibility = Visibility.Hidden;		
	timeValueLabel.Visibility = Visibility.Hidden;	
	timeEndLabel.Visibility = Visibility.Visible;	
end
function ScufflePanel:fightEndResult()
	local scuffleFightResult = {};
	if self.isScuffleWin then
		local moraleUp = resTableManager:GetValue(ResTable.config, '32', 'value');
		local winScore	= resTableManager:GetValue(ResTable.config, '34', 'value');
		local rowWinScore = resTableManager:GetValue(ResTable.config, '36', 'value');
		scuffleFightResult.moraleUp = moraleUp;
		if tRowWinCount >= 20 then	--我的连胜
			tRowWinCount = 20;
		elseif tRowWinCount <= 1 then
			tRowWinCount = 1;
		end
		if self.fightOtherWinCount >= 20 then --终结对方连胜
			self.fightOtherWinCount = 20;
		elseif self.fightOtherWinCount <= 1 then
			self.fightOtherWinCount = 1;
		end
		scuffleFightResult.winScore = winScore + rowWinScore * (tRowWinCount-1) + (self.fightOtherWinCount-1) *10;
	else
		local moraleDown = resTableManager:GetValue(ResTable.config, '33', 'value');
		local loseScore = resTableManager:GetValue(ResTable.config, '35', 'value');
		scuffleFightResult.moraleUp = moraleDown;
		scuffleFightResult.winScore = loseScore;
	end
	return scuffleFightResult;
end
--乱斗场排行
function ScufflePanel:reqScuffleRank()
	Network:Send(NetworkCmdType.req_scuffle_ranking, {});
end
function ScufflePanel:refreshRankData(msg)
	rankScrollPanel:VScrollBegin(); 
	rankStackPanel:RemoveAllChildren();	
	if not msg.rank then return end
	local rankList = msg.rank;
	local left	   = msg.left;
	local sortFunc = function(a, b)
		return a.rank < b.rank
	end
	table.sort(rankList,sortFunc);
	local rankCount = 1;
	local order = 0;
	for _,rankItem in pairs(rankList) do
		local control = uiSystem:CreateControl('scuffleRankTemplate');
		local ctrl = control:GetLogicChild(0);
		local bursh = ctrl:GetLogicChild('bursh');
		bursh:SetVertexColor(listColor[order%4+1]);
		local rank	= ctrl:GetLogicChild('rank');
		rank.Text = tostring(rankItem.rank);
		local name	= ctrl:GetLogicChild('name');
		name.Text = tostring(rankItem.nickname);
		local score = ctrl:GetLogicChild('score');
		score.Text = tostring(rankItem.score);
		rankStackPanel:AddChild(control)
		order = order + 1;
	end
	--if not ScufflePanel:isShowRank() and self:isScuffleShow() then
	--	rankBtn.Visibility = Visibility.Hidden;
	--	rankPanel.Visibility = Visibility.Visible;
	--end
end
function ScufflePanel:showRank()
	rankBtn.Visibility = Visibility.Hidden;
	rankPanel.Visibility = Visibility.Visible;
end
function ScufflePanel:closeRank()
	rankPanel.Visibility = Visibility.Hidden;
	rankBtn.Visibility = Visibility.Visible;
end
function ScufflePanel:isShowRank()
	return rankPanel.Visibility == Visibility.Visible;
end
--复活
function ScufflePanel:showRevive()
	revivePanel.Visibility = Visibility.Visible;
	reviveBG.Visibility = Visibility.Visible;
end
function ScufflePanel:closeRevive()
	revivePanel.Visibility = Visibility.Hidden;
	reviveBG.Visibility = Visibility.Hidden;
end
function ScufflePanel:startTime()
	reviveCD = 10;
	if reviveTimer ~= 0 then
		timerManager:DestroyTimer(reviveTimer);
		reviveTimer = 0;
	end 
	if reviveCD > 0 then
		self.reviveState = true;
		ActorManager.hero:StopMove()
		reviveTimeLabel.Text = tostring(Time2MinSecStr(reviveCD));
		reviveTimer = timerManager:CreateTimer(1, 'ScufflePanel:showTime', 0);
		--self:setHeroRevivePos()
	end
	
end
function ScufflePanel:showTime()
	--print('showTime->'..tostring(reviveTimeLabel.Text));
	if reviveCD > 1 then
		reviveCD = reviveCD - 1;
	else
		if reviveTimer ~= 0 then
			timerManager:DestroyTimer(reviveTimer);
			reviveTimer = 0;
		end
		reviveCD = 0;
		self.reviveState = false;
		self:reviveEndMovePos()
		self:closeRevive()
		return;
	end
	reviveTimeLabel.Text = tostring(Time2MinSecStr(reviveCD));
end
function ScufflePanel:reviveEndMovePos()
	--print('reviveEndMovePos--->')
	ActorManager.hero:MoveTo(Vector2(0, -230));
	local msg = {};
	msg.uid = ActorManager.user_data.uid;
	msg.sceneid = GlobalData.ScuffleSceneId;
	msg.x = math.floor(0);
	msg.y = math.floor(-230);
	Network:Send(NetworkCmdType.nt_move, msg, true);
end
function ScufflePanel:reviveBtnClick()
	self:closeRevive()
	ActorManager.hero:SetPosition( Convert2Vector3( Vector2(0, -230) ) );
end
--销毁
function ScufflePanel:Destroy()
	self:unbind();
	scufflePanel:DecRefCount();
	scufflePanel = nil;
end	

function ScufflePanel:isScuffleShow()
	return scufflePanel.Visibility == Visibility.Visible;
end
--显示
function ScufflePanel:onShowScuffle()
	isRunning = false;
	WorldScufflePanel:onClose();
	WorldMapPanel:onClose();
	LimitTaskPanel:Hide();
	isFailLeave = false;
	isFinishLeave = false;
	ScufflePanel.isScuffleFightEnd = false;
	
	timeLabel.Visibility = Visibility.Visible;		
	timeValueLabel.Visibility = Visibility.Visible;	
	timeEndLabel.Visibility = Visibility.Hidden;
	
	--reviveCD = 10;
	--self:startTime();
	--updateMarqueeTimer = timerManager:CreateTimer(1, 'ScufflePanel:UpdateMarquee', 0);
	--timerManager:CreateTimer(3, 'ScufflePanel:testInsertContent', 0, true);
	scufflePanel.Visibility = Visibility.Visible;
end
--离开乱斗场场景
function ScufflePanel:LeaveScuffleScene()
	Network:Send(NetworkCmdType.req_scuffle_leave_scene, {});
	--local msg = {};
	--msg.sceneid = 1001;
	--msg.x = 165;
	--msg.y = 67;
	--print('LeaveScuffleScene->')
	--ScufflePanel:onHide();
	--MainUI:SetSceneType(SceneType.MainCity);
	--NetworkMsg_EnterGame:onEnterCity( msg );
end
--隐藏
function ScufflePanel:onHide()
	if reviveTimer ~= 0 then
		timerManager:DestroyTimer(reviveTimer);
		reviveTimer = 0;
	end
	WorldScufflePanel:destroyScuffleStartTimer()
	if self:GetFailLeave() then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_scufflePanel_11);
	else
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_scufflePanel_10);
	end
	isRunning = false;
	marqueePanel.Visibility = Visibility.Hidden;
	scufflePanel.Visibility = Visibility.Hidden;
end
--乱斗场走马灯
function ScufflePanel:testInsertContent()--走马灯测试
	print('testInsertContent-->');
	table.insert(marqueeInfo,'你是超级无敌大傻逼');
	table.insert(marqueeInfo,'哈哈哈哈哈哈哈哈哈');
	table.insert(marqueeInfo,'煞笔煞笔傻逼傻逼');
	table.insert(marqueeInfo,'-----------------');
	self:startMarquee()
end
function ScufflePanel:retMarqueeInfo(msg)
	self:startMarquee();
end
function ScufflePanel:startMarquee()
	if isRunning == false and #marqueeInfo > 0 then
		marqueeLine.Translate = Vector2(0, 0);
		marqueePanel.Visibility = Visibility.Visible;		--显示面板
		local font = uiSystem:FindFont('huakang_25');
		local tipcolor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		marqueeLine:RemoveAllChildren();
		marqueeLine:AddText(marqueeInfo[1], tipcolor, font);
		if marqueePanel.Size.Width >= marqueeLine.Size.Width then
			oneMarqueeDistance = -((marqueePanel.Size.Width - marqueeLine.Size.Width)/2 + marqueeLine.Size.Width)
		else
			oneMarqueeDistance = -((marqueeLine.Size.Width - marqueePanel.Size.Width)/2 + marqueePanel.Size.Width)
		end
		isRunning = true;
		self:destroyMarqueeTimer();
	end
end
function ScufflePanel:UpdateMarquee(elapse)
	if isRunning and #marqueeInfo > 0 then
		local pos = marqueeLine.Translate;
		marqueeLine.Translate = Vector2(pos.x - marqueeSpeed * elapse, pos.y);
		if #marqueeInfo == 1 then
			if marqueeLine.Translate.x <= oneMarqueeDistance then
				table.remove(marqueeInfo,1);
				isRunning = false;
			end
		elseif #marqueeInfo > 1 then
			if marqueeLine.Translate.x <= marqueeMoveMaxDistance then
				table.remove(marqueeInfo,1);
				isRunning = false;
				marqueeTimer = timerManager:CreateTimer(1, 'ScufflePanel:startMarquee', 0);
			end
		end
	end
end
--乱斗场报名
function ScufflePanel:reqScuffleRegist()
	Network:Send(NetworkCmdType.req_scuffle_regist,{});
end
function ScufflePanel:retScuffleRegist(msg)
	self.selfState = 1;
	LimitTaskPanel:updateTask(LimitNews.scuffle);
	WorldScufflePanel:enableRegistBtn();
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_scufflePanel_8);
end
function ScufflePanel:onEnterScuffleScene( )
	local pos = ActorManager.hero:GetPosition();
	MainUI:SaveHeroTempPosition(pos);

	MainUI:SetSceneType(SceneType.Scuffle);
	--设置影响位置，要在设置活动场景之后
	ActorManager.hero:SetStartPosition( Convert2Vector3( Vector2(self.startPosX, self.startPosy) ) );
	MainUI:ShowScuffleUI();
	
	self:onShowScuffle();
end
--请求进入乱斗场
function ScufflePanel:onRequestEnterScuffle()
	local msg = {};
	msg.resid = GlobalData.ScuffleSceneId;
	msg.show_player_num = GlobalData.MaxSceneRoleNum;
	Network:Send(NetworkCmdType.req_enter_city, msg);
end
function ScufflePanel:onClickScuffleBtn()
	local level = Hero:GetLevel();
	if level < FunctionOpenLevel.scuffle then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_scufflePanel_7);
		return;
	end
	
	--请求进入乱斗场
	self:onRequestEnterScuffle();
end
--是否等待时间，进乱斗场有1分钟等待时间
function ScufflePanel:isWaitTime()
    return (LuaTimerManager:GetCurrentTime() >= Configuration.ScuffleSecondTime and LuaTimerManager:GetCurrentTime() < Configuration.ScuffleSecondTime + Configuration.ScuffleWaitTime);
end
--绑定数据
function ScufflePanel:bind()
	
	uiSystem:Bind(DDXTYPE.DDX_STRING, ActorManager.user_data, 'name', roleName, 'Text');				--绑定姓名
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'viplevel', vip, 'Text');				--绑定vip
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data.role.lvl, 'level', level, 'Text');		--绑定等级
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', jinbi, 'Text');					--绑定金币
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', shuijing, 'Text');					--绑定水晶
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'fp', zhandouli, 'Text');						--绑定战力
end

--取消绑定数据
function ScufflePanel:unbind()
	uiSystem:UnBind(ActorManager.user_data, 'name', roleName, 'Text');							--取消绑定姓名
	uiSystem:UnBind(ActorManager.user_data, 'viplevel', vip, 'Text');						--取消绑定vip
	uiSystem:UnBind(ActorManager.user_data.role.lvl, 'level', level, 'Text');				--取消绑定等级
	uiSystem:UnBind(ActorManager.user_data, 'money', jinbi, 'Text');						--取消绑定金币
	uiSystem:UnBind(ActorManager.user_data, 'rmb', shuijing, 'Text');							--取消绑定水晶
	uiSystem:UnBind(ActorManager.user_data, 'fp', zhandouli, 'Text');								--取消绑定战力
end
function ScufflePanel:destroyUpateMarqueeTimer()
	if updateMarqueeTimer ~= 0 then
		timerManager:DestroyTimer(updateMarqueeTimer);
		updateMarqueeTimer = 0;
	end
end
function ScufflePanel:destroyMarqueeTimer()
	if marqueeTimer ~= 0 then
		timerManager:DestroyTimer(marqueeTimer);
		marqueeTimer = 0;
	end
end
function ScufflePanel:setHeroRevivePos()
	ScufflePanel:startTime();
	ActorManager.hero:SetScuffleRevivePostion( Convert2Vector3( Vector2(self.reviveX, self.reviveY) ) );
	self:showRevive();
end
--请求乱斗场战斗
function ScufflePanel:onRequestFight( uid )
	local msg = {};
	--[[
	self.fightOtherUid = uid;
	self.fightOtherWinCount = 0;
	
	local player = ActorManager.actorList[uid];
	if player then
		self.fightOtherWinCount = player.conWinNum;
		print('fightOtherWinCount--->'..tostring(player.conWinNum));
	end
	]]
	msg.uid = uid;	
	Network:Send(NetworkCmdType.req_scuffle_battle, msg);	
end
function ScufflePanel:setFightEndIsWin(isWin)
	self.isScuffleWin = isWin;
	if self.isScuffleWin then
		tRowWinCount = tRowWinCount + 1; 
	else
		tRowWinCount = 0;
	end
end
--乱斗场战斗结束请求
function ScufflePanel:reqScuffleFightEnd()
	local msg = {};
	msg.is_win = self.isScuffleWin;
	msg.team_hp = {};
	Scuffle:getFinalHp(msg.team_hp);
	Network:Send(NetworkCmdType.req_scuffle_battle_end, msg);
end
--士气值为0踢出乱斗场
function ScufflePanel:SetFailLeave()
	isFailLeave = true;
end
function ScufflePanel:GetFailLeave()
	return isFailLeave;
end
--结束被踢掉乱斗场
function ScufflePanel:SetFinishLeave()
	isFinishLeave = true;
end
function ScufflePanel:GetFinishLeave()
	return isFinishLeave;
end
--乱斗场是否结束
function ScufflePanel:isScuffleOver()
	if self.morale <= 0 then
		self:SetFailLeave()
		ScufflePanel:LeaveScuffleScene();
		return false;
	end
	return true;
end
--乱斗场状态
function ScufflePanel:reqScuffleState()
	local level = Hero:GetLevel();
	if level < FunctionOpenLevel.scuffle then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_scufflePanel_7);
		return;
	end
	Network:Send(NetworkCmdType.req_scuffle_state,{});
end
function ScufflePanel:rqScuffleState()
	self:reqScuffleState();
	WorldScufflePanel:Show();
end
function ScufflePanel:retScuffleState(msg)
	self.scuffleState = msg.state; --0 不在时间段； 1 报名； 2 战斗 ；3 战斗结束
	self.selfState	= msg.self_state; -- 0 未报名，1 已报名
	self.scuffleTime = msg.remain_time;
	self.timerScuffleTime = msg.remain_time;
	--print('self.timerScuffleTime-->'..tostring(self.timerScuffleTime));
	--print('scuffleState->'..tostring(msg.state));
	--print('selfState->'..tostring(msg.self_state));
	--print('time->'..tostring(msg.remain_time));
	WorldScufflePanel:onShow()
end
--战斗结束返回
function ScufflePanel:retScuffleBattleEnd(msg)
	--print('retScuffleBattleEnd-x->'..tostring(msg.x)..' -y->'..tostring(msg.y))
	if not self.isScuffleWin then
		self.reviveX = msg.x;
		self.reviveY = msg.y;
		self:setHeroRevivePos();
	end
	--if self:isScuffleOver() and not self.isScuffleWin then
	--	self:setHeroRevivePos();
	--end
end