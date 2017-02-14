--allRolePanel.lua

--========================================================================
--所有角色界面

AllRolePanel =
	{
		roleList = {};				--资源表格中伙伴稀有度（绿、蓝、紫、金）
	};

--控件
local mainDesktop;
local allRolePanel;
local tabControl;
local uiHuobanList = {};


--初始化面板
function AllRolePanel:InitPanel(desktop)
	
	mainDesktop = desktop;
	allRolePanel = Panel(desktop:GetLogicChild('allRolePanel'));
	allRolePanel:IncRefCount();
	
	allRolePanel.Visibility = Visibility.Hidden;
	
	tabControl = TabControl( allRolePanel:GetLogicChild('tabControl') );
	uiHuobanList = {};
	table.insert( uiHuobanList, tabControl:GetLogicChild(3):GetLogicChild(0) );
	table.insert( uiHuobanList, tabControl:GetLogicChild(2):GetLogicChild(0) );
	table.insert( uiHuobanList, tabControl:GetLogicChild(1):GetLogicChild(0) );
	table.insert( uiHuobanList, tabControl:GetLogicChild(0):GetLogicChild(0) );
	tabControl.ActiveTabPageIndex = -1;

end

--销毁
function AllRolePanel:Destroy()
	allRolePanel:DecRefCount();
	allRolePanel = nil;
end

--显示
function AllRolePanel:Show()
	tabControl.ActiveTabPageIndex = 0;
	
	--设置模式对话框
	mainDesktop:DoModal(allRolePanel);
	
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(allRolePanel, StoryBoardType.ShowUI1);
end

--隐藏
function AllRolePanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(allRolePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
		
	tabControl.ActiveTabPageIndex = -1;
	
	for i = 1, 4 do
		uiHuobanList[i]:RemoveAllChildren();
	end
	
	--触发回收显存事件
	EventManager:FireEvent(EventType.RecoverDisplayMemory);
end

--========================================================================
--点击事件

--关闭
function AllRolePanel:onClose()
	MainUI:Pop();
end

--点击角色查看信息
function AllRolePanel:onRoleClick( Args )
end

--分页改变
function AllRolePanel:onPageChanged( Args )
	
	local args = UITabControlPageChangeEventArgs(Args);
	if args.m_pNewPage == nil then
		return;
	end

	local group = args.m_pNewPage.Tag;
	if uiHuobanList[group]:GetLogicChildrenCount() ~= 0 then
		return;
	end
	
	local roleList = AllRolePanel.roleList[group];
	local totalPage = math.ceil(#roleList / 4);	--计算应该创建的页数（4个一页）
	local index = 1;

	for i = 1, totalPage do
		local panel = uiSystem:CreateControl('pubRoleTemplate');
		uiHuobanList[group]:AddChild(panel);
		
		panel = panel:GetLogicChild(0);

		for i = 1, 4 do
			local role = roleList[index];
			local uiRole = panel:GetLogicChild(i - 1);
			
			if role == nil then
				uiRole.Visibility = Visibility.Hidden;
			else
				local name = Label(uiRole:GetLogicChild('name'));
				name.Text = role.name;
				name.TextColor = QualityColor[role.rare];

				local job = ImageElement(uiRole:GetLogicChild('job'));
				job.Image = role.jobIcon;

				local path = GlobalData.AnimationPath .. role.path .. '/';
				AvatarManager:LoadFile(path);
				local armature = ArmatureUI(uiRole:GetLogicChild('armature'));
				armature:LoadArmature(role.avatarName);
				armature:SetAnimation(AnimationType.f_idle);
				
				uiRole:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'AllRolePanel:onClick');
				uiRole.Tag = group;
				uiRole.TagExt = index;
			end

			index = index + 1;
		end
	end
	
	
	
	if totalPage == 1 then
		uiHuobanList[group].ShowPageBrush = false;
	else
		uiHuobanList[group].ShowPageBrush = true;
	end
	
end

--显示角色属性
function AllRolePanel:onClick( Args )
	local args = UIMouseButtonEventArgs(Args);
	local roleList = AllRolePanel.roleList[args.m_pControl.Tag];
	local resRole = roleList[args.m_pControl.TagExt];
	if resRole == nil then
		return;
	end
	
	local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(resRole.resid));
	
	SoundManager:PlayVoice('v' .. tostring(resRole.resid));
	
	local role = {};
	role.resid = resRole.resid;
	
	role.name = actorData['name'];
	if (actorData['title'] == nil) or (actorData['title'] == '') then
		role.fullName = role.name;		
	else
		role.fullName = actorData['title'] .. '·' .. role.name;	
	end
	role.rare = actorData['rare'];
	role.lvl = {};
	role.lvl.level = 1;
	role.job = actorData['job'];
	role.pro = {};
	role.quality = 0;
	role.skls = {};

  local keys = {'skill_id', 'skill_id2', 'skill_id3'};
  for key in keys do 
    if actorData[key] then
      local skill = {};
      skill.resid = actorData[key];
      skill.level = 1;
      table.insert(role.skls, skill);
    end
  end

	role.pro = {};
	role.pro.fp = actorData['fd'];
	role.pro.atk = actorData['base_atk'];
	role.pro.mgc = actorData['base_mgc'];
	role.pro.hp = actorData['base_hp'];	
	role.pro.def = actorData['base_def'];
	role.pro.res = actorData['base_res'];
	role.pro.cri = actorData['base_crit'];
	role.pro.dodge = actorData['base_dodge'];
	role.pro.acc = actorData['base_acc'];
	role.potential = 1;
	
	--角色职业
	if (JobType.magician == role.job) then
		role.pro.attack = role.pro.mgc;	
		role.pro.attackType= LANG_packagePanel_1;
	else
		role.pro.attack = role.pro.atk;
		role.pro.attackType= LANG_packagePanel_2;		
	end
	
	--显示角色属性
	TooltipPanel:ShowRole(allRolePanel, role, 2);
end
