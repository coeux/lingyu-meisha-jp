--unionSetBossTimePanel.lua
--=====================================================================
--设置公会boss时间

UnionSetBossTimePanel =
	{
		day = 0;
	};
	
--变量

--控件
local mainDesktop;
local panel;
local timeLabelList = {};
local checkList = {};


--初始化
function UnionSetBossTimePanel:InitPanel(desktop)
	self.day = 0;
	
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('unionSetBossTimePanel');
	panel:IncRefCount();
	
	timeLabelList = {};
	for index = 1, 7 do
		local label = panel:GetLogicChild('time' .. index);
		table.insert(timeLabelList, label);
	end	
	
	checkList = {};
	for index = 1, 7 do
		local check = panel:GetLogicChild(tostring(index));
		check:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'UnionSetBossTimePanel:onBossTimeChange');
		checkList[math.mod(index, 7)] = check;
	end	
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function UnionSetBossTimePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function UnionSetBossTimePanel:Show()
	checkList[ActorManager.user_data.unionBossDay].Selected = true;
	self.day = ActorManager.user_data.unionBossDay;
	
	for i = 0, 6 do 
		if ActorManager.user_data.unionPos == 2 then
			checkList[i].Pick = true;
		else
			checkList[i].Pick = false;
		end
	end
	
	for i = 1, 7 do		
		timeLabelList[i].Text = LANG_unionSetBossTimePanel_1 .. NumToWeek[i] .. ' ' .. Time2HMStr(Configuration.UnionBossStartTime);
	end
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function UnionSetBossTimePanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--==============================================================================
--事件
--关闭事件
function UnionSetBossTimePanel:onClose()
	MainUI:Pop();
end

--时间改变事件
function UnionSetBossTimePanel:onBossTimeChange(Args)
	local args = UIControlEventArgs(Args);
	self.day = args.m_pControl.Tag;
end

--确认更改boss时间
function UnionSetBossTimePanel:SetBossTime()
	if ActorManager.user_data.unionPos == 2 then
		--只有会长可以更改boss时间
		local msg = {};
		msg.day = self.day;
		Network:Send(NetworkCmdType.req_set_gang_boss_time, msg);
	end
	
	MainUI:Pop();
end

--服务器返回时间更改
function UnionSetBossTimePanel:ChangeBossTimeSuccess(msg)
	ActorManager.user_data.unionBossDay = self.day;
end