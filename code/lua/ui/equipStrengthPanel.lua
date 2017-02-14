--equipStrengthPanel.lua
--装备面板
--========================================================================
EquipStrengthPanel =
	{
		--变量
		pageIndex = 1,
		isShow = false,			--用于装备选择事件，false表示初始化事件，true表示点击事件

		currentRoleSelected = 0,			--当前选中的人物的pid
		selectedRole,						--当前选中的人物

		typeText,
		addCount,

		--界面
		mainDesktop,
		equipStrengthPanel,
		centerPanel,
		btnReturn,
		tabControl,

		cardRole,
		needMaterialNum = {},
		totalMaterialNum = {},

		--装备强化
		strengthPanel = {},
		eqUpPanel,
		eqStackPanel,
		eqInfoPanel,
		eqMoney,

		eqAdvPanel,
		advInfoPanel,

		equipUpList = {},
		equipAdvList ={},
		materialAdvList = {},
		equipInfo,
		effectAU = nil,
		playTimes = 1,
		userGuideBtn,
		isUserGuideEnter,
		eqSound,
		curIndex = 1;
	};
	
--装备属性类型
local equip_class_map = 
{
  [1] = LANG_EquipStrengthPanel_1; -- 攻击
  [2] = LANG_EquipStrengthPanel_2; -- 绝技
  [3] = LANG_EquipStrengthPanel_3; -- 防御
  [4] = LANG_EquipStrengthPanel_4; -- 技防
  [5] = LANG_EquipStrengthPanel_5; -- 生命
  [6] = LANG_EquipStrengthPanel_6;	-- 暴击
  [7] = LANG_EquipStrengthPanel_7;	-- 命中
  [8] = LANG_EquipStrengthPanel_8;	-- 闪避
  [9] = LANG_EquipStrengthPanel_9;	-- 韧性
  [10] =  LANG_EquipStrengthPanel_10;	-- 免伤
}; 

--初始化面板
function EquipStrengthPanel:InitPanel( desktop )
	--变量初始化
	self.selectedRole = nil;
	self.pageIndex = 1;
	self.isShow = false;						--用于装备选择事件，false表示初始化事件，true表示点击事件
	self.strengthPanel = {};
	self.eqSound = nil
	--界面初始化
	self.mainDesktop = desktop;
	self.equipStrengthPanel = Panel( desktop:GetLogicChild('equipStrengthPanel') );
	self.equipStrengthPanel.ZOrder = PanelZOrder.equip;
	self.equipStrengthPanel:IncRefCount();
	self.equipStrengthPanel.Visibility = Visibility.Hidden;
	self.equipStrengthPanel.ZOrder = 500;
	
	self.btnReturn = Button(self.equipStrengthPanel:GetLogicChild('returnBtn'));
	self.btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'EquipStrengthPanel:onClose');
	
	self.centerPanel = self.equipStrengthPanel:GetLogicChild('center');

	self.tabControl = self.centerPanel:GetLogicChild('tabControl');
	self.tabControl.ActiveTabPageIndex = 0;

	self.eqUpPanel = self.tabControl:GetLogicChild('equip');
	self.eqAdvPanel = self.tabControl:GetLogicChild('adv');

	self.eqStackPanel = self.eqUpPanel:GetLogicChild('eqStackPanel');
	self.eqInfoPanel = self.eqUpPanel:GetLogicChild('equipInfoPanel');
	self.eqMoney = self.eqUpPanel:GetLogicChild('goldPanel'):GetLogicChild('num');
	self.strengthPanel.strength_moneyCost = {};

	self.advInfoPanel = self.eqAdvPanel:GetLogicChild('advInfoPanel');

	for i=1, 5 do
		local eq = customUserControl.new(self.eqUpPanel:GetLogicChild('eqStackPanel'), 'HomeIconTemplate');
		local adv = customUserControl.new(self.eqAdvPanel:GetLogicChild('advStackPanel'), 'HomeIconTemplate');
		self.equipUpList[i] = eq;
		self.equipAdvList[i] = adv;
		self.strengthPanel.strength_moneyCost[i] = 0;
	end
	self:bind();
	uiSystem:UpdateDataBind();

	--装备升阶材料
	for i=1, 6 do
		self.materialAdvList[i] = customUserControl.new(self.advInfoPanel:GetLogicChild('material' .. i):GetLogicChild('item1'), 'itemTemplate');
	end

	self.userGuideBtn = self.equipStrengthPanel:GetLogicChild('userGuideBtn');
	self.userGuideBtn:SubscribeScriptedEvent('Button::ClickEvent', 'EquipStrengthPanel:userGuide');
	self.isUserGuideEnter = false;
end

--销毁
function EquipStrengthPanel:Destroy()
	self:unbind();
	self.equipStrengthPanel:DecRefCount();
	self.equipStrengthPanel = nil;
end

--显示
function EquipStrengthPanel:Show(enterRoleid)
	if not self:IsVisible() then
		HomePanel:destroyRoleSound()
	end
	if not HomePanel:rolePanelInfo() then HomePanel:ListClick() end
	if CardDetailPanel:isShow() then CardDetailPanel:onBack(); end
	self.currentRoleSelected = enterRoleid or 0;
	self:updateRole();
	self:updateEquip();


	self.pageIndex = 1;
	self.tabControl.ActiveTabPageIndex = 0;
	self.equipInfo = self.equipUpList[1];
	self.curIndex = self.equipInfo.ctrl:GetLogicChild('btn').TagExt;
	EquipStrengthPanel:UpdateInfo();
	self.equipInfo.ctrl.Selected = true;
	self.equipStrengthPanel.Visibility = Visibility.Visible;

	if UserGuidePanel:IsInGuidence(UserGuideIndex.equip, 1) and UserGuidePanel:GetIsequipguide() and self.currentRoleSelected == 0 then
		UserGuidePanel:ShowGuideShade(self.eqInfoPanel:GetLogicChild('autoBtn'), GuideEffectType.hand, GuideTipPos.right, LANG_EquipStrengthPanel_1);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.equipadv, 1) and UserGuidePanel:GetIsequipguide() then
		self.userGuideBtn.Visibility = Visibility.Visible;
		UserGuidePanel:ShowGuideShade(self.userGuideBtn,GuideEffectType.hand,GuideTipPos.right, '', 0.3);
	end

	--装备进阶tips刷新
	EquipStrengthPanel:UpdateAdvEquip();

	self.effectAU = nil;
	self.isShow = true;
end

function EquipStrengthPanel:userGuide()
	self.userGuideBtn.Visibility = Visibility.Hidden;
	self.pageIndex = 2;
	self.tabControl.ActiveTabPageIndex = 1;
	if UserGuidePanel:IsInGuidence(UserGuideIndex.equipadv, 1) and UserGuidePanel:GetIsequipguide() then
		UserGuidePanel:ShowGuideShade(self.equipAdvList[1].child, GuideEffectType.hand, GuideTipPos.right, LANG_EquipStrengthPanel_1, 0.4);
		self.isUserGuideEnter = true;
	end
end

--隐藏
function EquipStrengthPanel:Hide()
	self:RemoveRole();
	self.equipStrengthPanel.Visibility = Visibility.Hidden;
	if HomePanel:rolePanelInfo() then HomePanel:ListClick() end
	self.isShow = false;
end

--========================================================================
--功能函数
--========================================================================
--绑定数据
function EquipStrengthPanel:bind()
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', self.eqMoney, 'Text');					--绑定金币
end

--取消绑定数据
function EquipStrengthPanel:unbind()
	uiSystem:UnBind(ActorManager.user_data, 'money', self.eqMoney, 'Text');						--取消绑定金币
end

--是否显示
function EquipStrengthPanel:IsVisible()
	return self.isShow;
end

--删除角色
function EquipStrengthPanel:RemoveRole()
	self.selectedRole = nil;
end

--刷新装备升阶材料
function EquipStrengthPanel:RefreshRankMaterial(equip)
	local upBtn = self.advInfoPanel:GetLogicChild('lvupBtn');
	for j=1, 6 do
		local stuff = resTableManager:GetValue(ResTable.equip_compose, tostring(equip.resid), 'stuff_' .. j);
		if stuff and stuff ~= 0 then
			local needNum = resTableManager:GetValue(ResTable.equip_compose, tostring(equip.resid), 'stuff_' .. j .. '_num');
			local curNum = Package:GetEquip(stuff) and Package:GetEquip(stuff).num or 0;
			local materialInfo = resTableManager:GetRowValue(ResTable.item, tostring(stuff));
			local materialPanel = self.advInfoPanel:GetLogicChild('material' .. j);
			materialPanel.Visibility = Visibility.Visible;
			self.materialAdvList[j].initWithInfo(stuff, -1, 65, false);
			self.materialAdvList[j].addExtraClickEvent(stuff, 'EquipStrengthPanel:onMaterialClick');

			materialPanel:GetLogicChild('name').Text = materialInfo['name'];
			materialPanel:GetLogicChild('count').Text = '/' .. needNum;
			materialPanel:GetLogicChild('count1').Text = tostring(curNum);
			materialPanel:GetLogicChild('item1').Tag = stuff;
			if curNum < needNum then
				materialPanel:GetLogicChild('count1').TextColor = QuadColor(Color(232, 38, 74, 255));
			else
				materialPanel:GetLogicChild('count1').TextColor = QuadColor(Color(60, 137, 11, 255));
			end
			
			self.needMaterialNum[stuff] = needNum
			self.totalMaterialNum[stuff] = curNum		
		else
			self.advInfoPanel:GetLogicChild('material' .. j).Visibility = Visibility.Hidden;
		end
	end
end

--某角色装备是否可以进阶
function EquipStrengthPanel:IsEquipCanAdv(equiproleinfo)
	for i = 1, 5 do
		local equip = equiproleinfo.equips[tostring(i)];
		if EquipStrengthPanel:isCanAdvance(equip) then
			return true;
		end
	end
	return false;
end

--某装备是否可以升阶
function EquipStrengthPanel:isCanAdvance(equip)
	local isEnable = true;
	for j=1, 6 do
		local stuff = resTableManager:GetValue(ResTable.equip_compose, tostring(equip.resid), 'stuff_' .. j);
		if stuff and stuff ~= 0 then
			local needNum = resTableManager:GetValue(ResTable.equip_compose, tostring(equip.resid), 'stuff_' .. j .. '_num');
			local curNum = Package:GetEquip(stuff) and Package:GetEquip(stuff).num or 0;
			if curNum < needNum then
				isEnable = false;
			end	
		end
	end

	return isEnable
end

--是否有角色装备可以升阶
function EquipStrengthPanel:isHaveRoleEquipCanAdv()
	for _,roleinfo in ipairs(ActorManager.user_data.partners) do
		if EquipStrengthPanel:IsEquipCanAdv(roleinfo) then
			TipFlag:UpdateFlagEquip(true);
			return;
		end
	end
	if EquipStrengthPanel:IsEquipCanAdv(ActorManager.user_data.role) then
		TipFlag:UpdateFlagEquip(true);
		return;
	end
	TipFlag:UpdateFlagEquip(false);
	return;
end

function EquipStrengthPanel:ShowStrengthAdd()
	ToastMove:CreateToast(LANG_EquipStrengthPanel_12 .. self.typeText .. ' +' .. self.addCount);
end

function EquipStrengthPanel:ShowStrengthAdvAdd()
	ToastMove:CreateToast(LANG_EquipStrengthPanel_11 .. self.typeText .. ' +' .. self.addCount);
end


function EquipStrengthPanel:updateRole()
	self.currentRoleSelected = self.currentRoleSelected or 0;
	self.selectedRole = ActorManager:GetRole(self.currentRoleSelected);	
end

--刷新装备进阶tips状态
function EquipStrengthPanel:UpdateAdvEquip()
	if not self.selectedRole then
		Debug.print('have no selectedRole info !!!!')
		return
	end
	if EquipStrengthPanel:IsEquipCanAdv(self.selectedRole) then
		self.equipStrengthPanel:GetLogicChild('cricle').Visibility = Visibility.Visible;
	else
		self.equipStrengthPanel:GetLogicChild('cricle').Visibility = Visibility.Hidden;
	end
end

function EquipStrengthPanel:updateEquip()	
	for i = 1, 5 do	
		local equip = self.selectedRole.equips[tostring(i)];
		if equip then
			self.equipUpList[i].initEquip(equip, self.selectedRole, i, 0);
			self.equipUpList[i].initWithBtnClick(HomeTemplateType.Equipup);
			self.equipAdvList[i].initEquip(equip, self.selectedRole, i, 1);
			self.equipAdvList[i].initWithBtnClick(HomeTemplateType.Equipadv);			
		end
	end
end

function EquipStrengthPanel:PlayStrengthAdvEffect()
	PlayEffectLT('qianghua_output/', Rect(self.equipInfo.ctrl:GetLogicChild('btn'):GetAbsTranslate().x + self.equipInfo.ctrl:GetLogicChild('btn').Width * 0.5, self.equipInfo.ctrl:GetLogicChild('btn'):GetAbsTranslate().y + self.equipInfo.ctrl:GetLogicChild('btn').Height * 0.3, 0, 0), 'qianghua', self.equipInfo.ctrl:GetLogicChild('btn'));
	local upEquipResid = self.equipInfo.ctrl:GetLogicChild('btn').Tag;
	local upQuaNum = resTableManager:GetValue(ResTable.equip, tostring(upEquipResid), 'rank');
	local upFlag = true;
	for i = 1, 5 do
		local equip = self.selectedRole.equips[tostring(i)];
		if upEquipResid ~= equip.resid then
			local quaNum = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'rank');
			if upQuaNum - 1 >= quaNum then
				upFlag = false;
			end
		end
	end
	if upFlag then
		PlayEffectScale('shengji_output/', Rect(240,30,0,0), 'shengji', 4, 4, HomePanel:returnHomePanel():GetLogicChild('navi'));
	end
	local effect = PlayEffectLT('jinengjinjie_output/', Rect(self.eqAdvPanel:GetAbsTranslate().x + self.eqAdvPanel.Width * 0.5 , self.eqAdvPanel:GetAbsTranslate().y + self.eqAdvPanel.Height * 0.5, 0, 0), 'jinengjinjie');
	effect:SetScale(1.5, 1.5);
end

--判断是否有装备进阶过
function EquipStrengthPanel:IsEquipHaveAdv()
	for _,equip in pairs (ActorManager.user_data.role.equips) do
		local quaNum = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'rank');
		if quaNum > 1 then
			return true;
		end
	end	
	for _, partner in pairs (ActorManager.user_data.partners) do
		for _,equip in pairs (partner.equips) do
			local quaNum = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'rank');
			if quaNum > 1 then
				return true;
			end
		end	
	end
	return false;
end

--判断是否有装备升级过
function EquipStrengthPanel:IsEquipHaveUpLevel()
	for _,equip in pairs (ActorManager.user_data.role.equips) do
		if equip.strenlevel > 1 then
			return true;
		end
	end	
	for _, partner in pairs (ActorManager.user_data.partners) do
		for _,equip in pairs (partner.equips) do
			if equip.strenlevel > 1 then
				return true;
			end
		end	
	end
	return false;
end
--========================================================================
--界面响应
--========================================================================
--显示,page值为1或2
function EquipStrengthPanel:onShow(page)
	if not EquipStrengthPanel:IsVisible() then
		page = 2;
		if 2 == page then
			self.pageIndex = 2;
			self.tabControl.ActiveTabPageIndex = 1;
		else
			self.pageIndex = 1;
			self.tabControl.ActiveTabPageIndex = 0;
		end
		HomePanel:onEnterHomePanel(true)
		EquipStrengthPanel:Show()
	else
		EquipStrengthPanel:UpdateAdvInfo();
	end
	if PveLosePanel.isGuideEquipStrength then
		PlotPanel:changeContentPos(0, -30)				--  content的坐标是74,349,宽350,搞110
		PlotPanel:changeContentText(LANG_pve_lose_tip_1);
		PlotPanel:guideEquipShow()
	elseif PveLosePanel.isGuideEquipLevelUp then
		self.pageIndex = 2;
		self.tabControl.ActiveTabPageIndex = 1;
		EquipStrengthPanel:UpdateAdvInfo();
		PlotPanel:changeContentPos(0, -30)				--  content的坐标是74,349,宽350,搞110
		PlotPanel:changeContentText(LANG_pve_lose_tip_2);
		PlotPanel:guideEquipShow()
	end
end

--关闭事件
function EquipStrengthPanel:onClose(Args)
	self:destroyEquipUpSound()
	HomePanel:RoleShow();
	CardDetailPanel:Show(self.selectedRole.pid, self.selectedRole.resid);
	self:Hide();
	if UserGuidePanel:IsInGuidence(UserGuideIndex.equip, 1) and UserGuidePanel:GetIsequipguide() then
		UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(), GuideEffectType.hand, GuideTipPos.right, '', 0.3);
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.equip);
	end
end

--分页改变
function EquipStrengthPanel:onPageChange( Args )
	local args = UITabControlPageChangeEventArgs(Args);
	self.pageIndex = args.m_pNewPage.Tag;
	if self.selectedRole then
		if 1 == self.pageIndex then
			self.equipInfo = self.equipUpList[self.curIndex];
			self.equipInfo.ctrl.Selected = true;
			EquipStrengthPanel:UpdateInfo();
		elseif 2 == self.pageIndex then
			self.equipInfo = self.equipAdvList[self.curIndex];
			self.equipInfo.ctrl.Selected = true;
			EquipStrengthPanel:UpdateAdvInfo();
		end
	end
end

--强化
function EquipStrengthPanel:onStrength( Args )
	local arg = UIControlEventArgs(Args);
	local tag = arg.m_pControl.Tag;
	if self.selectedRole == nil then
		return;
	end
	
	local equip = self.selectedRole.equips[tostring(tag)];
	if equip == nil then
		return;
	end
	
	if (self.strengthPanel.strength_moneyCost[tag] > ActorManager.user_data.money) then
		CoinNotEnoughPanel:ShowCoinNotEnoughPanel(LANG_EquipStrengthPanel_17);
	else
		NetworkMsg_Item.equipRoleProperty = clone(self.selectedRole.pro);
		
		local msg = {};
		msg.eid = equip.eid;
		msg.num = 1;
		Network:Send(NetworkCmdType.req_upgrade_equip, msg);	
		self.effectAU = PlayEffectLT('qianghua_output/', Rect(self.eqInfoPanel:GetLogicChild('item'):GetAbsTranslate().x + self.eqInfoPanel:GetLogicChild('item').Width * 0.5, self.eqInfoPanel:GetLogicChild('item'):GetAbsTranslate().y + self.eqInfoPanel:GetLogicChild('item').Height * 0.3, 0, 0), 'qianghua', self.eqInfoPanel:GetLogicChild('item'));
		
	end
	
	--新手引导指引
	if UserGuidePanel:IsInGuidence(UserGuideIndex.equip, 1) and UserGuidePanel:GetIsequipguide() then
		UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(), GuideEffectType.hand, GuideTipPos.right, '', 0.3);
	end

end

--自动强化
function EquipStrengthPanel:onStrengthTen( Args )
	local arg = UIControlEventArgs(Args);
	local tag = arg.m_pControl.Tag;
	if self.selectedRole == nil then
		return;
	end
	
	local equip = self.selectedRole.equips[tostring(tag)];
	if equip == nil then
		return;
	end
	
	NetworkMsg_Item.equipRoleProperty = clone(self.selectedRole.pro);
	local count = 0;
	local cost = 0;
	for i = 1, self.selectedRole.lvl.level - equip.strenlevel do
		local discount = LovePanel:getGoldCostDecreased(self.selectedRole);
		cost = resTableManager:GetValue(ResTable.equip_upgrade_pay, tostring(equip.strenlevel+i), 'money') * discount + cost;
		if cost <= ActorManager.user_data.money then
			count = count + 1;
		else
			break;
		end
	end
	local msg = {};
	msg.eid = equip.eid;
	msg.num = count;
	self.addCount = msg.num * self.addCount;
	Network:Send(NetworkCmdType.req_upgrade_equip, msg, true);
	self.effectAU = PlayEffectLT('qianghua_output/', Rect(self.eqInfoPanel:GetLogicChild('item'):GetAbsTranslate().x + self.eqInfoPanel:GetLogicChild('item').Width * 0.5, self.eqInfoPanel:GetLogicChild('item'):GetAbsTranslate().y + self.eqInfoPanel:GetLogicChild('item').Height * 0.3, 0, 0), 'qianghua', self.eqInfoPanel:GetLogicChild('item'));
	self.playTimes = 3;
	self.effectAU:SetScriptAnimationCallback('EquipStrengthPanel:replay',0);
end

function EquipStrengthPanel:replay()
	if self.playTimes == 1 then
		return;
	end
	self.effectAU = PlayEffectLT('qianghua_output/', Rect(self.eqInfoPanel:GetLogicChild('item'):GetAbsTranslate().x + self.eqInfoPanel:GetLogicChild('item').Width * 0.5, self.eqInfoPanel:GetLogicChild('item'):GetAbsTranslate().y + self.eqInfoPanel:GetLogicChild('item').Height * 0.3, 0, 0), 'qianghua', self.eqInfoPanel:GetLogicChild('item'));
	self.playTimes = self.playTimes - 1;
	self.effectAU:SetScriptAnimationCallback('EquipStrengthPanel:replay',0);
end

--进阶
function EquipStrengthPanel:onAdvance( Args )
	--新手引导相关
	if UserGuidePanel:IsInGuidence(UserGuideIndex.equipadv, 1) and UserGuidePanel:GetIsequipguide() then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.equipadv);
	end

	local arg = UIControlEventArgs(Args);
	local tag = arg.m_pControl.Tag;
	if self.selectedRole == nil then
		return;
	end
	local equip = self.selectedRole.equips[tostring(tag)];
	if equip == nil then
		return;
	end

	local msg = {};
	msg.eid = equip.eid;
	msg.dst_resid = equip.resid;	--把原装备id传上去即可
	Network:Send(NetworkCmdType.req_compose_equip, msg, true);
	
	local taskid = Task:getMainTaskId();
	if SystemTaskId.advance == taskid and isShow then
		UserGuidePanel:ShowGuideShade(btnClose, GuideEffectType.hand, GuideTipPos.left, LANG_EquipStrengthPanel_24, 0.35);
		UserGuidePanel:SetInGuiding(false);
		--向服务器发送统计数据
		NetworkMsg_GodsSenki:SendStatisticsData(taskid, 4);
	end
end

--材料tip
function EquipStrengthPanel:onMaterialClick( Args )
	local args = UIControlEventArgs(Args);
	
	if args.m_pControl.Tag == 0 then
		return;
	end
	
	local item = {};
	item.resid = args.m_pControl.Tag;
	
	local itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');
	TooltipPanel:setNeedAndHaveNum( self.needMaterialNum[item.resid], self.totalMaterialNum[item.resid] )
	TooltipPanel:ShowItem(self.equipStrengthPanel, item, TipMaterialShowButton.Obtain);
end

--刷新强化等级及属性数值
function EquipStrengthPanel:updateEquipLv(equip)
	local curLvLabel = self.eqInfoPanel:GetLogicChild('curLv');
	local nextLvLabel = self.eqInfoPanel:GetLogicChild('nextLv');
	local curAtrLabel = self.eqInfoPanel:GetLogicChild('curAtr');
	local nextAtrLabel = self.eqInfoPanel:GetLogicChild('nextAtr');
	local curLvTip = self.eqInfoPanel:GetLogicChild('level');
	local curlv = equip.strenlevel or 0;
	local nextlv = curlv + 1;
	local eType = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'type');
	local baseValue = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'base_value');
	local value = resTableManager:GetValue(ResTable.equip_upgrade, tostring(eType), 'value');
	local curAtr = baseValue + value*curlv;
	local nextAtr = baseValue + value*nextlv;
	curAtrLabel.Text = tostring(curAtr);
	curLvTip.Text = tostring(curAtr);
	nextAtrLabel.Text = tostring(nextAtr);
	curLvLabel.Text = tostring(curlv);
	nextLvLabel.Text = tostring(nextlv);	
	self.addCount = nextAtr - curAtr;
end

--刷新升阶等级及属性数值
function EquipStrengthPanel:updateEquipAdvLv(equip)
	local curAtrLabel = self.advInfoPanel:GetLogicChild('curAtr');
	local nextAtrLabel = self.advInfoPanel:GetLogicChild('nextAtr');
	local curlv = equip.strenlevel or 0;
	local curRank = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'rank');
	local nextRank = (curRank < Configuration.equip_max_level) and (curRank + 1) or Configuration.equip_max_level;
	local baseValue = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'base_value');
	local nextresid = resTableManager:GetValue(ResTable.equip_compose, tostring(equip.resid), 'rankup_id')
	local composeBValue = resTableManager:GetValue(ResTable.equip, tostring(nextresid), 'base_value');
	local pointImg =  self.advInfoPanel:GetLogicChild('pointImg');
	local tipLabel = self.advInfoPanel:GetLogicChild('tip');

	local equipItem = self.advInfoPanel:GetLogicChild('item2');
	local imageIconNext = equipItem:GetLogicChild('equipIcon');
	local quaNum = resTableManager:GetValue(ResTable.equip, tostring(nextresid), 'rank');
	equipItem.Background = CreateTextureBrush('home/head_frame_' .. quaNum .. '.ccz', 'home');
	local equipArrayNext = resTableManager:GetRowValue(ResTable.equip, tostring(nextresid));
	imageIconNext.Image = GetPicture('icon/' .. tostring(equipArrayNext['icon'] .. '.ccz'));
	local nextName = self.advInfoPanel:GetLogicChild('name2');
	nextName.Text = equipArrayNext['name'];
	if curRank == Configuration.equip_max_level then
		equipItem.Visibility = Visibility.Hidden;
		nextName.Visibility = Visibility.Hidden;
		pointImg.Visibility = Visibility.Hidden;
		tipLabel.Visibility = Visibility.Visible;
	else
		equipItem.Visibility = Visibility.Visible;
		nextName.Visibility = Visibility.Visible;
		pointImg.Visibility = Visibility.Visible;
		tipLabel.Visibility = Visibility.Hidden;
	end

	local eType = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'type');
	local value = resTableManager:GetValue(ResTable.equip_upgrade, tostring(eType), 'value');
	local curAtr = baseValue + value*curlv;
	local nextAtr = curAtr + ((composeBValue == 0 and baseValue or composeBValue) - baseValue);

	curAtrLabel.Text = tostring(curAtr);
	nextAtrLabel.Text = tostring(nextAtr);
	self.addCount = nextAtr - curAtr;
end

function EquipStrengthPanel:UpdateInfo(args)
	local equipresid;
	if not args then
		equipresid = self.equipInfo.ctrl:GetLogicChild('btn').Tag;
	else
		equipresid = args.m_pControl.Tag;
		self.equipInfo = self.equipUpList[args.m_pControl.TagExt];
	end
	self.curIndex = self.equipInfo.ctrl:GetLogicChild('btn').TagExt;
	local equipArray = resTableManager:GetRowValue(ResTable.equip, tostring(equipresid));
	if not equipArray then
		return;
	end	
	local equipInfoTips = self.eqInfoPanel:GetLogicChild('tips');
	local equipItem = self.eqInfoPanel:GetLogicChild('item');
	local quaNum = resTableManager:GetValue(ResTable.equip, tostring(equipresid), 'rank');
	equipItem.Background = CreateTextureBrush('home/head_frame_' .. quaNum .. '.ccz', 'home');
	equipInfoTips.Text = equipArray['description'];
	local equipName = self.eqInfoPanel:GetLogicChild('name');
	equipName.Text = equipArray['name'];
	local equipType = self.eqInfoPanel:GetLogicChild('typeName');
	local equipType1 = self.eqInfoPanel:GetLogicChild('typeName1');
	equipType.Text = equip_class_map[equipArray['attribute']] .. ':';
	equipType1.Text = equip_class_map[equipArray['attribute']];
	self.typeText = equip_class_map[equipArray['attribute']];
	local imageIcon = self.eqInfoPanel:GetLogicChild('item'):GetLogicChild('equipIcon');
	imageIcon.Image = GetPicture('icon/' .. tostring(equipArray['icon'] .. '.ccz'));

	local UpBtn = self.eqInfoPanel:GetLogicChild('UpBtn');
	UpBtn:SubscribeScriptedEvent('Button::ClickEvent', 'EquipStrengthPanel:onStrength');
	local autoBtn = self.eqInfoPanel:GetLogicChild('autoBtn');
	autoBtn:SubscribeScriptedEvent('Button::ClickEvent', 'EquipStrengthPanel:onStrengthTen');

	local index = 0;
	for i = 1, 5 do	
		local equip = self.selectedRole.equips[tostring(i)];
		if equip.resid == equipresid then
			index = i;
			EquipStrengthPanel:updateEquipLv(equip);
			--爱恋度折扣
			local discount = LovePanel:getGoldCostDecreased(self.selectedRole);

			--超过最大等级
			local RoleMaxLv = resTableManager:GetValue(ResTable.config, '41', 'value');
			if RoleMaxLv <= equip.strenlevel then
				UpBtn.Enable = false;
				autoBtn.Enable = false;
				break;
			end

			local cost = resTableManager:GetValue(ResTable.equip_upgrade_pay, tostring(equip.strenlevel+1), 'money') * discount;
			local costLabel = self.eqInfoPanel:GetLogicChild('cost');
			if cost and cost > ActorManager.user_data.money then
				costLabel.TextColor = QuadColor(Color(232, 38, 74, 255));
			else
				costLabel.TextColor = QuadColor(Color(60, 137, 11, 255));
			end
			costLabel:SetFont('huakang_18_noborder_underline');
			costLabel:SubscribeScriptedEvent('UIControl::MouseClickEvent','MainUI:onBuyGold');
			if cost and equip.strenlevel >= self.selectedRole.lvl.level or cost > ActorManager.user_data.money then
				UpBtn.Enable = false;
				autoBtn.Enable = false;
			else
				UpBtn.Enable = true;
				autoBtn.Enable = true;
			end
			costLabel.Text = tostring(math.ceil(cost));
			self.strengthPanel.strength_moneyCost[i] = cost;
		end		
	end
	UpBtn.Tag = index;
	autoBtn.Tag = index;
	--  更新战斗力
	uiSystem:UpdateDataBind()
end

function EquipStrengthPanel:UpdateAdvInfo(args)
	if UserGuidePanel:IsInGuidence(UserGuideIndex.equipadv, 1) and self.isUserGuideEnter then
		UserGuidePanel:ShowGuideShade(self.advInfoPanel:GetLogicChild('lvupBtn'),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		self.isUserGuideEnter = false;
	end

	self:updateEquip();
	local equipresid;
	if not args then
		equipresid = self.equipInfo.ctrl:GetLogicChild('btn').Tag;
	else
		equipresid = args.m_pControl.Tag;
		self.equipInfo = self.equipAdvList[args.m_pControl.TagExt];
	end
	self.curIndex = self.equipInfo.ctrl:GetLogicChild('btn').TagExt;
	local equipArray = resTableManager:GetRowValue(ResTable.equip, tostring(equipresid));
	if not equipArray then
		return;
	end

	local equipType = self.advInfoPanel:GetLogicChild('broad'):GetLogicChild('typeName');
	equipType.Text = equip_class_map[equipArray['attribute']];
	self.typeText = equip_class_map[equipArray['attribute']];
	local equipItem = self.advInfoPanel:GetLogicChild('item1');
	local imageIcon = self.advInfoPanel:GetLogicChild('item1'):GetLogicChild('equipIcon');
	local quaNum = resTableManager:GetValue(ResTable.equip, tostring(equipresid), 'rank');
	equipItem.Background = CreateTextureBrush('home/head_frame_' .. quaNum .. '.ccz', 'home');
	imageIcon.Image = GetPicture('icon/' .. tostring(equipArray['icon'] .. '.ccz'));
	local curName = self.advInfoPanel:GetLogicChild('name1');
	curName.Text = equipArray['name'];

	local upBtn = self.advInfoPanel:GetLogicChild('lvupBtn');
	local index = 0;
	for i = 1, 5 do
		local equip = self.selectedRole.equips[tostring(i)];
		if equip.resid == equipresid then
			index = i;
			EquipStrengthPanel:updateEquipAdvLv(equip);
			EquipStrengthPanel:RefreshRankMaterial(equip);
			upBtn.Enable = EquipStrengthPanel:isCanAdvance(equip);
		end
	end
	upBtn.Tag = index;
	upBtn:SubscribeScriptedEvent('Button::ClickEvent', 'EquipStrengthPanel:onAdvance');

	--装备进阶tips刷新
	EquipStrengthPanel:UpdateAdvEquip()
end
function EquipStrengthPanel:destroyEquipUpSound()
	if self.eqSound ~= nil then
		soundManager:DestroySource(self.eqSound);
		self.eqSound = nil
	end
end
function EquipStrengthPanel:EquipUpgradeSound(resid)
	local randomNum = math.random(1,2)
	local soundName = resTableManager:GetValue(ResTable.actor,tostring(resid),'foster_voice')
	if soundName then
		self:destroyEquipUpSound()
		self.eqSound = SoundManager:PlayVoice( tostring(soundName[math.floor(randomNum)]))
	end
end
