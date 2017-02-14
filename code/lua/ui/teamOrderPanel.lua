--teamOrderPanel.lua
--======================================================================================
--排列出战队列面板

TeamOrderPanel = 
	{
		inTeamList 		= {};			--在队列内的角色
		inFellowList 	= {};			--小伙伴角色
		btnTrain		= nil;			--训练场按钮
	};
	
--变量
local mouseDownPosition;
local isMouseDown = false;
local roleCount = 0;			   		--伙伴个数
local pageCount = 0;               		--伙伴页数
local currentPage = 1;					--伙伴当前页
local MaxItemCount	= 6;		   	 	--一页包含的伙伴数量
local isTeamChange = false;				--队伍是否变化
local isFirstShow = true;				--是否第一次显示
local fateOpenMap = {};					--队伍中已经开启的命运

--控件
local mainDesktop;
local panel;
local tabControl;
local teamPage;
local fellowPage;
local labelFightAbility;
local rolePanelList = {};
local fellowPanelList = {};
local fatePanelList = {};
local partnerListPanel;
local partnerList = {};
local btnLeftPage;
local btnRightPage;
local guideShade;
local btnClose;
local background;
local labelTeamCount;
local labelFellowCount;
	

--初始化panel
function TeamOrderPanel:InitPanel(desktop)
	--变量初始化
	self.inTeamList = {};				--在队列内的角色
	mouseDownPosition = Vector2(0, 0);
	isMouseDown = false;
	roleCount = 0;			   			--伙伴个数
	pageCount = 0;               		--伙伴页数
	currentPage = 1;					--伙伴当前页
	MaxItemCount = 6;		   	 		--一页包含的伙伴数量	
	isTeamChange = false;				--队伍是否变化
	rolePanelList = {};
	fellowPanelList = {};
	partnerList = {};

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('teamOrderPanel'));
	panel:IncRefCount();
	
	tabControl	= TabControl(panel:GetLogicChild('tabControl'));
	teamPage	= TabPage(tabControl:GetLogicChild('1'));
	fellowPage	= TabPage(tabControl:GetLogicChild('2'));
	
	self.btnTrain = teamPage:GetLogicChild('xunlianchang');
	
	local teamPanel = Panel(panel:GetLogicChild('team'));
	partnerListPanel = Panel(teamPanel:GetLogicChild('partnerList'));
	btnLeftPage = Button(teamPanel:GetLogicChild('leftPage'));
	btnRightPage = Button(teamPanel:GetLogicChild('rightPage'));
	labelFightAbility = Label(panel:GetLogicChild('zhandouli'));
	btnClose = Button(panel:GetLogicChild('close'));
	labelTeamCount = Label(panel:GetLogicChild('emptyTeamCount'));
	labelFellowCount = Label(panel:GetLogicChild('emptyFellowCount'));
	--background = panel:GetLogicChild('background'):GetLogicChild('background');
	
	--新手引导使用
	guideShade = BrushElement(teamPage:GetLogicChild('guideShade'));
	local cpanel = teamPage:GetLogicChild('roleChildPanel');
	for index = 1, 5 do
		local userControl = UserControl(cpanel:GetLogicChild(tostring(index)));
		local controlList = {};
		local template = userControl:GetLogicChild('roleInTeamTemplate');
		controlList.template = template;
		controlList.avatureRole = ArmatureUI(template:GetLogicChild('role'));
		controlList.labelName = Label(template:GetLogicChild('name'));
		controlList.brushLock = BrushElement(template:GetLogicChild('lock'));
		controlList.labelIndex = Label(template:GetLogicChild('index'));
		controlList.labelUnLock = Label(template:GetLogicChild('unlock'));
		controlList.arrow = ArmatureUI(template:GetLogicChild('arrow'));
		controlList.fatePanel = BrushElement(template:GetLogicChild('fate'));
		controlList.fateList = {};
		for i = 1, 4 do
			table.insert(controlList.fateList, Label(controlList.fatePanel:GetLogicChild('fate' .. i)))
		end
		
		
		--初始化显示控件
		controlList.avatureRole.Visibility	= Visibility.Hidden;
		controlList.labelName.Visibility 	= Visibility.Hidden;		
		controlList.brushLock.Visibility 	= Visibility.Visible;
		controlList.labelIndex.Visibility 	= Visibility.Visible;
		controlList.labelUnLock.Visibility 	= Visibility.Hidden;
		controlList.arrow.Visibility 		= Visibility.Hidden;
		controlList.fatePanel.Visibility 	= Visibility.Hidden;
		
		--显示角色形象
		controlList.arrow.Skew = Vector2(90,90);
		controlList.arrow.Translate = Vector2(10, 0);	
		controlList.arrow:LoadArmature('jiantou');
		controlList.arrow:SetAnimation('play');
		
		--设置属性
		controlList.labelIndex.Text = tostring(index);
		controlList.template.Tag = index;								--设置阵型位置
		--添加响应事件
		controlList.template:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TeamOrderPanel:onRoleInTeamClick');
		
		table.insert(rolePanelList, controlList);
	end
	
	
	local fellowListPanel = fellowPage:GetLogicChild('fellowList');
	for index = 1, 6 do
		local userControl = UserControl(fellowListPanel:GetLogicChild(tostring(index)));
		local controlList = {};
		local template = userControl:GetLogicChild('fellowInTeamTemplate');
		controlList.template = template;
		controlList.itemImage = ItemCell(template:GetLogicChild('image'));
		controlList.imageJob = ImageElement(template:GetLogicChild('job'));
		controlList.labelName = Label(template:GetLogicChild('name'));
		controlList.ImageInFellow = ImageElement(template:GetLogicChild('inFellow'));
		controlList.labelLevel = Label(template:GetLogicChild('level'));
		
		--设置属性
		controlList.labelLevel.Text = 'Lv' .. self:getFellowOpenLevel(index) .. LANG_teamOrderPanel_7;
		controlList.template.Tag = index;								--设置阵型位置
		--添加响应事件
		controlList.template:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TeamOrderPanel:onFellowInTeamClick');
		
		table.insert(fellowPanelList, controlList);
	end
	
	local roleFateList = fellowPage:GetLogicChild('fateScrollPanel'):GetLogicChild('roleFateList');
	for index = 1, 4 do
		local fatePanel = StackPanel(roleFateList:GetLogicChild('role' .. index));
		table.insert(fatePanelList, fatePanel);
	end
	
	
	partnerListPanel.TagExt = DragDropGroup.leaveTeamPanel;
	for index = 1, 6 do
		local radioButton = RadioButton(partnerListPanel:GetLogicChild(tostring(index)));
		radioButton.GroupID = RadionButtonGroup.selectTeamHuoBan;
		radioButton.TagExt = DragDropGroup.leaveTeam;
		--添加响应事件
		radioButton:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'TeamOrderPanel:onRoleClick');	
		table.insert(partnerList, radioButton);
	end
	
	--隐藏
	panel.Visibility = Visibility.Hidden;
end

--销毁
function TeamOrderPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function TeamOrderPanel:Show()
	
	--记录老战斗力
	ActorManager.oldFP = ActorManager.user_data.fp;
	
	roleCount = 1 + #(ActorManager.user_data.partners);
	pageCount = math.ceil(roleCount / MaxItemCount);

	currentPage = 1;	--始终显示第一页
	self:refreshRoles();
	
	--设置背景
	teamPage.Background = CreateTextureBrush('background/duiwu_bg.ccz', 'godsSenki', Rect(0,0,604,235));
	
	self:refreshPageChangeButton();

	self:refresh();
	
	if isFirstShow then
		isFirstShow = false;
	end
	
	tabControl.ActiveTabPageIndex = 0;

	mainDesktop:DoModal(panel);	
	
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI2, nil, 'TeamOrderPanel:onUserGuid');	
end

function TeamOrderPanel:refresh()
	--刷新队伍
	self:refreshTeamRole();
	--刷新小伙伴
	self:refreshInTeamFellow();
	--刷新战斗力
	self:refreshTotalFightPoint();
	--刷新伙伴列表
	self:refreshRoleInTeamFlag();
	--刷新命运显示
	self:refreshRoleFateInTeam();
	--刷新命运列表
	self:refreshFateList();
	
	self:refreshCount();
end


function TeamOrderPanel:refreshCount()
	local teamCount = self:GetEmptyTeamCount();
	local fellowCount = self:GetEmptyFellowCount();
	if teamCount == 0 then
		labelTeamCount.Visibility = Visibility.Hidden;
	else
		labelTeamCount.Visibility = Visibility.Visible;
		labelTeamCount.Text = tostring(teamCount);
	end
	
	if fellowCount == 0 then
		labelFellowCount.Visibility = Visibility.Hidden;
	else
		labelFellowCount.Visibility = Visibility.Visible;
		labelFellowCount.Text = tostring(fellowCount);
	end
end

--打开时的新手引导
function TeamOrderPanel:onUserGuid()
	local taskid = Task:getMainTaskId();
	if taskid == SystemTaskId.team then
		--向服务器发送统计数据
		NetworkMsg_GodsSenki:SendStatisticsData(taskid, 3);
		
		UserGuidePanel:ShowGuideShade(guideShade, GuideEffectType.handMove, GuideTipPos.right, LANG_teamOrderPanel_1);	
	elseif taskid == SystemTaskId.team2 then
		UserGuidePanel:ShowGuideShade(guideShade, GuideEffectType.handMove2, GuideTipPos.right, LANG_teamOrderPanel_2);
	end
end

--隐藏
function TeamOrderPanel:Hide()
	
	--战斗力改变
	ActorManager:UpdateFightAbility();
	--GemPanel:totleFp();
	FightPoint:ShowFP(ActorManager.user_data.fp - ActorManager.oldFP);
	ActorManager.oldFP = ActorManager.user_data.fp;
	
	for index = 1, 5 do
		rolePanelList[index].avatureRole:Destroy();
	end
	
	self:RemoveAllRole();
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI2, 'StoryBoard::OnPopUI');
		
	--销毁背景图片
	teamPage.Background = nil;
	DestroyBrushAndImage('background/duiwu_bg.ccz', 'godsSenki');
	
	--触发回收显存事件
	EventManager:FireEvent(EventType.RecoverDisplayMemory);
	
end

--界面显示
function TeamOrderPanel:IsVisible()
	return panel:IsVisible();
end

--=====================================================================================
--功能函数

--刷新队伍中角色
function TeamOrderPanel:refreshTeamRole()
	local count = self:getPositionCount();
	for index = 1, 5 do
		if index <= count then
			if (ActorManager.user_data.team[index] > -1) then	
				--该位置上有角色
				self:showRoleInTeam(self.inTeamList[ActorManager.user_data.team[index]], index);
			else
				--该位置上无角色
				self:showEmptyPosition(index);
				ActorManager.user_data.team[index] = -1;
			end	
			--设置该位置上的角色可拖拽
			rolePanelList[index].template.TagExt = DragDropGroup.joinInTeam;
			rolePanelList[index].labelUnLock.Visibility = Visibility.Hidden;
		else
			if (count + 1) == index then
				rolePanelList[index].labelUnLock.Text = self:getOpenLevel(count + 1) .. LANG_teamOrderPanel_3;
				rolePanelList[index].labelUnLock.Visibility = Visibility.Visible;
			else
				rolePanelList[index].labelUnLock.Visibility = Visibility.Hidden;
			end
			ActorManager.user_data.team[index] = -2;
		end
	end
end	

--刷新小伙伴阵中角色
function TeamOrderPanel:refreshInTeamFellow()
	local count = self:getFellowOpenCount();
	for index = 1, 6 do
		if index <= count then
			if (ActorManager.user_data.fellow[index] > -1) then
				--该位置上有角色
				local actor = self.inFellowList[ActorManager.user_data.fellow[index]].role;		
				fellowPanelList[index].labelName.Text = actor.name;
				fellowPanelList[index].labelName.TextColor = QualityColor[actor.rare];			
				fellowPanelList[index].imageJob.Image = actor.jobIcon;			
				fellowPanelList[index].itemImage.Background = Converter.String2Brush( RoleQualityType[actor.rare] );
				fellowPanelList[index].itemImage.Image = GetPicture('navi/' .. actor.headImage .. '.ccz');
				
				fellowPanelList[index].labelName.Visibility = Visibility.Visible;
				fellowPanelList[index].imageJob.Visibility = Visibility.Visible;
				fellowPanelList[index].itemImage.Visibility = Visibility.Visible;
				fellowPanelList[index].ImageInFellow.Visibility = Visibility.Visible;
				fellowPanelList[index].template.Background = Converter.String2Brush('godsSenki.duiwu_kuang1');
				
			else
				--该位置上无角色
				fellowPanelList[index].labelName.Visibility = Visibility.Hidden;
				fellowPanelList[index].imageJob.Visibility = Visibility.Hidden;
				fellowPanelList[index].itemImage.Visibility = Visibility.Hidden;
				fellowPanelList[index].ImageInFellow.Visibility = Visibility.Hidden;
				fellowPanelList[index].template.Background = Converter.String2Brush('godsSenki.duiwu_kuang2');
				ActorManager.user_data.fellow[index] = -1;
			end	
			--设置该位置上的角色可拖拽
			fellowPanelList[index].template.TagExt = DragDropGroup.joinInFellow;
			fellowPanelList[index].labelLevel.Visibility = Visibility.Hidden;
		else
			--该位置没开放		
			fellowPanelList[index].labelName.Visibility = Visibility.Hidden;
			fellowPanelList[index].imageJob.Visibility = Visibility.Hidden;
			fellowPanelList[index].itemImage.Visibility = Visibility.Hidden;
			fellowPanelList[index].ImageInFellow.Visibility = Visibility.Hidden;
			fellowPanelList[index].labelLevel.Visibility = Visibility.Visible;
			fellowPanelList[index].template.Background = Converter.String2Brush('godsSenki.duiwu_kuang3');
			ActorManager.user_data.fellow[index] = -2;
		end
	end
end

--显示阵型中的角色，roleItem为inTeamList的元素，index为在阵型中的位置
function TeamOrderPanel:showRoleInTeam(roleItem, index)
	
	--显示和隐藏相关控件
	rolePanelList[index].brushLock.Visibility 		= Visibility.Hidden;
	rolePanelList[index].arrow.Visibility 			= Visibility.Hidden;
	rolePanelList[index].labelName.Visibility 		= Visibility.Visible;		
	rolePanelList[index].avatureRole.Visibility 	= Visibility.Visible;
	
	rolePanelList[index].labelName.Text = roleItem.role.name;
	rolePanelList[index].labelName.TextColor = QualityColor[roleItem.role.rare];
	
	--显示角色形象
	local path = GlobalData.AnimationPath .. resTableManager:GetValue(ResTable.actor, tostring(roleItem.role.resid), 'path') .. '/';
	AvatarManager:LoadFile(path);
	rolePanelList[index].avatureRole:LoadArmature(roleItem.role.actorForm);
	rolePanelList[index].avatureRole:SetAnimation(AnimationType.f_idle);

	--加载翅膀
	local wingData = roleItem.role.wings;
	if (wingData ~= nil) and (#wingData > 0) then
		AddWingsToUIActor(rolePanelList[index].avatureRole, wingData[1].resid);
	end 

end

--刷新阵中人物命运
function TeamOrderPanel:refreshRoleFateInTeam( )
	local lastOpenMap = fateOpenMap;
	fateOpenMap = {};

	for index = 1, 5 do
		if (ActorManager.user_data.team[index] > -1) then
			local roleItem = self.inTeamList[ActorManager.user_data.team[index]];
			rolePanelList[index].fatePanel.Visibility = Visibility.Visible;
			local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(roleItem.role.resid));
			local fateIdList = {};
			for i = 1, 4 do
				local id = actorData['destiny' .. i];		
				table.insert(fateIdList, id);
			end
			local fateCount = 0;
			for i = 1, 4 do
				local fateId = fateIdList[i];
				if fateId == 0 then
					rolePanelList[index].fateList[i].Visibility = Visibility.Hidden;
				else
					rolePanelList[index].fateList[i].Visibility = Visibility.Visible;
					local fateData = resTableManager:GetRowValue(ResTable.destiny, tostring(fateId));
					rolePanelList[index].fateList[i].Text = fateData['name'];
					if self:isFateOpen( fateId) then
						if lastOpenMap['' .. roleItem.role.resid .. fateId] ~= true and not isFirstShow then
							self:AddFateToast(roleItem.role, fateId);
						end
						--人物ID和命运ID拼接作为Key保存开启的命运状态
						fateOpenMap['' .. roleItem.role.resid .. fateId] = true;
						rolePanelList[index].fateList[i].TextColor = QualityColor[fateData['rare']];						
					else
						rolePanelList[index].fateList[i].TextColor = Configuration.GrayColor;
					end
					
					fateCount = fateCount + 1;
				end
			end
			if fateCount <=2 then
				rolePanelList[index].fatePanel.Size = Size(158, 32);
			else
				rolePanelList[index].fatePanel.Size = Size(158, 51);
			end
			
		end
	end
end

--显示小伙伴中命运列表
function TeamOrderPanel:refreshFateList( )
	local uiCount = 0;
	for index = 1,5 do
		local actorPid = ActorManager.user_data.team[index];
		if actorPid ~= 0 then
			uiCount = uiCount + 1;
			if actorPid > -1 then
			fatePanelList[uiCount].Visibility = Visibility.Visible;
			self:showRoleFate( fatePanelList[uiCount], self.inTeamList[actorPid].role);
			else
				fatePanelList[uiCount].Visibility = Visibility.Hidden;
			end
		end
		
	end
end

function TeamOrderPanel:showRoleFate( panel, role)
	local labelName = Label( panel:GetLogicChild('header'):GetLogicChild('name') );
	labelName.Text = role.name;
	labelName.TextColor = QualityColor[role.rare];
	local fateList = {};
	for i = 1, 4 do
		local fateInfo = RichTextBox(panel:GetLogicChild(tostring(i)));
		table.insert(fateList, fateInfo);
	end
	local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(role.resid));	
	local fateIdList = {};
	for i = 1, 4 do
		local id = actorData['destiny' .. i];		
		table.insert(fateIdList, id);
	end
	
	local font = uiSystem:FindFont('huakang_20');	
	
	for i = 1, 4 do
		local fateId = fateIdList[i];
		if fateId == 0 then
			fateList[i].Visibility = Visibility.Hidden;
		else
			fateList[i].Visibility = Visibility.Visible;
			fateList[i]:Clear();
			local fateData = resTableManager:GetRowValue(ResTable.destiny, tostring(fateId));
			local color;
			if not TeamOrderPanel:isFateOpen( fateId) then
				color = Configuration.GrayColor;
			else
				color = QualityColor[fateData['rare']];
			end

			fateList[i]:AppendText(fateData['name'] .. '：', color, font);
			fateList[i]:AppendText(LANG_teamOrderPanel_8, QuadColor(Color.White), font);	
			
			local anyHeroCount = 0;		--任意英雄个数			
			local heroId;
			local heroName;
			local isFirst = true;
			for index = 1,5 do
				heroId = fateData['hero' .. index];	
				--触发英雄与该英雄相同时不处理
				if heroId ~= role.resid then
					if heroId == -1 then
						anyHeroCount = anyHeroCount + 1;
					elseif heroId ~= 0 then
						if not isFirst then
							fateList[i]:AppendText('、', QuadColor(Color.White), font);
						end
						isFirst = false;
						heroData = resTableManager:GetRowValue(ResTable.actor, tostring(heroId));
						if not TeamOrderPanel:isInTeamById(heroId) then
							fateList[i]:AppendText(heroData['name'], Configuration.GrayColor, font);
						else
							fateList[i]:AppendText(heroData['name'], QualityColor[heroData['rare']], font);
						end
						
						
					end
				end
			end
			
			if anyHeroCount >= 2 then
				--按规则减1
				anyHeroCount = anyHeroCount - 1;
				if not isFirst then				
					fateList[i]:AppendText('、', QuadColor(Color.White), font);
				end
				isFirst = false;
				fateList[i]:AppendText(LANG_teamOrderPanel_9 .. anyHeroCount ..LANG_teamOrderPanel_10, QuadColor(Color.White), font);
			end
			
			fateList[i]:AppendText(LANG_teamOrderPanel_11, QuadColor(Color.White), font);
			local fateEffect = fateData['effect'];
			if fateEffect == 1  and actorData['job'] == JobType.magician then
				fateEffect = 8;
			end
			fateList[i]:AppendText(FatePropertyTypeName[fateEffect] .. '+', QuadColor(Color.White), font);
			fateList[i]:AppendText(tostring(math.floor(fateData['effect_value'] * 100)) .. '%', QuadColor(Color.White), font);
			fateList[i]:ForceLayout();
			if fateList[i]:GetLogicChildrenCount() <= 1 then
				fateList[i].Height = 27;
			else
				fateList[i].Height = 51;
			end
		end
	end
end

--浮动文字提示
function TeamOrderPanel:AddFateToast(role, fateId)
	local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(role.resid));
	local fateData = resTableManager:GetRowValue(ResTable.destiny, tostring(fateId));
	local fateEffect = fateData['effect'];
	if fateEffect == 1  and actorData['job'] == JobType.magician then
		fateEffect = 8;
	end
	local propStr = FatePropertyTypeName[fateEffect] .. '+' .. math.floor(fateData['effect_value'] * 100) .. '%'
	ToastMove:CreateToast( role.name, QualityColor[role.rare], LANG_teamOrderPanel_4, nil, fateData['name'], QualityColor[fateData['rare']], propStr, nil );
end

--该命运是否开启
function TeamOrderPanel:isFateOpen(fateId)
	local roleIdMap = {};
	if self.inTeamList == nil or #self.inTeamList == 0 then
		self:filterInTeamRoles();
	end
	for index = 1, 5 do
		if (ActorManager.user_data.team[index] > -1) then
			local roleItem = self.inTeamList[ActorManager.user_data.team[index]];
			roleIdMap[roleItem.role.resid] = true;
		end
	end
	
	for index = 1, 6 do
		if (ActorManager.user_data.fellow[index] > -1) then
			local roleItem = self.inFellowList[ActorManager.user_data.fellow[index]];
			roleIdMap[roleItem.role.resid] = true;
		end
	end
	
	local teamCount = self:GetTeamCount();
	local fellowCount = self:GetFellowCount();

	local fateData = resTableManager:GetRowValue(ResTable.destiny, tostring(fateId));
	local fateCount = 0;
	local isHeroNoInTeam = false;
	for i = 1, 5 do
		local heroid = fateData['hero' .. i];
		if heroid == -1 then
			fateCount = fateCount + 1;
		elseif heroid ~= 0 then
			--人物不在队伍中
			if not roleIdMap[heroid] then
				isHeroNoInTeam = true;
			end
		end
	end
	if (fateCount > 0 and teamCount + fellowCount >= fateCount) or (fateCount == 0 and not isHeroNoInTeam) then
		return true;
	else
		return false;
	end
end

--该英雄是否在队伍和小伙伴中
function TeamOrderPanel:isInTeamById(resid)
	local roleIdMap = {};
	if self.inTeamList == nil or #self.inTeamList == 0 then
		self:filterInTeamRoles();
	end
	for index = 1, 5 do
		if (ActorManager.user_data.team[index] > -1) then
			local roleItem = self.inTeamList[ActorManager.user_data.team[index]];
			if roleItem.role.resid == resid then
				return true;
			end
		end
	end
	
	for index = 1, 6 do
		if (ActorManager.user_data.fellow[index] > -1) then
			local roleItem = self.inFellowList[ActorManager.user_data.fellow[index]];
			if roleItem.role.resid == resid then
				return true;
			end
		end
	end

	return false;
end

--设置空位置，index为角色在阵型的位置
function TeamOrderPanel:showEmptyPosition(index)
	rolePanelList[index].arrow.Visibility 		= Visibility.Visible;
	rolePanelList[index].brushLock.Visibility 	= Visibility.Hidden;
	rolePanelList[index].labelName.Visibility 	= Visibility.Hidden;
	rolePanelList[index].avatureRole.Visibility	= Visibility.Hidden;
	rolePanelList[index].avatureRole:Destroy();
	rolePanelList[index].fatePanel.Visibility = Visibility.Hidden;
end

--下阵,index为角色在阵型的位置
function TeamOrderPanel:LeaveTeam(index)
	local actorPid = ActorManager.user_data.team[index];						--角色pid
	ActorManager.user_data.team[index] = -1;									--设置Team表该位置上的pid为-1，代表该位置无角色
	self.inTeamList[actorPid].role.teamIndex = -1;								--设置角色在阵型中的位置为-1，代表不在阵型中		
	self.inTeamList[actorPid] = nil;
	
	self:refresh();

	--命运系统会改变属性值，这边要通知服务器
	isTeamChange = true;
	self:onSendTeamChange();
end

--上阵,index为左侧头像列表下标。 teamIndex为角色要排到的阵型位置
function TeamOrderPanel:JoinInTeam(index, teamIndex)
	--显示上阵
	local role = self:getRoleFromRoleList(index);
	self.inTeamList[role.pid] = {role = role, index = index};	
	--设置角色和阵型的属性
	role.teamIndex = teamIndex;													--角色在阵型中的位置
	ActorManager.user_data.team[teamIndex] = role.pid;
	self:refresh();

	--新手引导显示下一个遮罩
	local taskid = Task:getMainTaskId();
	if taskid == SystemTaskId.team then
		UserGuidePanel:ShowGuideShade(btnClose, GuideEffectType.hand, GuideTipPos.left, LANG_teamOrderPanel_5, 0.35);
	elseif taskid == SystemTaskId.team2 then
		UserGuidePanel:ShowGuideShade(btnClose, GuideEffectType.hand, GuideTipPos.left, LANG_teamOrderPanel_5, 0.35);
	end
	
	--命运系统会改变属性值，这边要通知服务器
	isTeamChange = true;
	self:onSendTeamChange();
end

--上阵,index为左侧头像列表下标。 teamIndex为角色要排到的阵型位置, 小伙伴中下阵
function TeamOrderPanel:JoinInTeamFromFellow(index, teamIndex)
	--print('----JoinInTeamFromFellow--index:' .. index .. ' teamIndex:' .. teamIndex);
	--队伍上阵
	local role = self:getRoleFromRoleList(index);
	self.inTeamList[role.pid] = {role = role, index = index};
	--设置角色和阵型的属性
	role.teamIndex = teamIndex;			--角色在阵型中的位置
	ActorManager.user_data.team[teamIndex] = role.pid;
	
	--小伙伴下阵
	ActorManager.user_data.fellow[role.fellowIndex] = -1;
	self.inFellowList[role.pid] = nil;
	role.fellowIndex = -1;
	
	self:refresh();
	
	--命运系统会改变属性值，这边要通知服务器
	isTeamChange = true;
	--self:onSendTeamChange();
	
end

--队伍内与队伍外交换
function TeamOrderPanel:LeaveJoinTeam(srcIndex, desIndex)	
	local actorPid = ActorManager.user_data.team[desIndex];						--角色pid
	ActorManager.user_data.team[desIndex] = -1;									--设置Team表该位置上的pid为-1，代表该位置无角色
	self.inTeamList[actorPid].role.teamIndex = -1;								--设置角色在阵型中的位置为-1，代表不在阵型中		
	self.inTeamList[actorPid] = nil;
	
	--显示上阵
	local role = self:getRoleFromRoleList(srcIndex);
	self.inTeamList[role.pid] = {role = role, index = srcIndex};	
	--设置角色和阵型的属性
	role.teamIndex = desIndex;													--角色在阵型中的位置
	ActorManager.user_data.team[desIndex] = role.pid;
	
	self:refresh();	
		
	--命运系统会改变属性值，这边要通知服务器
	isTeamChange = true;
	self:onSendTeamChange();
end

--交换位置srcIndex为第一个角色在阵型中的位置，desIndex为第二个角色在阵型中的位置
function TeamOrderPanel:ExchangeRolePosition(srcIndex, desIndex)
	local srcPid = ActorManager.user_data.team[srcIndex];
	local srcRole = self.inTeamList[srcPid].role;
	
	local desPid = ActorManager.user_data.team[desIndex];
	
	if desPid >= 0 then
		--目标位置不为空
		local desRole = self.inTeamList[desPid].role;
		--交换位置
		ActorManager.user_data.team[desIndex] = srcPid;
		srcRole.teamIndex = desIndex;
		
		ActorManager.user_data.team[srcIndex] = desPid;
		desRole.teamIndex = srcIndex;
	elseif -1 == desPid then
		--目标位置为空
		ActorManager.user_data.team[desIndex] = srcPid;
		srcRole.teamIndex = desIndex;
		ActorManager.user_data.team[srcIndex] = -1;

	end
	self:refresh();
	
	isTeamChange = true;
end

--下阵小伙伴,index为角色在小伙伴队伍的位置
function TeamOrderPanel:LeaveFellow(index)
	--print('----LeaveFellow--index:' .. index);
	
	local actorPid = ActorManager.user_data.fellow[index];	
	ActorManager.user_data.fellow[index] = -1;			
	self.inFellowList[actorPid].role.fellowIndex = -1;		
	self.inFellowList[actorPid] = nil;
	
	self:refresh();
	
	isTeamChange = true;
	self:onSendTeamChange();
end

--上阵小伙伴,index为左侧头像列表下标。 fellowIndex为角色在小伙伴队伍中位置
function TeamOrderPanel:JoinInFellow(index, fellowIndex)
	--print('----JoinInFellow--index:' .. index .. ' fellowIndex:' .. fellowIndex);
	local role = self:getRoleFromRoleList(index);
	self.inFellowList[role.pid] = {role = role, index = index};	
	role.fellowIndex = fellowIndex;
	ActorManager.user_data.fellow[fellowIndex] = role.pid;
	
	self:refresh();

	isTeamChange = true;	
	self:onSendTeamChange();
end

--上阵小伙伴,index为左侧头像列表下标。 fellowIndex为角色在小伙伴队伍中位置, 队伍中下阵
function TeamOrderPanel:JoinInFellowFromTeam(index, fellowIndex)
	
	--print('----JoinInFellowFromTeam--index:' .. index .. ' fellowIndex:' .. fellowIndex);
	
	local role = self:getRoleFromRoleList(index);
	if 0 == ActorManager.user_data.team[role.teamIndex] then
		--主角不可下阵
		MainUI:onDragDropCancel();
		TeamOrderPanel:ShowMessageBox();
		return;
	end
	
	--小伙伴上阵
	self.inFellowList[role.pid] = {role = role, index = index};	
	role.fellowIndex = fellowIndex;
	ActorManager.user_data.fellow[fellowIndex] = role.pid;	
	
	--队伍下阵
	local actorPid = ActorManager.user_data.team[role.teamIndex];						--角色pid
	ActorManager.user_data.team[role.teamIndex] = -1;									--设置Team表该位置上的pid为-1，代表该位置无角色
	role.teamIndex = -1;								--设置角色在阵型中的位置为-1，代表不在阵型中		
	self.inTeamList[actorPid] = nil;
	
	self:refresh();
	isTeamChange = true;
	--self:onSendTeamChange();
end

--小伙伴内外交换
function TeamOrderPanel:LeaveJoinFellow(srcIndex, desIndex)
	--print('----LeaveJoinFellow--srcIndex:' .. srcIndex .. ' desIndex:' .. desIndex);
	--下阵小伙伴
	local actorPid = ActorManager.user_data.fellow[desIndex];						
	ActorManager.user_data.fellow[desIndex] = -1;			
	self.inFellowList[actorPid].role.fellowIndex = -1;	
	self.inFellowList[actorPid] = nil;
	
	--上阵新的小伙伴
	local role = self:getRoleFromRoleList(srcIndex);
	self.inFellowList[role.pid] = {role = role, index = srcIndex};	
	--设置角色和阵型的属性
	role.fellowIndex = desIndex;													--角色在阵型中的位置
	ActorManager.user_data.fellow[desIndex] = role.pid;
	
	self:refresh();	
		
	--命运系统会改变属性值，这边要通知服务器
	isTeamChange = true;
	self:onSendTeamChange();
end

--交换位置teamIndex为角色在队伍中的位置，fellowIndex为角色在小伙伴中的位置, 伙伴列表位置
function TeamOrderPanel:ExchangeTeamFellow(teamIndex, fellowIndex, partnerIndex)
	if teamIndex == nil then
		--print('----ExchangeTeamFellow--fellowIndex:' .. fellowIndex .. ' partnerIndex:' .. partnerIndex);
		--小伙伴下阵
		local actorPid = ActorManager.user_data.fellow[fellowIndex];	
		ActorManager.user_data.fellow[fellowIndex] = -1;			
		self.inFellowList[actorPid].role.fellowIndex = -1;		
		self.inFellowList[actorPid] = nil;
		
		self:JoinInFellowFromTeam(partnerIndex, fellowIndex);
	elseif fellowIndex == nil then
		--print('----ExchangeTeamFellow--teamIndex:' .. teamIndex .. ' partnerIndex:' .. partnerIndex);
		local actorPid = ActorManager.user_data.team[teamIndex];
		ActorManager.user_data.team[teamIndex] = -1;
		self.inTeamList[actorPid].role.teamIndex = -1;
		self.inTeamList[actorPid] = nil;
		self:JoinInTeamFromFellow(partnerIndex, teamIndex);
	end
	--命运系统会改变属性值，这边要通知服务器
	isTeamChange = true;
	self:onSendTeamChange();
end

--获取当前队伍的战斗力
function TeamOrderPanel:refreshTotalFightPoint()
	local totalFightPoint = 0;
	for _,role in pairs(self.inTeamList) do
		if role.role.teamIndex > 0 then
			totalFightPoint = totalFightPoint + role.role.pro.fp;
		end	
	end
	labelFightAbility.Text = tostring(totalFightPoint);
end

function TeamOrderPanel:refreshRoles()
	local currentCount = 0;
	for index = 1, 6 do
		currentCount = (currentPage - 1) * MaxItemCount + index;
		local radioButton = partnerList[index];
		if currentCount <= roleCount then
			radioButton.Tag = currentCount;
			--获取控件
			local labelName = Label(radioButton:GetLogicChild('name'));
			local imgJob = ImageElement(radioButton:GetLogicChild('job'));
			local imgHeadPic = ItemCell(radioButton:GetLogicChild('image'));
			
			--设置控件属性
			local actor = self:getRoleFromRoleList(currentCount);
			labelName.Text = actor.name;
			labelName.TextColor = QualityColor[actor.rare];
			imgJob.Image = actor.jobIcon;
			imgHeadPic.Background = Converter.String2Brush( RoleQualityType[actor.rare] );
			imgHeadPic.Image = GetPicture('navi/' .. actor.headImage .. '.ccz');	
			radioButton.Visibility = Visibility.Visible;
		else
			radioButton.Visibility = Visibility.Hidden;
		end
	end
end

--刷新翻页按钮
function TeamOrderPanel:refreshPageChangeButton()
	if currentPage > 1 then
		btnLeftPage.Enable = true;
	else
		btnLeftPage.Enable = false;
	end
	if currentPage < pageCount then
		btnRightPage.Enable = true;
	else
		btnRightPage.Enable = false;
	end
end

--伙伴向左翻页
function TeamOrderPanel:onTeamPageLeft()
	if currentPage > 1 then
		currentPage = currentPage - 1;
		self:refreshRoles();
	end
	self:refreshRoleInTeamFlag();
	self:refreshPageChangeButton();
end

--伙伴向右翻页
function TeamOrderPanel:onTeamPageRight()
	if currentPage < pageCount then
		currentPage = currentPage + 1;
		self:refreshRoles();
	end
	self:refreshRoleInTeamFlag();
	self:refreshPageChangeButton();
end


--根据角色在左侧头像中的位置获得角色
function TeamOrderPanel:getRoleFromRoleList(index)
	local role = nil;	
	if 1 == index then
		--主角
		role = ActorManager.user_data.role;
	else
		--伙伴
		role = ActorManager.user_data.partners[index - 1];
	end	
	return role;
end

--刷新队伍中伙伴上阵标示
function TeamOrderPanel:refreshRoleInTeamFlag()
	for index = 1, 6 do
		local imageInTeam = ImageElement(partnerList[index]:GetLogicChild('inTeam'));
		imageInTeam.Visibility = Visibility.Hidden;
		local imageInFellow = ImageElement(partnerList[index]:GetLogicChild('inFellow'));
		imageInFellow.Visibility = Visibility.Hidden;
	end
	local count = self:getPositionCount();
	for index = 1, 5 do
		if index <= count then
			if (ActorManager.user_data.team[index] > -1) then
				--所有伙伴中的位置
				local indexInTeam = self.inTeamList[ActorManager.user_data.team[index]].index;
				if indexInTeam <= currentPage * MaxItemCount and indexInTeam > (currentPage - 1) * MaxItemCount then
					--当前页伙伴中的位置
					indexInTeam = indexInTeam - (currentPage - 1) * MaxItemCount;
					local imageInTeam = ImageElement(partnerList[indexInTeam]:GetLogicChild('inTeam'));
					imageInTeam.Visibility = Visibility.Visible;
				end
			end
		end
	end
	local count = self:getFellowOpenCount();
	for index = 1, 6 do
		if index <= count then
			if (ActorManager.user_data.fellow[index] > -1) then
				--所有伙伴中的位置
				local indexInFellow = self.inFellowList[ActorManager.user_data.fellow[index]].index;
				if indexInFellow <= currentPage * MaxItemCount and indexInFellow > (currentPage - 1) * MaxItemCount then
					--当前页伙伴中的位置
					indexInFellow = indexInFellow - (currentPage - 1) * MaxItemCount;
					local imageInFellow = ImageElement(partnerList[indexInFellow]:GetLogicChild('inFellow'));
					imageInFellow.Visibility = Visibility.Visible;
				end
			end
		end
	end
end

--删除角色
function TeamOrderPanel:RemoveAllRole()	
	self.inTeamList = {};
end	

--获取当前空位置个数
function TeamOrderPanel:GetEmptyPositionCount()
	return self:GetEmptyTeamCount() + self:GetEmptyFellowCount();
end

--获取当前空位置个数
function TeamOrderPanel:GetEmptyTeamCount()
	return self:getPositionCount() - self:GetTeamCount();
end

--获取当前空位置个数
function TeamOrderPanel:GetEmptyFellowCount()
	return self:getFellowOpenCount() - self:GetFellowCount();
end

--获取队伍中人数
function TeamOrderPanel:GetTeamCount()
	local count = 0;
	for _, pid in ipairs(ActorManager.user_data.team) do
		if pid > -1 then
			count = count + 1;
		end
	end
	return count;
end

--获取小伙伴人数
function TeamOrderPanel:GetFellowCount()
	local count = 0;
	for _, pid in ipairs(ActorManager.user_data.fellow) do
		if pid > -1 then
			count = count + 1;
		end
	end
	return count;
end

--是否队伍页
function TeamOrderPanel:isTeamPage()
	--print('ActiveTabPageIndex' .. tabControl.ActiveTabPageIndex);
	return tabControl.ActiveTabPageIndex == 0;
end

--获取当前开启的阵型个数
function TeamOrderPanel:getPositionCount()
	local level = ActorManager.user_data.role.lvl.level;
	if TeamOpenType.pos5 <= level then
		return 5;
	elseif TeamOpenType.pos4 <= level then
		return 4;
	elseif TeamOpenType.pos3 <= level then
		return 3;
	elseif TeamOpenType.pos2 <= level then
		return 2;
	else
		return 1;
	end	
end	

--获取当前开启的阵型个数
function TeamOrderPanel:getFellowOpenCount()
	local level = ActorManager.user_data.role.lvl.level;
	for index = 1, 6 do
		if FellowOpenType['pos' .. (7 - index)] <= level then
			return 7 - index;
		end
	end
	return 0;
end	

--获取位置开发的等级数
function TeamOrderPanel:getOpenLevel(index)
	if 1 == index then
		return 1;
	elseif 2 == index then
		return TeamOpenType.pos2;
	elseif 3 == index then
		return TeamOpenType.pos3;
	elseif 4 == index then
		return TeamOpenType.pos4;
	elseif 5 == index then
		return TeamOpenType.pos5;
	end
end

--获取小伙伴位置开放的等级数
function TeamOrderPanel:getFellowOpenLevel(index)
	return FellowOpenType['pos' .. index];
end

--判断角色是否已经在队列里面
function TeamOrderPanel:isInTeam(role, teamOrder)
	local flag = false;
	for index,pid in ipairs(teamOrder) do
		if role.pid == pid then
			role.teamIndex = index;
			flag = true;
			break;
		else
			role.teamIndex = -1;
		end
	end
	return flag;
end	

--判断角色是否已经在小伙伴里面
function TeamOrderPanel:isInFellow(role, fellowOrder)
	local flag = false;
	for index,pid in ipairs(fellowOrder) do
		if role.pid == pid then
			role.fellowIndex = index;
			flag = true;
			break;
		else
			role.fellowIndex = -1;
		end
	end
	return flag;
end

--获取小伙伴队列中第一个空位置(位置沾满返回nil)
function TeamOrderPanel:GetFellowFirstEmptyPosition()
	for index = 1, 6 do
		if -1 == ActorManager.user_data.fellow[index] then
			return index;
		end
	end
	return nil;
end

--获取阵型队列中第一个空位置(位置沾满返回nil)
function TeamOrderPanel:GetFirstEmptyPosition()
	for index = 1, 5 do
		if -1 == ActorManager.user_data.team[index] then
			return index;
		end
	end
	return nil;
end

--=====================================================================================
--事件

--显示阵型界面
function TeamOrderPanel:onShowTeamPanel()
	--排序伙伴
	table.sort(ActorManager.user_data.partners, sortPartner);
	
	self:filterInTeamRoles();
	
	self:refreshTotalFightPoint();											--刷新战斗力
	MainUI:Push(self);
end

--分流伙伴
function TeamOrderPanel:filterInTeamRoles()
	--判断主角是否在阵型中
	if self:isInTeam(ActorManager.user_data.role, ActorManager.user_data.team) then
		self.inTeamList[0] = {role = ActorManager.user_data.role, index = 1};
	end
	--分流队伍阵型中的伙伴和不在阵型中的伙伴
	for index,role in ipairs(ActorManager.user_data.partners) do
		if self:isInTeam(role, ActorManager.user_data.team) then
			self.inTeamList[role.pid] = {role = role, index = (index + 1)};
		end
	end
	
	--分流小伙伴阵型中的伙伴和不在阵型中的伙伴
	for index,role in ipairs(ActorManager.user_data.partners) do
		if self:isInFellow(role, ActorManager.user_data.fellow) then
			self.inFellowList[role.pid] = {role = role, index = (index + 1)};
		end
	end
end

--阵型中的角色点击事件
function TeamOrderPanel:onRoleInTeamClick(Args)
	if UserGuidePanel.isUserGuide then
		return;
	end
	local args = UIControlEventArgs(Args);
	local teamIndex = args.m_pControl.Tag;							--获取角色在阵型中的位置
	local pid = ActorManager.user_data.team[teamIndex];			--角色pid
	--判断该位置上是否有角色
	if (nil ~= pid) and (pid >= 0) then
		local index = self.inTeamList[pid].index;
		local role = self:getRoleFromRoleList(index);
		TooltipPanel:ShowRole(panel, role, 3);
		
		SoundManager:PlayVoice('v' .. tostring(role.resid));
	end
end

--小伙伴中的角色点击事件
function TeamOrderPanel:onFellowInTeamClick(Args)
	local args = UIControlEventArgs(Args);
	local teamIndex = args.m_pControl.Tag;							--获取角色在阵型中的位置
	local pid = ActorManager.user_data.fellow[teamIndex];			--角色pid
	--判断该位置上是否有角色
	if (nil ~= pid) and (pid >= 0) then
		local index = self.inFellowList[pid].index;
		local role = self:getRoleFromRoleList(index);
		TooltipPanel:ShowRole(panel, role, 3);
	end
end

--关闭事件
function TeamOrderPanel:onClose()
	self:onSendTeamChange();
	
	MainUI:Pop();
	
	--新手引导
	local taskid = Task:getMainTaskId();
	if (Task.mainTask.step ~= Task.TaskUnreceive) and ( (SystemTaskId.team == taskid) or (SystemTaskId.team2 == taskid) ) then
		UserGuide:CommitSystemTask();
		
		--新手队伍设置结束
		UserGuidePanel:SetInGuiding(false);
		
		--隐藏引导箭头
		UserGuidePanel:HideAutoTaskGuide();
	else
		--新手队伍设置结束
		UserGuidePanel:SetInGuiding(false);
	end
end

function TeamOrderPanel:onSendTeamChange()
	if isTeamChange then
		local msg = {};
		local teamList = {};
		for index = 1,5 do
			table.insert(teamList, ActorManager.user_data.team[index]);
		end
		
		for index = 6,10 do
			table.insert(teamList, -1);
		end
		
		for index = 11,16 do
			table.insert(teamList, ActorManager.user_data.fellow[index-10]);
		end
		
		for index = 17,20 do
			table.insert(teamList, -1);
		end
		--通知本地队伍变化， 队伍id目前指定死了
		MutipleTeam:AdjustTeam({tid = 1, team = teamList});
		
		msg.team = teamList;
		Network:Send(NetworkCmdType.nt_team_change, msg, true);		--向服务器发送队伍改变消息	
		
		local taskid = Task:getMainTaskId();
		if taskid == SystemTaskId.team or taskid == SystemTaskId.team2 then
			NetworkMsg_GodsSenki:SendStatisticsData(taskid, 4);
		end
		isTeamChange = false;
	end
	
end

--角色头像点击事件
function TeamOrderPanel:onRoleClick(Args)
	if UserGuidePanel.isUserGuide then
		return;
	end
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag
	local role = self:getRoleFromRoleList(index);
	TooltipPanel:ShowRole(panel, role, 2);
	
	SoundManager:PlayVoice('v' .. tostring(role.resid));
end

--显示消息提示框
function TeamOrderPanel:ShowMessageBox()
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_teamOrderPanel_6);
end

--====================================================================================
--头像列表点击事件

local dragDropTimer = 0;
local radioButton = nil;

function TeamOrderPanel:onMouseDown(Args)
	if dragDropTimer ~= 0 then
		return;
	end
	
	local args = UIMouseButtonEventArgs(Args);	
	radioButton = args.m_pOriginalControl;
	
	--已经上阵的不可拖拽
	if -1 == self:getRoleFromRoleList(radioButton.Tag).teamIndex then
		dragDropTimer = timerManager:CreateTimer(GlobalData.MouseMoveTime, 'TeamOrderPanel:onDragDopTimer', 0);
	end
	
	mouseDownPosition = Vector2(mouseCursor.Translate.x, mouseCursor.Translate.y);
	isMouseDown = true;
end

function TeamOrderPanel:onMouseMove()
	local absX = 0;
	local absY = 0;
	if isMouseDown then
		absX = Math.Abs(mouseCursor.Translate.x - mouseDownPosition.x);
		absY = Math.Abs(mouseCursor.Translate.y - mouseDownPosition.y);
	end
	
	if (dragDropTimer ~= 0) then
		if isMouseDown and ((absX <= GlobalData.MouseMoveDistance) and (absY <= GlobalData.MouseMoveDistance)) then
			return ;
		else
			timerManager:DestroyTimer(dragDropTimer);
			dragDropTimer = 0;
			radioButton = nil;
		end	
	end		
end

function TeamOrderPanel:onMouseUp()
	if dragDropTimer ~= 0 then
		timerManager:DestroyTimer(dragDropTimer);
		dragDropTimer = 0;
		radioButton = nil;
	end	
	isMouseDown = false;
end

--按下超过一定时间没有移动认为是拖拽
function TeamOrderPanel:onDragDopTimer()
	timerManager:DestroyTimer(dragDropTimer);
	mainDesktop:DoDragDrop(radioButton);
	dragDropTimer = 0;
	radioButton = nil;
end

--下阵按钮点击事件
function TeamOrderPanel:onLeaveTeam(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;
	
	--team(1~5), fellow(11~16)
	if index <= 10 then
		if 0 == ActorManager.user_data.team[index] then
			--主角不可下阵
			MainUI:onDragDropCancel();
			TeamOrderPanel:ShowMessageBox();
			return;
		else
			TeamOrderPanel:LeaveTeam(index);
			TooltipPanel:onLostFocus();
		end
	else
		TeamOrderPanel:LeaveFellow(index - 10);
		TooltipPanel:onLostFocus();
	end

	
end

