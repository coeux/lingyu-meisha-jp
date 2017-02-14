--touchEvent.lua

--========================================================================

local closeMessageBoxFlag = 0;

--back按钮按下
function OnBackClicked()

	--非win32平台先关闭输入法
	if platformSDK.m_System ~= "Win32" then
		local desktop = uiSystem:GetActiveDesktop();
		if desktop ~= nil then
			local control = desktop.KeyFocusControl;
			if control ~= nil then
				desktop.KeyFocusControl = nil;
			end
		end
	end
	
	--android要求有退出游戏
	if platformSDK.m_System == "Android" then
		if closeMessageBoxFlag == 0 then
			local okDelegate = Delegate.new(MainUI, MainUI.TerminateApp, 0);	
			closeMessageBoxFlag = MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_touchEvent_1, okDelegate);
			MessageBox:SetCancelShowName(closeMessageBoxFlag,LANG_touchEvent_4);
			MessageBox:SetOkShowName(closeMessageBoxFlag,LANG_touchEvent_3);
		else
			MessageBox:Hide(closeMessageBoxFlag);
			closeMessageBoxFlag = 0;
		end
	end
	
end


--Menu按钮按下
function OnMenuClicked()
	
--[[	local bossRects = {}
	local bossData = { {x= 1, y =2}, {x=3, y=2} }
	local theRect;

	local hour, min, sec = Time2HourMinSec(2567);
		
	for k,v in ipairs(bossData) do
		theRect = Rect(v.x, v.y, 100, 100);
		table.insert(bossRects, theRect);
	end--]]
	
	
--[[	local hitEffect = sceneManager:CreateSceneNode('Armature');
	hitEffect:LoadArmature('start_2');
	hitEffect:SetAnimation('play');
	hitEffect.ZOrder = 100;
	ActorManager.hero:AttachEffect(AvatarPos.body, hitEffect);--]]
	
--[[	local appearEffect = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	appearEffect:LoadArmature(LANG_touchEvent_2);
	appearEffect:SetAnimation('play');
	appearEffect.Translate = Vector2(300, 300);
	local desktop = uiSystem:GetActiveDesktop();
	
	desktop:AddChild(appearEffect);--]]

end
