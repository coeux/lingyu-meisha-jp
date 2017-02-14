--lovePanel.lua
--=============================================================================================
LovePanel = 
{
	MAX_LOVE_TASK_LEVEL = 4;
	plot_id = -1;
	pid = 0;
	love_stage = 0;
};

local Bluecolor = QuadColor(Color(9, 47, 145, 255));

local mainDesktop;
local panel;
-- picturePanel
local picturePanel;
-- rewardPanel
local rewardPanel;
local loveListView;
--
local curPanel = 0;
local pictureList = {};
local rewardContent = {};
local callback;
local ctb;
local btnAchievement;
local navitimeCount = 0;
local isLoveType = true;
local isLoveType2 = true;
local guidereturn = false;

local isFinished = true;
local midRolePanel;
local loveRole;
local animationPanel;
local loveAnimationSound;
local curIndex = 0;

--=============================================================================================
function LovePanel:InitPanel(desktop)
	callback = nil;
	curPanel = 0;
	curIndex = 0;
	pictureList = {};
	rewardList = {};
	navitimeCount = 0;
	mainDesktop = desktop;
	loveAnimationSound = nil
	panel = desktop:GetLogicChild('lovePanel');
	panel:IncRefCount();
	self.loveStorySound = nil
	NetworkMsg_LoveTask:reqLoveTask();
	self:InitPicturepanel();
	self:InitRewardPanel();
end

function LovePanel:InitPicturepanel()
	picturePanel = panel:GetLogicChild('Panel');
	loveListView = picturePanel:GetLogicChild('listView');
	loveListView:SubscribeScriptedEvent('ListView::PageChangeEvent', 'LovePanel:refreshPictureList');
	self:InitCatPanel(picturePanel:GetLogicChild('catPanel'));
	for i = 1, 4 do
		local p = picturePanel:GetLogicChild('listView'):GetLogicChild(tostring(i));
		local img = p:GetLogicChild('img');
		local content1 = p:GetLogicChild('content1');
		local content2 = p:GetLogicChild('content2');
		local content3 = p:GetLogicChild('content3');
		local title		= p:GetLogicChild('title');
		local shader = img:GetLogicChild('shader');
		local opentalk = p:GetLogicChild('opentalk');
		opentalk.Pick = false;
		local plotBtn	= p:GetLogicChild('love_story');
		plotBtn:SubscribeScriptedEvent('Button::ClickEvent', 'LovePanel:onPlot');
		local atkBtn	= p:GetLogicChild('love_atk');
		atkBtn:SubscribeScriptedEvent('Button::ClickEvent', 'LovePanel:onReqCommit');
		local achieveBtn = p:GetLogicChild('achievement');
		achieveBtn:SubscribeScriptedEvent('Button::ClickEvent', 'LovePanel:onSwitch');
		table.insert(pictureList, {img = img, content1 = content1, content2 = content2, content3 = content3, title = title,
		opentalk = opentalk, plotBtn = plotBtn,atkBtn = atkBtn, shader = shader,achieveBtn = achieveBtn,});
	end
end

function LovePanel:InitRewardPanel()
	rewardPanel = panel:GetLogicChild('drawPanel');
	self:InitCatPanel(rewardPanel:GetLogicChild('catPanel'));
	local r = rewardPanel:GetLogicChild('reward');
	rewardContent.title = rewardPanel:GetLogicChild('title');
	rewardContent.hp = r:GetLogicChild('1'):GetLogicChild('num');
	rewardContent.atk = r:GetLogicChild('2'):GetLogicChild('num');
	rewardContent.mgc = r:GetLogicChild('3'):GetLogicChild('num');
	rewardContent.def = r:GetLogicChild('4'):GetLogicChild('num');
	rewardContent.res = r:GetLogicChild('5'):GetLogicChild('num');
	rewardContent.hpcount = r:GetLogicChild('1'):GetLogicChild('count');
	rewardContent.atkcount = r:GetLogicChild('2'):GetLogicChild('count');
	rewardContent.mgccount = r:GetLogicChild('3'):GetLogicChild('count');
	rewardContent.defcount = r:GetLogicChild('4'):GetLogicChild('count');
	rewardContent.rescount = r:GetLogicChild('5'):GetLogicChild('count');
	rewardContent.imgTip	= r:GetLogicChild('imgTip');
	rewardContent.headPanel	= rewardPanel:GetLogicChild('headPanel');
	rewardContent.headbg 	= rewardPanel:GetLogicChild('headPanel'):GetLogicChild('headbg');
	rewardContent.headbg.Image = GetPicture('home/head_frame_1.ccz');
	rewardContent.headIcon 	= rewardPanel:GetLogicChild('headPanel'):GetLogicChild('headbg'):GetLogicChild('haedIcon');
	r:GetLogicChild('1'):GetLogicChild('name').Text = LANG_lovePanel_1;
	r:GetLogicChild('2'):GetLogicChild('name').Text = LANG_lovePanel_2;
	r:GetLogicChild('3'):GetLogicChild('name').Text = LANG_lovePanel_3;
	r:GetLogicChild('4'):GetLogicChild('name').Text = LANG_lovePanel_4;
	r:GetLogicChild('5'):GetLogicChild('name').Text = LANG_lovePanel_5;
	rewardContent.privilege = r:GetLogicChild('privilege');
	rewardContent.privilege.Text = LANG_lovePanel_18;
	r:GetLogicChild('privilege1').Text = "";
	rewardContent.hp.Text = "0.0%";
	rewardContent.atk.Text = "0.0%";
	rewardContent.mgc.Text = "0.0%";
	rewardContent.def.Text = "0.0%";
	rewardContent.res.Text = "0.0%";
	rewardContent.hpcount.Text = "0";
	rewardContent.atkcount.Text = "0";
	rewardContent.mgccount.Text = "0";
	rewardContent.defcount.Text = "0";
	rewardContent.rescount.Text = "0";
end

function LovePanel:InitCatPanel(catPanel)
	local btnClose = catPanel:GetLogicChild('close');
	btnAchievement = catPanel:GetLogicChild('achievement');
	btnAchievement:SubscribeScriptedEvent('Button::ClickEvent', 'LovePanel:onSwitch');
	btnClose:SubscribeScriptedEvent('Button::ClickEvent', 'LovePanel:onClose');
end
--=============================================================================================
function LovePanel:Show()
	if UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) or UserGuidePanel:IsInGuidence(UserGuideIndex.love2, 1) then
		picturePanel:GetLogicChild('listView').Pick = false;
	end
	
	picturePanel:GetLogicChild('listView').ActivePageIndex = ActorManager:GetRole(self.pid).lvl.lovelevel == 4 and 3 or ActorManager:GetRole(self.pid).lvl.lovelevel;

	if LoveMaxPanel.isRefreshLovePic and LoveMaxPanel.roleList[1] then
		LoveMaxPanel.isRefreshLovePic = false;
		picturePanel:GetLogicChild('listView').ActivePageIndex = LoveMaxPanel.roleList[1].lvl.lovelevel;
	end

	ctb = CreateTextureBrush('background/love_book.ccz', 'background');
	picturePanel:GetLogicChild('bg').Background = ctb;
	rewardPanel:GetLogicChild('bg1').Background = ctb;
	self:moveIn();
	
	timerManager:CreateTimer(0.5, 'LovePanel:userGuide', 0, true);
end

function LovePanel:userGuide()
--	picturePanel:GetLogicChild('listView').ActivePageIndex = 3;
	local role = ActorManager:GetRole(self.pid);
	if role and role.lvl.lovelevel == 2 then
		if UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) and isLoveType then
			isLoveType = false;
			local guidebtn = picturePanel:GetLogicChild('listView'):GetLogicChild('3'):GetLogicChild('guidebtn');
			guidebtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'HomePanel:NaviClick');
			UserGuidePanel:ShowGuideShade(guidebtn,GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		elseif UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) then
			UserGuidePanel:ShowGuideShade(pictureList[3].atkBtn,GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		end
	elseif role and role.lvl.lovelevel == 3 then
		if UserGuidePanel:IsInGuidence(UserGuideIndex.love2, 1) then
			UserGuidePanel:ShowGuideShade(pictureList[4].atkBtn,GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		end
	end
end

function LovePanel:GetUserGuideBtn()
	return pictureList[4].achieveBtn;
end

function LovePanel:isShow()
	return panel.Visibility == Visibility.Visible;
end

function LovePanel:onShow(pid, cb)
	HomePanel:destroyRoleSound()
	self.pid = pid or 0;
	callback = cb;
	-- if LoveMaxPanel.isRefreshLovePic then
	self:Refresh();
	-- end
	MainUI:Push(self);
end

function LovePanel:Hide()
	ctb = nil;
	picturePanel:GetLogicChild('bg').Background = nil;
	rewardPanel:GetLogicChild('bg1').Background = nil;
	DestroyBrushAndImage('background/love_book.ccz', 'background');
	self:moveOut();
end

function LovePanel:onClose()
	if UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) or UserGuidePanel:IsInGuidence(UserGuideIndex.love2, 1) then  
		picturePanel:GetLogicChild('listView').Pick = false;
	end
	if CardDetailPanel.lovePanelSound then
		soundManager:DestroySource(CardDetailPanel.lovePanelSound);
		CardDetailPanel.lovePanelSound = nil
	end
	picturePanel:GetLogicChild('listView').ActivePageIndex = 0;
	MainUI:Pop();
	if callback then callback() end;
	callback = nil;
	if UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) and guidereturn then
		UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.love, 2);
		guidereturn = false;
	end
	if UserGuidePanel:IsInGuidence(UserGuideIndex.love2, 1) and guidereturn then
		UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.love2, 1);
		guidereturn = false;
	end
	if curPanel == 1 then
		LovePanel:onSwitch();
	end
	HomePanel:RoleShow();
end

function LovePanel:onForceClose()
	if self.isShow() then
		MainUI:Pop();
		callback = nil;
	end
end

function LovePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

function LovePanel:moveIn()
	panel.Visibility = Visibility.Visible;
	panel.Storyboard = 'storyboard.moveIn_1';
end

function LovePanel:moveOut()
	local board = panel:SetUIStoryBoard('storyboard.moveOut_1');
	board:SubscribeScriptedEvent('StoryboardInstance::FinishedEvent', "LovePanel:onHide");
end

function LovePanel:onHide()
	panel.Visibility = Visibility.Hidden;
end
--=============================================================================================
function LovePanel:Refresh()
	self:refreshPictureList();
	self:refreshReward();
end

function LovePanel:onSwitch()
	if curPanel == 0 then
		picturePanel.Visibility = Visibility.Hidden;
		rewardPanel.Visibility = Visibility.Visible;
		curPanel = 1;
		if UserGuidePanel:IsInGuidence(UserGuideIndex.love2, 1) then
			UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
			guidereturn = true;
		end
	else
		picturePanel.Visibility = Visibility.Visible;
		rewardPanel.Visibility = Visibility.Hidden;
		curPanel = 0;
	end
	self:refreshReward();
end

function LovePanel:onPlot(Args)
	if CardDetailPanel.lovePanelSound then
		soundManager:DestroySource(CardDetailPanel.lovePanelSound);
		CardDetailPanel.lovePanelSound = nil
	end
	local args = UIControlEventArgs(Args);
	local ltid = args.m_pControl.Tag;
	local role = ActorManager:GetRole(self.pid);
	self.plot_id = resTableManager:GetValue(ResTable.love_task, tostring(ltid), 'plot_id');
	TaskDialogPanel:LoveTaskDialog();
	SoundManager:PlayEffect('love_max')
end

function LovePanel:onReqCommit(Args)
	local args = UIControlEventArgs(Args);
	local ltid = args.m_pControl.Tag;
	isFinished = true;
	local taskData = resTableManager:GetRowValue(ResTable.love_task, tostring(ltid));
	LovePanel:checkLoveTask(ActorManager:GetRole(self.pid), taskData, 1);
	if isFinished then
		NetworkMsg_LoveTask:reqCommitLoveTask(ltid);
	end
end
--=============================================================================================
function LovePanel:refreshPictureList()
	local role = ActorManager:GetRole(self.pid);
	curIndex = loveListView.ActivePageIndex;
	local fill_picture = function(index)
		local id = role.resid * 100 + index;
		local taskData = resTableManager:GetRowValue(ResTable.love_task, tostring(id));
		pictureList[index].plotBtn.Tag = taskData['id'];
		pictureList[index].atkBtn.Tag = taskData['id'];
		pictureList[index].plotBtn.Visibility = Visibility.Visible;
		pictureList[index].atkBtn.Visibility = Visibility.Hidden;
		pictureList[index].opentalk.Visibility = Visibility.Visible;
		local isRunning = role.lvl.lovelevel == 0 or (index == role.lvl.lovelevel + 1 and role.lvl.lovelevel ~= self.MAX_LOVE_TASK_LEVEL);
		if index <= role.lvl.lovelevel then -- finished
			picturePanel:GetLogicChild(2):GetLogicChild(tostring(index)).Enable = true;
			picturePanel:GetLogicChild(2):GetLogicChild(tostring(index)):GetLogicChild(1).Visibility = index == role.lvl.lovelevel and Visibility.Visible or Visibility.Hidden;
			pictureList[index].title.Text = LANG_lovePanel_Title[index];
			pictureList[index].content1:RemoveAllChildren();
			pictureList[index].content2:RemoveAllChildren();
			pictureList[index].content3:RemoveAllChildren();
			pictureList[index].opentalk:RemoveAllChildren();
			local message = taskData['declaration_fo_marriage'];
			local i = 0;
			local startIndex, endIndex = string.find(message, '/n');
			while nil ~= startIndex do
				local text = string.sub(message, 1, startIndex - 1);
				if i == 0 then
					pictureList[index].opentalk:AddText(text, Bluecolor, uiSystem:FindFont('huakang_20_noborder'));
				else
					pictureList[index]["content" .. i]:AddText(text, Bluecolor, uiSystem:FindFont('huakang_20_noborder'));
				end
				message = string.sub(message, endIndex + 1, -1);
				startIndex, endIndex = string.find(message, '/n');
				i = i + 1;
			end

			if message then
				if i == 0 then
					pictureList[index].opentalk:AddText(message, Bluecolor, uiSystem:FindFont('huakang_20_noborder'));
				else
					pictureList[index]["content" .. i]:AddText(message, Bluecolor, uiSystem:FindFont('huakang_20_noborder'));
				end
			end
		elseif isRunning and LoveTask.allTasks[self.pid] and id == LoveTask.allTasks[self.pid].ltid then -- running
			picturePanel:GetLogicChild(2):GetLogicChild(tostring(index)).Enable = false;
			pictureList[index].title.Text = LANG_lovePanel_Title[index];
			pictureList[index].atkBtn.Enable = true;
			pictureList[index].plotBtn.Visibility = Visibility.Hidden;
			pictureList[index].atkBtn.Visibility = Visibility.Visible;
			pictureList[index].opentalk:RemoveAllChildren();
			pictureList[index].opentalk:AddText(taskData['open_talk'], Configuration.BlackColor, uiSystem:FindFont('huakang_20_noborder'));
			pictureList[index].opentalk.Visibility = Visibility.Visible;
			pictureList[index].content1:RemoveAllChildren();
			pictureList[index].content2:RemoveAllChildren();
			pictureList[index].content3:RemoveAllChildren();
			LovePanel:refreshTask(pictureList[index].content1, taskData, 1, role);
			LovePanel:refreshTask(pictureList[index].content2, taskData, 2, role);
			LovePanel:refreshTask(pictureList[index].content3, taskData, 3, role);
		else -- unopen
			picturePanel:GetLogicChild(2):GetLogicChild(tostring(index)).Enable = false;
			pictureList[index].opentalk:RemoveAllChildren();
			pictureList[index].content1:RemoveAllChildren();
			pictureList[index].content2:RemoveAllChildren();
			pictureList[index].content3:RemoveAllChildren();
			pictureList[index].title.Text = LANG_lovePanel_Title[index];
			pictureList[index].plotBtn.Visibility = Visibility.Hidden;
			pictureList[index].atkBtn.Visibility = Visibility.Visible;
			pictureList[index].opentalk.Visibility = Visibility.Visible;
			pictureList[index].atkBtn.Enable	= false;
			pictureList[index].img.ShaderType = IRenderer.UI_GrayShader;
			pictureList[index].opentalk:AddText(LANG_lovePanel_14, Configuration.BlackColor, uiSystem:FindFont('huakang_20_noborder'));
		end
		if role.lvl.lovelevel >= index or LoveTask:isComplete(taskData['id']) then
			pictureList[index].img.ShaderType = IRenderer.UI_NormalShader;
		end
	end
	fill_picture(1); fill_picture(2);
	fill_picture(3); fill_picture(4);
end

function LovePanel:refreshTask(curPanel, taskData, index, role)
	local haveCount = 0;
	if taskData['love_type' .. index] == -1 then
		return
	elseif taskData['love_type' .. index] == 3 then
		haveCount = Package:GetItemCount(taskData['value' .. index][1]);
		local label = uiSystem:CreateControl('Label');
		local itemData = resTableManager:GetRowValue(ResTable.item, tostring(taskData['value1'][1]));
		label.Text = tostring(itemData['name']);
		--label.Text = tostring(taskData['description' .. index]);
		label.TextAlignStyle = TextFormat.MiddleLeft;
		label:SetFont('huakang_20_noborder_underline');
		label.TextColor =  QuadColor(Color(20, 169, 164, 255));
		label.Horizontal = ControlLayout.H_CENTER;
		label.Vertical = ControlLayout.V_TOP;
		label.Size = Size(200,25);
		label.Tag = taskData['value' .. index][1];
		label.TagExt = taskData['value' .. index][2];
		label:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'LovePanel:onMaterialClick');	
		curPanel:AddUIControl(label);	
	elseif taskData['love_type' .. index] == 4 then
		haveCount = role.lovevalue;
		local label = uiSystem:CreateControl('Label');
		label.Text = tostring(taskData['description' .. index]);
		label.TextAlignStyle = TextFormat.MiddleLeft;
		label:SetFont('huakang_20_noborder_underline');
		label.TextColor = Bluecolor;
		label.Horizontal = ControlLayout.H_CENTER;
		label.Vertical = ControlLayout.V_TOP;
		label.Size = Size(200,25);	
		label:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'LovePanel:LoveValueTip');
		curPanel:AddUIControl(label);
	elseif taskData['love_type' .. index] == 5 then
		haveCount = role.naviClickNum1;
		local label = uiSystem:CreateControl('Label');
		label.Text = tostring(taskData['description' .. index]);
		label.TextAlignStyle = TextFormat.MiddleLeft;
		label:SetFont('huakang_20_noborder');
		label.TextColor = Bluecolor;
		label.Horizontal = ControlLayout.H_CENTER;
		label.Vertical = ControlLayout.V_TOP;
		label.Size = Size(200,25);	
		label:SetFont('huakang_20_noborder_underline');
		label.TextColor =  QuadColor(Color(20, 169, 164, 255));
		label:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'HomePanel:NaviClick');
		curPanel:AddUIControl(label);
	end
	curPanel:AppendText('(', Configuration.BlackColor, uiSystem:FindFont('huakang_18_noborder'));
	local needCount;
	if taskData['love_type' .. index] ~= 4 then
		needCount = taskData['value' .. index][2];
	else
		needCount = taskData['love_max'];
	end
	if haveCount >= needCount then
		curPanel:AppendText( tostring(haveCount), Configuration.GreenColor, uiSystem:FindFont('huakang_20_noborder'));
	else
		curPanel:AppendText( tostring(haveCount), Configuration.RedColor, uiSystem:FindFont('huakang_20_noborder'));
	end
	curPanel:AppendText('/' .. needCount .. ')', Configuration.BlackColor, uiSystem:FindFont('huakang_20_noborder'));
end
function LovePanel:LoveValueTip()
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_lovePanel_19);
end
function LovePanel:refreshReward()
	--print('LovePanel:refreshReward')
	self:InitRewardPanel()
	local role = ActorManager:GetRole(self.pid);
	local id = role.resid * 100 + (curIndex+1);

	local taskData = resTableManager:GetRowValue(ResTable.love_task, tostring(id));

	if taskData then
		local data = resTableManager:GetRowValue(ResTable.love_reward, tostring(taskData['love_reward_id']));
		rewardContent.title.Text = LANG_lovePanel_Title[curIndex+1];
		rewardContent.hp.Text = tostring(data['hp'] * 100 .. '%');
		rewardContent.hpcount.Text = tostring(math.ceil(role.pro.hp - role.pro.hp/(data['hp'] + 1)));
		rewardContent.atk.Text = tostring(data['atk'] * 100 .. '%');
		rewardContent.atkcount.Text = tostring(math.ceil(role.pro.attack - role.pro.attack/(data['atk'] + 1)));
		rewardContent.mgc.Text = tostring(data['mgc'] * 100 .. '%');
		rewardContent.mgccount.Text = tostring(math.ceil(role.pro.attack - role.pro.attack/(data['mgc'] + 1)));
		rewardContent.def.Text = tostring(data['def'] * 100 .. '%');
		rewardContent.defcount.Text = tostring(math.ceil(role.pro.def - role.pro.def/(data['def'] + 1)));
		rewardContent.res.Text = tostring(data['res'] * 100 .. '%');
		rewardContent.rescount.Text = tostring(math.ceil(role.pro.res - role.pro.res/(data['res'] + 1)));
		rewardContent.privilege.Text = string.format(LANG_lovePanel_8, math.floor(100-data['gold_cost_decreased']* 100));
	else
		rewardContent.title.Text = LANG_lovePanel_Title[1];
	end
	if role.lvl.lovelevel == self.MAX_LOVE_TASK_LEVEL then
		rewardContent.headPanel.Visibility = Visibility.Visible;
		rewardContent.imgTip.Visibility = Visibility.Visible;
		rewardContent.headbg.Visibility = Visibility.Visible;
		rewardContent.headIcon.Image = GetPicture('navi/' .. resTableManager:GetValue(ResTable.navi_main, tostring(10000 + role.resid), 'role_path_icon') .. '.ccz');
		local r = rewardPanel:GetLogicChild('bg'):GetLogicChild('LabelPanel');
		r:GetLogicChild('privilege1').Text = LANG_lovePanel_15;
	else
		rewardContent.imgTip.Visibility = Visibility.Hidden;
		rewardContent.headbg.Visibility = Visibility.Hidden;
		rewardContent.headPanel.Visibility = Visibility.Hidden;
	end
end

--获取培养折扣
function LovePanel:getGoldCostDecreased(roleInfo)
	local role = ActorManager:GetRole(roleInfo.pid);
	if not role then
		return 1;
	end
	local id = role.resid * 100 + role.lvl.lovelevel;	
	local taskData = resTableManager:GetRowValue(ResTable.love_task, tostring(id));
	if taskData then
		local data = resTableManager:GetRowValue(ResTable.love_reward, tostring(taskData['love_reward_id']));
		return tonumber(data['gold_cost_decreased']);
	else
		return 1;
	end
end
--=============================================================================================
function LovePanel:SetPid(pid)
	self.pid = pid;
end
--=============================================================================================


function LovePanel:ShowStroyPanel(loveid)
	local lovePanel = mainDesktop:GetLogicChild('LoveStoryPanel');
	lovePanel.Visibility = Visibility.Visible;
	local storyPanel = lovePanel:GetLogicChild('lovePanel');
	local textLabel = storyPanel:GetLogicChild('text');
	local taskData = resTableManager:GetRowValue(ResTable.love_task, tostring(loveid));
	textLabel.Text = taskData['letter'];
	local btn	= storyPanel:GetLogicChild('btn');
	storyPanel.Background= CreateTextureBrush('love/love_invite.ccz', 'background');
	--btn.Tag = loveid;
	--btn:SubscribeScriptedEvent('Button::ClickEvent', 'LovePanel:ShowPlot');
	lovePanel.Tag = loveid;
	lovePanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'LovePanel:ShowPlot');
	if UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) then
		UserGuidePanel:ShowGuideShade(lovePanel,GuideEffectType.hand,GuideTipPos.right, '', 0.3);
	end
	if UserGuidePanel:IsInGuidence(UserGuideIndex.love2, 1) then
		UserGuidePanel:ShowGuideShade(lovePanel,GuideEffectType.hand,GuideTipPos.right, '', 0.3);
	end
end


function LovePanel:checkLoveTask(role, taskData, tipflag)
	for index = 1,3 do
		local haveCount = 0;
		if taskData['love_type' .. index] == 3 then
			haveCount = Package:GetItemCount(taskData['value' .. index][1]);	
		elseif taskData['love_type' .. index]  == 4 then
			haveCount = role.lovevalue;
		elseif taskData['love_type' .. index]  == 5 then
			haveCount = role.naviClickNum1;
		end

		local needCount;
		if taskData['love_type' .. index] ~= 4 then
			needCount = taskData['value' .. index][2];
		else
			needCount = taskData['love_max'];
		end
		if (haveCount < tonumber(needCount)) and (tonumber(taskData['love_type' .. index]) ~= -1) then
			if tipflag then
				if taskData['love_type' .. index] == 3 then
					MessageBox:ShowDialog(MessageBoxType.Ok, '条件を満たしていません');
				elseif taskData['love_type' .. index] == 4 then
					MessageBox:ShowDialog(MessageBoxType.Ok, '信頼度が足りません');
				elseif taskData['love_type' .. index] == 5 then
					mainDesktop:GetLogicChild('loveTipsPanel').Visibility = Visibility.Visible;
				end
			end	
			isFinished = false;
			return false;
		end
	end
	return true;
end

function LovePanel:IsRoleCanAttack(role)
	if role.lvl.lovelevel == self.MAX_LOVE_TASK_LEVEL then
		return false
	else
		local id = role.resid * 100 + role.lvl.lovelevel + 1;
		local taskData = resTableManager:GetRowValue(ResTable.love_task, tostring(id));
		return LovePanel:checkLoveTask(role, taskData, false)
	end
end

function LovePanel:LoveTipPanelClick()
	mainDesktop:GetLogicChild('loveTipsPanel').Visibility = Visibility.Hidden;

end

function LovePanel:ShowPlot(Args)
	TaskDialogPanel.loveComplete = true
	mainDesktop:GetLogicChild('LoveStoryPanel').Visibility = Visibility.Hidden;
	local args = UIControlEventArgs(Args);
	local ltid = args.m_pControl.Tag;
	self.love_stage = tonumber(resTableManager:GetValue(ResTable.love_task, tostring(ltid), 'stage'));
	self.plot_id = resTableManager:GetValue(ResTable.love_task, tostring(ltid), 'plot_id');
	TaskDialogPanel:LoveTaskDialog();
	SoundManager:PlayEffect('love_max')
end

function LovePanel:naviClick(naviEnventId, x, y)
--	local taskInfo = resTableManager:GetRowValue(ResTable.love_task, tostring(naviEnventId));
--	for index = 1,3 do
--		if taskInfo and taskInfo['love_type' .. index]  == 5 and naviEnventId % 100 == taskInfo['value' .. index][1] then
			navitimeCount = navitimeCount + 1;
			Network:Send(NetworkCmdType.req_naviclicknum_add, {naviId = naviEnventId;});
			mainDesktop:GetLogicChild('lovetaskTipPanel'):GetLogicChild('tips').Text = 'スキンシップ +1';
			mainDesktop:GetLogicChild('lovetaskTipPanel').Visibility = Visibility.Visible;
			mainDesktop:GetLogicChild('lovetaskTipPanel').Horizontal = ControlLayout.H_CENTER;
			mainDesktop:GetLogicChild('lovetaskTipPanel').Vertical = ControlLayout.V_CENTER;
			mainDesktop:GetLogicChild('lovetaskTipPanel').Margin = Rect(0,0,0,0);
			timerManager:CreateTimer(1, 'LovePanel:hideLoveTipsPanel', 0, true);
--		end
--	end	
end

function LovePanel:hideLoveTipsPanel()
	navitimeCount = navitimeCount - 1;
	if navitimeCount == 0 then
		mainDesktop:GetLogicChild('lovetaskTipPanel').Visibility = Visibility.Hidden;
	end
end

--爱恋物品tip
function LovePanel:onMaterialClick( Args )
	local args = UIControlEventArgs(Args);

	if args.m_pControl.Tag == 0 then
		return;
	end

	local item = {};
	item.resid = args.m_pControl.Tag;

	local itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');
	TooltipPanel:setNeedAndHaveNum( args.m_pControl.TagExt, Package:GetItemCount( item.resid ));
	TooltipPanel:ShowItem(panel, item, TipMaterialShowButton.Obtain);
--	end	
end
function LovePanel:loveSound(resid)
	local soundName = resTableManager:GetValue(ResTable.actor,tostring(resid),'love_voice')
	if soundName then
		self.loveStorySound = SoundManager:PlayVoice( tostring(soundName))
	end
end
function LovePanel:showAnimation()

	loveRole = ActorManager:GetRole(self.pid);
	local roleInfo
	if loveRole then 
		local roleid = loveRole.resid;
		roleInfo = resTableManager:GetValue(ResTable.navi_main, tostring(roleid), 'role_path');
	end
	
	animationPanel = uiSystem:CreateControl('Panel')
	animationPanel.ZOrder = 1000
	animationPanel.Horizontal = ControlLayout.H_STRETCH;
	animationPanel.Vertical = ControlLayout.V_STRETCH;
	animationPanel.Background = Converter.String2Brush("EidolonSystem.Black")
	animationPanel.Visibility = Visibility.Visible
	
	midRolePanel = uiSystem:CreateControl('ImageElement')
	midRolePanel.Image = GetPicture('navi/' .. roleInfo..'.ccz')
	midRolePanel.Horizontal = ControlLayout.H_CENTER;
	midRolePanel.Vertical = ControlLayout.V_BOTTOM;
	midRolePanel.ZOrder = 0
	animationPanel:AddChild(midRolePanel)
	
	armatureFront = uiSystem:CreateControl('ArmatureUI')
	armatureFront:LoadArmature('cardupgrade');
	armatureFront:SetScale(2,2)
	armatureFront:SetAnimation('play1')
	armatureFront:SetScriptAnimationCallback('LovePanel:ArmatrueFrontEnd',0)
	armatureFront.Horizontal = ControlLayout.H_CENTER;
	armatureFront.Vertical = ControlLayout.V_CENTER;
	armatureFront.ZOrder = 1
	animationPanel:AddChild(armatureFront)
	loveAnimationSound = SoundManager:PlayEffect( 'v1100' )
	mainDesktop:AddChild(animationPanel)
end

function LovePanel:ArmatrueFrontEnd(armature)

	if armature:GetAnimation() == 'play1' then
		if self.love_stage == 4 then
			armature:SetAnimation('play3');
		else
			armature:SetAnimation('play2');
		end
		armature:SetScriptAnimationCallback('LovePanel:ArmatrueAfterEnd',0)
	end

	local roleInfo
	if loveRole then
		if loveRole.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
			local roleid = loveRole.resid+10000;
			roleInfo = resTableManager:GetValue(ResTable.navi_main, tostring(roleid), 'bg_path');
		else
			local roleid = loveRole.resid;
			roleInfo = resTableManager:GetValue(ResTable.navi_main, tostring(roleid), 'bg_path');
		end
	end
	midRolePanel.Size = Size(1136,640)
	midRolePanel.AutoSize = false
	midRolePanel.Image = GetPicture('navi/' .. roleInfo..'.jpg')
	--背景
	HomePanel:setNaviInfo(loveRole)
end

function LovePanel:ArmatrueAfterEnd(armature)
	if loveAnimationSound then
		soundManager:DestroySource(loveAnimationSound);
		loveAnimationSound = nil
	end
	
	if animationPanel ~= nil then
		mainDesktop:RemoveChild(animationPanel)
		animationPanel = nil
	end
	if UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) then
	--	UserGuidePanel:ShowGuideShade(LovePanel:GetUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		guidereturn = true;
	end

	if UserGuidePanel:IsInGuidence(UserGuideIndex.love2, 1) then
		UserGuidePanel:ShowGuideShade(LovePanel:GetUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		guidereturn = true;
	end

	picturePanel:GetLogicChild('listView').ActivePageIndex = ActorManager:GetRole(self.pid).lvl.lovelevel == 4 and 3 or ActorManager:GetRole(self.pid).lvl.lovelevel;
end
