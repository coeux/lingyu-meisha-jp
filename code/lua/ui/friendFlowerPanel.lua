--friendFlowerPanel.lua
FriendFlowerPanel = 
{
}

--变量
--控件
local maindesktop;
local panel;
local flowerList;
local flowerTimer;
local haveFlower;
local recordflowerstate;
local btnAll;
local btnClose;
local tip;
local listFlower;
local maincircle;

--初始化
function FriendFlowerPanel:InitPanel(desktop)
	--变量
	flowerList = {};
	flowerTimer = 0;
	haveFlower = false;
	self.newFlower = false;
	--控件
	maindesktop = desktop;
	panel = maindesktop:GetLogicChild('FriendFlowerPanel');
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.friendFLower;
	btnAll = panel:GetLogicChild('flowerPanel'):GetLogicChild('All');
	btnAll:SubscribeScriptedEvent('Button::ClickEvent', 'FriendFlowerPanel:accpetAll');
	btnClose = panel:GetLogicChild('flowerPanel'):GetLogicChild('close');
	btnClose:SubscribeScriptedEvent('Button::ClickEvent', 'FriendFlowerPanel:onClose');
    local title = panel:GetLogicChild('flowerPanel'):GetLogicChild('title');
    title.TextColor = QualityColor[6];
	tip = panel:GetLogicChild('flowerPanel'):GetLogicChild('tip');
	listFlower = panel:GetLogicChild('flowerPanel'):GetLogicChild('List'):GetLogicChild('flowerList');
    maincircle = FriendListPanel:VisibleMainCircle();
    recordflowerstate = false;
end

--销毁
function FriendFlowerPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end
--展现
function FriendFlowerPanel:Show()	   
	if(recordflowerstate) then    
		tip.Text = string.format(LANG_FRIEND_FLOWER_TIP, 60 - Friend.useFlower * 6);
		panel.Visibility = Visibility.Visible;
    else
		Toast:MakeToast(Toast.TimeLength_Long, '受け取れるハートはありません');
	end
end

--刷新鲜花获取
function FriendFlowerPanel:refresh(msg)
		flowerList = {};
		--Debug.print_var_dump("dfdfdaad", msg.flowers);
		if(msg.flowers and #msg.flowers > 0) then
			maincircle[1].Visibility = Visibility.Visible;
		else
			maincircle[1].Visibility = Visibility.Hidden;
		end
		listFlower:RemoveAllChildren();                                                       
		for _,info in pairs(msg.flowers) do
			recordflowerstate = true;      --此时说明别人送花了
			local flowerItem = customUserControl.new(listFlower, 'flowerTemplate');
			flowerItem.initWithInfo(info);
			flowerList[info.id] = flowerItem;
			haveFlower = true;
		end
		--开始计时
		if flowerTimer ~= 0 then
			timerManager:DestroyTimer(flowerTimer);
			flowerTimer = 0;
		end
		flowerTimer = timerManager:CreateTimer(1.0, 'FriendFlowerPanel:flowerTimerRefresh', 0);
		--检测是否有花
		self:UpdateFlowerTip()
		return haveFlower;
end

--隐藏
function FriendFlowerPanel:Hide()
	panel.Visibility = Visibility.Hidden;
end
--============================================================
--功能函数
--
function FriendFlowerPanel:onClose()
	self:Hide();
end

--全部接受
function FriendFlowerPanel:accpetAll()
	--flowerfix
	return;
--[[
    recordflowerstate = false;
	local msg = {};
	msg.uid = 0;
	Network:Send(NetworkCmdType.req_receive_all, msg);
--]]
end

--接受
function FriendFlowerPanel:accept(Args)
	--flowerfix
	return;
--[[
    recordflowerstate = false;
	local args = UIControlEventArgs(Args);
	local id = args.m_pControl.Tag;
	local msg = {};
	msg.id = id;
	Network:Send(NetworkCmdType.req_receive_flower, msg);
--]]
end

--接受返回
function FriendFlowerPanel:retAccept(idList)
	local numAddLp = 0;
	FriendListPanel:requireFlowerList();   --再次检测一下当前有没有送花的
	for _, id in pairs(idList) do
		local name = flowerList[id].getName();
		Toast:MakeToast(Toast.TimeLength_Long, 'スタミナ+6');
		Friend.useFlower = Friend.useFlower + 1;
		tip.Text = string.format(LANG_FRIEND_FLOWER_TIP, 60 - Friend.useFlower * 6);
		flowerList[id]:BeRemoved();
		flowerList[id] = nil;
		numAddLp = numAddLp + 1;
	end	
	self:UpdateFlowerTip()
end

--时间倒计时
function FriendFlowerPanel:flowerTimerRefresh()
	for _, flower in pairs(flowerList) do
		if not flower.update() then
			local id = flower.getId();
			flower:BeRemoved();
			flowerList[id] = nil;
		end
	end
end

function FriendFlowerPanel:UpdateFlowerTip()

	local count = 0  
	for k,v in pairs(flowerList) do  
		count = count + 1  
	end 
	if count ~= 0 or self.newFlower then
		MenuPanel.isHaveAcceptFlower = true
	else
		MenuPanel.isHaveAcceptFlower = false
	end
	MenuPanel:UpdateFriendTip()
end

