--taskFindPathPanel.lua

--========================================================================
--自动寻路界面

TaskFindPathPanel =
	{
	};

--控件
local mainDesktop;
local taskFindPathPanel;
local arm;

--初始化面板
function TaskFindPathPanel:InitPanel(desktop)
	--变量初始化

	--界面初始化
	mainDesktop = desktop;
	taskFindPathPanel = Panel(desktop:GetLogicChild('taskFindPath'));
	self.ShadePanel = Panel(desktop:GetLogicChild('ShadePanel'));
	taskFindPathPanel:IncRefCount();
	
	taskFindPathPanel.Visibility = Visibility.Hidden;
	isVisible = false;	

	arm = taskFindPathPanel:GetLogicChild('arm');
  local path = GlobalData.EffectPath.. 'taskfindpath_output/';
  AvatarManager:LoadFile(path);
  arm:LoadArmature('zidongxunlu');
  arm:SetScale(1.2,1.2);
  arm:SetAnimation('play');
end

--销毁
function TaskFindPathPanel:Destroy()
	taskFindPathPanel:DecRefCount();
	taskFindPathPanel = nil;
end

--显示自动寻路界面
function TaskFindPathPanel:Show()
	taskFindPathPanel.Visibility = Visibility.Visible;
	if ActorManager.user_data.role.lvl.level <= 5 then
		self.ShadePanel.Visibility = Visibility.Visible;
	else
		self.ShadePanel.Visibility = Visibility.Hidden;
	end
end

--隐藏
function TaskFindPathPanel:Hide()
	taskFindPathPanel.Visibility = Visibility.Hidden;
	self.ShadePanel.Visibility = Visibility.Hidden;
end
