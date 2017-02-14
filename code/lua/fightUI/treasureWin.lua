--treasureWin.lua
--==============================================================================
--巨龙宝库占领战斗结束界面

TreasureCaptureWinPanel = 
    {
    };

--控件
local panel;
local mainDesktop;

--初始化
function TreasureCaptureWinPanel:Initialize(desktop)
    mainDesktop = desktop;
    panel = desktop:GetLogicChild('win_treasure');
    panel:IncRefCount();
    panel.Visibility = Visibility.Hidden;
end

--销毁
function TreasureCaptureWinPanel:Destroy()
    panel:DecRefCount();
    panel = nil;
end

--显示
function TreasureCaptureWinPanel:Show()
    mainDesktop:DoModal(panel);
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function TreasureCaptureWinPanel:Hide()
    mainDesktop:UndoModal();
	--StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

--=================================================================================
--事件
--显示巨龙宝库占领战斗胜利界面
function TreasureCaptureWinPanel:ShowWinPanel(resultData)
	if (FightType.treasureGrabBattle == resultData.fightType or 
		  FightType.treasureRobBattle == resultData.fightType) and
			resultData.result == Victory.left and Treasure.is_help then
			return ;
	end
  self:Show();
end
