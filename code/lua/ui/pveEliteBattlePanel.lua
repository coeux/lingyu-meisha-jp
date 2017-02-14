--pveEliteBattlePanel.lua

--========================================================================
--pve精英战斗面板

PveEliteBarrierPanel =
	{
	};

local curGroup = 0;			--当前组
local maxGroup = 0;			--可以打开的最大组
local specifyGroup = 0;		--指定打开某组

--控件
local mainDesktop;
local panel;
local guanQiaList;
local front;
local back;
local reset;
local activityReset;
local bossNum;
local tip;
local curEquip;
local leftPage;
local rightPage;
local taskid = 0;			--当前主线任务


--初始化
function PveEliteBarrierPanel:InitPanel( desktop )

	--=============================================================================
	--变量初始化
	
	curGroup = 0;			--当前组
	maxGroup = 0;			--可以打开的最大组
	specifyGroup = 0;		--指定打开某组
	
	--=============================================================================
	--界面初始化

	mainDesktop 	= desktop;
	panel 			= Panel( desktop:GetLogicChild('pveElitePanel') );
	panel:IncRefCount();
	guanQiaList		= ListView( panel:GetLogicChild('guanQiaList') );
	front			= Button( panel:GetLogicChild('front') );
	back			= Button( panel:GetLogicChild('back') );
	reset			= Button( panel:GetLogicChild('reset') );
	activityReset	= Button( panel:GetLogicChild('activityreset') );
	bossNum			= Label( panel:GetLogicChild('bossNum') );
	tip				= Label( panel:GetLogicChild('tip') );
	curEquip		= Label( panel:GetLogicChild('curEquip') );	
	leftPage		= Button( panel:GetLogicChild('leftPage') );
	rightPage		= Button( panel:GetLogicChild('rightPage') );

	--初始化时隐藏panel
	panel.Visibility = Visibility.Hidden;

end


--销毁
function PveEliteBarrierPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end


--显示
function PveEliteBarrierPanel:Show()

	--计算可以打开的最大组
	self:refreshMaxGroup();
	
	--根据玩家通关的最大关卡确定打开的组
	if 0 ~= specifyGroup then
		curGroup = specifyGroup;
		specifyGroup = 0;
	else
		curGroup = maxGroup;
	end
	
	--显示组数据
	self:showGroupData(curGroup);
	
	--新手引导特殊显示
	taskid = Task:getMainTaskId();
	if SystemTaskId.elite == taskid then
		local guanqiaPanel = guanQiaList:GetLogicChild(0);
		local stackPanel = guanqiaPanel:GetLogicChild(0):GetLogicChild(0);
		local infoPanel = stackPanel:GetLogicChild('guanqia' .. 2);
		infoPanel.Background = Converter.String2Brush('godsSenki.pve_jy');
		
		local image = ImageElement( infoPanel:GetLogicChild('image') );
		image.Visibility = Visibility.Visible;

		local title = infoPanel:GetLogicChild('title');
		title.Background = Converter.String2Brush('godsSenki.pve_jy2');
	end
	
	--显示tip
	if ActorManager.user_data.viplevel < 2 then
		tip.Visibility = Visibility.Visible;
	else
		tip.Visibility = Visibility.Hidden;
	end

	--设置模式对话框
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, 'PveEliteBarrierPanel:onUserGuid');
	
	--活动按钮
	self:onRefreshResetBtn();
end

--打开时的新手引导
function PveEliteBarrierPanel:onUserGuid()
	if SystemTaskId.elite == taskid then
		UserGuidePanel:ShowGuideShade(guanQiaList:GetLogicChild(0):GetLogicChild(0):GetLogicChild(0):GetLogicChild(0), GuideEffectType.hand, GuideTipPos.bottom, LANG_pveEliteBattlePanel_1);
		--新手引导精英1结束
		UserGuidePanel:SetInGuiding(false);
		guanQiaList.Pick = false;
	end
end

--隐藏
function PveEliteBarrierPanel:Hide()
	
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

--刷新
function PveEliteBarrierPanel:Refresh()
	self:refreshMaxGroup();
	self:showGroupData(curGroup);
end

--获取打开的最大组
function PveEliteBarrierPanel:GetMaxGroup()
	if maxGroup == 0 then
		self:refreshMaxGroup();
	end
	
	return maxGroup;
end

--========================================================================
--功能函数
--========================================================================

--刷新最大精英组
function PveEliteBarrierPanel:refreshMaxGroup()

	maxGroup = 201;
	local finded = false;
	local roundID = ActorManager.user_data.round.eliteid;
	while true do
		--确定通关过的最大精英关卡所在组
		local guanqiaData = resTableManager:GetValue(ResTable.pveElite, tostring(maxGroup), 'scene_id');
		for i = 1, #guanqiaData do
			if roundID < guanqiaData[i] then
				finded = true;
				break;
			end
		end

		if finded then
			break;
		end

		maxGroup = maxGroup + 1;
	end
	
end

--显示一组
function PveEliteBarrierPanel:showGroupData( groupID )

	local pageIndex = guanQiaList.ActivePageIndex;

	--清空
	guanQiaList:RemoveAllChildren();


	local data = resTableManager:GetRowValue(ResTable.pveElite, tostring(groupID));
	
	local text = data['l_button'];
	if string.len(text) == 0 then
		front.Visibility = Visibility.Hidden;
	else
		front.Visibility = Visibility.Visible;
		front.Text = text;
	end
	
	text = data['r_button'];
	if string.len(text) == 0 then
		back.Visibility = Visibility.Hidden;
	else
		back.Visibility = Visibility.Visible;
		back.Text = text;
	end
	
	--达到当前显示最大组
	if groupID >= maxGroup then
		back.Enable = false;
	else
		back.Enable = true;
	end
	
	curEquip.Text = data['name'];

	local guanqiaData = data['scene_id'];
	local bossAllNum = #guanqiaData;
	local leftBossNum = 0;
	local unOpen = false;
	for i = 1, math.ceil(bossAllNum / 4) do
		local guanqiaPanel = uiSystem:CreateControl('pveEliteTemplate');
		guanQiaList:AddChild(guanqiaPanel);
		guanqiaPanel = guanqiaPanel:GetLogicChild(0);
		local stackPanel = guanqiaPanel:GetLogicChild(0);
		
		for j = 1, 4 do
			local id = guanqiaData[(i-1) * 4 + j];
			
			local infoPanel = stackPanel:GetLogicChild('guanqia' .. j);			
			if id == nil then
				infoPanel.Visibility = Visibility.Hidden;
			else
				infoPanel.Visibility = Visibility.Visible;

				--名字
				local name = Label( infoPanel:GetLogicChild('name') );
				name.Text = resTableManager:GetValue(ResTable.barriers, tostring(id), 'name');

				--图片
				local image = ImageElement( infoPanel:GetLogicChild('image') );
				local pic = GetPicture( 'navi/' .. resTableManager:GetValue(ResTable.barriers, tostring(id), 'icon') .. '/headPic.ccz' );
				image.Image = pic;

				local complete = infoPanel:GetLogicChild('complete');
				
				if (ActorManager.user_data.round.roundid < id - 1000) or (unOpen and ActorManager.user_data.round.eliteid < id) then
					--加锁状态
					infoPanel.Background = Converter.String2Brush('godsSenki.pve_jy1');
					
					local title = infoPanel:GetLogicChild('title');
					title.Background = Converter.String2Brush('godsSenki.pve_jy12');
					
					image.Visibility = Visibility.Hidden;
					complete.Visibility = Visibility.Hidden;
				else
					if ActorManager.user_data.round.eliteid < id then
						--开放通过的下一个关卡
						unOpen = true;
					end

					--完成情况
					if ActorManager.user_data.round.passround[id] then
						complete.Visibility = Visibility.Visible;
						complete.Pick = false;
						infoPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PveEliteBarrierPanel:onResetElite');
					else
						leftBossNum = leftBossNum + 1;
						complete.Visibility = Visibility.Hidden;

						infoPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PveEliteBarrierPanel:onEnterElite');
						infoPanel.Tag = id;
					end
				end
			end

		end

	end
	
	--分页的点是否显示
	if guanQiaList:GetLogicChildrenCount() < 2 then
		guanQiaList.ShowPageBrush = false;
		leftPage.Visibility = Visibility.Hidden;
		rightPage.Visibility = Visibility.Hidden;		
	else
		guanQiaList.ShowPageBrush = true;
		leftPage.Visibility = Visibility.Visible;
		rightPage.Visibility = Visibility.Visible;
	end

	--boss数量
	bossNum.Text = leftBossNum .. '/' .. bossAllNum;
	
	--重置副本次数
	local flushNum = ActorManager.user_data.round.elite_flush;
	if flushNum == nil then
		flushNum = 0;
	end
	
	--精英关卡重置次数
	local vipLevel = ActorManager.user_data.viplevel;
	local totalFlushNum = resTableManager:GetValue(ResTable.vip, tostring(vipLevel), 'reset_elite');
	
	local leftNum = totalFlushNum - flushNum;
	reset.Text = '重置副本(' .. leftNum .. '/' .. totalFlushNum .. ')';

	if leftNum <= 0 then
		reset.Enable = false;
	else
		reset.Enable = true;
	end
	
	if pageIndex ~= -1 then
		guanQiaList:SetActivePageIndexImmediate(pageIndex);
	end

end

--是否处于打开状态
function PveEliteBarrierPanel:IsVisible()
	return Visibility.Visible == panel.Visibility;
end

--测试特定关卡是否打过
function PveEliteBarrierPanel:CanFight( roundID )
	return ActorManager.user_data.round.passround[roundID] == nil;
end

--========================================================================
--事件
--========================================================================

--往前翻页
function PveEliteBarrierPanel:onPageFront()
	guanQiaList:TurnPageForward();
end

--往后翻页
function PveEliteBarrierPanel:onPageBack()
	guanQiaList:TurnPageBack();
end

--关闭
function PveEliteBarrierPanel:onClose()
	MainUI:PopAll();
	
	--新手引导，提交精英关卡1和精英关卡2
	if SystemTaskId.elite == taskid then
		UserGuide:CommitSystemTask();
		guanQiaList.Pick = true;
	end
end

--向前
function PveEliteBarrierPanel:onFront()

	local tmp = curGroup - 1;
	local data = resTableManager:GetValue(ResTable.pveElite, tostring(tmp), 'id');
	if string.len(data) ~= 0 then
		curGroup = tmp;
		self:showGroupData(curGroup);
	end

end

--向后
function PveEliteBarrierPanel:onBack()

	local tmp = curGroup + 1;
	local data = resTableManager:GetValue(ResTable.pveElite, tostring(tmp), 'id');
	if string.len(data) ~= 0 then
		curGroup = tmp;
		self:showGroupData(curGroup);
	end

end

--打开指定组的精英关卡界面
function PveEliteBarrierPanel:onShowEliteWithGroup(groupid)
	if nil == groupid or 0 == groupid then
		return;
	end
	specifyGroup = groupid;
	MainUI:Push(PveEliteBarrierPanel);
end

function PveEliteBarrierPanel:onRefreshResetBtn()
	if ActorManager.user_data.round.free_flush_elite == 0 then
		reset.Visibility = Visibility.Hidden;
		activityReset.Visibility = Visibility.Visible;
	else
		reset.Visibility = Visibility.Visible;
		activityReset.Visibility = Visibility.Hidden;
	end
end

function PveEliteBarrierPanel:onActivityReset()
	self:onRealResetElite();
end

--重置精英关卡
function PveEliteBarrierPanel:onResetElite()
	BuyCountPanel:ApplyData(VipBuyType.vop_reste_adv_round);
end

--确认重置精英关卡
function PveEliteBarrierPanel:onRealResetElite()
	local msg = {}
	msg.gid = curGroup;
	Network:Send(NetworkCmdType.req_round_flush, msg);
end

--进入精英关卡
function PveEliteBarrierPanel:onEnterElite( Args )
	
	local arg = UIControlEventArgs(Args);
	
	if ActorManager.user_data.power < Configuration.EliteRequestPower then
		BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
		BuyCountPanel:SetTitle(LANG_pveEliteBattlePanel_2);
	else
		--请求进入关卡		
		if Package:GetAllItemCount() > ActorManager.user_data.bagn - Configuration.WarningPackageCount then
			local okdelegate = Delegate.new(PveEliteBarrierPanel, PveEliteBarrierPanel.requestFight, arg.m_pControl.Tag);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_pveEliteBattlePanel_3, okdelegate);
		else
			self:requestFight(arg.m_pControl.Tag);
		end	
	end
	
	--新手引导,关闭精英界面，避免同时弹出任务界面
	if SystemTaskId.elite == taskid then
		--向服务器发送统计数据
		NetworkMsg_GodsSenki:SendStatisticsData(taskid, 3);

		self:onClose();
	end
end

--进入战斗
function PveEliteBarrierPanel:requestFight(eid)
	local msg = {};
	msg.resid = eid;
	Network:Send(NetworkCmdType.req_elite_enter, msg);
	
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);
end

--精英战斗结束回调函数
function PveEliteBarrierPanel:OnEliteFightCallBack(resultData)
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
	Network:Send(NetworkCmdType.req_elite_exit, msg);--通知服务器精英战斗结束
end

--精英战斗结束收到服务器消息的回调函数
function PveEliteBarrierPanel:OnEliteFightAfterSerMsgCallBack(iswin, barrierID)
	if not iswin then
		return;
	end
	
	ActorManager.user_data.round.passround[barrierID] = true;
	if ActorManager.user_data.round.eliteid < barrierID then
		ActorManager.user_data.round.eliteid = barrierID;
	end
	self:Refresh();	
end
--========================================================================
--响应网络消息

--重置精英关卡
function PveEliteBarrierPanel:onRefreshElite( msg )
	--刷新免费按钮显示
	if ActorManager.user_data.round.free_flush_elite == 0 then
		ActorManager.user_data.round.free_flush_elite = ActorManager.user_data.round.free_flush_elite + 1;
	else
		ActorManager.user_data.round.elite_flush = ActorManager.user_data.round.elite_flush + 1;		--更新刷过的组次数
	end

	--重置已经通过的关卡为未通过
	local guanqiaData = resTableManager:GetValue(ResTable.pveElite, tostring(msg.gid), 'scene_id');
	for _,v in ipairs(guanqiaData) do
		ActorManager.user_data.round.passround[v] = nil;
	end

	self:showGroupData(curGroup);

	self:onRefreshResetBtn();

end

--十二点重置精英关卡
function PveEliteBarrierPanel:ShowGroupData()
	self:showGroupData(curGroup);
end
