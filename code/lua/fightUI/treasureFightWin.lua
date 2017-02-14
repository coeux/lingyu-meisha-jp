--treasureFightWin.lua
--=========================
--幻境探宝胜利界面



TreasureFightWinPanel = 
	{
	};

--变量
--
--控件
local mainDesktop;
local panel;
local jinbiValue;
local drops = {};

function TreasureFightWinPanel:Initialize(desktop)
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('win_fight_treasure');
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.win_pvp;

	jinbiValue = panel:GetLogicChild('bg_panel'):GetLogicChild('rewardPanel'):GetLogicChild('value1');
	drops = {};
	for i=1,5 do
		drops[i] = {};
		drops[i] = customUserControl.new(panel:GetLogicChild('bg_panel'):GetLogicChild('drops'):GetLogicChild(tostring(i)), 'itemTemplate');
	end
	drops.setNum = function(num)
		panel:GetLogicChild('bg_panel'):GetLogicChild('drops').Size = Size(70*num,70);
		for i=1,5 do
			if i <= num then
				panel:GetLogicChild('bg_panel'):GetLogicChild('drops'):GetLogicChild(tostring(i)).Visibility = Visibility.Visible;
			else
				panel:GetLogicChild('bg_panel'):GetLogicChild('drops'):GetLogicChild(tostring(i)).Visibility = Visibility.Hidden;
			end
		end
	end


	panel:GetLogicChild('sure'):SubscribeScriptedEvent('Button::ClickEvent', 'FightOverUIManager:OnBackToPveBarrier');
end

--销毁
function TreasureFightWinPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function TreasureFightWinPanel:Show()	
	panel.Visibility = Visibility.Visible;
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function TreasureFightWinPanel:Hide()
	panel.Visibility = Visibility.Hidden;
end

--=========================================
--事件

--显示界面
function TreasureFightWinPanel:ShowWinPanel(resultData)
	jinbiValue.Text = tostring(resultData.coin);
	local count = 1;
	for resid, num in pairs(TreasurePanel.drop_things) do
		drops[count].initWithInfo(resid,-1,70,true)
		count = count + 1;
	end
	drops.setNum(count-1);
	self:Show();
end


