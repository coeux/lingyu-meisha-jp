--unionSceneUIPanel.lua
--======================================================================================
--boss场景UI
UnionSceneUIPanel =
	{
	};
	
--变量
local unionBossButtonEffect = nil;

--控件
local mainDesktop;
local panel;

local unionInfoButton;						--公会信息按钮
local unionBossButton;						--公会boss按钮

local isBossOpen = false;
--初始化
function UnionSceneUIPanel:InitPanel(desktop)
	unionBossButtonEffect = nil;
	
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('unionSceneUI');
	
	--公会	
	unionInfoButton = panel:GetLogicChild('unionInfoButton');
	unionBossButton = panel:GetLogicChild('unionBoss');
	
	unionBossButton.Visibility = Visibility.Hidden;
	panel.Visibility = Visibility.Hidden;
end

--销毁
function UnionSceneUIPanel:Destroy()
	panel = nil;
end

--显示
function UnionSceneUIPanel:ShowUnionSceneUI()
	panel.Visibility = Visibility.Visible;
end

--隐藏
function UnionSceneUIPanel:CloseUnionSceneUI()
	panel.Visibility = Visibility.Hidden;
end	

--显示公会boss相关按钮和特效
function UnionSceneUIPanel:ShowUnionButtonAndEffect()
	isBossOpen = true;
	MenuPanel:ShowUnionButtonEffect();
	
	unionBossButton.Visibility = Visibility.Visible;
	if (nil == unionBossButtonEffect) then
		unionBossButtonEffect = uiSystem:CreateControl('ArmatureUI');
		unionBossButtonEffect:LoadArmature('shouchong');
		unionBossButtonEffect:SetAnimation('play');
		unionBossButtonEffect.Margin = Rect(0, 0, 0, 0);
		unionBossButtonEffect.Horizontal = ControlLayout.H_CENTER;
		unionBossButtonEffect.Vertical = ControlLayout.V_CENTER;
		unionBossButton:AddChild(unionBossButtonEffect);
	end
end

--隐藏公会boss相关按钮和特效
function UnionSceneUIPanel:HideUnionButtonAndEffect()
	isBossOpen = false;
	MenuPanel:HideUnionButtonEffect();
	
	unionBossButton.Visibility = Visibility.Hidden;
	if (nil ~= unionBossButtonEffect) then
		unionBossButton:RemoveChild(unionBossButtonEffect);
		unionBossButtonEffect = nil;
	end
end

function UnionSceneUIPanel:isBossOpen()
	return isBossOpen;
end
