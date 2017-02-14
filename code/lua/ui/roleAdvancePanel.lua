--roleAdvancePanel.lua

--========================================================================
--角色进阶界面

RoleAdvancePanel =
	{
		canAdvance		= false;			--可以进阶
	};
	
--变量
local role				= {};
local canAdvanceRoleCount = 0;				--可升阶人物的数量
local isAdvanceRoleCountChanged;			--是否有材料改变,判断是否重新计算可升阶人物的数量
local requireAdvanceMoney = 0;				--升星需要金币
local lastIndex = 0;
local isSoulNoEnough = false;
local isChipNoEnough = false;
local noEnoughChipId = 0;

--控件
local mainDesktop;
local advancePanel;

local labelCurName;
local stackPanelStar1;
local stackPanelStar2;
local brushArrow;
local labelInfo;
local labelCoin;
local btnAdvance;

local huobanList;
local huobanListClip;
local lastVoidId;


--初始化面板
function RoleAdvancePanel:InitPanel(desktop)
	
	--变量
	self.canAdvance		= false;			--可以进阶
	role				= {};
	canAdvanceRoleCount = 0;				--可升阶人物的数量
	isAdvanceRoleCountChanged = true;		--是否有材料改变,判断是否重新计算可升阶人物的数量
	requireAdvanceMoney = 0;				--升星需要金币
	lastVoidId = 0;

	--界面初始化
	mainDesktop = desktop;
	advancePanel = Panel(desktop:GetLogicChild('roleAdvancePanel'));
	advancePanel:IncRefCount();
	advancePanel.Visibility = Visibility.Hidden;
	
	huobanListClip = advancePanel:GetLogicChild('huobanListClip');
	huobanList = huobanListClip:GetLogicChild('huobanList');
	
	labelCurName 		= Label(advancePanel:GetLogicChild('name'));
	stackPanelStar1		= advancePanel:GetLogicChild('star1');
	stackPanelStar2		= advancePanel:GetLogicChild('star2');
	labelInfo			= Label(advancePanel:GetLogicChild('info'));
	labelCoin			= Label(advancePanel:GetLogicChild('jbNum'));
	btnAdvance			= Button(advancePanel:GetLogicChild('advance'));
	brushArrow			= BrushElement(advancePanel:GetLogicChild('arrow'));
	
end

--销毁
function RoleAdvancePanel:Destroy()
	advancePanel:DecRefCount();
	advancePanel = nil;
end

--显示
function RoleAdvancePanel:Show()
	
	--记录老战斗力
	ActorManager.oldFP = ActorManager.user_data.fp;

	--添加角色
	self:AddRole();
	
	--设置模式对话框
	mainDesktop:DoModal(advancePanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(advancePanel, StoryBoardType.ShowUI1, nil, 'RoleAdvancePanel:onUserGuid');	
end

--打开时的新手引导
function RoleAdvancePanel:onUserGuid()
	if UserGuidePanel:GetInGuilding() then
		if btnAdvance.Enable then
			UserGuidePanel:ShowGuideShade(btnAdvance, GuideEffectType.hand, GuideTipPos.bottom, LANG_roleAdvancePanel_1, nil, 0.5);
		end
		UserGuidePanel:SetInGuiding(false);
	end	
end

--隐藏
function RoleAdvancePanel:Hide()
	--战斗力改变
	ActorManager:UpdateFightAbility();
	--GemPanel:totleFp();
	FightPoint:ShowFP(ActorManager.user_data.fp - ActorManager.oldFP);
	ActorManager.oldFP = ActorManager.user_data.fp;	
	
	--删除角色
	self:RemoveRole();

	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(advancePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--添加角色
function RoleAdvancePanel:AddRole()
	
	--排序伙伴
	table.sort(ActorManager.user_data.partners, sortPartner);
	
	--获取主角个伙伴的总个数
	local roleCount = 1 + #(ActorManager.user_data.partners);
	
	--创建头像列表
	for i = 1, roleCount do
		local t = uiSystem:CreateControl('huobanInfoTemplate');		
		local radioButton = RadioButton(t:GetLogicChild(0));
		radioButton.Visibility = Visibility.Visible;
		radioButton.GroupID = RadionButtonGroup.selectRoleAdvanceHuoBan;
		radioButton.Tag = i;
		--添加响应事件
		radioButton:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RoleAdvancePanel:onRoleClick');
		
		--获取控件
		local labelName = Label(radioButton:GetLogicChild('name'));
		local imgJob = ImageElement(radioButton:GetLogicChild('job'));
		local imgHeadPic = ItemCell(radioButton:GetLogicChild('image'));
		local imgInTeam = ItemCell(radioButton:GetLogicChild('inTeam'));
		local imgUP = ImageElement(radioButton:GetLogicChild('up'));
		
		--设置控件属性
		local actor = {};
		if 1 == i then
			--主角
			actor = ActorManager.user_data.role;	
		else
			--伙伴
			actor = ActorManager.user_data.partners[i - 1];
		end	
		labelName.Text = actor.name;
		labelName.TextColor = QualityColor[actor.rare];
		imgJob.Image = actor.jobIcon;
		imgHeadPic.Background = Converter.String2Brush( RoleQualityType[actor.rare] );
		imgHeadPic.Image = GetPicture('navi/' .. actor.headImage .. '.ccz');
		
		imgInTeam.Visibility = Visibility.Hidden;
		
		if self:isRoleCanAdvance(actor) then
			imgUP.Visibility = Visibility.Visible;
		else
			imgUP.Visibility = Visibility.Hidden;
		end
		
		--添加到头像列表
		huobanList:AddChild(t);
	end
	
	if huobanList:GetLogicChildrenCount() ~= 0 then
		local tt = huobanList:GetLogicChild(0);
		local radioButton = RadioButton(tt:GetLogicChild(0));
		radioButton.Selected = true;
	end
end

--删除角色
function RoleAdvancePanel:RemoveRole()
	huobanList:RemoveAllChildren();
	role = {};	
end

--刷新伙伴进阶
function RoleAdvancePanel:RefreshRole( pid )
	if (role ~= nil) and (role.pid == pid) then
		local radioButton = UISystem.GetSelectedRadioButton(RadionButtonGroup.selectRoleAdvanceHuoBan);
		if radioButton ~= nil then
			self:SetRole(radioButton.Tag);
		end
	end
end

function RoleAdvancePanel:onRoleAdvance( pid)
	self:RefreshRole( pid );
	RoleAdvanceInfoPanel:onShow(role);
end

--设置角色属性
function RoleAdvancePanel:SetRole(index)
	lastIndex = index;
	
	--设置数据
	if 1 == index then
		--主角
		role = ActorManager.user_data.role;	
	else
		--伙伴
		role = ActorManager.user_data.partners[index - 1];
	end
	
	-- 播放声优
	if lastVoidId ~= role.resid then
		SoundManager:PlayVoice('v' .. tostring(role.resid));
		lastVoidId = role.resid;
	end
	
	--名字
	labelCurName.Text = role.fullName;
	labelCurName.TextColor = QualityColor[role.rare];

	--星级
	for i = 1, Configuration.RoleMaxStarNum do
		local child = stackPanelStar1:GetLogicChild(i-1);
		if child == nil then
			--星不够就动态创建
			child = stackPanelStar1:GetLogicChild(0):Clone();
			stackPanelStar1:AddChild(child);
		end

		if role.quality >= i then
			child.Visibility = Visibility.Visible;
		else
			child.Visibility = Visibility.Hidden;
		end
	end
	
	--设置进阶数据	
	btnAdvance.Enable = true;
	labelInfo.Visibility = Visibility.Hidden;

	stackPanelStar2.Visibility = Visibility.Visible;
	for i = 1, Configuration.RoleMaxStarNum do
		local child = stackPanelStar2:GetLogicChild(i-1);
		if child == nil then
			--星不够就动态创建
			child = stackPanelStar2:GetLogicChild(0):Clone();
			stackPanelStar2:AddChild(child);
		end

		if (role.quality + 1)  >= i then
			child.Visibility = Visibility.Visible;
		else
			child.Visibility = Visibility.Hidden;
		end
	end

	self.canAdvance = true;

	--设置消耗数据
	local stuffID;
	--为了满星特殊显示
	if role.quality >= Configuration.RoleMaxStarNum then
		stuffID = role.resid * 10 + role.quality;
	else
		stuffID = role.resid * 10 + role.quality + 1;
	end
	local stuffData = resTableManager:GetRowValue(ResTable.qualityup_stuff, tostring(stuffID));
	labelCoin.Text = tostring(stuffData['var3']);
	requireAdvanceMoney = stuffData['var3'];

	isSoulNoEnough = false;
	isChipNoEnough = false;

	for i = 1, 2 do
		local countID;
		local resID;
		if i == 1 then
			countID = 'var2';
			resID = '10009';
		elseif i == 2 then
			countID = 'var1';
			resID = '3' .. stuffData['resid'];
		end
		
		local xiaohao = advancePanel:GetLogicChild('materialList'):GetLogicChild('xiaohao'..i);
		
		local name = Label(xiaohao:GetLogicChild('name'));
		local cur = Label(xiaohao:GetLogicChild('cur'));
		local need = Label(xiaohao:GetLogicChild('need'));
		local item = ItemCell(xiaohao:GetLogicChild('item'));

		local count;
		count = stuffData[countID];
		if count == 0 then
			xiaohao.Visibility = Visibility.Hidden;
		else
			xiaohao.Visibility = Visibility.Visible;
			local quality = resTableManager:GetValue(ResTable.item, resID, 'quality');
			name.Text = resTableManager:GetValue(ResTable.item, resID, 'name');
			name.TextColor = QualityColor[quality];
						
			local curNum = 0;
			if resID == '10009' then
				curNum = ActorManager.user_data.soul;
				cur.Text = tostring(curNum);
				local iconId = resTableManager:GetValue(ResTable.item, resID, 'icon');
				item.Image = GetPicture('icon/' .. iconId .. '.ccz');
			else
				local chipItem = Package:GetChip(tonumber(resID));
				if chipItem == nil then
					cur.Text = '0';
					local iconId = resTableManager:GetValue(ResTable.item, resID, 'icon');
					item.Image = GetPicture('icon/' .. iconId .. '.ccz');
				else
					cur.Text = tostring(chipItem.count);
					curNum = chipItem.count;
					item.Image = chipItem.icon;
				end
			end
			
			
			--设置背景刷
			item.Background = Converter.String2Brush( QualityType[quality] );
			
			item.Tag = tonumber(resID);
			
			local needNum = count;
			--为了满星特殊显示
			if role.quality >= Configuration.RoleMaxStarNum then
				cur.Text = '0';
				needNum = 0;
				self.canAdvance = false;
			end
			need.Text = '/' .. needNum;
			
			--修改文字颜色
			if curNum < needNum then
				cur.TextColor = Configuration.RedColor;
				if i == 1 then
					isSoulNoEnough = true;
				elseif i == 2 then
					isChipNoEnough = true;
					noEnoughChipId = resID;
				end
				--self.canAdvance = false;
			else
				cur.TextColor = Configuration.GreenColor;
			end
		end				
	end
	
	advancePanel:GetLogicChild('materialList'):ForceLayout();
	
	if role.quality >= Configuration.RoleMaxStarNum then
		labelCoin.Visibility = Visibility.Hidden;
		labelInfo.Visibility = Visibility.Visible;
	else
		labelCoin.Visibility = Visibility.Visible;
		labelInfo.Visibility = Visibility.Hidden;
	end
	
	if self.canAdvance then
		btnAdvance.Enable = true;
	else
		btnAdvance.Enable = false;
	end
	
	self:SetAdvanceRoleCountChanged();

end

--设置材料种类和数量已经改变
--队伍变化，背包里材料和图纸变化，角色等级变化
function RoleAdvancePanel:SetAdvanceRoleCountChanged()
	isAdvanceRoleCountChanged = true;

end

--获取可升阶的人物数量
function RoleAdvancePanel:GetAdvanceRoleCount()
	if not isAdvanceRoleCountChanged then
		return canAdvanceRoleCount;
	end
	
	canAdvanceRoleCount = 0;								--重置数量
	
	--获取主角个伙伴的总个数
	local roleCount = 1 + #(ActorManager.user_data.partners);
	
	--创建头像列表
	for i = 1, roleCount do
		local actor = {};
		if 1 == i then
			--主角
			actor = ActorManager.user_data.role;
		else
			--伙伴
			actor = ActorManager.user_data.partners[i - 1];
		end	
		
		local actorCanAdvance = self:isRoleCanAdvance(actor);
		if actorCanAdvance then
			canAdvanceRoleCount = canAdvanceRoleCount + 1;
		end
		
		local huobanPanel = huobanList:GetLogicChild(i - 1);
		if huobanPanel ~= nil then
			local up = huobanPanel:GetLogicChild(0):GetLogicChild('up');
			if actorCanAdvance then
				up.Visibility = Visibility.Visible;
			else
				up.Visibility = Visibility.Hidden;
			end
		end
	end

	isAdvanceRoleCountChanged = false;
	return canAdvanceRoleCount;
end

function RoleAdvancePanel:isRoleCanAdvance( role )
	
	local actorCanAdvance = true;
	--是否满星
	if role.quality >= Configuration.RoleMaxStarNum then
		return false;
	end
	--设置消耗数据
	local stuffID = role.resid * 10 + role.quality + 2;	
	local stuffData = resTableManager:GetRowValue(ResTable.qualityup_stuff, tostring(stuffID));
--[[
	--判断金币数量	
	if ActorManager.user_data.money < stuffData['var3'] then
		return false;
	end
	
	--判断灵能数量	
	if ActorManager.user_data.soul < stuffData['var2'] then
		return false;
	end
--]]	
	--判断碎片数量
	local chipId = 30000 + stuffData['resid'];
	local chipItem = Package:GetChip(tonumber(chipId));	
	if (chipItem == nil or chipItem.count < stuffData['var1']) and stuffData['var1'] ~= 0 then
		return false;
	end
	return actorCanAdvance;
end

--刷新角色信息
function RoleAdvancePanel:refreshRoleInfo()
	if Visibility.Visible == advancePanel.Visibility then
		self:SetRole(lastIndex);
	end
end

--========================================================================
--点击事件

--关闭事件
function RoleAdvancePanel:onClose()
	MainUI:Pop();
end

--显示
function RoleAdvancePanel:onShow()
	MainUI:Push(self);
end

--头像点击事件
function RoleAdvancePanel:onRoleClick(Args)
	local args = UIControlEventArgs(Args);
	self:SetRole(args.m_pControl.Tag);
end

function RoleAdvancePanel:goPub()
	print('RoleAdvancePanel:goPub(), now change to new UI')
end
--进阶点击事件
function RoleAdvancePanel:onAdvanceClick(Args)
	if self.canAdvance then
		if isSoulNoEnough then
			local okDelegate = Delegate.new(RoleAdvanceSoulPanel, RoleAdvanceSoulPanel.onShow);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_roleAdvancePanel_6, okDelegate);
		elseif isChipNoEnough then
			local okDelegate = Delegate.new(RoleAdvancePanel, RoleAdvancePanel.goPub);
			local contents = {};
			local data = resTableManager:GetRowValue(ResTable.item, tostring(noEnoughChipId));
			table.insert(contents, {cType = MessageContentType.Text; text = data['name'], color = QualityColor[data['quality']]});
			table.insert(contents, {cType = MessageContentType.Text; text = LANG_roleAdvancePanel_4});
			MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate);
		elseif ActorManager.user_data.money < requireAdvanceMoney then
			CoinNotEnoughPanel:ShowCoinNotEnoughPanel(LANG_roleAdvancePanel_5);
		else
			local msg = {};
			msg.pid = role.pid;
			Network:Send(NetworkCmdType.req_quality_up, msg);
		end
	else
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_roleAdvancePanel_3);
	end
end

--材料tip
function RoleAdvancePanel:onMaterialClick( Args )
	local args = UIControlEventArgs(Args);
	
	local item = {};
	item.resid = args.m_pControl.Tag;
	TooltipPanel:ShowItem(advancePanel, item, TipMaterialShowButton.Obtain);
end
