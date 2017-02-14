--CityPersonInfoPanel.lua
--========================================================================
--主城人物信息弹窗

CityPersonInfoPanel =
	{
		player = {}
	};	
local headPanel; 
local infoBtn;   	
local addBtn;    	
local chatBtn;   	
local infoPanel; 	
local nameLabel; 	
local unionLabel;	
local vipPanel;
local iconBg;    
local iconHead;  
local levelLabel;
  	
local mainDesktop;
local cityPersonInfoPanel;
--变量初始化

--初始化面板
function CityPersonInfoPanel:InitPanel(desktop)
	
	mainDesktop = desktop;
	cityPersonInfoPanel = Panel(desktop:GetLogicChild('mCityPersonInfoPanel'));
	cityPersonInfoPanel:IncRefCount();
	cityPersonInfoPanel.Visibility = Visibility.Hidden
	cityPersonInfoPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','CityPersonInfoPanel:Hide');
	cityPersonInfoPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'CityPersonInfoPanel:Hide');
	infoBtn   = cityPersonInfoPanel:GetLogicChild('infoBtn');
	infoBtn:SubscribeScriptedEvent('Button::ClickEvent','CityPersonInfoPanel:personInfo');
	addBtn    = cityPersonInfoPanel:GetLogicChild('addBtn');
	addBtn:SubscribeScriptedEvent('Button::ClickEvent','CityPersonInfoPanel:addPerson');
	chatBtn   = cityPersonInfoPanel:GetLogicChild('chatBtn');
	chatBtn:SubscribeScriptedEvent('Button::ClickEvent','CityPersonInfoPanel:goChat');
	
	infoPanel = cityPersonInfoPanel:GetLogicChild('infoPanel');
	nameLabel = infoPanel:GetLogicChild('nameLabel');
	unionLabel= infoPanel:GetLogicChild('unionLabel');
	vipPanel  = infoPanel:GetLogicChild('vipPanel');
	
	headPanel = cityPersonInfoPanel:GetLogicChild('headPanel');
	iconBg    = headPanel:GetLogicChild('iconBg')
	iconHead  = headPanel:GetLogicChild('iconhead')
	levelLabel= headPanel:GetLogicChild('levelLabel')
	
end
function CityPersonInfoPanel:personInfo()
	if self.player.id then
		PersonInfoPanel:ReqOtherInfosClick(self.player.id)
	end
end
function CityPersonInfoPanel:addPerson()
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.friendlist then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_CityPerson_2);
		return;
	end
	if self.player.id then
		Friend:onAddFriend(self.player.id)
	end
end
function CityPersonInfoPanel:goChat()
	--MessageBox:ShowDialog(MessageBoxType.Ok, '未開放');
	---[[
	if self.player.id then 
		--print('resID->'..tostring(self.player.resID));
		NewChatPanel:onWisper(self.player.id);
	end
	--]]
end
--销毁
function CityPersonInfoPanel:Destroy()
	cityPersonInfoPanel:IncRefCount();
	cityPersonInfoPanel = nil;
end

--显示
function CityPersonInfoPanel:Show(player)
	self.player = player
	self:nameShow(player)
	self:unionShow(player)
	self:vipShow(player)
	self:ShowHeadPanel(player)
	mainDesktop.FocusControl = cityPersonInfoPanel;
	-- 适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		cityPersonInfoPanel:SetScale(factor,factor)
	end
	cityPersonInfoPanel.Visibility = Visibility.Visible
	StoryBoard:ShowUIStoryBoard(cityPersonInfoPanel, StoryBoardType.ShowUI1, nil, '');
end
function CityPersonInfoPanel:vipShow(player)
	vipPanel:RemoveAllChildren()
	if player.viplevel > 0 then
		vipPanel.Margin = Rect(0,-1,0,0)
		local vipLabel = vipToImage(player.viplevel)
		vipLabel:SetScale(0.8,0.8)
		if player.viplevel > 9 then 
			vipLabel.Margin = Rect(-6,0,0,0)
		else
			vipLabel.Margin = Rect(-1,0,0,0)
		end
		vipPanel:AddChild(vipLabel)
	end
end
function CityPersonInfoPanel:nameShow(player)
	local index = 1
	if player.quality == 1 then
		index = 1
	elseif player.quality >1 and player.quality <=3 then
		index = 2
	elseif player.quality >= 4 and player.quality <= 6 then
		index = 3
	elseif player.quality >= 7 and player.quality <= 9 then
		index = 4
	elseif player.quality >= 10 and player.quality <= 13 then
		index = 5
	elseif player.quality >= 14 and player.quality <= 17 then
		index = 6
	end
	nameLabel.TextColor = QualityColor[index]
	nameLabel.Text = tostring(player.name)
end
function CityPersonInfoPanel:unionShow(player)
	if not string.isNilOrTemp(player.unName) then
		unionLabel.TextColor = QuadColor(Color(155, 255, 75, 255));
		unionLabel.Text = '【'..player.unName..'】'
	else
		unionLabel.TextColor = QuadColor(Color(255, 255, 255, 255));
		unionLabel.Text = LANG_CityPerson_1
	end
end
function CityPersonInfoPanel:ShowHeadPanel(player)
	if player.level then
		levelLabel.Text = 'Lv.'..player.level
	else
		print('level is nil!')
	end
	
	local imageName = resTableManager:GetValue(ResTable.navi_main, tostring(player.resID), 'role_path_icon');
	if imageName then
		iconHead.Image = GetPicture('navi/' .. imageName .. '.ccz');
	end
	iconBg.Image = GetPicture('main/main_cell.ccz');
end

--隐藏
function CityPersonInfoPanel:Hide()
	cityPersonInfoPanel.Visibility = Visibility.Hidden
	StoryBoard:HideUIStoryBoard(cityPersonInfoPanel, StoryBoardType.HideUI1, 'StoryBoard:OnPopUI');
end
function CityPersonInfoPanel:isShow()
	return cityPersonInfoPanel.Visibility == Visibility.Visible and true or false
end 

