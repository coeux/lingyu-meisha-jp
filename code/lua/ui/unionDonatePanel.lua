--unionDonatePanel.lua
--=============================================================================================
--捐献界面

UnionDonatePanel =
	{
	};
	
--变量
local donateList = {};

--控件
local panel;
local mainDesktop;
local labelMyDonate;
local btnList = {};
local gouList = {};
local btnClose;

--初始化
function UnionDonatePanel:InitPanel(desktop)	
	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('unionDonatePanel'));
	panel.Visibility = Visibility.Hidden;
	
	--vip达到等级，显示红包界面
	--[[
	local openVipLevel = resTableManager:GetValue(ResTable.vip_open, tostring(VipBuyType.vop_union_zhizun), 'viplv');
	if ActorManager.user_data.viplevel >= openVipLevel then
		panel = Panel(desktop:GetLogicChild('unionDonatePanelVip7'));
		panel.Visibility = Visibility.Hidden;
	end
	--]]
	
	panel:IncRefCount();
	
	panel.Visibility = Visibility.Hidden;

	donateList = {{resid = 10001, num = 10000, donate = 100};{resid = 10003, num = 20, donate = 200}; {resid = 10003, num = 120, donate = 1200}; {resid = 10003, num = 400, donate = 4000}};

	--初始化item
	for index = 1, 3 do
		local item = customUserControl.new(panel:GetLogicChild(tostring(index)):GetLogicChild('item'), 'itemTemplate');
		item.initWithInfo(donateList[index].resid, donateList[index].num, 100 ,true);
	end

	--初始化btn
	for index = 1, 3 do
		local btn = panel:GetLogicChild(tostring(index)):GetLogicChild('donate');
		btn:SubscribeScriptedEvent('Button::ClickEvent', 'UnionDonatePanel:onDonate');
		btn.Tag = index;
		btnList[index] = btn;
		gouList[index] = panel:GetLogicChild(tostring(index)):GetLogicChild('gou');
		gouList[index].Visibility = Visibility.Hidden;
	end
	
	labelMyDonate = panel:GetLogicChild('myDonatePanel'):GetLogicChild('labelDonate');

	btnClose = panel:GetLogicChild('close');
	btnClose:SubscribeScriptedEvent('Button::ClickEvent', 'UnionDonatePanel:onClose');
	
	--注册事件
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.nt_gang_pay_change, UnionDonatePanel, UnionDonatePanel.refresh);
end

--销毁
function UnionDonatePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function UnionDonatePanel:Show()
	self:refresh();
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function UnionDonatePanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--=============================================================================================
--功能函数
--刷新
function UnionDonatePanel:refresh()
	labelMyDonate.Text = tostring(ActorManager.user_data.curDonate);		--显示当前贡献值
	
	for index = 1, 3 do
		local donateItem = donateList[index];
		local flag = false;
		if donateItem.resid == 10001 then
			if ActorManager.user_data.money >= donateItem.num then
				flag = true;
			end
		elseif donateItem.resid == 10003 then
			if ActorManager.user_data.rmb >= donateItem.num then
				flag = true;
			end
		end
		btnList[index].Enable = flag;
		--判断是否已经捐献过
		if ActorManager.user_data.dailyDonate > 0 then
			if ActorManager.user_data.dailyDonate == donateItem.donate then
				gouList[index].Visibility = Visibility.Visible;
			else
				gouList[index].Visibility = Visibility.Hidden;
			end
			btnList[index].Enable = false;
		end
	end


	--[[
	for index = 1, 4 do
		local btnItem = btnList[index];
		local donateItem = donateList[index];
		if btnItem ~= nil then
			local good = resTableManager:GetValue(ResTable.item, tostring(donateItem.resid), {'icon', 'quality'});

			btnItem.donateValue.Text = '+' .. donateItem.donate;
			btnItem.gou.Visibility = Visibility.Hidden;
			btnItem.itemCell.ItemNum = donateItem.num;
			btnItem.itemCell.Image = GetIcon(good['icon']);

			if ActorManager.user_data.dailyDonate > 0 then
				if ActorManager.user_data.dailyDonate == donateItem.donate then
					btnItem.gou.Visibility = Visibility.Visible;
					btnItem.button.Enable = true;
					btnItem.button.Pick = false;
				else
					btnItem.button.Enable = false;
					btnItem.button.Pick = false;
				end
			else
				btnItem.button.Enable = true;
				btnItem.button.Pick = true;
			end
		end
	end
	--]]
end

--24点重置
function UnionDonatePanel:ResetUnionDonateAt24()
	ActorManager.user_data.dailyDonate = 0;

	if panel.Visibility == Visibility.Visible then
		self:refresh();
	end
end

--=============================================================================================
--事件
--关闭
function UnionDonatePanel:onClose()
	MainUI:Pop();
end

--捐献
function UnionDonatePanel:onDonate(Args)
	local args = UIControlEventArgs(Args);
	local donateItem = donateList[args.m_pControl.Tag];
	local msg = {};
	
	if args.m_pControl.Tag == 1 then		--金币		
		msg.money = donateItem.num;
		msg.rmb = 0;
	else 									--水晶
		msg.money = 0;
		msg.rmb = donateItem.num;
	end

	ActorManager.user_data.dailyDonate = ActorManager.user_data.dailyDonate + donateItem.donate;
	Network:Send(NetworkCmdType.req_gang_pay, msg);
end
