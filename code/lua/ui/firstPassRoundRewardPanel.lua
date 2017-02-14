--FirstPassRoundRewardPanel.lua
--=============================================================================================
--捐献界面

FirstPassRoundRewardPanel =
{
};

--初始化
function FirstPassRoundRewardPanel:InitPanel(desktop)
	--控件初始化
	self.mainDesktop = desktop;
	self.panel = Panel(desktop:GetLogicChild('firstPassRewardPanel'));
	self.panel.Visibility = Visibility.Hidden;
	self.panel:IncRefCount();

	self.titlePic = self.panel:GetLogicChild('titlePic');
	self.titlePic.Image = GetPicture('dynamicPic/first_pass_round.ccz');
	self.armature = self.panel:GetLogicChild('armature');
	self.sureBtn = self.panel:GetLogicChild('sureBtn');
	self.sureBtn:SubscribeScriptedEvent('Button::ClickEvent', 'FirstPassRoundRewardPanel:onClose');

	self.bgPic = self.panel:GetLogicChild('bgPic');
	self.rewardPanel = self.bgPic:GetLogicChild('rewardPanel');
	self.passRound = self.bgPic:GetLogicChild('passRound');
	self.passRound.Visible = Visibility.Hidden;
	self.stackPanel = self.bgPic:GetLogicChild('stackPanel');
	self.rewardPic = self.bgPic:GetLogicChild('rewardPic');

	self.rewardName = self.rewardPic:GetLogicChild('rewardName');
	self.haveNum = self.rewardPic:GetLogicChild('haveNum');
	self.tip = self.rewardPic:GetLogicChild('tip');
	self.progress = self.rewardPic:GetLogicChild('progress');
	self.needNum = self.rewardPic:GetLogicChild('needNum');

	self.stackPanel.Visibility = Visibility.Hidden;
end

function FirstPassRoundRewardPanel:GetReturnBtn()
	return self.sureBtn;
end

--销毁
function FirstPassRoundRewardPanel:Destroy()
	self.panel:DecRefCount();
	self.panel = nil;
end

--显示
function FirstPassRoundRewardPanel:Show()
	mainDesktop:DoModal(self.panel);
	StoryBoard:ShowUIStoryBoard(self.panel, StoryBoardType.ShowUI1);
end

function FirstPassRoundRewardPanel:onShow(roundid, itemid, num)
	self.stackPanel:RemoveAllChildren();
	if roundid > 5000 and roundid < 6000 then
		--精英副本
		self.stackPanel.Visibility = Visibility.Hidden;
		self.rewardPic.Visibility = Visibility.Visible;
		self.rewardPanel.Visibility = Visibility.Visible;

		local roundName = resTableManager:GetValue(ResTable.barriers, tostring(roundid), 'name');
		self.passRound.Text = LANG_first_pass_round_name .. roundName;
		local pieceName = resTableManager:GetValue(ResTable.item, tostring(itemid), 'name');
		self.rewardName.Text = tostring(pieceName);
		self.tip.Visibility = Visibility.Visible;
		local needPieceNum = 80;
		local stuffID = 12;
		if not ActorManager:IsHavePartner(itemid - 30000) and (itemid - 30000) ~= 0 then
			-- local rank = resTableManager:GetValue(ResTable.item, tostring(itemid), 'quality');
			-- stuffID = (itemid - 30000) * 10 + rank + 1;
		 -- 	if rank == 5 then
		 --    	stuffID = (itemid - 30000) * 10 + 6;
		 --  	end
		  	needPieceNum = resTableManager:GetValue(ResTable.actor, tostring(itemid - 30000), 'hero_piece');
		else
			local currentRole = ActorManager:GetRoleFromResid(itemid - 30000);
	  		stuffID = currentRole.resid * 10 + currentRole.rank + 1 + 1;
		 	if currentRole.rank == 5 then
		    	stuffID = currentRole.resid * 10 + 6;
		  	end
		  	local stuffData = resTableManager:GetRowValue(ResTable.qualityup_stuff, tostring(stuffID));
		  	needPieceNum = stuffData['var1'];
		end
		
  		-- local stuffData = resTableManager:GetRowValue(ResTable.qualityup_stuff, tostring(stuffID))
		local chipItem = Package:GetChip(itemid);
		--  设置进度条
		if chipItem then
			--在显示这个界面之前服务器已经将碎片加入背包并且给客户端发了通知
		    self.haveNum.Text = tostring(chipItem.count);
		    self.needNum.Text = '/' .. tostring(needPieceNum);  
	    	if(tonumber(self.haveNum.Text) < tonumber(needPieceNum)) then
		      self.progress.CurValue = chipItem.count;
		      self.haveNum.TextColor = QuadColor(Color(255, 0, 0, 255));
		    else
		      self.progress.CurValue = needPieceNum;
		      self.haveNum.TextColor = QuadColor(Color(0, 255, 0, 255));
	    	end
	  	else
		    self.haveNum.Text = tostring(0) .. '/';
		    self.needNum.Text = tostring(needPieceNum);
		    self.progress.CurValue = 0; 
		end
	 	self.progress.MaxValue = needPieceNum;
	 	local ctrl = customUserControl.new(self.rewardPanel, 'itemTemplate');
		ctrl.initWithInfo(itemid, num, 80, true);
	elseif roundid > 4000 and roundid < 5000 then
		self.stackPanel.Visibility = Visibility.Visible;
		self.rewardPic.Visibility = Visibility.Hidden;
		self.rewardPanel.Visibility = Visibility.Hidden;
		--探宝
		self.passRound.Text = string.format(LANG_first_pass_treasure_name, roundid - 4000);
		local drop_list = resTableManager:GetValue(ResTable.treasure, tostring(roundid), 'first_drop');
		for i=1,#drop_list do
			local resid = drop_list[i][1];
			local num = drop_list[i][3];
			local ctrl = customUserControl.new(self.stackPanel, 'itemTemplate');
			ctrl.initWithInfo(resid, num, 80, true);
		end
	end

	self.armature:LoadArmature('guang');
	self.armature:SetAnimation('play');

	MainUI:Push(self);
end

function FirstPassRoundRewardPanel:onClose()
	--if ActorManager.user_data.userguide.isnew == UserGuideIndex.task10 and Task:getMainTaskId() == SystemTaskId[UserGuideIndex.task10] then
	--	UserGuidePanel:ShowGuideShade(TreasurePanel:GetReturnBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	--end
	MainUI:Pop();
end

function FirstPassRoundRewardPanel:Hide()
	StoryBoard:HideUIStoryBoard(self.panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	GodsSenki:BackToMainScene(SceneType.HomeUI)	
end