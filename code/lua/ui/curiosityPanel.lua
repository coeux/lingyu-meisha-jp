--curiosityPanel.lua
--========================================================================
--宠物界面

CuriosityPanel =
	{
		index = 0; --listView
		curItem;
	};

--控件
local mainDesktop;
local curiosityPanel;
local curiosPanel; 		
local curiosityListView; 	
local introduceLabel; 		
local curiosProgress; 		
local levelLabel;	   		
local leftButton;	   		
local rightButton;	   		
local nameLabel;	   		
local proPanel;			
local befActivePanel; 		
local btnCuriosity;		
local conditionStackPanel; 
local aftActivePanel;		
local pPanel;				
local upProPanel;			
local itemPanel;			
local propNameLabel;		
local consumeLabel;		
local btnUp;				
local btnReturn;
local btnIllustrate;
local illPanel;
local illLabel;
local bg;
local curExpLabel;
local needExpLabel;
local expLabel;
local tipLabel;
local proPanelList = {};
local conditionPanelList = {};

local totalProAddList = {};
local proAddList = {};

local timeMax = 10;
local clickCount;
local clickList = {};

local attType = 
{
	[1] = 'combo_d_down',
	[2] = 'combo_r_down',
	[3] = 'combo_d_up',
	[4] = 'combo_r_up',
	[5] = 'combo_anger',
}
local name_table = {
	[1] = 'c1_level',
	[2] = 'c2_level',
	[3] = 'c3_level',
	[4] = 'c4_level',
	[5] = 'c5_level',
}
local exp_table = 
{
	'c1_exp',
	'c2_exp',
	'c3_exp',
	'c4_exp',
	'c5_exp',
}

local conditionFunc = 
{
	function(arg) return CuriosityPanel:isHeroLevelCondition(arg) end ,
	function(arg) return CuriosityPanel:isCuriosityLevelConditon(arg) end,
	function(arg) return CuriosityPanel:isPartnerCountCondition(arg) end,
	function(arg) return CuriosityPanel:isRoleStarsCondition(arg) end,
	function(arg) return CuriosityPanel:isRoleMarriageCondition(arg) end,
	function(arg) return CuriosityPanel:isHunShiCondition(arg) end,
}
--初始化面板
function CuriosityPanel:InitPanel(desktop)

	self.index = 0;
	--控件初始化
	mainDesktop = desktop;
	curiosityPanel = Panel(desktop:GetLogicChild('curiosityPanel'));
	curiosityPanel.ZOrder = PanelZOrder.curiosity;
	curiosityPanel.Visibility = Visibility.Hidden;
	curiosityPanel:IncRefCount();
	
	topPanel = curiosityPanel:GetLogicChild('topPanel');
	btnReturn = curiosityPanel:GetLogicChild('btnReturn');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'CuriosityPanel:onClose');
	btnIllustrate = curiosityPanel:GetLogicChild('btnIllustrate');
	btnIllustrate:SubscribeScriptedEvent('Button::ClickEvent', 'CuriosityPanel:showIllustrate');
	illPanel	  = curiosityPanel:GetLogicChild('illPanel');
	illPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','CuriosityPanel:hideIllustrate');
	illLabel	  = illPanel:GetLogicChild('explain'):GetLogicChild('content'):GetLogicChild('explainLabel');
	illLabel.Text = LANG_curiosity_explain;
	bg = curiosityPanel:GetLogicChild('bg');
	self:initCuriosPanel();
	self:initProPanel();
	
end
--左边面板
function CuriosityPanel:initCuriosPanel()
	curiosPanel 		= curiosityPanel:GetLogicChild('curiosPanel');
	curiosityListView 	= curiosPanel:GetLogicChild('curiosityListView');
	curiosityListView:SubscribeScriptedEvent('ListView::PageChangeEvent', 'CuriosityPanel:onListViewChange');
	introduceLabel 		= curiosPanel:GetLogicChild('introducePanel'):GetLogicChild('introduceLabel');
	curiosProgress 		= curiosPanel:GetLogicChild('curiosProgress');
	levelLabel	   		= curiosPanel:GetLogicChild('levelLabel');
	leftButton	   		= curiosPanel:GetLogicChild('leftButton');
	leftButton.Tag = 1;
	leftButton:SubscribeScriptedEvent('Button::ClickEvent', 'CuriosityPanel:changeBtnClick');
	rightButton	   		= curiosPanel:GetLogicChild('rightButton');
	rightButton.Tag = 2;
	rightButton:SubscribeScriptedEvent('Button::ClickEvent', 'CuriosityPanel:changeBtnClick');
	nameLabel	   		= curiosPanel:GetLogicChild('nameLabel');
	curExpLabel			= curiosPanel:GetLogicChild('cur');
	needExpLabel		= curiosPanel:GetLogicChild('need');
	expLabel = curiosPanel:GetLogicChild('label');
	curiosPanel.Horizontal = ControlLayout.H_CENTER;
	curiosPanel.Margin = Rect(210, 110, 0, 0);
end
--右边属性面板
function CuriosityPanel:initProPanel()
	proPanel			= curiosityPanel:GetLogicChild('proPanel');
	befActivePanel 		= proPanel:GetLogicChild('befActivePanel');
	befActivePanel.Visibility = Visibility.Hidden;
	btnCuriosity		= befActivePanel:GetLogicChild('btnCuriosity');
	btnCuriosity:SubscribeScriptedEvent('Button::ClickEvent','CuriosityPanel:activateClick');
	conditionScrollPanel= befActivePanel:GetLogicChild('conditionScrollPanel');
	conditionStackPanel = conditionScrollPanel:GetLogicChild('conditionStackPanel');
	aftActivePanel		= proPanel:GetLogicChild('aftActivePanel');
	pPanel				= aftActivePanel:GetLogicChild('pPanel');
	aftActivePanel.Visibility = Visibility.Hidden;
	for i = 1 , 5 do
		local tPanel = pPanel:GetLogicChild('p'..i);
		tPanel:GetLogicChild('upProLabel').Visibility = Visibility.Hidden
		table.insert(proPanelList,tPanel);
	end
	upProPanel			= aftActivePanel:GetLogicChild('upProPanel');
	itemPanel			= upProPanel:GetLogicChild('itemPanel');
	propNameLabel		= upProPanel:GetLogicChild('propNameLabel');
	consumeLabel		= upProPanel:GetLogicChild('consumeLabel');
	btnUp				= upProPanel:GetLogicChild('btnUp');
	tipLabel			= upProPanel:GetLogicChild('tipLabel');
	btnUp:SubscribeScriptedEvent('Button::ClickEvent','CuriosityPanel:upLevelClick');
end 
--显示
function CuriosityPanel:onShow()
	HomePanel:destroyRoleSound()
	if ChroniclePanel:isShow() then
		ChroniclePanel:onClose()
	end
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.curiosity then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_curiosity_6);
		return;
	end
	HomePanel:hideRolePanel();
	clickCount = 0;
	clickList = {};
	self.index = 0;
	self:Show();
	
end
function CuriosityPanel:Show()
	bg.Background = CreateTextureBrush('background/artifact_bg.jpg', 'background');
	local rowNum = resTableManager:GetRowNum(ResTable.artifact);
	curiosityListView:RemoveAllChildren();
	for i = 1 , rowNum do
		local curiosData = resTableManager:GetRowValue(ResTable.artifact, tostring(i));
		local tPanel = uiSystem:CreateControl('Panel');
		tPanel.Size = Size(300,300);
		tPanel.Background = CreateTextureBrush('artifact/'..i..'.ccz','artifact');
		curiosityListView:AddChild(tPanel);
	end
	self:refreshData()
	curiosityPanel.Visibility = Visibility.Visible;
end

function CuriosityPanel:onListViewChange(Arg)
	self.index = curiosityListView.ActivePageIndex;
	self:refreshData();
end

function CuriosityPanel:refreshData()
	local curiosType = self.index+1;
	local curiosData = resTableManager:GetRowValue(ResTable.artifact, tostring(curiosType));
	if not curiosData then 
		print('curiosData--nil--196--curiosType->'..tostring(curiosType));
		return;
	end
	local level = ComboPro[name_table[curiosType]];
	--print('refreshData-curiosType->'..curiosType..' -curlevel->'..tostring(level))
	self:refreshCurios(curiosData);
	if level < 0  then
		self:refreshNoActivatePro(curiosData);
	else
		self:refreshActivatePro(curiosData);
	end
end
--珍宝等级，名字，介绍
function CuriosityPanel:refreshCurios(curiosData)
	introduceLabel.Text = tostring(curiosData['description']);
	nameLabel.Text = tostring(curiosData['name']);
	local curiosType = self.index+1;
	local level = ComboPro[name_table[curiosType]];
	
	local max_level = curiosData["max_level"];
	local curExp = 0;
	local preExp = 0;
	if level <= 0 then
		level = 0;
		local curLevelData = resTableManager:GetRowValue(ResTable.artifact_levelup, tostring(curiosType*1000+level));
		if curLevelData then
			curExp = curLevelData['exp'];
		end
	elseif level == max_level then
		curExp = 0;
	else
		local curLevelData = resTableManager:GetRowValue(ResTable.artifact_levelup, tostring((curiosType)*1000+level));
		local preLevelData = resTableManager:GetRowValue(ResTable.artifact_levelup, tostring((curiosType)*1000+level-1));
		if curLevelData and preLevelData then
			curExp = tonumber(curLevelData['exp']);
			preExp = tonumber(preLevelData['exp']);
		end
	end
	needExpLabel.Text = tostring(curExp-preExp);
	levelLabel.Text = string.format('Lv.%d',tonumber(level));
	curExpLabel.Text = tostring(ComboPro[exp_table[curiosType]]-preExp);
	--print('curExp->'..tonumber(ComboPro[exp_table[curiosType]]-preExp));
	curiosProgress.CurValue = tonumber(ComboPro[exp_table[curiosType]]-preExp);
	curiosProgress.MaxValue = tonumber(curExp-preExp);
end

--未开启面板
function CuriosityPanel:refreshNoActivatePro(curiosData)
	aftActivePanel.Visibility = Visibility.Hidden;
	befActivePanel.Visibility = Visibility.Visible;
	conditionStackPanel:RemoveAllChildren();
	local conditionNum = curiosData['open'];
	local allActive = true;
	for k,con in pairs(conditionNum) do
		local isActive = true;
		local conditionCtrl = uiSystem:CreateControl('curiostyItemTemplate');
		conditionStackPanel:AddChild(conditionCtrl);
		isActive = self:initItemTemplate(conditionCtrl,k,con[1],con[2]);
		if not isActive then
			allActive = false;
		end
	end
	if allActive then
		btnCuriosity.Enable = true;
	else
		btnCuriosity.Enable = false;
	end
end
function CuriosityPanel:initItemTemplate(ctrl,k,num,conditionData)
	local ct = ctrl:GetLogicChild(0);
	local label = ct:GetLogicChild('label');
	local conditionLabel = ct:GetLogicChild('conditionLabel');
	local conditionBrush = ct:GetLogicChild('conditionBrush');
	local noConditionBrush = ct:GetLogicChild('noConditionBrush');
	conditionBrush.Visibility = Visibility.Hidden;
	noConditionBrush.Visibility = Visibility.Hidden;
	label.Text = string.format(LANG_curiosity_2,k);
	conditionLabel.Text = string.format(LANG_curiosity_condition[num],conditionData);
	local compCondtion = conditionData;
	local conditionFlag = conditionFunc[num](compCondtion);
	if conditionFlag then
		label.TextColor = QuadColor(Color(42,167,0,255));
		conditionLabel.TextColor = QuadColor(Color(42,167,0,255));
		conditionBrush.Visibility = Visibility.Visible;
	else
		label.TextColor = QuadColor(Color(38,19,0,255));
		conditionLabel.TextColor = QuadColor(Color(38,19,0,255));
		noConditionBrush.Visibility = Visibility.Visible;
	end
	return conditionFlag;
end
--开启后面板
function CuriosityPanel:refreshActivatePro(curiosData)
	aftActivePanel.Visibility = Visibility.Visible;
	befActivePanel.Visibility = Visibility.Hidden;
	local curiosType = self.index+1;
	local level = ComboPro[name_table[curiosType]];
	itemPanel:RemoveAllChildren();
	self.curItem = customUserControl.new(itemPanel, 'itemTemplate');
	self.curItem.initWithInfo(curiosData['item'], -1, 78, true);
	local matResid = curiosData['item'];
	local matItem = Package:GetMaterial( matResid );
	local matNum = matItem and matItem.num or 0;
	local needNum = 0;
	if level >= 10 then
		needNum = 2*math.floor(level/10);
	else
		needNum = 1;
	end
	consumeLabel.Text = string.format('%d/%d',tostring(matNum),needNum);
	local itemName = resTableManager:GetValue(ResTable.item, tostring(matResid),'name');
	if itemName then
		propNameLabel.Text = tostring(itemName);
	end
	local max_level = curiosData["max_level"];
	if not max_level then return end
	
	local totalAtt = {};
	for i = 1 , 5 do
		totalAtt[i] = 0;
	end
	for leve_i = 1 , max_level do
		local totalCuriosAtt = resTableManager:GetRowValue(ResTable.artifact_levelup, tostring(curiosType*1000+leve_i));
		if totalCuriosAtt and totalCuriosAtt['attribute'] then
			local i = 1;
			while totalCuriosAtt['attribute'][i] do 
				local cAtt = totalCuriosAtt['attribute'][i];
				local cType = cAtt[1];
				if leve_i%5 == 0 then
					totalAtt[cType] = totalAtt[cType] + cAtt[3];
				else
					totalAtt[cType] = totalAtt[cType] + cAtt[2];
				end
				i = i + 1;
			end
		end
	end
	local curCuriosAtt = ComboPro:getAttributebyType(curiosType);
	if curCuriosAtt then 
		for i = 1 , 5 do
			local label = proPanelList[i]:GetLogicChild('label');
			local proNameLabel = proPanelList[i]:GetLogicChild('proNameLabel');
			local proProgress = proPanelList[i]:GetLogicChild('progress');
			local curAtt = 0;
			local comboNum = 0;
			if i == 5 then
				if curCuriosAtt[attType[i]] then
					for k,v in pairs(curCuriosAtt[attType[i]]) do 
						comboNum = k;
						curAtt = v;
					end
				end
			else
				if curCuriosAtt[attType[i]] then
					curAtt = curCuriosAtt[attType[i]];
				end
			end
			
			if i == 5 then
				proNameLabel.Text = string.format(LANG_curiosity_att[i],tostring(comboNum),tostring(curAtt));
			else
				proNameLabel.Text = string.format(LANG_curiosity_att[i],tostring(curAtt));
			end
			proProgress.CurValue = tonumber(curAtt*10)
			proProgress.MaxValue = tonumber(totalAtt[i])*10;
		end
	end
	local cProData = ComboPro:getAttributebylevel(curiosType,level);
	for i = 1 , 5 do
		proPanelList[i]:GetLogicChild('upProLabel').Visibility = Visibility.Hidden;
	end
	if cProData then
		local curAtt = 0;
		for k,v in pairs(cProData) do
			for k1,v1 in pairs(v) do
				curAtt = v1;
			end
		end
		local upProLabel = proPanelList[level%5+1]:GetLogicChild('upProLabel');
		if level > 0 and (level+1)%5 == 0 then
			upProLabel.Text = string.format('(+%s)',tonumber(curAtt));
		else
			upProLabel.Text = string.format('(+%s%%)',tonumber(curAtt));
		end
		upProLabel.TextColor = QuadColor(Color(42,167,0,255));
		if level < max_level then 
			upProLabel.Visibility = Visibility.Visible;
		end
	end
end
--销毁
function CuriosityPanel:Destroy()
	curiosityPanel:IncRefCount();
	curiosityPanel = nil;
end

--返回
function CuriosityPanel:onClose()
	HomePanel:turnPageChange();
	HomePanel:showRolePanel();
	self:Hide();
end


function CuriosityPanel:showIllustrate()
	illPanel.Visibility = Visibility.Visible;
end

function CuriosityPanel:hideIllustrate()
	illPanel.Visibility = Visibility.Hidden;
end
--升级
function CuriosityPanel:upLevelClick()
	local curiosType = self.index+1;
	local level = ComboPro[name_table[curiosType]];
	local curiosData = resTableManager:GetRowValue(ResTable.artifact, tostring(curiosType));
	if not curiosData then return end 
	local matItem = Package:GetMaterial( curiosData['item'] );
	local needNum = 0;
	if level >= 10 then
		needNum = 2*math.floor(level/10);
	else
		needNum = 1;
	end
	local haveNum = matItem and matItem.num or 0;
	
	if level >= curiosData['max_level'] then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_curiosity_1);
		return;
	end
	if haveNum < needNum then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_curiosity_3);
		return;
	end
	local msg = {};
	msg.type_id = curiosType;
	Network:Send(NetworkCmdType.req_combo_pro_levelup_t,msg);
	
end
function CuriosityPanel:upLevelCallBack(msg)
	self:addClickCount();
	self:refreshData()
end
function CuriosityPanel:addClickCount()
	clickCount = clickCount + 1;
	clickList[clickCount] = {};
	clickList[clickCount].timer = timerManager:CreateTimer(0.1, 'CuriosityPanel:timeAppear', clickCount);
	clickList[clickCount].time = timeMax;
	clickList[clickCount].clickLabel = uiSystem:CreateControl('Label');
	local label = uiSystem:CreateControl('Label');
	label.Text = tostring(LANG_curiosity_4);
	label.TextAlignStyle = TextFormat.MiddleCenter;
	label:SetFont('huakang_16_miaobian_R108G3B130');
	label.Horizontal = ControlLayout.H_CENTER;
	label.Vertical = ControlLayout.V_BOTTOM;
	label.Margin = Rect(0,0,0,5);
	label.Size = Size(100,20);
	expLabel:AddChild(label);

	clickList[clickCount].clickLabel = label;
end

function CuriosityPanel:timeAppear(index)
	clickList[index].time = clickList[index].time - 1;
	if clickList[index].time <= 0 then
		timerManager:DestroyTimer(clickList[index].timer);
		clickList[index].timer = 0;
		clickList[index].clickLabel.Visibility = Visibility.Hidden;
		expLabel:RemoveChild(clickList[index].clickLabel);
	end
	clickList[index].clickLabel.Opacity = clickList[index].time/timeMax;
	local bottom = math.floor(math.sqrt(timeMax-clickList[index].time)*7);
	clickList[index].clickLabel.Margin = Rect(0,0,0,bottom+5);
end
--激活
function CuriosityPanel:activateClick()
	local msg = {};
	msg.type_id = self.index+1;
	Network:Send(NetworkCmdType.req_combo_pro_open_t,msg);
end
function CuriosityPanel:activateCallBack(msg)
	self:refreshData()
end
--左右切换
function CuriosityPanel:changeBtnClick(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	if tag == 1 then
		curiosityListView:TurnPageForward();
	elseif tag == 2 then
		curiosityListView:TurnPageBack();
	end
end

function CuriosityPanel:Hide()
	DestroyBrushAndImage('background/artifact_bg.jpg', 'background');
	curiosityPanel.Visibility = Visibility.Hidden;
end
function CuriosityPanel:isHeroLevelCondition(level)
	if ActorManager.user_data.role.lvl.level >= level then
		return true
	end
	return false;
end
function CuriosityPanel:isCuriosityLevelConditon(level)
	if ComboPro[name_table[self.index]] >= level then
		return true;
	end
	return false;
end
function CuriosityPanel:isPartnerCountCondition(partnerCount)
	local curPartnerCount = 1;
	for _,role in pairs(ActorManager.user_data.partners) do
		curPartnerCount = curPartnerCount + 1;
	end
	if curPartnerCount >= partnerCount then
		return true;
	end
	return false;
end
function CuriosityPanel:isRoleStarsCondition(rStars)
	local roleStarsCount = 0;
	for _,role in pairs(ActorManager.user_data.partners) do
		local curRole = ActorManager:GetRole(role.pid);
		roleStarsCount = roleStarsCount + curRole.rank
	end
	local curRole = ActorManager:GetRole(0);
	roleStarsCount = roleStarsCount + curRole.rank;
	if roleStarsCount >= rStars then
		return true;
	end
	return false;
end
function CuriosityPanel:isRoleMarriageCondition(mCount)
	local marriageCount = 0;
	for _,role in pairs(ActorManager.user_data.partners) do
		local role = ActorManager:GetRole(role.pid);
		if role.lvl.lovelevel == 4 then
			marriageCount = marriageCount + 1;
		end
	end
	if ActorManager.user_data.role.lvl.lovelevel == 4 then
		marriageCount = marriageCount + 1;
	end
	if marriageCount >= mCount then
		return true;
	end
	return false;
end
function CuriosityPanel:isHunShiCondition(hLevel)
	local hunShiLevel = 0;
	hunShiLevel = ActorManager.user_data.counts.soulranknum;
	if hunShiLevel >= hLevel then
		return true;
	end
	return false;
end
