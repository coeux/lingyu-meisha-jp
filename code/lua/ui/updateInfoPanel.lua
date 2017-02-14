--updateInfoPanel.lua
--==================================================================================
--更新公告界面

UpdateInfoPanel = 
	{
	};

--控件
local mainDesktop;
local updatePanel;			--更新公告面板
local richTextUpdateInfo;	--更新信息的富文本控件


function UpdateInfoPanel:InitPanel( desktop )

	--控件初始化
	mainDesktop = desktop;
	updatePanel = desktop:GetLogicChild('updatePanel');
	updatePanel:IncRefCount();
	richTextUpdateInfo = updatePanel:GetLogicChild('updateInfo');
	
	updatePanel.Visibility = Visibility.Hidden;

end

--销毁
function UpdateInfoPanel:Destroy()
	updatePanel:DecRefCount();
	updatePanel = nil;
end

--显示
function UpdateInfoPanel:Show()
	--更新公告
	local arg = VersionUpdate.serverUrl .. '/up_notice.php' .. '?version=' .. VersionUpdate.localGameVersion .. '&domain=' .. platformSDK.m_Platform .. '&system=' .. platformSDK.m_System;
	if VersionUpdate.curLanguage == LanguageType.cn then
		curlManager:SendHttpScriptRequest(arg, '', 'UpdateInfoPanel:onGetUpdateInfo', 0);
	elseif VersionUpdate.curLanguage == LanguageType.tw then
		curlManager:SendHttpScriptRequest(arg, '', 'UpdateInfoPanel:onGetUpdateInfo', 0);
	end

	mainDesktop:DoModal(updatePanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(updatePanel, StoryBoardType.ShowUI1);
end

--隐藏
function UpdateInfoPanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(updatePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--============================================================================================
--功能函数

--关闭
function UpdateInfoPanel:onClose()
	MainUI:Pop();
end

--获取更新内容
function UpdateInfoPanel:onGetUpdateInfo( request )
	if request.m_Data ~= nil then
		local info = request.m_Data;
		richTextUpdateInfo:Clear();
		
		richTextUpdateInfo:Parser(info);
		richTextUpdateInfo:ForceLayout();
		
		richTextUpdateInfo:PageBegin();
	end
end
