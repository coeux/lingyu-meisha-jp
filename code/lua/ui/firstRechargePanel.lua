--firstRechargePanel.lua
--==================================================================================
--首次充值界面
FirstRechargePanel =
	{
		roleResid = 0;
		firstEnter = false;
	};
	
--控件
local 	mainDesktop;
local 	panel;
local 	button;

local   rechargePanel 
local	titleLabel 		
local	rechangeImg 	
local	rechangeInfo 	
local brush_1;
local brush_2;
local	roleImg			
local	rechargeBtn 	
local	rewardPanel 	
local	rewardBtn	
local 	stackPanel	
local	colseBtn
local gemRewardList ={};
local roleInfo;		
local roleArm;
local targetArm;
local roleName;
local quImg;
local playBtn;
local detailBtn;

local isPlay = false;

--初始化
function FirstRechargePanel:InitPanel(desktop)
	self.firstEnter = false;

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('firstRechargePanel'));
	panel:IncRefCount();
	rechargePanel 	= panel:GetLogicChild('rechargePanel');
	rechargeBtn 	= rechargePanel:GetLogicChild('rechargeBtn');
	rewardPanel 	= rechargePanel:GetLogicChild('rewardPanel');
	rewardBtn		= rechargePanel:GetLogicChild('rewardBtn');
	colseBtn		= rechargePanel:GetLogicChild('close');
	roleInfo		= rechargePanel:GetLogicChild('roleInfo');
	roleArm			= roleInfo:GetLogicChild('role_arm');
	targetArm		= roleInfo:GetLogicChild('target_arm');
	roleName		= roleInfo:GetLogicChild('name');
	quImg			= roleInfo:GetLogicChild('qu_img');
	playBtn			= roleInfo:GetLogicChild('playBtn');
	detailBtn		= roleInfo:GetLogicChild('detailBtn');
	rechangeInfo 	= roleInfo:GetLogicChild('rechangeInfo');
	brush_1			= rechargePanel:GetLogicChild('brush_1');
	brush_2			= brush_1:GetLogicChild('brush_2');
	
	playBtn:SubscribeScriptedEvent('Button::ClickEvent','FirstRechargePanel:playBtnClick');
	detailBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','FirstRechargePanel:detailBtnClick');
	colseBtn:SubscribeScriptedEvent('Button::ClickEvent', 'FirstRechargePanel:onClose');
	rechargeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'RechargePanel:onShowRechargePanel');
	rewardBtn:SubscribeScriptedEvent('Button::ClickEvent', 'FirstRechargePanel:onButtonClick');
	panel.Visibility = Visibility.Hidden;
	FirstRechargePanel:initRechargeRewards()
end
function FirstRechargePanel:playBtnClick()
	if isPlay then
		return;
	end
	isPlay = true;
	local r = math.random(1, 3);
	local actorInfo = 
	{
		AnimationType.attack,
		AnimationType.skill,
		AnimationType.skill2,
	}
	local data = resTableManager:GetRowValue(ResTable.actor, tostring(self.roleResid));
	local script;
	if r == 1 then
		script = data['atk_script'];
	elseif r == 2 then
		script = data['skill_script'];
	elseif r == 3 then
		script = data['skill_script2'];
	end

	AvatarPosEffect:SetPlayerEnemyArmature(roleArm, targetArm);
	LoadLuaFile('skillScript/' .. script .. '.lua');
	--加载脚本所需资源
	local scriptLua = _G[script];
	scriptLua:preLoad();
	local effectScript = effectScriptManager:CreateEffectScript(script);
	effectScript:SetArgs('Attacker', 100);
	--此参数代表此次攻击的ID，参数名称等测试完毕更改技能脚本
	effectScript:SetArgs('Targeter', -100);
	effectScript:TakeOff();

	roleArm:SetAnimation(tostring(actorInfo[r]));
	roleArm:SetScriptAnimationCallback('FirstRechargePanel:actorEnd', 0);
end
function FirstRechargePanel:actorEnd( )
	isPlay = false;
	roleArm:SetAnimation(AnimationType.f_idle);
	self:initRole();
end
function FirstRechargePanel:detailBtnClick()
	local str = 30000+self.roleResid;
	TipsPanel:onShow(str);
end
--销毁
function FirstRechargePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function FirstRechargePanel:Show()
	rechargePanel.Background = CreateTextureBrush('recharge/first_recharege_bg.ccz','godsSenki');
	rechangeInfo.Image = GetPicture('recharge/first_recharege_tip.ccz');
	brush_1.Background = CreateTextureBrush('recharge/des_bg.ccz', 'rechange');
	--brush_2.Background = CreateTextureBrush('recharge/des_info.ccz', 'rechange');
	FirstRechargePanel:OnRefreshRechargePanel()
	mainDesktop:DoModal(panel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--首冲有礼面板初始化
function FirstRechargePanel:initRechargeRewards()
	--物品奖励
	for index = 1, 4 do
		local ItemCell = rewardPanel:GetLogicChild('' .. index);
		table.insert(gemRewardList, {itemCell = ItemCell});
	end
end

--刷新首冲有礼奖励
function FirstRechargePanel:OnRefreshRechargePanel()
	local reward = resTableManager:GetRowValue(ResTable.recharge_fristtime, 0);

	for index = 1, 3 do
		local resid = reward['item' .. index ];
		local num = reward['count' .. index ];
		local contrl = customUserControl.new(rewardPanel:GetLogicChild(''.. (index + 1)), 'itemTemplate');
		print(resid)
		contrl.initWithInfo(resid, -1, 90, true);
		-- local Item = resTableManager:GetValue(ResTable.item, tostring(reward['item' .. index ]), {'name', 'icon', 'quality'});
		-- gemRewardList[index].itemCell.Image = GetIcon(Item['icon']);
		-- gemRewardList[index].itemCell.ItemNum = reward['count' .. index];
		table.insert(rewardList, {id = reward['item' .. index ], count = reward['count' .. index ]});
		local name = resTableManager:GetValue(ResTable.item,tostring(resid),'name');
		rewardPanel:GetLogicChild('r'.. (index + 1)).Text = tostring(name)..'x'..tostring(num);
	end

	local resid = reward['item4'];
	local num = reward['count4'];
	local contrl = customUserControl.new(rewardPanel:GetLogicChild(tostring(1)), 'itemTemplate');
	contrl.initWithInfo(resid, -1, 90, true);
	local chipName = resTableManager:GetValue(ResTable.item,tostring(resid),'name');
	print(resid)
	rewardPanel:GetLogicChild('r'.. (1)).Text = tostring(chipName)..'x'..tostring(num);
	self.roleResid = resid%10000;
	self:initRole();

	FirstRechargePanel:RefreshButton();
end
function FirstRechargePanel:initRole()
	local data = resTableManager:GetRowValue(ResTable.actor, tostring(self.roleResid));
	local rare = resTableManager:GetValue(ResTable.item, tostring(self.roleResid+40000), 'quality');
	--roleName.Text = tostring(data['name']);
	quImg.Image = GetPicture('chouka/qu_'..rare..'.ccz');

	roleArm:Destroy();
	local path = GlobalData.AnimationPath .. data['path'] .. '/';
	AvatarManager:LoadFile(path);
	roleArm:LoadArmature(data['img']);
	roleArm:SetAnimation(AnimationType.f_idle);
	roleArm:SetScale(1.3, 1.3);
	roleArm.Horizontal = ControlLayout.H_CENTER;
	roleArm.Vertical = ControlLayout.V_CENTER;
end

--隐藏
function FirstRechargePanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');

	if self.firstEnter then
		--[[
		local showTime12 = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(15005), 'time');
		local showTime13 = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(15006), 'time');
		local cardEvent = ActorManager.user_data.functions.card_event;
		if ActorManager.user_data.extra_data.is_pub_4 then --十连抽	
			EverydayTipPanel:Show(1)
		elseif showTime12 and LuaTimerManager:GetCurrentTimeStamp() <= (ActorManager.user_data.reward.servercreatestamp+tonumber(showTime12)*86400) then	--限定商店
			EverydayTipPanel:Show(2)
		elseif showTime13 and LuaTimerManager:GetCurrentTimeStamp() <= (ActorManager.user_data.reward.servercreatestamp+tonumber(showTime13)*86400) then	--指定
			EverydayTipPanel:Show(3)
		elseif LuaTimerManager:GetCurrentTimeStamp() >= cardEvent.begin_stamp and LuaTimerManager:GetCurrentTimeStamp() <= cardEvent.end_stamp then
			EverydayTipPanel:Show(4)
		end
		]]
		EverydayTipPanel:onShow();
		self.firstEnter = false;
	end	
end

--=================================================================================
--功能函数
--刷新按钮
function FirstRechargePanel:RefreshButton()
	--[[
	if ActorManager.user_data.reward.first_yb == 0 then
		rewardBtn.Enable = false;
	elseif ActorManager.user_data.reward.first_yb == 1 and ActorManager.user_data.reward.recharge_back.can_get_first == 1 then
		rewardBtn.Enable = true;
	elseif ActorManager.user_data.reward.first_yb == -1 then
		rewardBtn.Enable = false;
	else
		rewardBtn.Enable = false;
	end
	]]
	if ActorManager.user_data.reward.first_yb == 1 and ActorManager.user_data.reward.recharge_back.can_get_first == 1 then
		rewardBtn.Enable = true;
	else
		rewardBtn.Enable = false;
	end
end

--=================================================================================
--事件
--显示
function FirstRechargePanel:firstEnterRechargePanel()
	self.firstEnter = true;
	self:onShowFirstRechargePanel();
end
function FirstRechargePanel:onShowFirstRechargePanel()
	MainUI:Push(self);
end

--关闭
function FirstRechargePanel:onClose()
	MainUI:Pop();
end

--按钮相应事件
function FirstRechargePanel:onButtonClick()
	if 1 == ActorManager.user_data.reward.first_yb then
		--领取奖励
		local msg = {};
		msg.flag = 101;
		Network:Send(NetworkCmdType.req_reward, msg);
	end
end

--添加首次充值奖励显示
function FirstRechargePanel:onGetFirstReward(dismess)
	for _, item in ipairs(rewardList) do
		if (item.id == actorID) and (dismess == 1) then
			--如果获得英雄，显示是否已分解为碎片
			local pieceid, piecenum = ActorManager:ShowTipOfHeroToPiece(actorID);
			ToastMove:AddGoodsGetTip(pieceid, piecenum);
		else
			ToastMove:AddGoodsGetTip(item.id, item.count);
		end
	end
end

