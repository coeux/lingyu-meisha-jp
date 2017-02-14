--announcementPanel.lua

--========================================================================
--announcement面板

AnnouncementPanel =
	{
		firstEnter = true;
	};

--初始化
function AnnouncementPanel:InitPanel( desktop )
	self.updateInfo = {};
	self.eventInfo = {};
	self.curType = 1;
	self.firstEnter = false;
	self.mainDesktop 	= desktop;
	self.announcementPanel = Panel( desktop:GetLogicChild('AnnouncementPanel') );
	self.btnPanel = self.announcementPanel:GetLogicChild('btnPanel')

	self.announcementPanel.ZOrder = 500;

	self.bgPanel 	= 	self.announcementPanel:GetLogicChild('bg');
	self.closeBtn 	= 	self.announcementPanel:GetLogicChild('close');

	self.btnPanel	= 	Panel( self.announcementPanel:GetLogicChild('btnPanel') );
	self.updateBtn 	=  	self.btnPanel:GetLogicChild('updateBtn');
	self.eventBtn 	= 	self.btnPanel:GetLogicChild('eventBtn');

	self.infoPanel 	= self.announcementPanel:GetLogicChild('infoPanel');
	self.listPanel = self.infoPanel:GetLogicChild('List');

	self.contentPanel = self.announcementPanel:GetLogicChild('contentPanel');
	self.title			= self.contentPanel:GetLogicChild('title');
	self.time			= self.contentPanel:GetLogicChild('time');
	self.info			= self.contentPanel:GetLogicChild('info');
	self.imgtip			= self.contentPanel:GetLogicChild('new');
	self.infoList 		= self.contentPanel:GetLogicChild('scrollPanel'):GetLogicChild('List')
	self.contentPanel.Background = CreateTextureBrush('Welfare/Welfare_ann_bg.ccz','Welfare');
	--self.contentPanel:GetLogicChild('imgBrush').Background = CreateTextureBrush('Welfare/Welfare_item_bg.ccz','Welfare');

	self.activityArea = 	self.announcementPanel:GetLogicChild('activityArea');
	self.tipPic = self.activityArea:GetLogicChild('tipPic')
	self.bgTop = self.activityArea:GetLogicChild(0);
	self.tipPic.Image =  GetPicture('Welfare/Welfare_title_5.ccz');
	self.activityArea.Background = CreateTextureBrush('Welfare/Welfare_bg_2.ccz','Welfare');
	--self.bgTop.Background = CreateTextureBrush('Welfare/welfare_top.ccz','Welfare');
	self.activityArea.Visibility = Visibility.Visible;


	--初始化时隐藏panel
	self.announcementPanel.Visibility = Visibility.Hidden;

	--事件绑定
	self.contentPanel:GetLogicChild('btn'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'AnnouncementPanel:HideInfo')
	self.updateBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'AnnouncementPanel:ClickBtn')
	self.eventBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'AnnouncementPanel:ClickBtn')
	self.eventBtn.Visibility = Visibility.Hidden;
end

--销毁
function AnnouncementPanel:Destroy()
	self.announcementPanel = nil;
end

--显示
function AnnouncementPanel:Show()
	self.infoPanel.Visibility = Visibility.Visible;
	self.contentPanel.Visibility = Visibility.Hidden;
	if not ActivityAllPanel:IsShow() then
		self.bgPanel.Visibility = Visibility.Visible
		self.announcementPanel.Margin = Rect(0, 0, 0, 0);
		self.closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'AnnouncementPanel:Hide');
	else
		self.announcementPanel.Margin = Rect(-122, -28, 0, 0);
		self.closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityAllPanel:OnClose');
	end
	self.announcementPanel.Visibility = Visibility.Visible;
end

--隐藏
function AnnouncementPanel:Hide()
	self.bgPanel.Visibility = Visibility.Hidden;
	self.announcementPanel.Visibility = Visibility.Hidden;
	ActorManager.user_data.reward.isshowtoday = 0
	if self.firstEnter then
		if not RolePortraitPanel:isFirstRecharge() then --首充
			FirstRechargePanel:firstEnterRechargePanel();
		else
			EverydayTipPanel:onShow();
		--[[
		elseif ActorManager.user_data.extra_data.is_pub_4 then --十连抽	
			EverydayTipPanel:Show(1)
		elseif showTime12 and LuaTimerManager:GetCurrentTimeStamp() <= (ActorManager.user_data.reward.servercreatestamp+tonumber(showTime12)*86400) then	--限定商店
			EverydayTipPanel:Show(2)
		elseif showTime13 and LuaTimerManager:GetCurrentTimeStamp() <= (ActorManager.user_data.reward.servercreatestamp+tonumber(showTime13)*86400) then	
			EverydayTipPanel:Show(3)
		elseif LuaTimerManager:GetCurrentTimeStamp() >= cardEvent.begin_stamp and LuaTimerManager:GetCurrentTimeStamp() <= cardEvent.end_stamp then
			EverydayTipPanel:Show(4)
			--]]
		end

		self.firstEnter = false;
	end
	--[[
	if not ActivityAllPanel:IsShow() then
		--判断今日是否有登录奖励，奖励是否已经领取
		local index = ActorManager.user_data.reward.lg_days;
		-- 0表示今天不是第一次登录,1表示今天第一次登录
		local isShowToday = 1;
		if ActorManager.user_data.reward.isshowtoday then
			isShowToday = ActorManager.user_data.reward.isshowtoday;
		end
		if index then
			if #TomorrowRewardPanel.receiveDay > 0 then
				local rowData1 = resTableManager:GetRowValue(ResTable.login_count, tostring(TomorrowRewardPanel.receiveDay[1]));

				if rowData1 and  isShowToday == 1 and ActorManager.user_data.role.lvl.level >= 8 then
					TomorrowRewardPanel:onShowRewardInfo(TomorrowRewardPanel.receiveDay[1], true);
				elseif isShowToday == 1 and ActorManager.user_data.role.lvl.level >= 8 then  --明天有登录奖励
					local count = TomorrowRewardPanel:nextCanDrawRewardDay(index);
					TomorrowRewardPanel:onShowRewardInfo(count, false);
				end
			elseif isShowToday == 1 and ActorManager.user_data.role.lvl.level >= 8 and not TomorrowRewardPanel:isGetAllReward() then 
				local count = TomorrowRewardPanel:nextCanDrawRewardDay(index);
				TomorrowRewardPanel:onShowRewardInfo(count, false);
			end
			ActorManager.user_data.reward.isshowtoday = 0;
		end
	end
	]]
end

--显示公告内容
function AnnouncementPanel:ShowInfo()
	self.contentPanel.Visibility = Visibility.Visible;
	self.infoPanel.Visibility = Visibility.Hidden;
end

--关闭公告内容
function AnnouncementPanel:HideInfo()
	self.contentPanel.Visibility = Visibility.Hidden;
	self.infoPanel.Visibility = Visibility.Visible;
end

--========================================================================
--功能函数
--========================================================================
--公告类型点击事件
function AnnouncementPanel:ClickBtn(Args)
	AnnouncementPanel:HideInfo()
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	AnnouncementPanel:RefreshPanel(tag)
	self.curType = tag;
end

--公告信息
function AnnouncementPanel:RefreshPanel(typeindex)
	self.listPanel:RemoveAllChildren();
	if typeindex == 1 then
		for _,upinfo in pairs(self.updateInfo) do
			local announceTemplate = uiSystem:CreateControl('AnnouncementTemplate')
			local radioBtn 	= announceTemplate:GetLogicChild(0);
			local titleInfo = radioBtn:GetLogicChild('title');
			local timeInfo 	= radioBtn:GetLogicChild('time');
			local infoLabel = radioBtn:GetLogicChild('info');
			local imgInfo 	= radioBtn:GetLogicChild('new');
			radioBtn.Background = CreateTextureBrush('Welfare/Welfare_item_bg.ccz','Welfare');
			titleInfo.Text = upinfo.title;
			timeInfo.Text = string.sub(upinfo.time, 6, 10);
			if not string.find(upinfo.content, '&') then
				infoLabel.Text = ''
			else
				infoLabel.Text = string.sub(upinfo.content,1,(string.find(upinfo.content, '&') -1));
			end
			radioBtn.Tag = upinfo.id;
			if LuaTimerManager:GetCurrentTimeStamp() - upinfo.timestamp < 86400 then
				imgInfo.Visibility = Visibility.Visible;
			else
				imgInfo.Visibility = Visibility.Hidden;
			end
			radioBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'AnnouncementPanel:showInfoPanel')
			self.listPanel:AddChild(announceTemplate);
		end
	else
		for _,updateinfo in pairs(self.eventInfo) do
			local announceTemplate = uiSystem:CreateControl('AnnouncementTemplate')
			local radioBtn 	= announceTemplate:GetLogicChild(0);
			local titleInfo = announceTemplate:GetLogicChild(0):GetLogicChild('title');
			local timeInfo 	= announceTemplate:GetLogicChild(0):GetLogicChild('time');
			local infoLabel = announceTemplate:GetLogicChild(0):GetLogicChild('info');
			local imgInfo 	= announceTemplate:GetLogicChild(0):GetLogicChild('new');
			titleInfo.Text = updateinfo.title;
			radioBtn.Tag = updateinfo.id;
			timeInfo.Text = string.sub(updateinfo.start_time, 6, 10);
			if not string.find(updateinfo.content, '&') then
				infoLabel.Text = ''
			else
				infoLabel.Text = string.sub(updateinfo.content,1,(string.find(updateinfo.content, '&') -1));
			end

			if LuaTimerManager:GetCurrentTimeStamp() - updateinfo.timestamp < 86400 then
				imgInfo.Visibility = Visibility.Visible;
			else
				imgInfo.Visibility = Visibility.Hidden;
			end

			radioBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'AnnouncementPanel:showInfoPanel')
			self.listPanel:AddChild(announceTemplate);
		end
	end
	self.infoPanel.VScrollPos = 0;
end

function AnnouncementPanel:showInfoPanel(Args)
	self.infoLen = 100;
	self.infoList:RemoveAllChildren();
	local args = UIControlEventArgs(Args);
	local id = args.m_pControl.Tag;
	if self.curType == 1 then
		for _,upinfo in pairs(self.updateInfo) do
			if id == upinfo.id then
				self.title.Text =  upinfo.title;
				self.time.Text = string.sub(upinfo.time, 6, 10);
				--if not string.find(upinfo.content, '&') then
					self.info.Text = ''
				--else
					--self.info.Text = string.sub(upinfo.content,1,(string.find(upinfo.content, '&') -1));
				--end
				if LuaTimerManager:GetCurrentTimeStamp() - upinfo.timestamp < 86400 then
					self.imgtip.Visibility = Visibility.Visible;
				else
					self.imgtip.Visibility = Visibility.Hidden;
				end
				local announinfo = upinfo.content
				local _,pos = string.find(announinfo,'&');
				while(pos)
				do	
					local pushinfo 	= string.sub(announinfo,1, pos - 1);
					announinfo = string.sub(announinfo,pos+1, string.len(announinfo));
					local infoTemplate = uiSystem:CreateControl('content')
					local infoContent 	= infoTemplate:GetLogicChild(0);
					infoContent.Text = pushinfo;
					if string.len(pushinfo) > self.infoLen then
						infoTemplate.Size = Size(500,  (string.len(pushinfo)/self.infoLen + 1) * 25)
						infoContent.Size = Size(500, (string.len(pushinfo)/self.infoLen + 1) * 25)
					else
						infoTemplate.Size = Size(500, 25)
						infoContent.Size = Size(500, 25)
					end
					self.infoList:AddChild(infoTemplate);
					_,pos = string.find(announinfo,'&');
				end
			end
		end
	else
		for _,upinfo in pairs(self.eventInfo) do
			if id == upinfo.id then
				self.title.Text =  upinfo.title;
				self.time.Text = string.sub(upinfo.start_time, 6, 10);
				if not string.find(upinfo.content, '&') then
					self.info.Text = ''
				else
					self.info.Text = string.sub(upinfo.content,1,(string.find(upinfo.content, '&') -1));
				end
				if LuaTimerManager:GetCurrentTimeStamp() - upinfo.timestamp < 86400 then
					self.imgtip.Visibility = Visibility.Visible;
				else
					self.imgtip.Visibility = Visibility.Hidden;
				end

				local announinfo = upinfo.content
				local _,pos = string.find(announinfo,'&');
				while(pos)
				do	
					local pushinfo 	= string.sub(announinfo,1, pos - 1);
					announinfo = string.sub(announinfo,pos+1, string.len(announinfo));
					local infoTemplate = uiSystem:CreateControl('content')
					local infoContent 	= infoTemplate:GetLogicChild(0);
					infoContent.Text = pushinfo;
					if string.len(pushinfo) > self.infoLen then
						infoTemplate.Size = Size(418,  (string.len(pushinfo)/self.infoLen + 1) * 25)
						infoContent.Size = Size(418, (string.len(pushinfo)/self.infoLen + 1) * 25)
					else
						infoTemplate.Size = Size(418, 25)
						infoContent.Size = Size(418, 25)
					end
					self.infoList:AddChild(infoTemplate);
					_,pos = string.find(announinfo,'&');
				end
			end
		end
	end
	AnnouncementPanel:ShowInfo()
	self.contentPanel:GetLogicChild('scrollPanel').VScrollPos = 0;
end


--========================================================================
--事件
--========================================================================
function  AnnouncementPanel:FirstEnter()
	self.firstEnter = true;
	self:ReqShowInfo();
end
--请求公告内容
function AnnouncementPanel:ReqShowInfo()
	if not ActivityAllPanel:IsShow() then
		if UserGuidePanel:GetInGuilding() then
			 return                   
		end

		if ActorManager.user_data.role.lvl.level <= 10 then
			return                   
		end 
	end

	Network:Send(NetworkCmdType.req_announcement_t, {});

end


--请求公告内容回调
function AnnouncementPanel:GetShowInfo(msg)
	self.updateInfo = {};
	self.eventInfo = {};
	for _,info in pairs(msg.info_update) do
		self.updateInfo[info.id] = info;
	end

	for _,info in pairs(msg.info_event) do
		self.eventInfo[info.id] = info;
	end
	AnnouncementPanel:RefreshPanel(1)
	self.updateBtn.Selected = true;
	Debug.print_var_dump(msg)
	AnnouncementPanel:Show()
end
