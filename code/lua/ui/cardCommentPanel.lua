--CardCommentPanel.lua
--=============================================================================================
--捐献界面

CardCommentPanel =
{
	message 					= '';
	currentResid 				= 0;
	currentUid					= 0;
	currentRoleInfo 			= nil;
	reqNewestCommentStamp 		= {};				--刷新最新评论的时间间隔
	reqHotestCommentstamp 		= {};				--刷新最热评论的时间间隔
	lastNewestComment 			= {};				--上一次最新评论缓存
	lastHotestComment			= {};				--上一次最热评论缓存
	content 					= {};				--评论文字
	praiseNumLabel 				= {};				--显示赞的label
	praiseNumMaxComment 		= {};				--点赞最多的一条评论
};


--初始化
function CardCommentPanel:InitPanel(desktop)
	--控件初始化
	self.currentRoleInfo = nil;
	self.currentResid = 0;
	self.currentUid = 0;
	self.message = '';
	self.content = '';
	self.lastNewestComment = {};
	self.lastHotestComment = {};
	self.praiseNumLabel = {};
	self.reqNewestCommentStamp = {};
	self.reqHotestCommentstamp = {};
	self.praiseNumMaxComment = {};

	self.mainDesktop = desktop;
	self.commentCardPanel = Panel(desktop:GetLogicChild('commentCardPanel'));
	self.commentCardPanel.Visibility = Visibility.Hidden;
	self.commentCardPanel:IncRefCount();

	self.title = self.commentCardPanel:GetLogicChild('titlebg'):GetLogicChild('title');
	self.closeBtn = self.commentCardPanel:GetLogicChild('closeBtn');
	self.closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardCommentPanel:onClose');
	self.scrollPanel = self.commentCardPanel:GetLogicChild('scrollPanel')
	self.stackPanel = self.scrollPanel:GetLogicChild('stackPanel');
	self.comment = self.commentCardPanel:GetLogicChild('comment');
	self.messageLabel = self.commentCardPanel:GetLogicChild('message');
	self.sendBtn = self.commentCardPanel:GetLogicChild('sendBtn');
	self.sendBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardCommentPanel:sendComment');
	self.bg = self.commentCardPanel:GetLogicChild('bg');
	self.tip = self.commentCardPanel:GetLogicChild('tip');
	self.tip.Visibility = Visibility.Hidden;

	self.noRolePanel = self.commentCardPanel:GetLogicChild('noRolePanel');
	self.mainPicPanel = self.commentCardPanel:GetLogicChild('mainPicPanel');
	self.mainPicPanel.Translate = Vector2(-50,0);
	self.showSelfPanel = self.commentCardPanel:GetLogicChild('showSelfPanel');
	self.showSelfPanel.Visibility = Visibility.Hidden;
	self.haveRolePanel = self.commentCardPanel:GetLogicChild('haveRolePanel');
	self.mainRolePanel = self.commentCardPanel:GetLogicChild('mainRolePanel');
	self.rolePicPanel = self.commentCardPanel:GetLogicChild('rolePicPanel');

	self.btnPanel = self.commentCardPanel:GetLogicChild('btnPanel');
	self.newestBtn = self.btnPanel:GetLogicChild('newestBtn');
	self.newestBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'CardCommentPanel:onChangeRadio');
	self.newestBtn.GroupID = RadionButtonGroup.cardComment;
	self.newestBtn.Tag = 1;
	self.hotestBtn = self.btnPanel:GetLogicChild('hotestBtn');
	self.hotestBtn.GroupID = RadionButtonGroup.cardComment;
	self.hotestBtn.Tag = 2;
	-- self.hotestBtn:GetLogicChild('hotestLabel').Text = '最热';
	self.hotestBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'CardCommentPanel:onChangeRadio');

	self.checkBox = self.showSelfPanel:GetLogicChild('checkBox');
    self.checkBox:SubscribeScriptedEvent('CheckBox::CheckChangedEvent', 'CardCommentPanel:onCheckBoxChanged');
    self.selectPic = self.checkBox:GetLogicChild('select');

    self.worldLine1 = self.commentCardPanel:GetLogicChild('worldLine1');
    self.worldLine2 = self.commentCardPanel:GetLogicChild('worldLine2');

    self.checkBox.Visibility = Visibility.Visible;
    self.selectPic.Visibility = Visibility.Hidden;
    self.noRolePanel.Visibility = Visibility.Hidden;
    self.mainRolePanel.Visibility = Visibility.Hidden;
    self.haveRolePanel.Visibility = Visibility.Hidden;
end

--销毁
function CardCommentPanel:Destroy()
	self.commentCardPanel:DecRefCount();
	self.commentCardPanel = nil;
end

function CardCommentPanel:sendComment()
	-- local info = ActorManager:GetRole(18);   --14, 1, 18
	-- self:showNoRolePanel(info);
	-- self:showHaveRolePanel(self.role);
	-- self:showMainRolePanel(ActorManager.user_data.role);
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.cardComment then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_open_card_comment);
		return;
	end
	self.content = tostring(self.messageLabel.Text);

	if utf8.len(self.content) < Configuration.commentMinWords then
    	--评论字数不够
    	Toast:MakeToast(Toast.TimeLength_Long, LANG_card_comment_info_4);
    	return;
	end

	self.messageLabel.Text = '';
	local msg ={};
	msg.uid = ActorManager.user_data.uid;
	msg.isshow = 0;--self.checkBox.Checked and 1 or 0;
	msg.resid = self.currentResid;
	msg.comment = tostring(self.content);
	Network:Send(NetworkCmdType.req_comment_card, msg);
end

function CardCommentPanel:getCommentInfo()
	local info = {};
	info.praisenum = 0;
	info.uid = ActorManager.user_data.uid;
	info.name = tostring(ActorManager.user_data.name);
	info.comment = tostring(self.content);
	info.isshow = self.checkBox.Checked and 1 or 0;
	info.viplevel = ActorManager.user_data.viplevel;
	info.grade = ActorManager.user_data.role.lvl.level;

	local equip_lvl = Configuration.equip_max_level;
    if ActorManager.user_data.role.equips then
      for i=1, 5 do
        if ActorManager.user_data.role.equips[tostring(i)] then
          local equip_resid = ActorManager.user_data.role.equips[tostring(i)].resid
          local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(equip_resid), 'rank')
          if equip_rank < equip_lvl then
            equip_lvl = equip_rank
          end
        end
      end
    end
	info.equiprank = equip_lvl;

	return info;
end

function CardCommentPanel:onRetComment(msg)
	if msg.code == 0 then
		--当前缓存已经满了
		if #self.lastNewestComment[self.currentResid] >= Configuration.commentNewestCacheLen then
			table.remove(self.lastNewestComment[self.currentResid], 50);
		end
		--临时表
		local tab = {};
		tab[1] = self:getCommentInfo();
		for i=1,#self.lastNewestComment[self.currentResid] do
			tab[i + 1] = self.lastNewestComment[self.currentResid][i];
		end
		self.lastNewestComment[self.currentResid] = msg.infos;
		self:onShow(self.currentRoleInfo, self.lastNewestComment[self.currentResid]);
	end
end

function CardCommentPanel:onChangeRadio(Arg)
	local arg = UIControlEventArgs(Arg);
	local tag = arg.m_pControl.Tag;
	if tag == 1 then
		self.newestBtn.Selected = true;
		self:showNewestComment();
	elseif tag ==2 then
		self.hotestBtn.Selected = true;
		self:showHotestComment();
	end
	self.scrollPanel.VScrollPos = 0;
end

function CardCommentPanel:initCommentTemplate(messageInfo)
	local control = uiSystem:CreateControl('commentTemplate');
	local ctrl = control:GetLogicChild(0);
	local bestPic = ctrl:GetLogicChild('bestPic');
	local praiseNum = ctrl:GetLogicChild('praiseNum');
	local comment = ctrl:GetLogicChild('comment');
	local userName = ctrl:GetLogicChild('userName');
	local grade = ctrl:GetLogicChild('grade');
	local vipPanel = ctrl:GetLogicChild('vipPanel');
	local praiseBtn = ctrl:GetLogicChild('praise');
	local btnPanel = ctrl:GetLogicChild('panel');

	if messageInfo.praisenum and messageInfo.praisenum >= 100 then
		bestPic.Visibility = Visibility.Visible;
	else
		bestPic.Visibility = Visibility.Hidden;
	end
	praiseNum.Text = tostring(messageInfo.praisenum or 0);
	self.praiseNumLabel[messageInfo.id] = praiseNum;
	--过屏蔽字
	local str = LimitedWord:replaceLimited(messageInfo.comment);
	comment.Text = tostring(str or '');
	if messageInfo.isshow == 1 then
		userName.Font = uiSystem:FindFont('huakang_18_underline');
		userName.Tag = messageInfo.uid;
		userName:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardCommentPanel:displayUserInfo');
	else
		userName.Font = uiSystem:FindFont('huakang_18');
	end
	userName.TextColor = QualityColor[Configuration:getNameColorByEquip(messageInfo.equiprank or 1)];
	userName.Text = tostring(messageInfo.name or '');
	if messageInfo.grade then
		grade.Text = 'LV.' .. messageInfo.grade;
	end
	if messageInfo.viplevel and messageInfo.viplevel > 0 then
		vipPanel.Visibility = Visibility.Visible;
		local viplbl = vipToImage(messageInfo.viplevel or 0);
		viplbl:SetScale(0.7, 0.7);
		viplbl.Horizontal = ControlLayout.H_CENTER;
	  	viplbl.Vertical = ControlLayout.V_CENTER;
		vipPanel:AddChild(viplbl);
	else
		vipPanel.Visibility = Visibility.Hidden;
	end

	btnPanel.Tag = messageInfo.uid;
	btnPanel.TagExt = messageInfo.id;
	btnPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardCommentPanel:onPraise');

	return control;
end

function CardCommentPanel:initRoleHead(roleInfo, size, isHave, isShowAttribute)
	local control = uiSystem:CreateControl('cardHeadTemplate');
	if size and size > 0 then
		control:SetScale(size/100,size/100);
	else
		control:SetScale(0.5,0.5);
	end
	local quality = control:GetLogicChild(0):GetLogicChild('fg');
	local imageHead = control:GetLogicChild(0):GetLogicChild('img');
	local selectMark = control:GetLogicChild(0):GetLogicChild('select');
	local lvlMark = control:GetLogicChild(0):GetLogicChild('lvl');
	local loveMark = control:GetLogicChild(0):GetLogicChild('love');
	local attributeMark = control:GetLogicChild(0):GetLogicChild('attribute');
	local rankMark = control:GetLogicChild(0):GetLogicChild('quality');
	local dataInfo = resTableManager:GetRowValue(ResTable.actor, tostring(roleInfo.resid));
	imageHead.Image = GetPicture('navi/' .. dataInfo['img'] .. '_icon_01.ccz');

	if isHave then
		loveMark.Visibility = (roleInfo.lvl.lovelevel == 4) and Visibility.Visible or Visibility.Hidden
		rankMark.Visibility = Visibility.Visible;
		attributeMark.Visibility = Visibility.Visible;
		attributeMark.Image = GetPicture('login/login_icon_' .. self.currentRoleInfo.attribute .. '.ccz');
		rankMark.Image = GetPicture('personInfo/nature_' .. (roleInfo.quality - 1) .. '.ccz');

		local equip_lvl = 100;
		for i=1, 5 do
			local equip_resid = roleInfo.equips[tostring(i)].resid;
			local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(equip_resid), 'rank');
			if equip_rank < equip_lvl then
				equip_lvl = equip_rank;
			end
		end
		quality.Image = GetPicture('home/head_frame_' .. tostring(equip_lvl) .. '.ccz');
	else
		quality.Image = GetPicture('home/head_frame_2.ccz');
		if isShowAttribute then
			attributeMark.Visibility = Visibility.Visible;
			attributeMark.Image = GetPicture('login/login_icon_' .. self.currentRoleInfo.attribute .. '.ccz');
		else
			attributeMark.Visibility = Visibility.Hidden;
		end
		loveMark.Visibility = Visibility.Hidden;
		rankMark.Visibility = Visibility.Hidden;
	end
	selectMark.Visibility = Visibility.Hidden;
	lvlMark.Visibility = Visibility.Hidden;

	control.Horizontal = ControlLayout.H_CENTER;
  	control.Vertical = ControlLayout.V_CENTER;

  	return control;
end

function CardCommentPanel:initRolePicPanel(roleInfo)
	local pic = self.rolePicPanel:GetLogicChild('pic');
	-- local roleName = self.rolePicPanel:GetLogicChild('roleName');
	local roleType = self.rolePicPanel:GetLogicChild('roleType');
	local rolePanel = self.rolePicPanel:GetLogicChild('panel');
	local comElement = self.rolePicPanel:GetLogicChild('comElement');
	comElement:RemoveAllChildren();
	local dataInfo = resTableManager:GetRowValue(ResTable.actor, tostring(roleInfo.resid));
	pic.Image = GetPicture('login/login_icon_' .. dataInfo['attribute'] .. '.ccz');
	-- roleName.Text = tostring(dataInfo['name']);
	local font = uiSystem:FindFont('huakang_22_noborder');
	comElement:AddText(tostring(dataInfo['name']), QuadColor(Color(0, 0, 0, 255)), font);
	if tonumber(dataInfo['hit_area']) == 15 then
		roleType.Text = LANG_CardDetailPanel_1;
	elseif tonumber(dataInfo['hit_area']) == 130 then
		roleType.Text = LANG_CardDetailPanel_2;
	elseif tonumber(dataInfo['hit_area']) == 260 then
		roleType.Text = LANG_CardDetailPanel_3;
	end

	local ctrl = self:initRoleHead(roleInfo, 60, false, false);
	rolePanel:AddChild(ctrl);
end

function CardCommentPanel:onShow(roleInfo, infos)
	self.commentCardPanel.Background = CreateTextureBrush('home/home_comment_bg.ccz','godsSenki');
	self.worldLine1.Background = CreateTextureBrush('home/home_comment_line.ccz','godsSenki');
	self.worldLine2.Background = CreateTextureBrush('home/home_comment_line.ccz','godsSenki');

	self.messageLabel.Text = '';
	self.comment.Text = LANG_card_comment_info_2; 
	self.checkBox.Checked = true;
	self.scrollPanel.VScrollPos = 0;
	if roleInfo.pid == 0 then
		self.mainPicPanel.Visibility = Visibility.Hidden;
		self.rolePicPanel.Visibility = Visibility.Hidden;
		local lbl = self.mainPicPanel:GetLogicChild('lbl');
		lbl.Translate = Vector2(30,0);
		local panel1 = self.mainPicPanel:GetLogicChild('panel1');
		local roleInfo1 = {};
		roleInfo1.resid = 101;
		roleInfo1.attribute = 201;
		local ctrl1 = self:initRoleHead(roleInfo1, 60, false, false);
		panel1:AddChild(ctrl1);
		local panel2 = self.mainPicPanel:GetLogicChild('panel2');
		panel2.Visibility = Visibility.Visible;
		panel2.Translate = Vector2(10, 0);
		local roleInfo2 = {};
		roleInfo2.resid = 102;
		roleInfo2.attribute = 202;
		local ctrl2 = self:initRoleHead(roleInfo2, 60, false, false);
		panel2:AddChild(ctrl2);
		local panel3 = self.mainPicPanel:GetLogicChild('panel3');
		panel3.Translate = Vector2(20, 0);
		local roleInfo3 = {};
		roleInfo3.resid = 103;
		roleInfo3.attribute = 200;
		local ctrl3 = self:initRoleHead(roleInfo3, 60, false, false);
		panel3:AddChild(ctrl3);
	else
		self.mainPicPanel.Visibility = Visibility.Hidden;
		self.rolePicPanel.Visibility = Visibility.Hidden;
		self:initRolePicPanel(roleInfo);
	end

	--加载评论数据
	self.stackPanel:RemoveAllChildren();
	if not infos then
		return;
	end
	if #infos == 0 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_card_comment_info_3);
	end

	--有最热评论，则将最热评论放到第一个位置
	local info_ = self.praiseNumMaxComment[self.currentResid];
	if info_ and info_.uid ~= 0 and info_.id > 0 and self.newestBtn.Selected == true then
		local ctrl = self:initCommentTemplate(info_);
		self.stackPanel:AddChild(ctrl);
	end

	for i=1,#infos do
		local ctrl = self:initCommentTemplate(infos[i]);
		self.stackPanel:AddChild(ctrl);
	end

	if not(self.commentCardPanel.Visibility == Visibility.Visible) then
		MainUI:Push(self);
	end
end

function CardCommentPanel:onReqCommentPanel(roleInfo)
	self.currentRoleInfo = roleInfo;
	self.currentResid = roleInfo.resid;
	self.newestBtn.Selected = true;
	--重新请求   1 当前时间戳大于上一次时间戳加上时间间隔  2 没有上一次的评论信息  3 没有上一次时间戳
	if not self.lastNewestComment[roleInfo.resid] or not self.reqNewestCommentStamp[roleInfo.resid] or 
		(self.reqNewestCommentStamp[roleInfo.resid] + Configuration.reqNewestCommentInterval) < LuaTimerManager:GetCurrentTimeStamp() then
		local msg = {};
		msg.uid = ActorManager.user_data.uid;
		msg.resid = roleInfo.resid;
		msg.type = 1;
		Network:Send(NetworkCmdType.req_newest_card_comment, msg);
	else
		CardCommentPanel:onShow(roleInfo, self.lastNewestComment[roleInfo.resid]);
	end
end

function CardCommentPanel:onReceiveComment(msg)
	-- Debug.dump_lua(msg.infos);
	if msg.type == 1 then
		self.lastNewestComment[self.currentResid] = msg.infos;
		self.reqNewestCommentStamp[self.currentResid] = msg.stamp;
		self.praiseNumMaxComment[self.currentResid] = msg.max_comment;
	--	CardCommentPanel:onShow(self.currentRoleInfo, msg.infos);
	elseif msg.type == 2 then
		self.lastHotestComment[self.currentResid] = msg.infos;
		self.reqHotestCommentstamp[self.currentResid] = msg.stamp;
	--	CardCommentPanel:onShow(self.currentRoleInfo, msg.infos);
	end
end

function CardCommentPanel:update_commment(msg)
     if msg.type == 1 then
         self.lastNewestComment[self.currentResid] = msg.infos;
         self.praiseNumMaxComment[self.currentResid] = msg.max_comment;
         CardCommentPanel:onShow(self.currentRoleInfo, msg.infos);
     elseif msg.type == 2 then
         self.lastHotestComment[self.currentResid] = msg.infos;
         CardCommentPanel:onShow(self.currentRoleInfo, msg.infos);
     end
end

--显示
function CardCommentPanel:Show()
	mainDesktop:DoModal(self.commentCardPanel);
	--增加UI弹出时候的效果
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		StoryBoard:ShowUIStoryBoard(self.commentCardPanel, StoryBoardType.ShowUIScale);
	else
		StoryBoard:ShowUIStoryBoard(self.commentCardPanel, StoryBoardType.ShowUI1);
	end
	GodsSenki:LeaveMainScene()
end

function CardCommentPanel:onPraise(Args)
	local args = UIControlEventArgs(Args);
 	local msg = {};
 	msg.commentid = args.m_pControl.TagExt;
 	msg.commentuid = args.m_pControl.Tag;
 	msg.praiseuid = ActorManager.user_data.uid;
 	Network:Send(NetworkCmdType.req_praise_comment, msg);
end

function CardCommentPanel:onRetPraise(msg)
	if msg.code == 0 then
		local num = tonumber(self.praiseNumLabel[msg.id].Text );
		self.praiseNumLabel[msg.id].Text = tostring(num + 1);
		local tab = self.lastNewestComment[self.currentResid];
		local tab1 = self.lastHotestComment[self.currentResid];
		--最新评论里找,找到就加1
		for i=1,#tab do
			if tab[i].id == msg.id then
				tab[i].praisenum = tab[i].praisenum + 1;
				break;
			end
		end
		--最热的评论里如果包含这条则也加1
		if tab1 then
			for i=1,#tab1 do
				if tab1[i].id == msg.id then
					tab1[i].praisenum = tab1[i].praisenum + 1;
					break;
				end
			end
		end
	end
end

function CardCommentPanel:displayUserInfo(Args)
	local arg = UIControlEventArgs(Args);
 	local uid = arg.m_pControl.Tag;
 	self.currentUid = uid;
 	-- local msg = {};
 	-- msg.uid = uid;
 	-- msg.resid = self.currentResid;
 	-- Network:Send(NetworkCmdType.req_index_role_info, msg);
end

function CardCommentPanel:onRetIndexRoleInfo(msg)
	if msg.isfind == 0 then
		--没有该角色
		self:showNoRolePanel(self.currentRoleInfo, msg.name);
	elseif msg.isfind == 1 then
		if self.currentRoleInfo.resid > 100 then
			self:showMainRolePanel(msg.data, msg.name, msg.resid);
		else
			self:showHaveRolePanel(msg.data, msg.name);
		end
	end
end

function CardCommentPanel:getEquipRankByUid(uid)
	local messageInfo = nil;
	for i=1,#self.lastNewestComment[self.currentResid] do
		if self.lastNewestComment[self.currentResid][i].uid == uid then
			messageInfo = self.lastNewestComment[self.currentResid][i];
			break;
		end
	end
	if not messageInfo and self.lastHotestComment[self.currentResid] then
		for i=1,#self.lastHotestComment[self.currentResid] do
			if self.lastHotestComment[self.currentResid][i].uid == uid then
				messageInfo = self.lastHotestComment[self.currentResid][i];
				break;
			end
		end
	end

	if messageInfo then
		return messageInfo.equiprank;
	else
		return 1;
	end
end

function CardCommentPanel:showNoRolePanel(roleInfo, name)
	self.noRolePanel.Visibility = Visibility.Visible;
	self.bg.Visibility = Visibility.Visible;

	local btnClose = self.noRolePanel:GetLogicChild('closeBtn');
	local rolePanel = self.noRolePanel:GetLogicChild('rolePanel');
	local uname = self.noRolePanel:GetLogicChild('userName');
	local rname = self.noRolePanel:GetLogicChild('roleName');

	btnClose:SubscribeScriptedEvent('Button::ClickEvent', 'CardCommentPanel:closeNoRolePanel');
	local ctrl = self:initRoleHead(roleInfo, 100, false, true);
	rolePanel:AddChild(ctrl);

	local rank = self:getEquipRankByUid(self.currentUid);
	uname.TextColor = QualityColor[Configuration:getNameColorByEquip(rank or 1)];
	uname.Text = tostring(name or '');
	rname.Text = string.format(LANG_card_comment_info_1, tostring(roleInfo.name));
end

function CardCommentPanel:showHaveRolePanel(roleInfo, name)
	self.haveRolePanel.Visibility = Visibility.Visible;
	self.bg.Visibility = Visibility.Visible;

	local rolePanel =  self.haveRolePanel:GetLogicChild('rolePanel');
	local btnClose = self.haveRolePanel:GetLogicChild('closeBtn');
	local roleName = self.haveRolePanel:GetLogicChild('roleInfoPanel'):GetLogicChild('roleName');
	local grade = self.haveRolePanel:GetLogicChild('roleInfoPanel'):GetLogicChild('grade');
	local userName = self.haveRolePanel:GetLogicChild('userInfoPanel'):GetLogicChild('userName');
	local atkValue = self.haveRolePanel:GetLogicChild('atkInfoPanel'):GetLogicChild('atkValue');
	local magAtkValue = self.haveRolePanel:GetLogicChild('magAtkInfoPanel'):GetLogicChild('magAtkValue');
	local defValue = self.haveRolePanel:GetLogicChild('defInfoPanel'):GetLogicChild('defValue');
	local magDefValue = self.haveRolePanel:GetLogicChild('magDefInfoPanel'):GetLogicChild('magDefValue');
	local hpValue = self.haveRolePanel:GetLogicChild('hpInfoPanel'):GetLogicChild('hpValue');

	local ctrl = self:initRoleHead(roleInfo, 100, true, true);
	rolePanel:AddChild(ctrl);
	grade.Text = tostring(roleInfo.lvl.level);

	local rank = self:getEquipRankByUid(self.currentUid);
	userName.TextColor = QualityColor[Configuration:getNameColorByEquip(rank or 1)];
	userName.Text = tostring(name or '');
	roleName.Text = tostring(self.currentRoleInfo.name);
	atkValue.Text = tostring(roleInfo.pro.atk);
	magAtkValue.Text = tostring(roleInfo.pro.mgc);
	defValue.Text = tostring(roleInfo.pro.def);
	magDefValue.Text = tostring(roleInfo.pro.res);
	hpValue.Text = tostring(roleInfo.pro.hp);

	btnClose:SubscribeScriptedEvent('Button::ClickEvent', 'CardCommentPanel:closeHaveRolePanel');
end

function CardCommentPanel:showMainRolePanel(roleInfo, name, resid)
	self.mainRolePanel.Visibility = Visibility.Visible;
	self.bg.Visibility = Visibility.Visible;

	local rolePanel =  self.mainRolePanel:GetLogicChild('rolePanel');
	local btnClose = self.mainRolePanel:GetLogicChild('closeBtn');
	local grade = self.mainRolePanel:GetLogicChild('roleInfoPanel'):GetLogicChild('grade');
	local attributePic = self.mainRolePanel:GetLogicChild('roleInfoPanel'):GetLogicChild('attributePic');
	local mainPic = self.mainRolePanel:GetLogicChild('roleInfoPanel'):GetLogicChild('mainPic');
	local userName = self.mainRolePanel:GetLogicChild('userInfoPanel'):GetLogicChild('userName');
	local atkValue = self.mainRolePanel:GetLogicChild('atkInfoPanel'):GetLogicChild('atkValue');
	local magAtkValue = self.mainRolePanel:GetLogicChild('magAtkInfoPanel'):GetLogicChild('magAtkValue');
	local defValue = self.mainRolePanel:GetLogicChild('defInfoPanel'):GetLogicChild('defValue');
	local magDefValue = self.mainRolePanel:GetLogicChild('magDefInfoPanel'):GetLogicChild('magDefValue');
	local hpValue = self.mainRolePanel:GetLogicChild('hpInfoPanel'):GetLogicChild('hpValue');

	local ctrl = self:initRoleHead(roleInfo, 100, true, true);
	rolePanel:AddChild(ctrl);
	grade.Text = tostring(roleInfo.lvl.level);

	local rank = self:getEquipRankByUid(self.currentUid);
	userName.TextColor = QualityColor[Configuration:getNameColorByEquip(rank or 1)];
	userName.Text = tostring(name or '');
	local attribute = 201;
	if resid then
		attribute = resTableManager:GetValue(ResTable.actor, tostring(resid), 'attribute');
	end
	attributePic.Image = GetPicture('login/login_icon_' .. attribute .. '.ccz');
	mainPic.Image = GetPicture('home/home_zhuan1.ccz');
	atkValue.Text = tostring(roleInfo.pro.atk);
	magAtkValue.Text = tostring(roleInfo.pro.mgc);
	defValue.Text = tostring(roleInfo.pro.def);
	magDefValue.Text = tostring(roleInfo.pro.res);
	hpValue.Text = tostring(roleInfo.pro.hp);

	btnClose:SubscribeScriptedEvent('Button::ClickEvent', 'CardCommentPanel:closeMainRolePanel');
end

function CardCommentPanel:closeNoRolePanel()
	self.noRolePanel.Visibility = Visibility.Hidden;
	self.bg.Visibility = Visibility.Hidden;
end

function CardCommentPanel:closeHaveRolePanel()
	self.haveRolePanel.Visibility = Visibility.Hidden;
	self.bg.Visibility = Visibility.Hidden;
end

function CardCommentPanel:closeMainRolePanel()
	self.mainRolePanel.Visibility = Visibility.Hidden;
	self.bg.Visibility = Visibility.Hidden;
end

function CardCommentPanel:showNewestComment()
	self.comment.Visibility = Visibility.Visible;
	--self.showSelfPanel.Visibility = Visibility.Visible;
	-- self.showSelfPanel:GetLogicChild('tip').Text = '我非常喜欢她';
	self.tip.Visibility = Visibility.Hidden;
	self.sendBtn.Visibility = Visibility.Visible;

	if not self.lastNewestComment[self.currentRoleInfo.resid] or not self.reqNewestCommentStamp[self.currentRoleInfo.resid] or 
		(self.reqNewestCommentStamp[self.currentRoleInfo.resid] + Configuration.reqNewestCommentInterval) < LuaTimerManager:GetCurrentTimeStamp() then
		local msg = {};
		msg.uid = ActorManager.user_data.uid;
		msg.resid = self.currentResid;
		msg.type = 1;
		Network:Send(NetworkCmdType.req_newest_card_comment, msg);
	else
		self.stackPanel:RemoveAllChildren();
		self:onShow(self.currentRoleInfo, self.lastNewestComment[self.currentResid]);
	end
end

function CardCommentPanel:showHotestComment()
	self.comment.Visibility = Visibility.Hidden;
	--self.showSelfPanel.Visibility = Visibility.Hidden;
	self.sendBtn.Visibility = Visibility.Hidden;

	if not self.lastHotestComment[self.currentRoleInfo.resid] or not self.reqHotestCommentstamp[self.currentRoleInfo.resid] or 
		(self.reqHotestCommentstamp[self.currentRoleInfo.resid] + Configuration.reqHotestCommentInterval) < LuaTimerManager:GetCurrentTimeStamp() then
		local msg = {};
		msg.uid = ActorManager.user_data.uid;
		msg.resid = self.currentResid;
		msg.type = 2;
		Network:Send(NetworkCmdType.req_newest_card_comment, msg);
	else
		self.stackPanel:RemoveAllChildren();
		self:onShow(self.currentRoleInfo, self.lastHotestComment[self.currentResid]);
	end
end

function CardCommentPanel:onCheckBoxChanged()
	if self.checkBox.Checked then
    	self.selectPic.Visibility = Visibility.Visible;
 	else
    	self.selectPic.Visibility = Visibility.Hidden;
  	end
end

--字符内容改变事件
function CardCommentPanel:onTextChange(Args)
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.cardComment then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_open_card_comment);
		return;
	end
  	local args = UIControlEventArgs(Args);
  	if utf8.len(args.m_pControl.Text) > Configuration.commentMaxWords then
    	--超过最大字符限制
    	args.m_pControl.Text = self.message;
  	else
    	--没有超过最大字符限制
    	self.message = args.m_pControl.Text;
  	end
end

function CardCommentPanel:ClickText()
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.cardComment then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_open_card_comment);
		return;
	end
  	if self.comment.Text == LANG_card_comment_info_2 then
	    self.comment.Text = '';
	  end
end

--隐藏
function CardCommentPanel:Hide()
	--mainDesktop:UndoModal();
	--增加UI消失时的效果
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		StoryBoard:HideUIStoryBoard(self.commentCardPanel, StoryBoardType.HideUIScale, 'StoryBoard::OnPopUI');
	else
		StoryBoard:HideUIStoryBoard(self.commentCardPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	end
	
	GodsSenki:BackToMainScene(SceneType.HomeUI)	
	DestroyBrushAndImage('home/home_comment_bg.ccz','godsSenki', 'godsSenki');
	DestroyBrushAndImage('home/home_comment_line.ccz','godsSenki');
end

function CardCommentPanel:onClose()
	MainUI:Pop();
end