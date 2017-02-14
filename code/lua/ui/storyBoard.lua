--storyBoard.lua

--========================================================================
--storyboard 类

StoryBoardType = 
{
	ShowUI1 = 1;			-- UI出现,适宜于大的面板UI
	ShowUI2 = 2;			-- UI出现,适宜于小的UI
	ShowUI3 = 3;			-- UI出现，适用于ipad等需要缩放的界面UI
	ShowUI4 = 4;			-- UI出现，备用
	ShowUI5 = 5;			-- UI出现，备用
	ShowUIScale = 6;
	HideUI1 = 11;			-- UI隐藏，适宜于大的UI隐藏
	HideUI2 = 12;			-- UI隐藏，适宜于小的UI隐藏
	HideUI3 = 13;			-- UI隐藏，
	HideUI2 = 14;			-- UI隐藏，
	HideUI2 = 15;			-- UI隐藏，
	HideUIScale = 16;
};

StoryBoard = 
{
};

local mainBoard;
local hiddenUI;
local hiddenTopUI;

function StoryBoard:InitPanel(desktop)
	hiddenUI = nil;
	hiddenTopUI = nil;
	mainBoard = desktop;
end

function StoryBoard:Destroy()
	hiddenUI = nil;
	hiddenTopUI = nil;
end

function StoryBoard:ShowUIStoryBoard(showUI, showType, keyFrameCallback, finishedCallback)
	local storyBoard = nil;
	if showType == StoryBoardType.ShowUI1 then
		storyBoard = showUI:SetUIStoryBoard("storyboard.showUIBoard1");
	elseif showType == StoryBoardType.ShowUI2 then
		storyBoard = showUI:SetUIStoryBoard("storyboard.showUIBoard2");
	elseif showType == StoryBoardType.ShowUI3 then
		storyBoard = showUI:SetUIStoryBoard("storyboard.showUIBoard3");
	elseif showType == StoryBoardType.ShowUIScale then
		storyBoard = showUI:SetUIStoryBoard("storyboard.showUIScale");
	end
	
	if storyBoard ~= nil then
		if (keyFrameCallback ~= nil) and (string.len(keyFrameCallback) ~= 0) then
			storyBoard:SubscribeScriptedEvent('StoryboardInstance::KeyFrameEvent', keyFrameCallback);
		end
		if (finishedCallback ~= nil) and (string.len(finishedCallback) ~= 0) then
			storyBoard:SubscribeScriptedEvent('StoryboardInstance::FinishedEvent', finishedCallback);
		end
	end
	
end

function StoryBoard:HideUIStoryBoard(hideUI, hideType, finishedCallback, keyFrameCallback )
	--print ("Hide storyboard --------------------------------------------"..hideUI.Name);
	
	if hiddenUI ~= nil then
		self:OnPopUI();
	end
	hiddenUI = hideUI;
	
	local storyBoard = nil;
	if hideType == StoryBoardType.HideUI1 then
		storyBoard = hideUI:SetUIStoryBoard("storyboard.hideUIBoard1");		
	elseif hideType == StoryBoardType.HideUI2 then
		storyBoard = hideUI:SetUIStoryBoard("storyboard.hideUIBoard2");
	elseif hideType == StoryBoardType.HideUI3 then
		storyBoard = hideUI:SetUIStoryBoard("storyboard.hideUIBoard3");
	elseif hideType == StoryBoardType.HideUIScale then
		storyBoard = hideUI:SetUIStoryBoard("storyboard.hideUIScale");
	end
	
	if storyBoard ~= nil then
		if (keyFrameCallback ~= nil) and (string.len(keyFrameCallback) ~= 0) then
			storyBoard:SubscribeScriptedEvent('StoryboardInstance::KeyFrameEvent', keyFrameCallback);
		end
		if (finishedCallback ~= nil) and (string.len(finishedCallback) ~= 0) then
			storyBoard:SubscribeScriptedEvent('StoryboardInstance::FinishedEvent', finishedCallback);
		end
	end
end

function StoryBoard:DetectSameStoryBoardList()
	local taskPanel = TaskDialogPanel:GetTaskPanel();
	StoryBoard:DetectSameStoryBoard(taskPanel);
end

function StoryBoard:DetectSameStoryBoard(showUI)
	--print ("StoryBoard:DetectSameStoryBoard *******************".."ShowUI:"..showUI.Name);
	if hiddenUI ~= nil then
		if IsEqual( showUI, hiddenUI) then
			--print ("StoryBoard:OnPopUI *******************".."ShwoUI:"..showUI.Name..",HiddenUI:"..hiddenUI.Name);
			self:OnPopUI();
		end
	end

end

function StoryBoard:OnPopPlayingUI(  )
	if hiddenUI ~= nil then
		hiddenUI:SetUIStoryBoard("");
		--print ("PopPlaying UI name"..hiddenUI.Name);
		StoryBoard:OnPopUI();
	end
end

function StoryBoard:OnPopUI( Args )
	if Args == nil then
		mainBoard:UndoModal();
	else
		local args = StoryboardKeyFrameArgs(Args);
		mainBoard:UndoModal( UIControl(args.m_pTarget) );
	end
	--print("StoryBoard:OnPopUI ----------------------------------------------");
	
--[[	if hiddenUI ~= nil then
		print("StoryBoard:OnPopUI ----------------------------------------------"..hiddenUI.Name);
	else
		print("StoryBoard:OnPopUI ----------------------------------------------");
	end--]]
	
	hiddenUI = nil;
end

function StoryBoard:HideTopUIStoryBoard(hideUI, hideType, finishedCallback, keyFrameCallback )
	--print ("Hide HideTopUIStoryBoard --------------------------------------------"..hideUI.Name);
	
	if hiddenTopUI ~= nil then
		StoryBoard:OnPopTopUI();
	end
	
	hiddenTopUI = hideUI;
	local storyBoard = nil;	
	if hideType == StoryBoardType.HideUI1 then
		storyBoard = hideUI:SetUIStoryBoard("storyboard.hideUIBoard1");		
	elseif hideType == StoryBoardType.HideUI2 then
		storyBoard = hideUI:SetUIStoryBoard("storyboard.hideUIBoard2");
	elseif hideType == StoryBoardType.HideUI3 then
		storyBoard = hideUI:SetUIStoryBoard("storyboard.hideUIBoard3");
	end
	
	if storyBoard ~= nil then
		if (keyFrameCallback ~= nil) and (string.len(keyFrameCallback) ~= 0) then
			storyBoard:SubscribeScriptedEvent('StoryboardInstance::KeyFrameEvent', keyFrameCallback);
		end
		if (finishedCallback ~= nil) and (string.len(finishedCallback) ~= 0) then
			storyBoard:SubscribeScriptedEvent('StoryboardInstance::FinishedEvent', finishedCallback);
		end
	end
end

function StoryBoard:OnPopTopUI( Args )
	--print ("StoryBoard onPopTopUI");
	if hiddenTopUI ~= nil then
		hiddenTopUI:SetUIStoryBoard("");
		
		if Args == nil then
			topDesktop:UndoModal();
		else
			local args = StoryboardKeyFrameArgs(Args);
			topDesktop:UndoModal( UIControl(args.m_pTarget) );
		end

		hiddenTopUI = nil;
	end
end

function StoryBoard:OnPopFightDesktopUI()
	local fightDesktop = FightManager:GetFightDeskTop();
	if fightDesktop then
		fightDesktop:UndoModal();
	end
end



