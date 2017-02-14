--roleMiKuPanel.lua

--========================================================================
--角色迷窟

RoleMiKuPanel =
	{
		totalRoundPageNum		= 0;	--迷窟总的分页数
		item2round				= {};	--英雄碎片到关卡的映射
		MaxRoundID				= 5035;	--最大迷窟关卡id
	};


--变量
local roundList = {};					--关卡列表
local curPage = 0;						--当前分页

--控件
local mainDesktop;
local roleMiKuPanel;
local background1;
local background2;
local tili;
local tiliText;
local tiliMaxText;
local preLabel;
local preButton;
local nextLabel;
local nextButton;


--初始化面板
function RoleMiKuPanel:InitPanel( desktop )

	--变量初始化
	roundList = {};
	curPage = 0;

	--界面初始化
	mainDesktop = desktop;
	roleMiKuPanel = Panel( desktop:GetLogicChild('roleMiKuPanel') );
	roleMiKuPanel:IncRefCount();
	roleMiKuPanel.Visibility = Visibility.Hidden;
	
	background1 = roleMiKuPanel:GetLogicChild('background1');
	background2 = roleMiKuPanel:GetLogicChild('background2');
	tili = roleMiKuPanel:GetLogicChild('tili');
	tiliText = roleMiKuPanel:GetLogicChild('tiliValue'):GetLogicChild(0):GetLogicChild('tiliValue');
	tiliMaxText = roleMiKuPanel:GetLogicChild('tiliValue'):GetLogicChild(0):GetLogicChild('tiliMaxValue');
	preLabel = roleMiKuPanel:GetLogicChild('preLabel');
	preButton = roleMiKuPanel:GetLogicChild('preBtn');
	nextLabel = roleMiKuPanel:GetLogicChild('nextLabel');
	nextButton = roleMiKuPanel:GetLogicChild('nextBtn');
	
	
	--获取关卡控件
	local stackPanel = roleMiKuPanel:GetLogicChild('1');
	for i = 1, 10 do
		local round = {};
		local roundPanel = stackPanel:GetLogicChild( tostring(i) ):GetLogicChild(0);
		round.headPic = roundPanel:GetLogicChild('headPic');
		round.button = roundPanel:GetLogicChild('btn');
		round.name = roundPanel:GetLogicChild('name');
		round.nameBackground = roundPanel:GetLogicChild('nameBackground');
		round.level = roundPanel:GetLogicChild('level');
		round.panel = roundPanel;
		
		round.button:SubscribeScriptedEvent('Button::ClickEvent', 'RoleMiKuPanel:onClick');
		round.button.Tag = i;

		roundList[i] = round;
		
		if i == 5 then
			stackPanel = roleMiKuPanel:GetLogicChild('2');
		end
	end
	
	tiliMaxText.Text = '/' .. Configuration.MaxPower;		--体力上限
end


--销毁
function RoleMiKuPanel:Destroy()
	roleMiKuPanel:DecRefCount();
	roleMiKuPanel = nil;
end

--显示
function RoleMiKuPanel:Show()
	
	tiliText.Text = tostring(ActorManager.user_data.power);
	
	self:bind();
	self:updateBind();
	self:RefreshPowerColor();
	
	--显示当前通过的最大关卡分页
	local roundMaxID = ActorManager.user_data.round.caveid;
	if roundMaxID == 0 then
		roundMaxID = RoundIDSection.MiKuBegin + 1;
	else
		roundMaxID = math.min(roundMaxID + 1, self.MaxRoundID);
	end
	
	curPage = math.floor( (roundMaxID - RoundIDSection.MiKuBegin - 1) / 10 );
	self:RefreshPage(curPage);
	
	--设置背景
	background1.Background = CreateTextureBrush('background/yingxiongmiku_beijing.ccz', 'godsSenki', Rect(0,0,340,345));
	background2.Background = CreateTextureBrush('background/yingxiongmiku_beijing.ccz', 'godsSenki', Rect(0,0,340,345));
	
	--显示属性界面
	mainDesktop:DoModal(roleMiKuPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(roleMiKuPanel, StoryBoardType.ShowUI1, nil, 'RoleMiKuPanel:onUserGuid');	

end

--打开时的新手引导
function RoleMiKuPanel:onUserGuid()
	if UserGuidePanel:GetInGuilding() then
		UserGuidePanel:ShowGuideTalk(LANG_roleMiKuPanel_1);
		
		UserGuidePanel.hideGuideTalkEvent = Delegate.new(RoleMiKuPanel, RoleMiKuPanel.onClickGuid);
	end	
end

--打开时的点击新手引导
function RoleMiKuPanel:onClickGuid()
	if UserGuidePanel:GetInGuilding() then
		if roundList[1].enable then
			UserGuidePanel:ShowGuideShade(roundList[1].button, GuideEffectType.hand, GuideTipPos.bottom, LANG_roleMiKuPanel_2, nil, 0.5);
		end
		UserGuidePanel:SetInGuiding(false);
	end
end

--隐藏
function RoleMiKuPanel:Hide()
	
	--销毁背景图片
	background1.Background = nil;
	background2.Background = nil;
	DestroyBrushAndImage('background/yingxiongmiku_beijing.ccz', 'godsSenki');
	
	--解除绑定
	self:unBind();
	
	--隐藏属性界面
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(roleMiKuPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	
	--触发回收显存事件
	EventManager:FireEvent(EventType.RecoverDisplayMemory);

end

--刷新体力颜色
function RoleMiKuPanel:RefreshPowerColor()
	if tiliText == nil then
		return;
	end
	
	if ActorManager.user_data.power > Configuration.MaxPower then
		tiliText.TextColor = QuadColor( Color(0,246,255, 255) );
	else
		tiliText.TextColor = Configuration.WhiteColor;
	end
end

--刷新页面
function RoleMiKuPanel:RefreshPage( pageNum )
	
	local roundMaxID = ActorManager.user_data.round.caveid;
	if roundMaxID == 0 then
		roundMaxID = RoundIDSection.MiKuBegin + 1;
	else
		roundMaxID = roundMaxID + 1;
	end
	
	local firstLock = true;		--第一个锁
	if roundMaxID < (pageNum * 10 + RoundIDSection.MiKuBegin + 1) then
		--一个都没开
		firstLock = false;
	end
	
	for i = 1, 10 do
		local roundid = pageNum * 10 + RoundIDSection.MiKuBegin + i;
		local round = roundList[i];
		
		local data = resTableManager:GetValue(ResTable.miku, tostring(roundid), {'name', 'rare', 'portrait', 'level'});
		if data == nil then
			round.panel.Visibility = Visibility.Hidden;
		else
			round.panel.Visibility = Visibility.Visible;

			round.roundid = roundid;
			
			if roundid <= roundMaxID then
				if ActorManager.hero:GetLevel() >= data['level'] then
					--可以打
					round.enable = true;
					round.nameBackground.Enable = true;
					round.name.Text = data['name'];
					round.name.TextColor = QualityColor[data['rare']];
					round.level.Visibility = Visibility.Hidden;
					
					round.button.NormalBrush = Converter.String2Brush('godsSenki.yingxiongmiku_bosskuang1');
					round.button.CoverBrush = Converter.String2Brush('godsSenki.yingxiongmiku_bosskuang1');
					round.button.PressBrush = Converter.String2Brush('godsSenki.yingxiongmiku_bosskuang2');
				else
					--未解锁
					if firstLock then
						round.enable = false;
						round.nameBackground.Enable = false;
						round.name.Text = data['name'];
						round.name.TextColor =  QualityColor[data['rare']];
						round.level.Visibility = Visibility.Visible;
						round.level.Text = data['level'] .. LANG__21;
						
						round.headPic.Image = nil;
						
						round.button.NormalBrush = Converter.String2Brush('godsSenki.yingxiongmiku_bosskuang3');
						round.button.CoverBrush = Converter.String2Brush('godsSenki.yingxiongmiku_bosskuang3');
						round.button.PressBrush = Converter.String2Brush('godsSenki.yingxiongmiku_bosskuang3');
						
						firstLock = false;
					end
				end
			else
				--未解锁
				round.enable = false;
				round.nameBackground.Enable = false;
				round.level.Visibility = Visibility.Hidden;
				
				if firstLock then
					round.name.Text = data['name'];
					round.name.TextColor =  QualityColor[data['rare']];
					firstLock = false;
				else
					round.name.Text = '???';
					round.name.TextColor =  Configuration.WhiteColor;
				end
				
				round.headPic.Image = nil;
				
				round.button.NormalBrush = Converter.String2Brush('godsSenki.yingxiongmiku_bosskuang3');
				round.button.CoverBrush = Converter.String2Brush('godsSenki.yingxiongmiku_bosskuang3');
				round.button.PressBrush = Converter.String2Brush('godsSenki.yingxiongmiku_bosskuang3');
			end
		end
	end
	
	--刷新按钮
	if pageNum == 0 then
		preButton.Enable = false;
		preLabel.Enable = false;
	else
		preButton.Enable = true;
		preLabel.Enable = true;
	end
	if pageNum == self.totalRoundPageNum then
		nextButton.Enable = false;
		nextLabel.Enable = false;
	else
		nextButton.Enable = true;
		nextLabel.Enable = true;
	end

end

--调到英雄碎片对应的关卡
function RoleMiKuPanel:Goto( itemID )

	local rounds = self.item2round[itemID];
	if rounds == nil then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_roleMiKuPanel_3);
		return;
	end
	
	local roundMaxID = ActorManager.user_data.round.caveid;
	if roundMaxID == 0 then
		roundMaxID = RoundIDSection.MiKuBegin + 1;
	else
		roundMaxID = roundMaxID + 1;
	end
	
	local roundid = 0;
	for k, v in ipairs(rounds) do
		if v <= roundMaxID then
			roundid = v;
		else
			break;
		end
	end
	
	if roundid == 0 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_roleMiKuPanel_4);
		return;
	end

	MainUI:Push(self);
	
	curPage = math.floor( (roundid - RoundIDSection.MiKuBegin - 1) / 10 );
	self:RefreshPage(curPage);
	
	RoleMiKuInfoPanel:onEnterBarrierInfo(roundid);

end

--迷窟战斗结束的回调函数
function RoleMiKuPanel:OnNormalFightCallBack(resultData)
	local msg = {};
	msg.resid = resultData.id;
	msg.killed = FightManager:GetKillMonsterList();
	if resultData.result == Victory.left then
		msg.stars = 0;
		msg.win = true;
	else
		msg.stars = 0;
		msg.win = false;
	end
	Network:Send(NetworkCmdType.req_cave_exit, msg);			--通知服务器普通战斗结束
end

--迷窟战斗结束收到服务器消息的回调函数
function RoleMiKuPanel:OnNormalFightAfterSerMsgCallBack(iswin, roundid)
	if not iswin then
		return;
	end
	
	--重置助战好友的助战状态
	if nil ~= Friend.helpFriend then
		Friend.helpFriend.ishelped = 1;
	end
	
	--更新迷窟关卡id
	if roundid > ActorManager.user_data.round.caveid then
		ActorManager.user_data.round.caveid = roundid;
	end

	--更新通过次数
	if ActorManager.user_data.round.cave[ tostring(roundid) ] == nil then
		ActorManager.user_data.round.cave[ tostring(roundid) ] = { n_enter = 0; n_flush = 0 };
	end
	ActorManager.user_data.round.cave[ tostring(roundid) ].n_enter = ActorManager.user_data.round.cave[ tostring(roundid) ].n_enter + 1;
	
	--刷新页面
	self:RefreshPage(curPage);
	
	--刷新重置次数
	RoleMiKuInfoPanel:RefreshResetCount();
end

--========================================================================

--将控件显示与role角色属性绑定
function RoleMiKuPanel:bind()
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'powerProgress', tili, 'CurValue');		--绑定体力
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'power', tiliText, 'Text');				--绑定体力显示值
end

--解除绑定
function RoleMiKuPanel:unBind()
	uiSystem:UnBind(ActorManager.user_data, 'powerProgress', tili, 'CurValue');		--取消绑定体力
	uiSystem:UnBind(ActorManager.user_data, 'power', tiliText, 'Text');				--取消绑定体力显示值
end

--刷新绑定
function RoleMiKuPanel:updateBind()
	uiSystem:UpdateDataBind();
end

--========================================================================
--点击事件

--关闭
function RoleMiKuPanel:onClose()
	MainUI:Pop();
end

--前一页
function RoleMiKuPanel:onPrePage()
	if curPage == 0 then
		return;
	end
	
	curPage = curPage - 1;
	self:RefreshPage(curPage);
end

--后一页
function RoleMiKuPanel:onNextPage()
	if curPage == self.totalRoundPageNum then
		return;
	end
	
	curPage = curPage + 1;
	self:RefreshPage(curPage);
end

--点击
function RoleMiKuPanel:onClick( Args )
	local args = UIControlEventArgs(Args);
	
	local round = roundList[args.m_pControl.Tag];
	if not round.enable then
		return;
	end
	
	local roundid = curPage * 10 + RoundIDSection.MiKuBegin + args.m_pControl.Tag;
	RoleMiKuInfoPanel:onEnterBarrierInfo(roundid);
end

