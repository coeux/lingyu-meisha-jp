--totalRechargePanel.lua
--==============================================================================================
--累计充值界面

TotalRechargePanel =
	{
		m_max = 18888;
	};

--变量
local rechargeLevel = 0;								--充值等级
local rechargeLevelList = {};
local rechargeMap = {2980, 6210, 9430, 12670, 15900, 18888};
rechargeMap[0] = 0;
local changeBrushValue = 1615;
local isShow;											--是否已经显示

--控件	
local mainDesktop;
local panel;
local labelTotalRecharge;								--累计充值
local progressBar;										--累计充值进度条
local headPic;
local yadianna;											--雅典娜全身像
local listView;
local rewardList = {};
local getRewardButton;

function TotalRechargePanel:InitPanel(desktop)
	--变量初始化
	rechargeLevel = 0;									--充值等级
	rechargeLevelList = {};
	rechargeMap = {2980, 6210, 9430, 12670, 15900, 18888};
	rechargeMap[0] = 0;
	changeBrushValue = 1615;
	isShow = false;										--是否已经显示
	rewardList = {};

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('totalRechargePanel'));
	panel:IncRefCount();
	
	labelTotalRecharge = panel:GetLogicChild('recharged'):GetLogicChild('label');
	progressBar = panel:GetLogicChild('rmbProb');
	headPic = panel:GetLogicChild('headPic');
	yadianna = panel:GetLogicChild('yadianna');
	getRewardButton = panel:GetLogicChild('getReward');
	progressBar.MaxValue = rechargeMap[#rechargeMap];
	
	for index = 1, 6 do
		local ctrl = panel:GetLogicChild('rmb' .. index);
		local label = ctrl:GetLogicChild('label');
		local rmb = resTableManager:GetValue(ResTable.recharge_accumulative, tostring(index), 'recharge');
		label.Text = tostring(rmb);
		table.insert(rechargeLevelList, rmb);
	end
	rechargeLevelList[0] = 0;
	rechargeLevelList[7] = rechargeLevelList[6];
	
	listView = panel:GetLogicChild('listView');
	for index = 1, 6 do
		local rewardpanel = listView:GetLogicChild(tostring(index)):GetLogicChild(0);
		local itemCell1 = rewardpanel:GetLogicChild('gem1');
		local name1 = rewardpanel:GetLogicChild('gemName1');
		local count1 = rewardpanel:GetLogicChild('count1');
		local itemCell2 = rewardpanel:GetLogicChild('gem2');
		local name2 = rewardpanel:GetLogicChild('gemName2');
		local count2 = rewardpanel:GetLogicChild('count2');
		local btnGetreward = rewardpanel:GetLogicChild('getReward');
		
		btnGetreward.Tag = index;
		
		--显示图标
		local reward = resTableManager:GetRowValue(ResTable.recharge_accumulative, tostring(index));
		--奖励1
		local reward1 = resTableManager:GetRowValue(ResTable.item, tostring(reward['item1']));
		count1.Text = tostring(reward['count1']);
		itemCell1.Image = GetIcon(reward1['icon']);
		itemCell1.Background = Converter.String2Brush( QualityType[reward1['quality']] );
		--name1.Text = reward1['name'];
		name1.TextColor = QualityColor[reward1['quality']];
		
		--奖励2
		local reward2 = resTableManager:GetRowValue(ResTable.item, tostring(reward['item2']));
		count2.Text = tostring(reward['count2']);
		itemCell2.Image = GetIcon(reward2['icon']);
		itemCell2.Background = Converter.String2Brush( QualityType[reward2['quality']] );
		name2.Text = reward2['name'];
		name2.TextColor = QualityColor[reward2['quality']];
		
		table.insert(rewardList, {rewardpanel, btnGetreward});
	end
	
	--初始化雅典娜头像
	headPic.Background = Converter.String2Brush( RoleQualityType[5] );	--金色
	-- headPic.Image = GetPicture('
	isShow = false;
	panel.Visibility = Visibility.Hidden;
end

--销毁
function TotalRechargePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function TotalRechargePanel:Show()
	--显示累计充值
	self:RefreshRechargeLevel();
	self:refreshListView();
	self:refreshTotalRechargeProb();
	
	if not isShow then
		yadianna.Background = CreateTextureBrush('dynamicPic/huodong_yadianna.ccz', 'godsSenki', Rect(0,0,377,341));
		isShow = true;
	end
	
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function TotalRechargePanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--===========================================================================================
--功能函数
--获得累计充值等级
function TotalRechargePanel:getRechargeLevel(rmb)
	for index = 0, 5 do
		if (rmb >= rechargeLevelList[index]) and (rmb < rechargeLevelList[index + 1]) then
			return index;
		end
	end
	return 6;
end

--刷新充值等级
function TotalRechargePanel:RefreshRechargeLevel()
	rechargeLevel = self:getRechargeLevel(ActorManager.user_data.vipexp);		--充值等级
	labelTotalRecharge.Text = tostring(ActorManager.user_data.vipexp);			--显示已充值水晶
end

--刷新累计充值进度条
function TotalRechargePanel:refreshTotalRechargeProb()
	
	if ActorManager.user_data.vipexp >= self.m_max then
		progressBar.CurValue = progressBar.MaxValue;
		local brush = uiSystem:FindResource('huodong_jindu_2', 'godsSenki');
		progressBar.ForwardBrush = brush;
	else
		local value = (ActorManager.user_data.vipexp - rechargeLevelList[rechargeLevel]) * (rechargeMap[rechargeLevel + 1] - rechargeMap[rechargeLevel]) / (rechargeLevelList[rechargeLevel + 1] - rechargeLevelList[rechargeLevel]);
		progressBar.CurValue = rechargeMap[rechargeLevel] + math.floor(value);
		if (progressBar.CurValue > self.m_max - 100) and (progressBar.CurValue < self.m_max) then
			progressBar.CurValue = self.m_max - 100;
		end
		
		if progressBar.CurValue <= changeBrushValue then
			local brush = uiSystem:FindResource('huodong_jindu_4', 'godsSenki');
			progressBar.ForwardBrush = brush;
		else
			local brush = uiSystem:FindResource('huodong_jindu_2', 'godsSenki');
			progressBar.ForwardBrush = brush;
		end
	end
end

--刷新充值listView
function TotalRechargePanel:refreshListView()
	local font = uiSystem:FindFont('huakang_20');
	for index = 1, 6 do
		local rewardpanel = listView:GetLogicChild(tostring(index)):GetLogicChild(0);	
		local label = rewardpanel:GetLogicChild('label');
		label:RemoveAllChildren();
		
		label:AddText(LANG_totalRechargePanel_1, QuadColor(Color(248, 220, 159, 255)), font);
		if rechargeLevel >= index then
			label.Visibility = Visibility.Hidden;
		else
			label.Visibility = Visibility.Visible;
			label:AddText(tostring(rechargeLevelList[index] - ActorManager.user_data.vipexp), Configuration.WhiteColor, font);
		end	
	
		label:AddBrush(uiSystem:FindResource('shuijing', 'common'), Size(23,26));
		
		label:AddText(LANG_totalRechargePanel_2, QuadColor(Color(248, 220, 159, 255)), font);	
	end
	
	self:RefreshGetRewardButton(true);
end

--领取奖励后的处理
function TotalRechargePanel:AfterGetReward( index, dismess, refreshFlag )
	self:RefreshGetRewardButton(refreshFlag);			--刷新领取按钮
	self:onTotalRewardDisplay(index, dismess);
	local btn;
	if index < 7 then
		local rewardpanel = listView:GetLogicChild(tostring(index)):GetLogicChild(0);
		btn = rewardpanel:GetLogicChild('getReward');
	elseif (index == 7) then
		btn = getRewardButton;
	end
	--PlayEffectLT('richangrenwulingqujiangli_output/', Rect(btn:GetAbsTranslate().x  + btn.Width * 0.5, btn:GetAbsTranslate().y + btn.Height * 0.5, 0, 0), 'richangrenwulingqujiangli');
end

--刷新领取按钮状态
function TotalRechargePanel:RefreshGetRewardButton( refreshFlag )
	
	local firstPos = -1;		--第一个可以领取的位置
	local endPos = -1;			--最后一个已领取的位置

	for index = 1, 6 do
		local rewardpanel = listView:GetLogicChild(tostring(index)):GetLogicChild(0);
		local btnGetreward = rewardpanel:GetLogicChild('getReward');
		
		if ActorManager.user_data.reward.acc_yb[index] == 0 then		--条件没满足
			btnGetreward.Enable = false;
			btnGetreward.Text = LANG_totalRechargePanel_3;
		elseif ActorManager.user_data.reward.acc_yb[index] == 1 then	--可领取
			btnGetreward.Enable = true;
			btnGetreward.Text = LANG_totalRechargePanel_4;
			
			if firstPos == -1 then
				firstPos = index;	--记录第一个可领取的位置
			end
		elseif ActorManager.user_data.reward.acc_yb[index] == -1 then	--已领取
			btnGetreward.Enable = false;
			btnGetreward.Text = LANG_totalRechargePanel_5;
			
			local label = rewardpanel:GetLogicChild('label');
			label.Visibility = Visibility.Hidden;
			
			endPos = index;			--记录已领取位置
		end
	end
	
	if refreshFlag then
		local pos = 0;
		if firstPos ~= -1 then
			pos = firstPos - 1;
		elseif endPos ~= -1 then
			pos = endPos;
		else
			pos = math.max(0, ActorManager.user_data.viplevel - 1);
		end

		listView:SetActivePageIndexImmediate(pos);
	end
	
	if ActorManager.user_data.reward.acc_yb[7] == 0 then		--条件没满足
		getRewardButton.Enable = false;
		getRewardButton.Text = LANG_totalRechargePanel_6;
	elseif ActorManager.user_data.reward.acc_yb[7] == 1 then	--可领取
		getRewardButton.Enable = true;
		getRewardButton.Text = LANG_totalRechargePanel_7;
	elseif ActorManager.user_data.reward.acc_yb[7] == -1 then	--已领取
		getRewardButton.Enable = false;
		getRewardButton.Text = LANG_totalRechargePanel_8;
	end

	--有、无奖励可以领
	if self:IsHaveReward() then
		PromotionPanel:ShowTotalRechargeEffect();
	else
		PromotionPanel:HideTotalRechargeEffect();
	end
end

--刷新累计充值标志
function TotalRechargePanel:RefreshTotalRechargeFlag( index )
	ActorManager.user_data.reward.acc_yb[index] = 1;			--可领取

	--有、无奖励可以领
	--if self:IsHaveReward() then
	--	PromotionPanel:ShowTotalRechargeEffect();
	--else
	--	PromotionPanel:HideTotalRechargeEffect();
	--end
end

--是否可以领取奖励
function TotalRechargePanel:IsHaveReward()
	for index = 1, 7 do
		if ActorManager.user_data.reward.acc_yb[index] == 1 then
			return true;
		end
	end
	
	return false;
end

--是否可以显示
function TotalRechargePanel:IsFinished()
	for index = 1, 7 do
		if ActorManager.user_data.reward.acc_yb[index] ~= -1 then
			return false;
		end
	end
	
	return true;
end


--===========================================================================================
--事件

--显示累计充值界面
function TotalRechargePanel:onShowTotalRechargePanel()
	MainUI:Push(self);
end

--关闭累计充值界面
function TotalRechargePanel:onClose()
	MainUI:Pop();
end

--领取按钮响应事件
function TotalRechargePanel:onGetReward(Args)
	local args = UIControlEventArgs(Args);
	msg = {};
	msg.flag = 200 + args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_reward, msg);
	
	if args.m_pControl.Tag == 6 then -- 把雅典娜一起领取
		msg.flag = 200 + args.m_pControl.Tag + 1;
		Network:Send(NetworkCmdType.req_reward, msg);		
	end
end

--显示雅典娜tip
function TotalRechargePanel:onYaDianNaClick()
	local role = {};
	role.resid = 2002;		--写死雅典娜
	role.lvl = {};
	role.lvl.level = 1;
	role.lvl.exp = 0;
	
	local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(role.resid));
	role.pro = {};
	role.pro.hp = actorData['base_hp'];
	role.pro.atk = actorData['base_atk'];
	role.pro.def = actorData['base_def'];
	role.pro.mgc = actorData['base_mgc'];
	role.pro.res = actorData['base_res'];
	role.pro.cri = actorData['base_crit'];
	role.pro.acc = actorData['base_acc'];
	role.pro.dodge = actorData['base_dodge'];
	role.pro.fp = 1137;		--战力
	role.quality = 0;		--星级
	role.potential = 1;		--潜力

	--调整伙伴数据
	ActorManager:AdjustRole(role);
	ActorManager:AdjustRoleSkill(role);
	ActorManager:AdjustRolePro(role.job, role.pro, role.pro);
	
	TooltipPanel:ShowRole(panel, role, 2);
end

--显示奖励
function TotalRechargePanel:onTotalRewardDisplay(index, dismess)
	local reward = resTableManager:GetRowValue(ResTable.recharge_accumulative, tostring(index));

	if (index < 7) then
		local reward1 = resTableManager:GetRowValue(ResTable.item, tostring(reward['item1']));		--奖励1
		ToastMove:AddGoodsGetTip(reward['item1'], reward['count1']);
		ToastMove:AddGoodsGetTip(reward['item2'], reward['count2']);
	elseif (index == 7) then
		if dismess == 1 then
			--如果获得英雄，显示是否已分解为碎片
			local pieceid, piecenum = ActorManager:ShowTipOfHeroToPiece(reward['heroid']);
			ToastMove:AddGoodsGetTip(pieceid, piecenum);
		else
			ToastMove:AddGoodsGetTip(reward['heroid'], 1);
		end
	end
end
