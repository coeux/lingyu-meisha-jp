--arenaDialogPanel.lua
--================================================================================
ArenaDialogPanel =
{
	titleupdata = {};
}

local mainDesktop;
local panel;
-- record
local recordPanel;
local btnClose1
local stackPanel1
local nonePanel;
-- title
local titlePanel;
local btnClose2;
local scrollPanel2;
local stackPanel2;
--
local which = 1;
local notopenlist = {};
local maxCount = 0;
local itemHeight = 0;
--================================================================================
function ArenaDialogPanel:InitPanel(desktop)
	which = 1;
	notopenlist = {};
	maxCount = 0;
	itemHeight = 0;

  mainDesktop = desktop;
  panel = desktop:GetLogicChild('arenaResultPanel');
  panel:IncRefCount();

	self:InitRecordPanel();
	self:InitTitlePanel();
end

function ArenaDialogPanel:InitRecordPanel()
	recordPanel = panel:GetLogicChild('recordPanel');
	btnClose1 = recordPanel:GetLogicChild('close');
	stackPanel1 = recordPanel:GetLogicChild('tsp'):GetLogicChild('sp');
	nonePanel = recordPanel:GetLogicChild('none');
	nonePanel.Visibility = Visibility.Hidden;

  btnClose1:SubscribeScriptedEvent('Button::ClickEvent', 'ArenaDialogPanel:onClose');
end

function ArenaDialogPanel:InitTitlePanel()
	titlePanel = panel:GetLogicChild('meritoriousPanel');
	btnClose2 = titlePanel:GetLogicChild('close');
	scrollPanel2 = titlePanel:GetLogicChild('tsp');
	stackPanel2 = scrollPanel2:GetLogicChild('sp');

	maxCount = #self.titleupdata;
	for _, title in pairs(self.titleupdata) do
		local it = customUserControl.new(stackPanel2, 'meritoriousTemplate');
		itemHeight = it.height();
		it.initWithData(title);
		if title.id <= ActorManager.user_data.arena.title_lv then
			it.open()
		else
			notopenlist[title.id] = it;
		end
	end

  btnClose2:SubscribeScriptedEvent('Button::ClickEvent', 'ArenaDialogPanel:onClose');
end
--================================================================================
function ArenaDialogPanel:onShow(tag)
	--适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		recordPanel:SetScale(factor,factor);
	end
	which = tag;
	if tag == 1 then
		recordPanel.Visibility = Visibility.Visible;
		titlePanel.Visibility = Visibility.Hidden;
		self:RefreshRecordPanel();
	else
		recordPanel.Visibility = Visibility.Hidden;
		titlePanel.Visibility = Visibility.Visible;
		self:RefreshTitlePanel();
	end
  MainUI:Push(self);
end

function ArenaDialogPanel:Show()
  mainDesktop:DoModal(panel);
  StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI2);
end

function ArenaDialogPanel:Hide()
  StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI2, 'StoryBoard::OnPopUI');
end

function ArenaDialogPanel:onClose()
	self:Hide();
  MainUI:Pop();
end

function ArenaDialogPanel:Destroy()
  panel:DecRefCount();
  panel = nil;
end
--================================================================================
function ArenaDialogPanel:onShare()
	print("share");
end

function ArenaDialogPanel:onPlayback()
	print('playback');
end
--================================================================================
function ArenaDialogPanel:RefreshRecordPanel()
	stackPanel1:RemoveAllChildren();
	nonePanel.Visibility = Visibility.Visible;
	for _, record in pairs(ArenaPanel.records) do
		local item = customUserControl.new(stackPanel1, 'arenaResultTemplate');
		item.initWithRecord(record);
		nonePanel.Visibility = Visibility.Hidden;
	end
end

function ArenaDialogPanel:RefreshTitlePanel()
	local scrollCount = maxCount - ActorManager.user_data.arena.title_lv - 9;
	if scrollCount > 0 then
		scrollPanel2.VScrollPos = (itemHeight + stackPanel2.Space) * scrollCount;
	end
end

function ArenaDialogPanel:onTitleUp(id)
	notopenlist[id].open();
	table.remove(notopenlist);
end
--================================================================================
