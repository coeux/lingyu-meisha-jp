--HunShiPanel.lua

--========================================================================
--魂师界面

HunShiPanel =
	{
		
	};
local attImages = 
{
	'login/login_icon_202.ccz',
	'login/login_icon_200.ccz',
	'login/login_icon_203.ccz',
	'login/login_icon_201.ccz',
}

local attNum = 
{
	'202',
	'200',
	'203',
	'201',
}


--控件
local mainDesktop;
local hunShiPanel;
local recordPanel; 
local recordLabel; 
local duanWeiLabel;
local bottomPanel;     
local bottomTitelLabel;
local bottomAttBtn;	
local midTipPanel;
local tipText;    
local examBtn;    
local mapImg;
local upPanel;     
local upStackPanel;
local tipPanel;
local ruleExplain;
local explainBtn;
local explainLabel;
local nowPointControl;
local nPointControl;
local explainBg;
local costCountLabel;

local attPanelList = {};
--变量
local attBtnFlag;
local nextData = {}; --开启下一个点增加的属性
local upTipData = {};
local nextRank = {};
local clickBtnFlag;
local cost = 0;

--初始化面板
function HunShiPanel:InitPanel( desktop )
	self.old_soul_node_infos = {};
	clickBtnFlag = false;
	nowPointControl = nil
	--界面初始化
	mainDesktop = desktop;
	hunShiPanel = desktop:GetLogicChild('hunShiPanel')
	hunShiPanel:IncRefCount()
	hunShiPanel.Visibility = Visibility.Hidden
	hunShiPanel.ZOrder = PanelZOrder.soul + 1;
	--战绩和段位
	recordPanel  = hunShiPanel:GetLogicChild('recordPanel')
	recordLabel  = recordPanel:GetLogicChild('recordlabel')
	duanWeiLabel = recordPanel:GetLogicChild('duanWeilabel')

	--属性显示界面
	bottomPanel      = hunShiPanel:GetLogicChild('bottomPanel')
	bottomTitelLabel = bottomPanel:GetLogicChild('titelLabel')
	bottomAttBtn	 = bottomPanel:GetLogicChild('attBtn')
	bottomAttBtn:SubscribeScriptedEvent('Button::ClickEvent','HunShiPanel:attBtnOnClick')
	for i = 1 ,4 do
		local attPanel = bottomPanel:GetLogicChild('attPanel'..i):GetLogicChild(0)
		attPanelList[i] = attPanel
		local attImg = attPanel:GetLogicChild('attImage')
		attImg.Image = GetPicture(attImages[i])
		if 3 ~= i then
			attImg:SetScale(0.8,0.8)
		end
	end
	--加成提示
	upPanel      = hunShiPanel:GetLogicChild('upPanel')
	upStackPanel = upPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel')
	upPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'HunShiPanel:upPanelHide')
	upPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'HunShiPanel:upPanelHide')
	costCountLabel = upPanel:GetLogicChild('costCountLabel')
	costCountLabel.Text = '0'
	upPanel.Visibility = Visibility.Hidden
	--中间提示文字
	midTipPanel = hunShiPanel:GetLogicChild('midTipPanel')
	tipText     = midTipPanel:GetLogicChild('tipText')
	midTipPanel.ZOrder = 1
	tipText.Margin = Rect(0,0,0,0)
	tipText.Horizontal = ControlLayout.H_CENTER
	tipText.Vertical   = ControlLayout.V_CENTER
	examBtn     = midTipPanel:GetLogicChild('examBtn')
	--tipText.Visibility = Visibility.Hidden
	--examBtn.Visibility = Visibility.Visible
	examBtn:SubscribeScriptedEvent('Button::ClickEvent','HunShiPanel:examBtnOnClick')
	--地图和背景
	bgImg  = hunShiPanel:GetLogicChild('bg')
	mapImg = hunShiPanel:GetLogicChild('mapImg')
	--魂师说明
	ruleExplain  = hunShiPanel:GetLogicChild('ruleExplain')
	ruleExplain:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'HunShiPanel:RuleExplainHide')
	ruleExplain.Visibility = Visibility.Hidden
	explainBtn = hunShiPanel:GetLogicChild('explainBtn')
	explainBtn:SubscribeScriptedEvent('Button::ClickEvent','HunShiPanel:RuleExplainShow')
	explainLabel = ruleExplain:GetLogicChild('content'):GetLogicChild('explainLabel')
	explainImg = ruleExplain:GetLogicChild('content'):GetLogicChild('explainImg');
	--explainLabel.Size = Size(600,530)
	explainLabel.Text = LANG_hunshi_explain
	--蒙板
	explainBg    = hunShiPanel:GetLogicChild('explainBG')
	explainBg:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'HunShiPanel:RuleExplainHide')
	explainBg.Visibility = Visibility.Hidden
	--其它
	btnReturn = hunShiPanel:GetLogicChild('btnReturn')
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'HunShiPanel:onClose');
	tipPanel = hunShiPanel:GetLogicChild('tipPanel')
	tipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'HunShiPanel:tipPanelHide')
	tipPanel.Visibility = Visibility.Hidden
end
function HunShiPanel:RuleExplainHide()
	ruleExplain.Visibility = Visibility.Hidden
	explainBg.Visibility = Visibility.Hidden
end
function HunShiPanel:RuleExplainShow()
	explainImg.Image = GetPicture('explain/explain_hunshi_0.ccz');
	ruleExplain.Visibility = Visibility.Visible
	explainBg.Visibility = Visibility.Visible
end
--销毁
function HunShiPanel:Destroy()
	hunShiPanel:DecRefCount()
	hunShiPanel = nil
end
function HunShiPanel:attBtnOnClick()
	self:attChangeState(attBtnFlag)
	attBtnFlag = attBtnFlag == false and true or false
end
function HunShiPanel:attChangeState(flag)
	if flag then
		bottomTitelLabel.Text = LANG_hunshi_1
		bottomAttBtn.Text = LANG_hunshi_2
	else
		bottomTitelLabel.Text = LANG_hunshi_3
		bottomAttBtn.Text = LANG_hunshi_4
	end
	for i = 1 , 4 do
		local attPanel = attPanelList[i]
		for j = 1, 5 do
			local att = attPanel:GetLogicChild('att'..j)
			if flag then
				att:GetLogicChild('rightPanel').Visibility = Visibility.Hidden
				att:GetLogicChild('nowValue').Visibility = Visibility.Visible
			else
				att:GetLogicChild('rightPanel').Visibility = Visibility.Visible
				att:GetLogicChild('nowValue').Visibility = Visibility.Hidden
			end
		end
	end
end
function HunShiPanel:examBtnOnClick(Arg)
	local arg = UIControlEventArgs(Arg);
	local tag = arg.m_pControl.Tag;
	FbIntroductionPanel:onEnterFBInfo(tag)
end
--ActorManager.user_data.counts.soulvalue    战绩
--ActorManager.user_data.counts.soulranknum  段数
--ActorManager.user_data.counts.soulid       哪个点
--ActorManager.user_data.counts.soul_node_infos['201']['soul_node_point']['1'] 属性值
function HunShiPanel:refreshAtt()
	self:upPanelShow()
	local full = false
	tipText.Visibility = Visibility.Visible
	examBtn.Visibility = Visibility.Hidden
	recordLabel.Text = tostring(ActorManager.user_data.counts.soulvalue)
	local hunshiDuanWei = ActorManager.user_data.counts.soulranknum
	

	local nowPoint = 0
	if ActorManager.user_data.counts.soulid == 0 then
		nowPoint = 1000
	else
		nowPoint = ActorManager.user_data.counts.soulid
	end
	local nextHunShiData = resTableManager:GetValue(ResTable.soul_node,tostring(tonumber(nowPoint)+1),
	{'propertytype1','propertyindex1','promote1',
	 'propertytype2','propertyindex2','promote2',
	 'propertytype3','propertyindex3','promote3',
	 'propertytype4','propertyindex4','promote4'})
	if nil == nextHunShiData then
		nextHunShiData = resTableManager:GetValue(ResTable.soul_node,tostring(tonumber(hunshiDuanWei+1)*1000),
		{'propertytype1','propertyindex1','promote1',
		'propertytype2','propertyindex2','promote2',
		'propertytype3','propertyindex3','promote3',
		'propertytype4','propertyindex4','promote4'})
		if nil == nextHunShiData then
			--满阶
			bottomAttBtn.Visibility = Visibility.Hidden
			full = true
			self:attChangeState(true)
		else
			--干架
			local fireId = resTableManager:GetValue(ResTable.soul_node,tostring(nowPoint),'round')
			if fireId then
				examBtn.Tag = tonumber(fireId)
			end
			tipText.Visibility = Visibility.Hidden
			examBtn.Visibility = Visibility.Visible
			self.old_soul_node_infos = ActorManager.user_data.counts.soul_node_infos
		end
	end

	nextData = {}
	for i = 1 , 4 do
		nextData[i] = {0,0,0,0,0}
	end
	if nextHunShiData then
		for i = 1, 4 do
			if nextHunShiData['propertytype'..i] then
				for j = 1, 5 do
					if nextHunShiData['propertytype'..i][j] then
						if tonumber(nextHunShiData['propertytype'..i][j]) == tonumber(attNum[1]) then
							local num = nextData[1][tonumber(nextHunShiData['propertyindex'..i])] 
							nextData[1][tonumber(nextHunShiData['propertyindex'..i])]= nextHunShiData['promote'..i] + num
						elseif tonumber(nextHunShiData['propertytype'..i][j]) == tonumber(attNum[2]) then
							local num = nextData[2][tonumber(nextHunShiData['propertyindex'..i])] 
							nextData[2][tonumber(nextHunShiData['propertyindex'..i])] = nextHunShiData['promote'..i] + num
						elseif tonumber(nextHunShiData['propertytype'..i][j]) == tonumber(attNum[3]) then
							local num = nextData[3][tonumber(nextHunShiData['propertyindex'..i])] 
							nextData[3][tonumber(nextHunShiData['propertyindex'..i])] = nextHunShiData['promote'..i] + num
						else
							local num = nextData[4][tonumber(nextHunShiData['propertyindex'..i])] 
							nextData[4][tonumber(nextHunShiData['propertyindex'..i])] = nextHunShiData['promote'..i] + num
						end
					end
				end
			end
		end
	end

	for i = 1 , 4 do 
		local attPanel = attPanelList[i]
		for j = 1 , 5 do
			local att = attPanel:GetLogicChild('att'..j)
			local rightPanel = att:GetLogicChild('rightPanel')
			local oldValue = rightPanel:GetLogicChild('oldValue')
			local upValue  = rightPanel:GetLogicChild('upValue')
			local nowValue = att:GetLogicChild('nowValue')
			if ActorManager.user_data.counts.soulid == 0 then
				nowValue.Text = '0'
				oldValue.Text = '0'
				upValue.Text  = tostring(nextRank[attNum[i]] and nextRank[attNum[i]]['soul_node_point'][''..j] or 0)
			else
				if ActorManager.user_data.counts.soul_node_infos[attNum[i]] and ActorManager.user_data.counts.soul_node_infos[attNum[i]]['soul_node_point'][''..j] then
					upValue.Text  = tostring(nextRank[attNum[i]] and nextRank[attNum[i]]['soul_node_point'][''..j] or 0)
					oldValue.Text = tostring(ActorManager.user_data.counts.soul_node_infos[attNum[i]]['soul_node_point'][''..j])
					nowValue.Text = tostring(ActorManager.user_data.counts.soul_node_infos[attNum[i]]['soul_node_point'][''..j])
				else
					upValue.Text = tostring(nextRank[attNum[i]] and nextRank[attNum[i]]['soul_node_point'][''..j] or 0)
					oldValue.Text = '0'
					nowValue.Text = '0'
				end
			end
		end
	end

	mapImg:RemoveAllChildren()
	local i = 0
	local eventFlag = true --为第一个白球设置点击事件
	local totleCount = 0
	local curCount = 0
	local dataId = 0
	local mapId = 0
	local imgList = {}
	if full then
		dataId = tonumber(ActorManager.user_data.counts.soulranknum-1)*1000+1
		mapId = tonumber(ActorManager.user_data.counts.soulranknum-1) % 2
	else
		dataId = tonumber(ActorManager.user_data.counts.soulranknum)*1000+1
		mapId = tonumber(ActorManager.user_data.counts.soulranknum) % 2
	end
	mapImg.Image = GetPicture('background/hunshi_map_'..mapId..'.ccz')
	while true do
		local hunShiData = resTableManager:GetValue(ResTable.soul_node,tostring(dataId),{'name','coordinate'})
		if hunShiData then
			
			local img = uiSystem:CreateControl('ImageElement')
			img.Tag = dataId
			if dataId <= ActorManager.user_data.counts.soulid then
				img.Image = GetPicture('common/hunshi_open.ccz')
				curCount = curCount + 1
			else
				img.Image = GetPicture('common/hunshi_close.ccz')
				if eventFlag then
					nowPointControl = dataId
					img:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'HunShiPanel:imgOnClick')
					eventFlag = false
				end
			end
			table.insert(imgList,img)
			local label = uiSystem:CreateControl('TextElement')
			label.Pick = false
			label.Horizontal = ControlLayout.H_CENTER
			label.Vertical   = ControlLayout.V_CENTER
			label.Text = tostring(hunShiData['name'])
			label.Font = uiSystem:FindFont('huakang_18_miaobian')
			label.TextColor = QuadColor(Color(64,64,64,255))
			img.Translate = Vector2(tonumber(hunShiData['coordinate'][1]),tonumber(hunShiData['coordinate'][2]))
			img:AddChild(label)
			mapImg:AddChild(img)
			i = i + 1
			totleCount = totleCount + 1
			--PlayEffect('hunshijinjie_output/',Rect(0,0,0,0),'hunshijinjie',img)
		else
			break
		end
		dataId = dataId + 1
	end
	if clickBtnFlag then
		for _,v in pairs(imgList) do
			if v.Tag == nPointControl then
				--print('nPointControl-->'..tostring(nPointControl))
				self:PlayEffect(v)
			end
		end
	end
	if full then
		duanWeiLabel.Text = tostring(LANG_hunshi_duanwei[tonumber(hunshiDuanWei-1)])
		tipText.Text = LANG_hunshi_7
	else
		duanWeiLabel.Text = tostring(LANG_hunshi_duanwei[tonumber(hunshiDuanWei)])
		tipText.Text = LANG_hunshi_5..curCount..'/'..totleCount..LANG_hunshi_6
	end
end
function HunShiPanel:PlayEffect(control)
	local armatureFront = uiSystem:CreateControl('ArmatureUI')
	armatureFront:LoadArmature('hunshijinjie');
	armatureFront:SetScale(1.5,1.5)
	armatureFront:SetAnimation('play1')
	armatureFront.Translate = Vector2(53,35)
	armatureFront:SetScriptAnimationCallback('HunShiPanel:ArmatrueFrontEnd',0)
	armatureFront.ZOrder = 1
	control:AddChild(armatureFront)
	clickBtnFlag = false
end
function HunShiPanel:imgOnClick(Arg)
	local arg = UIControlEventArgs(Arg);
	local tag = arg.m_pControl.Tag;
	local nowPoint = 0
	if ActorManager.user_data.counts.soulid == 0 then
		nowPoint = 1000
	else
		nowPoint = ActorManager.user_data.counts.soulid
	end
	cost = resTableManager:GetValue(ResTable.soul_node,tostring(nowPoint+1),'cost')
	if ActorManager.user_data.counts.soulvalue < tonumber(cost) then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_hunshi_8);
	else
		nPointControl = nowPointControl
		clickBtnFlag = true
		upTipData = nextData 
		local msg = {}
		msg.soulid = tag
		Network:Send(NetworkCmdType.req_open_soulid,msg)
	end
end

function HunShiPanel:upPanelShow()
	if not clickBtnFlag then
		return;
	end  
	upStackPanel:RemoveAllChildren()
	local attData = {}
	for i = 1, 5 do
		attData[i] = {}
		attData[i].att = {}
		attData[i].count = 0;
		for j = 1, 4 do
			if upTipData[j][i]>0 then
				table.insert(attData[i].att,j)
				attData[i].count = upTipData[j][i];
			end
		end
		if attData[i].count > 0 then
			local uiCtrl = uiSystem:CreateControl('hunShiUpTemplate')
			local uiControl = uiCtrl:GetLogicChild(0)
			local count = 1
			for _,v in pairs(attData[i].att) do
				local attImg = uiControl:GetLogicChild('ImgPanel'):GetLogicChild('ImgStack'):GetLogicChild('img'..count)
				attImg.Visibility = Visibility.Visible
				attImg.Image = GetPicture(attImages[tonumber(v)])
				count = count + 1
			end
			uiControl:GetLogicChild('attLabel').Text = LANG_hunshi_att_name[i]
			uiControl:GetLogicChild('valueLabel').Text = tostring(attData[i].count)
			upStackPanel:AddChild(uiCtrl)
		end
	end
	costCountLabel.Text = ''..tostring(cost)
	mainDesktop.FocusControl = upPanel;
	upPanel.Visibility = Visibility.Visible
	StoryBoard:ShowUIStoryBoard(upPanel, StoryBoardType.ShowUI1, nil, '');
end
function HunShiPanel:ArmatrueFrontEnd(armature)
	--print('end-->')
	if armature:GetAnimation() == 'play1' then
		armature:SetAnimation('play2');
	end
end
function HunShiPanel:upPanelHide()
	upPanel.Visibility = Visibility.Hidden
	StoryBoard:HideUIStoryBoard(upPanel, StoryBoardType.HideUI1, 'StoryBoard:OnPopUI');
end
function HunShiPanel:tipPanelShow()
	mainDesktop.FocusControl = tipPanel;
	tipPanel.Visibility = Visibility.Visible
	StoryBoard:ShowUIStoryBoard(tipPanel, StoryBoardType.ShowUI1, nil, '');
end
function HunShiPanel:tipPanelHide()
	tipPanel.Visibility = Visibility.Hidden
	StoryBoard:HideUIStoryBoard(tipPanel, StoryBoardType.HideUI1, 'StoryBoard:OnPopUI');
end
function HunShiPanel:refreshData()
	self:refreshAtt()
end

--请求下一阶加成数据,没有下一阶则刷新一下数据
function HunShiPanel:ReqNextData()
	local info = resTableManager:GetRowValue(ResTable.soul_node,tostring(tonumber(ActorManager.user_data.counts.soulranknum+1)*1000))
	if info then
		local msg = {}
		msg.soulid = tonumber(ActorManager.user_data.counts.soulranknum+1)*1000;
		Network:Send(NetworkCmdType.req_soulnode_pro,msg)
	else
		HunShiPanel:refreshData();
	end
end

--接收加成数据
function HunShiPanel:setNextData(data)
	nextRank = data
end

function HunShiPanel:isVisible()
	return hunShiPanel.Visibility == Visibility.Visible
end


function HunShiPanel:onShow()
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.hunShi then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_open_hunShi);
		return;
	end
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		mapImg:SetScale(factor,factor);
		bottomPanel:SetScale(factor,factor);
		recordPanel:SetScale(factor,factor)
		recordPanel.Translate = Vector2(593*(factor-1)/2,0)
	end
	HunShiPanel:ReqNextData()
	--HunShiLevelUpPanel:Show()
	self:Show()
	--MainUI:Push(HunShiPanel)
end
--显示
function HunShiPanel:Show()
	if ChroniclePanel:isShow() then
		ChroniclePanel:onClose()
	end
	if BagListPanel:isShow() then
		BagListPanel:onClose()
	end
	attBtnFlag = true --切换按钮状态
	nowPointControl = nil
	self.old_soul_node_infos = {}
	clickBtnFlag = false
	bgImg.Background = CreateTextureBrush("background/default_bg.jpg", 'background');
	self:refreshData()
	self:attBtnOnClick()
	hunShiPanel.Visibility = Visibility.Visible
	HomePanel:setRolePanelZOrder(false)
	StoryBoard:ShowUIStoryBoard(hunShiPanel, StoryBoardType.ShowUI1);
	--mainDesktop:DoModal(hunShiPanel);
	--StoryBoard:ShowUIStoryBoard(hunShiPanel, StoryBoardType.ShowUI1, nil, '');
end
function HunShiPanel:onDestroy()
  bgImg.Background = nil;
  DestroyBrushAndImage("background/duiwu_bg.jpg", 'background');
  StoryBoard:OnPopUI();
end


--隐藏
function HunShiPanel:Hide()
	hunShiPanel.Visibility = Visibility.Hidden
	self:onDestroy()
	HomePanel:setRolePanelZOrder(true)
	--StoryBoard:HideUIStoryBoard(hunShiPanel, StoryBoardType.HideUI1, 'HunShiPanel:onDestroy');
end

--========================================================================
--界面响应
--========================================================================

--返回
function HunShiPanel:onClose()
	StoryBoard:HideUIStoryBoard(hunShiPanel, StoryBoardType.HideUI1, 'HunShiPanel:Hide');
	-- self:Hide()
	--MainUI:Pop()
end
