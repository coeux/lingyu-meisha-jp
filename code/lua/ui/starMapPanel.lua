--starMapPanel.lua

--12星图属性变更面板
local attrMainPanel;
local attrLabel1;
local attrLabel2;
local attrLabel3;
local replaceBtn;
local refreshBtn;
local cancelBtn;
local oldNumLabel;
local newNumLabel;
local getMsg = {};

--选择面板
local okCanelMain;
local okCanelOk;
local okCanelCanel;
local okDelegate;
local infoLabel;

--变量
local curSelected = -1;
local refreshStarColor = 1;

--控件
local mainDesktop;
local mainPanel;
local starMapStack;
local scrollCtrl;
local starMapBoard;
local selRoleData;
local starTotalPercentTxt;
local selRoleTag;  -- pos
local selRoleTagPid; -- pid
local selClickBtn; --当前点击按钮
local selStarLv;
local selStarIndex;
local selRefresh;
local starAttrLabels;
local starMap11BtnWihite1;
local starTypeNum =
{
	whiteStarNum		= 8;				--白色英雄星魂数
	greeStarNum			= 9;				--绿色英雄星魂数
	blueStarNum			= 10;				--蓝色英雄星魂数
	purpleStarNum		= 11;				--紫色英雄星魂数
	glodStarNum			= 12;				--金色英雄星魂数		
};

local starNumConfig = {{3,2,2,1,0}, {3,3,2,1,0}, {3,3,2,1,1}, {2,2,3,2,2}, {1,2,3,3,3}};
local starColorNameData = {"White", "Green", "Blue", "Purple", "Gold"};
local starLockBmpName = {"star_D1", "star_C2", "star_B3", "star_A4", "star_S5"}
local starBmpName = {"star_D", "star_C", "star_B", "star_A", "star_S"}
local starAttrName = {LANG_starMapPanel_1,LANG_starMapPanel_2,LANG_starMapPanel_3,LANG_starMapPanel_4,LANG_starMapPanel_5,LANG_starMapPanel_6,LANG_starMapPanel_7,LANG_starMapPanel_8}
local starAttrNameInTable = {"min_atk","max_atk","min_mgc","max_mgc","min_def","max_def","min_res","max_res","min_hp","max_hp"}
local starName = {LANG_starMapPanel_9,LANG_starMapPanel_10,LANG_starMapPanel_11,LANG_starMapPanel_12,LANG_starMapPanel_13};
local materialIds = {19001, 19002, 19003, 19004, 19005};

StarMapAttrPanel = 
{
};

function StarMapAttrPanel:InitPanel(desktop)
	
	--UI初始化
	mainDesktop = desktop;	
	attrMainPanel = Panel(desktop:GetLogicChild('starmapRefreshPanel'));
	attrLabel1 = attrMainPanel:GetLogicChild('shuijingLabel1');
	attrLabel2 = attrMainPanel:GetLogicChild('shuijingLabel2');
	attrLabel3 = attrMainPanel:GetLogicChild('shuijingLabel3');
	replaceBtn = attrMainPanel:GetLogicChild('replace');
	refreshBtn = attrMainPanel:GetLogicChild('refresh');
	cancelBtn = attrMainPanel:GetLogicChild('cancel');	
	oldNumLabel = attrMainPanel:GetLogicChild('oldNumber');
	newNumLabel = attrMainPanel:GetLogicChild('newNumber');
	attrLabel1.Visibility = Visibility.Hidden;
	attrLabel2.Visibility = Visibility.Hidden;
	attrLabel3.Visibility = Visibility.Visible;
	attrMainPanel:IncRefCount();		
	starMap11BtnWihite1 = nil;
	getMsg['pid'] = 0;
	getMsg['code'] = 0;
	getMsg['lv'] = 0;
	getMsg['pos'] = 0;
	getMsg['att'] = 0;
	getMsg['value'] = 0;
	
	attrMainPanel.Visibility = Visibility.Hidden;
end

function StarMapAttrPanel:Show()
	--设置模式对话框
	mainDesktop:DoModal(attrMainPanel);	
	StoryBoard:ShowUIStoryBoard(attrMainPanel, StoryBoardType.ShowUI2);
	refreshStarColor = 1;
end

function StarMapAttrPanel:Hide()
	--mainDesktop:UndoModal();
	StoryBoard:HideUIStoryBoard(attrMainPanel, StoryBoardType.HideUI2, 'StoryBoard::OnPopUI');
end

function StarMapAttrPanel:Destroy()
	attrMainPanel:DecRefCount();
	attrMainPanel = nil;
end

function StarMapAttrPanel:ShowTwoButtonsPanel()
	attrMainPanel.Size = Size(450, 295);
	refreshBtn.Translate = Vector2(-60, 0);
	cancelBtn.Translate = Vector2(60, 0);
	replaceBtn.Visibility = Visibility.Hidden;
end

function StarMapAttrPanel:ShowThreeButtonsPanel()
	attrMainPanel.Size = Size(550, 295);
	refreshBtn.Translate = Vector2(0, 0);
	cancelBtn.Translate = Vector2(0, 0);
	replaceBtn.Visibility = Visibility.Visible;
end

function StarMapAttrPanel:ShowAttrPanel(oldAttr, oldValue, oldLevel, newAttr, newValue, newLevel)
	if newAttr == 0 then
		StarMapAttrPanel:ShowTwoButtonsPanel();
	else
		StarMapAttrPanel:ShowThreeButtonsPanel();
	end
	local attrValue = oldValue;
	local att = tonumber(oldAttr);
	local attrText = starAttrName[att+1].." "..attrValue;
	--print("The attr text is:"..attrText);
	oldNumLabel.Text = attrText;
	local attrRatio = StarMapPanel:GetStarRatio(oldLevel+1, att, attrValue);
	if attrRatio > 1 then
		--print ("Bad attr value:"..i..",att:"..att..",attrValue:"..attrValue);
		attrRatio = 1					
	end

	local attrRatioRank = StarMapPanel:GetStarRatioRank(attrRatio*100);
	if attrRatioRank ~= -1 then
		oldNumLabel.TextColor = QualityColor[attrRatioRank+1];		
	end
			
	attrValue = newValue;
	att = tonumber(newAttr);
	attrText = starAttrName[att+1].." "..attrValue;
	--print("The attr text is:"..attrText);
	newNumLabel.Text = attrText;
	attrRatio = StarMapPanel:GetStarRatio(newLevel+1, att, attrValue);
	if attrRatio > 1 then
		--print ("Bad attr value:"..i..",att:"..att..",attrValue:"..attrValue);
		attrRatio = 1					
	end
	
	attrRatioRank = StarMapPanel:GetStarRatioRank(attrRatio*100);
	if attrRatioRank ~= -1 then
		newNumLabel.TextColor = QualityColor[attrRatioRank+1];		
	end	
	
	refreshStarColor = attrRatioRank + 1;
	
	if newAttr == 0 and newValue == 0 then	
		newNumLabel.Text = '???';
		newNumLabel.TextColor = QualityColor[1];		
	end
end

function StarMapAttrPanel:OnRefreshWithRmb(costRmb, leftTimes)
	print ('StarMapAttrPanel');
	--attrLabel1.Text = LANG_starMapPanel_14.. tostring(costRmb) ..LANG_starMapPanel_15 ;
	--attrLabel2.Text = LANG_starMapPanel_16..tostring(leftTimes)..LANG_starMapPanel_17;

	attrLabel1:RemoveAllChildren();

	local width = attrLabel1.Size.Width;	
	local contents = {}
	table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_14});
	table.insert(contents, {mType = MultiTextControlType.Text; text = tostring(costRmb), color = QualityColor[3]});
	table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_43, color = QualityColor[3]});
	table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_15});	
	local ctrls = MultiTextControl:GetCombinedList(contents, width);
	for _, v in pairs(ctrls) do
		attrLabel1:AddChild(v);			
	end

	attrLabel2:RemoveAllChildren();

	local width = attrLabel2.Size.Width;	
	local contents = {}
	table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_16});
	table.insert(contents, {mType = MultiTextControlType.Text; text = tostring(leftTimes), color = QualityColor[2]});
	table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_17, color = QualityColor[2]});	
	local ctrls = MultiTextControl:GetCombinedList(contents, width);
	for _, v in pairs(ctrls) do
		attrLabel2:AddChild(v);			
	end
		
end


okCanelPanel = 
{
}


function okCanelPanel:InitPanel(desktop)
	
	--UI初始化
	mainDesktop = desktop;	
	okCanelMain = Panel(desktop:GetLogicChild('OKCancelPanel'));
	okCanelOk = okCanelMain:GetLogicChild('ok');
	okCanelCanel = okCanelMain:GetLogicChild('cancel');	
	infoLabel = okCanelMain:GetLogicChild('infoLabel');
	okCanelMain:IncRefCount();	
	okCanelMain.Visibility = Visibility.Hidden;
end

function okCanelPanel:DoMsgOk()
	okDelegate:Callback();
end

function okCanelPanel:Show()
	--设置模式对话框
	okCanelOk:SubscribeScriptedEvent('Button::ClickEvent', 'okCanelPanel:DoMsgOk');
	okCanelCanel:SubscribeScriptedEvent('Button::ClickEvent', 'okCanelPanel:Close');

	mainDesktop:DoModal(okCanelMain);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(okCanelMain, StoryBoardType.ShowUI2, nil, 'okCanelPanel:onUserGuid');		
end

--打开时的新手引导
function okCanelPanel:onUserGuid()
	UserGuidePanel:ShowGuideShade(okCanelOk, GuideEffectType.hand, GuideTipPos.bottom, LANG_starMapPanel_18, nil, 0.5);
end

function okCanelPanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(okCanelMain, StoryBoardType.HideUI2, 'StoryBoard::OnPopUI');	
end

function okCanelPanel:Destroy()
	okCanelMain:DecRefCount();
	okCanelMain = nil;
end

function okCanelPanel:Close()
	MainUI:Pop();
end



--========================================================================
--12星图界面

StarMapPanel =
{
};


--初始化面板
function StarMapPanel:InitPanel(desktop)

	--变量初始化
	curSelected = -1;
	
	--UI初始化
	mainDesktop = desktop;	
	mainPanel = Panel(desktop:GetLogicChild('starMapPanel'));
	mainPanel:IncRefCount();	

	scrollCtrl = mainPanel:GetLogicChild('starMapScroll');	
	starMapStack = scrollCtrl:GetLogicChild('starMapStack');	
	starAttrLabels = {}
	local rightTopBrush = mainPanel:GetLogicChild('rightTopBrush');
	starAttrLabels[1] = rightTopBrush:GetLogicChild('starWhiteNum');
	starAttrLabels[2] = rightTopBrush:GetLogicChild('starGreenNum');
	starAttrLabels[3] = rightTopBrush:GetLogicChild('starBlueNum');
	starAttrLabels[4] = rightTopBrush:GetLogicChild('starPurpleNum');
	starAttrLabels[5] = rightTopBrush:GetLogicChild('starGoldNum');
	
	local rightBottomBrush = mainPanel:GetLogicChild('rightBottomBrush');
	starMapBoard = rightBottomBrush:GetLogicChild('starMapBoard');
	starTotalPercentTxt = starMapBoard:GetLogicChild('starCompleteRatio');
	--print("StarmapBoard:"..tostring(starMapBoard==nil));		
	mainPanel.Visibility = Visibility.Hidden;
end
	

--销毁
function StarMapPanel:Destroy()
	mainPanel:DecRefCount();
	mainPanel = nil;
end

--显示
function StarMapPanel:Show()
	
	--记录老战斗力
	ActorManager.oldFP = ActorManager.user_data.fp;
	
	--设置模式对话框
	mainDesktop:DoModal(mainPanel);

	--添加角色
	self:AddRole();
	
	--设置背景
	starMapBoard.Background = CreateTextureBrush('background/star_beijing.ccz', 'godsSenki', Rect(0,0,450,330));
	
	--滚动到开始
	scrollCtrl:VScrollBegin();
	
	--强制刷新数据
	self:updateBind();	
	
	StoryBoard:ShowUIStoryBoard(mainPanel, StoryBoardType.ShowUI1, nil, 'StarMapPanel:onUserGuid');
end

--新手引导
function StarMapPanel:onUserGuid()
	UserGuidePanel:ShowGuideShade(starMap11BtnWihite1, GuideEffectType.hand, GuideTipPos.bottom, LANG_starMapPanel_19, nil, 0.5);
end

function StarMapPanel:updateBind()
	
end

--隐藏
function StarMapPanel:Hide()
	
	--战斗力改变
	ActorManager:UpdateFightAbility();
	--GemPanel:totleFp();
	FightPoint:ShowFP(ActorManager.user_data.fp - ActorManager.oldFP);
	ActorManager.oldFP = ActorManager.user_data.fp;

	--销毁背景图片
	starMapBoard.Background = nil;
	DestroyBrushAndImage('background/star_beijing.ccz', 'godsSenki');
	StoryBoard:HideUIStoryBoard(mainPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

function StarMapPanel:OnClose()
	--print("Will close starMap panel");
	MainUI:Pop();
end

function StarMapPanel:ShowStarMapPanel()
	MainUI:Push(self);
	self:InitPlayerInfo();
end

-- UI 操作相关函数
function StarMapPanel:GetStarRatio(starLevel, starAttr, starAttrVal)
	local attrNameMin = starAttrNameInTable[starAttr*2+1];
	local attrNameMax = starAttrNameInTable[starAttr*2+2];
	--print("starLevel:"..starLevel);
	---print("attrNameMin:"..attrNameMin);
	local attrMin = resTableManager:GetValue(ResTable.star_map, tostring(starLevel), attrNameMin);
	local attrMax = resTableManager:GetValue(ResTable.star_map, tostring(starLevel), attrNameMax);
	local ratio = (starAttrVal-attrMin)/(attrMax-attrMin);
	return ratio;
end

function StarMapPanel:GetStarRatioRank(ratio)
	if ratio >= 0 and ratio <= 25 then
		return 0
	elseif ratio <= 50 then
		return 1
	elseif ratio <= 70 then
		return 2
	elseif ratio <= 90 then
		return 3
	elseif ratio <= 99 then
		return 4
	elseif ratio <= 100 then
		return 5
	end
	
	return -1
end

function StarMapPanel:InitPlayerInfo()
	--print("Start Init playerInfo pannel");
	self:OnSetRoleInfo(1, 0); -- 默认选择主角
end

function StarMapPanel:OnSelectRole(Args)
	local args = UIControlEventArgs(Args);
	self:OnSetRoleInfo(args.m_pControl.Tag, args.m_pControl.TagExt);	
end

function StarMapPanel:OnUnlockStar()

end

--打开哪（白绿蓝紫金8-12）个属性面板
function StarMapPanel:ShowBoard(boardName)
	local boardList = {"Panel12Stars", "Panel11Stars", "Panel10Stars", "Panel9Stars", "Panel8Stars"}
	
	--print("StarMapPel, show board:".. boardName);
	for i = 1, #boardList do
		--print ("Will show:" ..tostring(i)..","..boardList[i]);
		local curPanel = starMapBoard:GetLogicChild(boardList[i]);		
		if boardName == boardList[i] then
			curPanel.Visibility = Visibility.Visible;
		else
			curPanel.Visibility = Visibility.Hidden;
		end
	end
end

--开启星魂
function StarMapPanel:DoOpenHeroStar(roleTagPid, lv, starIndex)
	MainUI:Pop();
	self:OpenHeroStar(selRoleTagPid, lv, starIndex);
end

function StarMapPanel:OnReqRefreshHeroStar(roleTagPid, lv, starIndex)
	MainUI:Pop();
	MainUI:Push(StarMapAttrPanel);
	
	replaceBtn.Visibility = Visibility.Hidden;
end

--刷新或者开启星魂
function StarMapPanel:OnClickStarBtn(Args)
	local args = UIControlEventArgs(Args);
	local TagExt = args.m_pControl.TagExt;
	local starIndex = TagExt%10; 
	local starLevel = (TagExt-starIndex)/10;
	local lv = 5-starLevel;
	selClickBtn = args.m_pControl;
	selStarLv = lv;
	selStarIndex = starIndex;
	selRefresh = args.m_pControl.Tag
	
	if selRefresh == 0 then
		okDelegate = Delegate.new(StarMapPanel, StarMapPanel.DoOpenHeroStar, selRoleTagPid, lv, starIndex);	
		--okCanelPanel:Show();
		MainUI:Push(okCanelPanel);
		infoLabel:RemoveAllChildren();

		local width = infoLabel.Size.Width;	
		local contents = {}
		table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_20});
		table.insert(contents, {mType = MultiTextControlType.Text; text = starName[lv+1], color = QualityColor[5-lv]});
		table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_44, color = QualityColor[5-lv]});
		table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_21});
		--infoLabel.Text = LANG_starMapPanel_20.. starName[lv+1]..LANG_starMapPanel_21;
		local ctrls = MultiTextControl:GetCombinedList(contents, width);
		for _, v in pairs(ctrls) do
			infoLabel:AddChild(v);			
		end
		okCanelOk.Text = LANG_starMapPanel_22;
	else
		MainUI:Push(StarMapAttrPanel);
		replaceBtn.Visibility = Visibility.Hidden;
		local materialId = materialIds[5-selStarLv];
		local itemMat = Package:GetEquip(materialId);	
		if itemMat ~= nil then	
			attrLabel3.Visibility = Visibility.Visible;
			attrLabel1.Visibility = Visibility.Hidden;
			attrLabel2.Visibility = Visibility.Hidden;
			--attrLabel3.Text = LANG_starMapPanel_23.. starName[lv+1] .. ‘刷新星魂？(剩余’ .. tostring( itemMat.num ) .. '个)';

			attrLabel3:RemoveAllChildren();

			local width = attrLabel3.Size.Width;	
			local contents = {}
			table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_23});
			table.insert(contents, {mType = MultiTextControlType.Text; text = starName[lv+1], color = QualityColor[5-lv]});
			table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_45, color = QualityColor[5-lv]});
			table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_46});			
			table.insert(contents, {mType = MultiTextControlType.Text; text = tostring( itemMat.num ), color = QualityColor[2]});
			table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_47, color = QualityColor[2]});
			table.insert(contents, {mType = MultiTextControlType.Text; text = '）'});
			local ctrls = MultiTextControl:GetCombinedList(contents, width);
			for _, v in pairs(ctrls) do
				attrLabel3:AddChild(v);			
			end
			
		else
			--attrLabel3.Text = LANG_starMapPanel_24.. starName[lv+1] .. "等星刷新星魂？(剩余0个)";
			attrLabel3.Visibility = Visibility.Hidden;
			attrLabel1.Visibility = Visibility.Visible;
			attrLabel2.Visibility = Visibility.Visible;
			self:OnReqRefreshStarmapWithCoin();
		end

		local actor = selRoleData
		local stars = actor.stars
		for i=1, #stars do
			local curStar = stars[i];
			
			if curStar.pos == selStarIndex and curStar.lv == selStarLv then			
				StarMapAttrPanel:ShowAttrPanel(curStar.att, curStar.value, curStar.lv, 0, 0, 0);
				break;
			end
		end	

	end
end

--
function StarMapPanel:DoRefreshWork()
	-- 默认用星魂刷新
	if refreshStarColor == 5 then  -- 刷到了金色属性，提示一下
		local okDelegate = Delegate.new(StarMapPanel, StarMapPanel.GoWithRefreshWork, 0);	
		MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_starMapPanel_48, okDelegate);		
	else
		StarMapPanel:GoWithRefreshWork()
	end
end	

function StarMapPanel:GoWithRefreshWork()
	local materialId = materialIds[5-selStarLv];
	materialItem = Package:GetEquip(materialId);
	if materialItem == nil then
		--self:OnRequestGetStarVal(selRoleTagPid, selStarLv, selStarIndex, 2);
		--self:OnReqRefreshStarmapWithCoin()
		self.RefreshStarWithCoin();
	else
		self:OnRequestGetStarVal(selRoleTagPid, selStarLv, selStarIndex, 1);	
	end	
end

function StarMapPanel:RefreshCompletePercent(totalStarNum, starData)
	local totalPercentage = 0;
	for i=1, #starData do
		
	end
	--local starMapData = resTableManager:
end

-- totalStarNum: 8-12 
-- 设置星魂面板信息
function StarMapPanel:SetPanelInfo(panelName, totalStarNum, starData)
	local curPanel = starMapBoard:GetLogicChild(panelName);
	
	if curPanel == nil then
		--print("Can't find panel:" .. panelName);
		return;
	end
	
	local starConfigData = {{}, {}, {}, {}, {}}
	
	for i=1, #starConfigData do
		for j=1, 3 do
			starConfigData[i][j] = nil;
		end
	end
	
	for i=1, #starData do
		local curData = starData[i];
		local index = #starConfigData-curData.lv
		--print("curDataPos: "..tostring(curData));
		if index >= 0 and index <= 5 then
			starConfigData[index][curData.pos] = curData -- lv 特~四，0~4, config 四-特 1-5
		else
			print("Error index:"..index);		
		end
	end
	
	-- 先把所有图片按钮和标签都清空，再进行初始化
	local starConfigIndex = totalStarNum - starTypeNum.whiteStarNum + 1;
	local starConfig = starNumConfig[starConfigIndex];	
	local starTotalNum = 0;
	local starTotalComplete = 0.0;
	
	-- 初始化图片
	for i=1, #starConfig do
		local starNum = starConfig[i];
		starTotalNum = starTotalNum + starNum;
		local colorName = starColorNameData[i];
		for j=1, starNum do
			local bmpName = "starMap"..totalStarNum.."Bmp"..colorName..j;
			bmpName = tostring(bmpName);
			local curBmp = curPanel:GetLogicChild(bmpName);
			if curBmp == nil then
				--print("The bmp name is: " .. bmpName);
			end
			local texLockName = starLockBmpName[i];
			local texNormalName = starBmpName[i];

			local btnName = "starMap"..totalStarNum.."Btn"..colorName..j;
			local curBtn = curPanel:GetLogicChild(btnName);		
			if curBtn == nil then
				--print ("The empty btn name is: " .. btnName);
			end	

			if totalStarNum == 12 and colorName == "White" and j == 1 then
				starMap11BtnWihite1 = curBtn;
			end
			
			curBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'StarMapPanel:OnClickStarBtn');	
			curBtn.TagExt = i*10 + j; -- i [1,5], j [1, 3]
			curBtn:RemoveAllChildren();

			local attrName = "starMap"..totalStarNum.."Attr"..colorName..j;
			local curAttrLable = curPanel:GetLogicChild(attrName);
			if curAttrLable == nil then
				--print("The empty attr name is: " .. attrName);
			end
			curAttrLable.Visibility	= Visibility.Hidden;

			if starConfigData[i][j] == nil then
				curBmp.Background = uiSystem:FindResource(texLockName, "xingzuo");
				curBtn.Tag = 0; -- Lock				
				curAttrLable.Visibility	= Visibility.Hidden;						
			else
				curBmp.Background = uiSystem:FindResource(texNormalName, "xingzuo");
				curBtn.Tag = 1; -- not lock 				
				
				if i == 4 then   -- 紫色的星
					--PlayEffect("xingtu_zi_output/", Rect(0,6,4,0), "xingtu_zi", curBtn);
				elseif i == 5 then
					--PlayEffect("xingtu_cheng_output/", Rect(0, 5, 5, 0), "xingtu_cheng", curBtn);
				end
				curAttrLable.Visibility	= Visibility.Visible;
				local attrValue = starConfigData[i][j].value;
				local att = tonumber(starConfigData[i][j].att);
				local attrText = starAttrName[att+1].." "..attrValue;
				--print("The attr text is:"..attrText);
				curAttrLable.Text = attrText;
				local attrRatio = self:GetStarRatio(6-i, att, attrValue);
				if attrRatio > 1 then
					--print ("Bad attr value:"..i..",att:"..att..",attrValue:"..attrValue);
					attrRatio = 1					
				end
				starTotalComplete = starTotalComplete + attrRatio;
				local attrRatioRank = self:GetStarRatioRank(attrRatio*100);
				if attrRatioRank ~= -1 then
					curAttrLable.TextColor = QualityColor[attrRatioRank+1];		
				else
					--print ("Bad attr value:"..i..",att:"..att..",attrValue:"..attrValue);
				end
			end
		end
	end	
	
	local totalCompleteRatio = starTotalComplete*100/starTotalNum;
	local ratio = string.format("%.2f",totalCompleteRatio);
	starTotalPercentTxt.Text = LANG_starMapPanel_25 .. ratio.."%";
	
	for i = 1, #materialIds do
		materialID = materialIds[i];
		materialItem = Package:GetEquip(materialID);
		if materialItem == nil then
			starAttrLabels[i].Text = "X 0";
		else
			starAttrLabels[i].Text = "X " .. materialItem.num;
		end	
	end

	StarMapPanel:RefershStarNums();
	-- for test
	--if totalStarNum == 12 then
	--		UserGuidePanel:ShowGuideShade(starMap11BtnWihite1, GuideEffectType.hand, GuideTipPos.bottom, LANG_starMapPanel_26, nil, 0.5);
	--end
	
end

function StarMapPanel:RefershStarNums()
	for i = 1, #materialIds do
		materialID = materialIds[i];
		materialItem = Package:GetEquip(materialID);
		if materialItem == nil then
			starAttrLabels[i].Text = "X 0";
		else
			starAttrLabels[i].Text = "X " .. materialItem.num;
		end
		
	end
end

function StarMapPanel:RefreshRoleInfo()
	local actor = selRoleData;
	local stars = actor.stars
	local starNum = #(stars)
	
	local actorRare = actor.rare;
	if selRoleTagPid == 0 then
		actorRare = 5;
	end
	local panelStarNum = actorRare + 7;
	local starPanelName = "Panel"..panelStarNum.."Stars";
	

	self:ShowBoard(starPanelName);
	self:SetPanelInfo(starPanelName, panelStarNum, stars);	
end

function StarMapPanel:OnSetRoleInfo(roleTag, rolePid)
	local actor = {}
	if roleTag == 1 then  -- 主角
		actor = ActorManager.user_data.role;
	else
		actor = ActorManager.user_data.partners[roleTag - 1];
	end
	selRoleData = actor;	
	selRoleTag = roleTag;
	selRoleTagPid = rolePid;
	self:RefreshRoleInfo();
end

function StarMapPanel:AddRole()
	starMapStack:RemoveAllChildren();
	
	--排序伙伴
	table.sort(ActorManager.user_data.partners, sortPartner);

	--获取主角＋伙伴的总个数
	local roleCount = 1 + #(ActorManager.user_data.partners);
	
	--创建头像列表
	for i = 1, roleCount do
		local t = uiSystem:CreateControl('huobanInfoTemplate');
		local radioButton = RadioButton(t:GetLogicChild(0));
		radioButton.Visibility = Visibility.Visible;
		radioButton.GroupID = RadionButtonGroup.selectStarmapHuoBan;
		radioButton.Tag = i;
		--添加响应事件
		radioButton:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'StarMapPanel:OnSelectRole');
		
		--获取控件
		local labelName = Label(radioButton:GetLogicChild('name'));
		local imgJob = ImageElement(radioButton:GetLogicChild('job'));
		local imgHeadPic = ItemCell(radioButton:GetLogicChild('image'));
		local inTeam = radioButton:GetLogicChild('inTeam');
		inTeam.Visibility = Visibility.Hidden;
		local up = radioButton:GetLogicChild('up');
		up.Visibility = Visibility.Hidden;
		
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
		radioButton.TagExt = actor.pid;
		
		--添加到头像列表
		starMapStack:AddChild(t);
	end

	if starMapStack:GetLogicChildrenCount() ~= 0 then
		local tt = starMapStack:GetLogicChild(0);
		local radioButton = RadioButton(tt:GetLogicChild(0));
		radioButton.Selected = true;
	end	
end

-- 网络消息相关函数
function StarMapPanel:OpenHeroStarError(msg)
	--print("OpenHeroStarError");
	if msg.code == 1007 then
		--MessageBox:ShowDialog(MessageBoxType.Ok, LANG_starMapPanel_27);
		okDelegate = Delegate.new(StarMapPanel, StarMapPanel.GoToHuntStar);	
		--okCanelPanel:Show();
		MainUI:Push(okCanelPanel);
		infoLabel:RemoveAllChildren();

		local width = infoLabel.Size.Width;	
		local contents = {}
		table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_28});
		local ctrls = MultiTextControl:GetCombinedList(contents, width);
		for _, v in pairs(ctrls) do
			infoLabel:AddChild(v);			
		end

		okCanelOk.Text = LANG_starMapPanel_29;		
		return;
	else
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_starMapPanel_30);
		return;	
	end	
end

--刷新星魂返回的数据信息
function StarMapPanel:GotHeroStarRes(msg)
	--print("GotHeroStarRes");
	--print(tostring(msg.code));
	--print(tostring(msg));
	
	if msg.code ~= 0 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_starMapPanel_31);
		return;
	end	
	
	local actor = selRoleData
	local stars = actor.stars
	-- 先更新数据
	local newStarData = {}
	newStarData.lv = msg.lv;
	newStarData.pos = msg.pos;
	newStarData.att = msg.att;
	newStarData.value = msg.value;
	
	stars[#stars+1] = newStarData;
	
	-- 刷新界面
	self:RefreshRoleInfo();

	PlayEffect("xingtuxiangqian_output/", Rect(0,6,6,0), "xingtuxianqian", selClickBtn);	
	
	-- 接着新手引导
	if UserGuidePanel:GetInGuilding() then
		UserGuidePanel:ShowGuideShade(starMap11BtnWihite1, GuideEffectType.hand, GuideTipPos.bottom, LANG_starMapPanel_32, nil, 0.5);
		UserGuidePanel:SetInGuiding(false);
	end
end

function StarMapPanel:OpenHeroStar(pid, lv, pos)
	local msg = {};
	msg.pid = pid;
	msg.lv = lv;
	msg.pos = pos;
	Network:Send(NetworkCmdType.req_star_open_t, msg);
end

function StarMapPanel:RefreshStarWithCoin()
	StarMapPanel:OnRequestGetStarVal(selRoleTagPid, selStarLv, selStarIndex, 2);	
end

function StarMapPanel:OnReqRefreshStarmapWithCoin()
	BuyCountPanel:ApplyData(VipBuyType.vop_starmap);
end

--返回刷新界面
function StarMapPanel:GotRefreshHeroStar(msg)
	-- 先更新数据
	local actor = selRoleData
	local stars = actor.stars
	for i=1, #stars do
		local curStar = stars[i];
		
		if curStar.pos == msg.pos and curStar.lv == msg.lv then
			curStar.value = msg.value;
			curStar.att = msg.att;
			break;
		end
	end
	
	-- 刷新界面
	self:RefreshRoleInfo();
	
	-- 更新刷新面板
	StarMapAttrPanel:ShowAttrPanel(msg.att, msg.value, msg.lv, 0, 0, 0);	
	
	PlayEffect("xingtuxiangqian_output/", Rect(0,6,6,0), "xingtuxianqian", selClickBtn);
end	

function StarMapPanel:OnRequestGetStarVal(pid, lv, pos, flag)
	local msg = {};
	msg.pid = pid;
	msg.lv = lv;
	msg.pos = pos;
	msg.flag = flag;
	Network:Send(NetworkCmdType.req_star_get_t, msg);	
end

function StarMapPanel:OnGotGetStarValError(msg)
	print("StarMapPanel:OnGotGetStarValError:"..msg.code);
	if msg.code == 1007 then
		StarMapPanel:OnRequestGetStarVal(selRoleTagPid, selStarLv, selStarIndex, 2);
	end
end

--刷新星魂的结果
function StarMapPanel:OnGotGetStarVal(msg)
	local actor = selRoleData
	local stars = actor.stars
	for i=1, #stars do
		local curStar = stars[i];
		
		if curStar.pos == msg.pos and curStar.lv == msg.lv then
			--curStar.value = msg.value;
			--curStar.att = msg.att;
			replaceBtn.Visibility = Visibility.Visible;
			getMsg['pid'] = msg.pid;
			getMsg['code'] = msg.code;
			getMsg['lv'] = msg.lv;
			getMsg['pos'] = msg.pos;
			getMsg['att'] = msg.att;
			getMsg['value'] = msg.value;		
			StarMapAttrPanel:ShowAttrPanel(curStar.att, curStar.value, curStar.lv, msg.att, msg.value, msg.lv);
			break;
		end
	end	
	
	local materialId = materialIds[5-selStarLv];
	local itemMat = Package:GetEquip(materialId);		
	if itemMat ~= nil then
		--attrLabel3.Text = LANG_starMapPanel_34.. starName[msg.lv+1] .. "等星刷新星魂？(剩余" .. tostring( itemMat.num ) .. "个)";	
		attrLabel3:RemoveAllChildren();

		local width = attrLabel3.Size.Width;	
		local contents = {}
		local lv = msg.lv;
		table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_23});
		table.insert(contents, {mType = MultiTextControlType.Text; text = starName[lv+1], color = QualityColor[5-lv]});
		table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_49, color = QualityColor[5-lv]});
		table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_50});			
		table.insert(contents, {mType = MultiTextControlType.Text; text = tostring( itemMat.num ), color = QualityColor[2]});
		table.insert(contents, {mType = MultiTextControlType.Text; text = LANG_starMapPanel_51, color = QualityColor[2]});
		table.insert(contents, {mType = MultiTextControlType.Text; text = '）'});
		local ctrls = MultiTextControl:GetCombinedList(contents, width);
		for _, v in pairs(ctrls) do
			attrLabel3:AddChild(v);			
		end
				
	else
		--每次刷新请求VIP数据
		StarMapPanel:OnReqRefreshStarmapWithCoin();	
		attrLabel3.Visibility = Visibility.Hidden;
		attrLabel1.Visibility = Visibility.Visible;
		attrLabel2.Visibility = Visibility.Visible;		
	end
	
	StarMapPanel:RefershStarNums();
	StarMapAttrPanel:ShowThreeButtonsPanel();
end

--申请设置星魂
function StarMapPanel:OnRequestSetStarVal()
	local msg = {};	
	replaceBtn.Visibility = Visibility.Hidden;
	Network:Send(NetworkCmdType.req_star_set_t, msg);		
end

--设置星魂返回
function StarMapPanel:OnGotSetStarVal(msg)
	print("StarMapPanel:OnGotSetStarVal");
	self:GotRefreshHeroStar(getMsg);
end

function StarMapPanel:KeepOld(args)
	print ("Keep old attr");	
	MainUI:Pop();
	StarMapPanel:RefreshRoleInfo();
end

function StarMapPanel:UseTheNewAttr(args)
	print ("StarMapPanel:UseTheNewAttr");	
	self:OnRequestSetStarVal();	
end

--========================================================================
--界面响应

--显示说明
function StarMapPanel:onShuoMing()
	HelpPanel:SetDisplayAndMove(8);
	MainUI:Push(HelpPanel);
end

function StarMapPanel:GoToHuntStar()
	MainUI:Pop();StoryBoard:OnPopPlayingUI();
	MainUI:Pop();StoryBoard:OnPopPlayingUI();
	MainUI:Push(ZodiacSignPanel);
end
