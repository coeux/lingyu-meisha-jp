--login.lua

--========================================================================
--登陆类

--登陆状态（增加登陆状态是因为服务器的socket发送connect后要peek成功，才能发送消息）
LoginState =
{
	idle			= 0;	--空闲
	connectRoute	= 1;	--连接路由
	connectGateWay	= 2;	--连接网关
};

Login =
{
	loginState		= LoginState.idle;		--登陆状态

	accountData		= nil;					--账户数据
	serverList		= nil;					--服务器列表
	recomServerList	= nil;					--火爆服务器列表
	roleList		= nil;					--角色列表
	roleInfo		= nil;					--创建角色生成

	hostnum			= 0;					--当前服务器号

	index			= 0;					--登陆角色roleList索引
	uid				= 0;					--登陆角色的UID
	selectRoleResID	= 101;					--创建角色时选中角色的资源ID
	name = nil;							--账号
	isPlayMp4 = false;
	scaleImgShow = false;
};

--变量
local initFinishTimer = 0;	--sdk初始化结束计时器
local NewServerFlag	  = 1;	--新服标记位
local HotServerFlag   = 2;  --爆满标志位
local backgroundImage = '';
local s_changebgstate = false;

--界面元
local desktop;
local loginPanel;			--账号登录
local loginBackground;		--登陆背景
local accountPanel;		--账号界面

--local namebox;
local s_checkname;
local s_checktable;         --检查重名字的table

local accountName;			--账户名
local selectServerPanel;	--选择服务器
local selectServerPanel1
local createActorPanel;		--创建角色
local versionTextElement;	--版本号
local roleDesc;             --角色描述
local startPanel;
local start1;	  
local start2;	
local loginLogo;  
local desc1 ;
local descLabel = {};
local descIconAndName = {};
local roleDesc1, roleDesc2, roleDesc3 = nil;  --角色描述文件
local s_allranname;               --里面装的是随机的名字
local closeServerChoicePanel      --选择服务器面板上面的圆圈X
--local roleNamePanel;
local roleNameImg;

--默认登录
local actors = {};			--角色（table）
local curServer;			--当前服务器
local btnLogin;				--进入游戏按钮
local btnLogout;				
local loginBtnState = 0;	--按钮状态, 1表示平台登录成功，点登录进角色列表，0进平台登录
local isBtnLoginValid = false;	--点击登录按钮是否有效


--选择服务器
local lastLoginServer;		--上次登录服务器
local huobaoServers = {};	--火爆服务器
local serverList;			--服务器列表

local naviList;
local roleRadioButtons = { };
local roleBackgrounds = { };
local removeBackGroundBursh = {};
local waitimage;

local roleSound;

local serverlistPanel;
local showTime = 0;
local scaleNum = 0.6;
local num = 0;
local loginImgNum = 0;
local scaleTimer = 0;
local imgScaleShowTime = 0;

--删除角色

--登录参数
local loginArgs = {}

--初始化
function Login:Init()

	--设置异步加载
	renderer.AsyncLoadFlag = GlobalData.AsyncLoadEnable;

	--消息记录
	eventRecordManager.PlayBackEnable = GlobalData.PlayBackEnable;
	eventRecordManager.PlayBackOpen = GlobalData.PlayBackOpen;

	if eventRecordManager.PlayBackEnable then
		if eventRecordManager.PlayBackOpen then
			eventRecordManager:readEventInfo();
		else
			eventRecordManager:CleanFile();
			eventRecordManager:SaveRandomSeedInfo();
		end
	end
	--设置背景图片
	if VersionUpdate.curLanguage == LanguageType.cn then
		if platformSDK.m_Platform == 'liulian' or platformSDK.m_Platform == 'jituo1' or platformSDK.m_Platform == 'jituo2' then
			backgroundImage = 'background/H022_card_03.jpg';
		elseif platformSDK.m_Platform == 'djzj' then
			backgroundImage = 'background/H022_card_04.jpg';
		elseif platformSDK.m_Platform == 'xuegao1' or platformSDK.m_Platform == 'xuegao2' then
			backgroundImage = 'background/H022_card_05.jpg';
		elseif platformSDK.m_Platform == 'chaoyou' then
			backgroundImage = 'background/H022_card_03.jpg'
		elseif platformSDK.m_Platform == 'soga' then
			backgroundImage = 'background/H022_card_07.jpg';
		elseif platformSDK.m_Platform == 'zhanji' then
			backgroundImage = 'background/H022_card_08.jpg';
		else
			if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
				backgroundImage = 'background/H022_card_02_pad.jpg';
			else
				backgroundImage = 'background/H022_card_02.jpg';
			end
		end
	elseif VersionUpdate.curLanguage == LanguageType.tw then
		if platformSDK.m_Platform == 'teeplay' then
			backgroundImage = 'background/H022_card_02.jpg';
		else
			backgroundImage = 'background/H022_card_02.jpg';
		end
	end

end

--初始化渲染步骤
function Login:InitRenderStep()
	--加载资源
	if VersionUpdate.testmode == true then
		local uidir = '../langResource/'.. VersionUpdate.curLanguage .. '/resource/ui/';
		uiSystem:SetWorkingPath(uidir);
	else
		uiSystem:SetWorkingPath('resource/ui/');
	end

	if GlobalData.AsyncLoadEnable then
		uiSystem:LoadResourceXML('godsSenki_merge.res');
	else
		uiSystem:LoadResourceXML('godsSenki.res');
	end

	SceneRenderStep:Init();
	BottomRenderStep:Init();
	UIRenderStep:Init();
	TopRenderStep:Init();
end

--系统初始化
function Login:InitSystem()
	ResTable:Init();
	AvatarManager:Init();
	EventManager:Init();
	Network:Init();
	SoundManager:Init();
	PlotManager:Init();
end

--初始化网络需要的界面
function Login:InitPanel()
	self.scaleImgShow = false;
	--初始化变量
	initFinishTimer = 0;
	--加载登陆UI
	uiSystem:LoadSchemeXML('login.lay');
	uiSystem:LoadResource('common');
	uiSystem:LoadResource('login');
	desktop = uiSystem:GetDesktop('login');
	SetDesktopSize(desktop);
	local waitingPanel = Panel(desktop:GetLogicChild('waitingPanel'));
	waitimage = waitingPanel:GetLogicChild('loading');
	waitimage.Image = GetPicture('login/loading.ccz');
	loginPanel = Panel(desktop:GetLogicChild('loginPanel'));
	closeServerChoicePanel = Button(loginPanel:GetLogicChild('close1'));
	closeServerChoicePanel:SubscribeScriptedEvent('Button::ClickEvent', 'Login:onCloseChangeServer');
	btnLogin = Button( loginPanel:GetLogicChild('login'));
	--btnLogin.Text = "START";
	btnLogin:SubscribeScriptedEvent('Button::ClickEvent', 'Login:SendRequestRoleList');         --登陆按钮
	btnLogin.Visibility = Visibility.Visible;
	isBtnLoginValid = false;
	loginBackground =   ImageElement(loginPanel:GetLogicChild('background1'));
	selectServerPanel1 = loginPanel:GetLogicChild('selectServerPanel1');
	selectServerPanel = selectServerPanel1:GetLogicChild('selectServerPanel2');		            --服务器选择界面

	serverlistPanel = loginPanel:GetLogicChild('selectServerPanel2');

	startPanel = loginPanel:GetLogicChild('startPanel');
	start1	   = startPanel:GetLogicChild('start1');
	start2	   = startPanel:GetLogicChild('start2');
	start1.Image = GetPicture('login/start_2.ccz');
	start2.Image = GetPicture('login/start_1.ccz');

	loginLogo	= loginPanel:GetLogicChild('loginLogo');
	loginLogo.Image = GetPicture('login/login_logo.ccz');
	loginLogo:SetScale(1.5,1.5);
	loginLogo.Visibility = Visibility.Hidden;

	--上次登录服务器
	lastLoginServer = serverlistPanel:GetLogicChild('serverPanel'):GetLogicChild('lastLoginPanel'):GetLogicChild('lastLoginServer');
	lastLoginServer.Visibility = Visibility.Hidden;
	lastLoginServer:SubscribeScriptedEvent('Button::ClickEvent', 'Login:onSelectServer');

	--当前服务器
	curServer = loginPanel:GetLogicChild('curServerBtn'):GetLogicChild('curServer');	        --当前服务器文字
	curServer.Visibility = Visibility.Hidden;
	versionTextElement = desktop:GetLogicChild('version');
	if VersionUpdate.localGameVersion == nil then
		versionTextElement.Text = LANG_login_1;
	else
		versionTextElement.Text = VersionUpdate.localGameVersion .. "@" .. appFramework:GetVMVersion();
	end
	local curServerBtn = loginPanel:GetLogicChild('curServerBtn');                              --当前服务器按钮
	curServerBtn:SubscribeScriptedEvent('Button::ClickEvent', 'Login:onChangeServer');
	accountPanel = desktop:GetLogicChild('accountPanel');
	accountName = TextElement( accountPanel:GetLogicChild('accountName'));		--账户名
	createActorPanel = accountPanel:GetLogicChild('createActorPanel');			--创建角色界面
	Login.namebox = createActorPanel:GetLogicChild('nameBox');
	Login.namebox:SubscribeScriptedEvent('Label::TextChangedEvent', 'Login:onTextChange');
	Login.namebox:SubscribeScriptedEvent('UIControl::GotKeyboardFocusEvent', 'Login:onResumeInput');



	roleDesc = createActorPanel:GetLogicChild('DescPanel');                     --角色描述
	desc1 = roleDesc:GetLogicChild('desc');                                     --每个英雄对应的描述
	local label1 =  desc1:GetLogicChild('label1') ;
	local label2 =  desc1:GetLogicChild('label2') ;
	local label3 =  desc1:GetLogicChild('label3') ;
	descLabel = {label1, label2, label3};
	local roleInfo = resTableManager:GetRowValue(ResTable.create_role,  tostring(101));
	roleDesc1 = roleInfo['description1'];
	roleDesc2 = roleInfo['description2'];
	roleDesc3 = roleInfo['description3'];
	descLabel[1].Text = roleDesc1 ;
	descLabel[2].Text = roleDesc2 ;
	descLabel[3].Text = roleDesc3 ;
	local roledescpath = roleInfo['icon2'];
	local desciconpath = roleInfo['icon3'];
	local descimage = roleDesc:GetLogicChild('role');
	local descimagename = descimage:GetLogicChild('name');
	local descicon = descimage:GetLogicChild('icon');
	descicon.Visibility = Visibility.Visible;
	descicon.Image = GetPicture('login/' .. roledescpath.. '.ccz');
	descimagename.Background = CreateTextureBrush('login/' .. desciconpath .. '.ccz', 'login');
	--默认登录
	s_checkname = Panel(accountPanel:GetLogicChild('CheckName'));
	s_checkname.ZOrder = 100;
	s_checktable = s_checkname:GetLogicChild('CheckNameTip');
	--创建角色
	naviList = ListView( createActorPanel:GetLogicChild('naviList') );
	naviList:SubscribeScriptedEvent('ListView::PageChangeEvent', 'Login:onNaviChanged');   --listview page change
	naviList.Pick = true;
	local radioRole1 =  createActorPanel:GetLogicChild('radioRole1') ;
	local radioRole2 =  createActorPanel:GetLogicChild('radioRole2') ;
	local radioRole3 =  createActorPanel:GetLogicChild('radioRole3') ;
	roleRadioButtons = {radioRole1, radioRole2, radioRole3};
	roleRadioButtons[1].Selected = true;
	for i = 1, #roleRadioButtons do
		roleRadioButtons[i]:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'Login:onRadinButton');
		roleRadioButtons[i].Tag = i;
		roleRadioButtons[i].UnSelectedBrush = CreateTextureBrush('login/P10' .. i .. '_icon_01_1.ccz', 'login');
		roleRadioButtons[i].SelectedBrush = CreateTextureBrush('login/P10' .. i .. '_icon_01_2.ccz', 'login');
	end
	local leftBtn = createActorPanel:GetLogicChild('leftButton')
	local rightBtn = createActorPanel:GetLogicChild('rightButton')
	leftBtn:SubscribeScriptedEvent('Button::ClickEvent', 'Login:onLeftButton');
	rightBtn:SubscribeScriptedEvent('Button::ClickEvent', 'Login:onRightButton');
	local bg1 = accountPanel:GetLogicChild('bg1');			                            --角色背景
	local bg2 = accountPanel:GetLogicChild('bg2');			                            --角色背景
	local bg3 = accountPanel:GetLogicChild('bg3');			                            --角色背景
	roleBackgrounds = {bg1, bg2, bg3};
	local diceButton = createActorPanel:GetLogicChild('dice');                          --随机姓名的东西
	diceButton:SubscribeScriptedEvent('Button::ClickEvent', 'Login:randomChoiceName');
	diceButton.Visibility = Visibility.Hidden;
	local closebtn = createActorPanel:GetLogicChild('backButton');                                 --选择角色界面关闭按钮
	closebtn:SubscribeScriptedEvent('Button::ClickEvent', 'Login:onCancelSelectRole')
	roleNameImg = createActorPanel:GetLogicChild('namgImg');
	--roleNameLabel = roleNamePanel:GetLogicChild('roleNameLabel');


	Network:InitPanel();
	MessageBox:InitPanel();

end

function Login:onEnterLogout()
	appFramework:Reset();
end

local recordCurrentBursh = nil;
function Login:onRadinButton(Arg)
	local arg = UIControlEventArgs(Arg);
	self.s_tag = arg.m_pControl.Tag - 1;
	s_changebgstate = true;
	self.selectRoleResID = 101 +  self.s_tag;
	--[[local naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(self.selectRoleResID));

	local naviIconImage = naviInfo['role_path_icon'];
	if(recordCurrentBursh) then
		print("00000000", naviIconImage );
		DestroyBrushAndImage('navi/' .. recordCurrentBursh..'_2'.. '.png', 'navi');
		recordCurrentBursh = nil;
	end
	recordCurrentBursh = naviIconImage;
	
	roleRadioButtons[self.s_tag + 1].Scale = Vector2(1.1, 1.1);
	roleRadioButtons[self.s_tag + 1].UnSelectedBrush = CreateTextureBrush('navi/' .. naviIconImage..'_2'.. '.png', 'navi');--]]
	--local roleName = resTableManager:GetValue(ResTable.actor,tostring(self.selectRoleResID),'name');
	--roleNameLabel.Text = tostring(roleName);

	roleNameImg.Image = GetPicture('login/name_'..arg.m_pControl.Tag..'.ccz');
	naviList.ActivePageIndex = self.s_tag;
end

function Login:randomChoiceName()
	local s_randomname = "noname";
	local function s_randomreturn(random)
		local randomNameInfo = resTableManager:GetRowValue(ResTable.random_name,  tostring(random));
		return randomNameInfo['name'];
	end
	local value1 = math.ceil(math.random(1001, 1050));
	local value2 = math.ceil(math.random(2001, 2050));
	local value3 = math.ceil(math.random(3001, 3050));

	Login.namebox.Text = s_randomreturn(value1)..s_randomreturn(value2)..s_randomreturn(value3);
end

function Login:onChildMoved()
	local parentPos = naviList:GetAbsTranslate().x;
	local currentChild = naviList:GetLogicChild(naviList.ActivePageIndex);
	local childPos = currentChild:GetAbsTranslate().x;
	local offsetRate =  (math.abs(childPos - parentPos)) / (currentChild.Width * 1.5);

	local nextIndex = 0;
	if childPos - parentPos > 0 then -- 向右侧滑动
		nextIndex = ((naviList.ActivePageIndex - 1) + 3) % 3 + 1
	else
		nextIndex = ((naviList.ActivePageIndex + 1) + 3) % 3 + 1
	end

	if(s_changebgstate) then
		s_changebgstate = false;
		local roleDestable = {};
		local roleInfo = resTableManager:GetRowValue(ResTable.create_role,  tostring(self.selectRoleResID));
		roleDesc1 = roleInfo['description1'];
		roleDesc2 = roleInfo['description2'];
		roleDesc3 = roleInfo['description3'];
		roleDestable = {roleDesc1, roleDesc2, roleDesc3};
		descLabel[1].Text = roleDestable[1];
		descLabel[2].Text = roleDestable[2];
		descLabel[3].Text = roleDestable[3];
		local roledescpath = roleInfo['icon2'];
		local desciconpath = roleInfo['icon3'];
		local descimage = roleDesc:GetLogicChild('role');
		local descimagename = descimage:GetLogicChild('name');
		local descicon = descimage:GetLogicChild('icon');
		descicon.Visibility = Visibility.Visible;
		descicon.Image = GetPicture('login/' .. roledescpath.. '.ccz');
		descimagename.Background = CreateTextureBrush('login/' .. desciconpath .. '.ccz', 'login');
	end
	if offsetRate > 1 then offsetRate = 1 end
	for i = 1, 3 do
		local child = naviList:GetLogicChild(i - 1);
		if i == naviList.ActivePageIndex + 1 then -- 当前选中
			child.Opacity = 1 - offsetRate;
			roleBackgrounds[i].Opacity = 1 - offsetRate;
			child.Scale = Vector2(1 - offsetRate, 1 - offsetRate);
		elseif i == nextIndex then
			child.Opacity =  offsetRate;
			roleBackgrounds[i].Opacity = offsetRate;
			roleBackgrounds[i].Visibility = Visibility.Visible;
			child.Scale = Vector2(offsetRate, offsetRate);
		else
			child.Opacity =  0;
			roleBackgrounds[i].Opacity = 0;
			child.Scale = Vector2(0, 0);
		end
	end
end

function Login:onLeftButton()
	naviList:TurnPageForward();
end

function Login:onRightButton()
	naviList:TurnPageBack();
end

--销毁
function Login:Destroy()
	MessageBox:Destroy();
	--销毁背景
	--sloginBackground.Image = nil;
	--accountPanel.Background = nil;
	uiSystem:DestroyControl(desktop);
	uiSystem:UnloadResource('login');
end
function Login:loadSoundFlag()
	local file = appFramework:GetDocumentPath() .. SystemPanel.fileName;
	if not OperationSystem.IsPathExist(file) then
		--文件不存在
		return;
	end

	local xfile = xmlParseFile(file);
	if xfile == nil then
		return;
	end

	local rootNode = xfile[1];
	if rootNode == nil then
		return;
	end
	local attr = rootNode['attr'];
	if attr == nil then
		return;
	end
	local sound = attr['sound'];
	if sound == nil then
		return;
	end

	local soundEffect = attr['soundEffect'];
	if soundEffect == nil then
		return;
	end
	if tonumber(sound) == 1 then
		SystemPanel.soundFlag = true;
	else
		SystemPanel.soundFlag = false;
	end

	if tonumber(soundEffect) == 1 then
		SystemPanel.soundEffectFlag = true;
	else
		SystemPanel.soundEffectFlag = false;
	end
end
--进入
function Login:onEnter()
	VersionUpdate.gameInitFinished = true;

	loginImgNum = 0;
	scaleTimer = 0;
	showTime = 0;
	imgScaleShowTime = 0;
	scaleNum = 0.6;
	num = 0;
	--等待Mp4播放完毕开始播放背景音乐， onPlayMp4Finish
	--

	loginBackground.Background = CreateTextureBrush(backgroundImage, 'background');
	--loginBackground.Image = GetPicture(backgroundImage);
	--切换场景和桌面
	uiSystem:SwitchToDesktop(desktop);
	--播放声音
	self:loadSoundFlag()
	SoundManager:PlayTitleSound();
	--未登录状态
	loginPanel.Visibility = Visibility.Visible;
	--没有SDK的时候临时直接进入游戏
	if platformSDK.m_System == "iOS" then
		if platformSDK.m_Platform == 'appstore' then
			self:gameLogin()
		end
		if platformSDK.m_IsInit then --and platformSDK.m_Platform ~= '' and platformSDK.m_Platform ~= nil then
			--SDK初始化成功
			if VersionUpdate.sdkLoginFinished then
				onLoginSuccess();
			else
				platformSDK:OnLogin();
			end
		else
			--SDK初始化未完成，设置定时器等待
			initFinishTimer = timerManager:CreateTimer(0.2, 'Login:onSDKInitFinished', 0);
		end
	elseif platformSDK.m_System == "Android" then
		if platformSDK.m_IsInit then --and platformSDK.m_Platform ~= '' and platformSDK.m_Platform ~= nil then
			--SDK初始化成功
			if VersionUpdate.sdkLoginFinished then
				onLoginSuccess();
			else
				platformSDK:OnLogin();
			end
		else
			--SDK初始化未完成，设置定时器等待
			initFinishTimer = timerManager:CreateTimer(0.2, 'Login:onSDKInitFinished', 0);
		end
	elseif platformSDK.m_System == "Win32" then
		self:gameLogin();
	end
end

function Login:startScaleEffect(Elapse)
	if scaleTimer >= 0.11 then
		self:startWordScale();
		self:imgScaleEffect();
		scaleTimer = 0;
	end
	if self.scaleImgShow then
		self:loginImgEffect(Elapse);
	end
	scaleTimer = scaleTimer + Elapse;
end
function Login:startWordScale(elap)
	local notAdd = false;
	if showTime <= 4 then
		--start2.Visibility = Visibility.Visible;
		--start1.Visibility = Visibility.Visible;
		start2.Opacity = showTime/4;--1/(4/0.2);
		start1.Opacity = showTime/4;
	elseif showTime <= 5 then
		--start2.Visibility = Visibility.Hidden;
		--start1.Visibility = Visibility.Hidden;
		start2.Opacity = 1-(showTime-4);
		start1.Opacity = 1-(showTime-4);
	elseif showTime > 5 then
		notAdd = true;
		showTime = 0;
	end
	if not notAdd then
		showTime = showTime + 0.2;
	end
end
function Login:imgScaleEffect()
	if imgScaleShowTime <= 4 then
		num = 0.4 / (4 / 0.2);
	elseif imgScaleShowTime <= 5 then
		num = -0.4 / (1 / 0.2);
	elseif imgScaleShowTime > 5 then
		num = 0;
		imgScaleShowTime = 0;
		scaleNum = 0.6;
	end
	if num ~= 0 then
		imgScaleShowTime = imgScaleShowTime + 0.2;
		scaleNum = scaleNum+num;
		start1:SetScale(scaleNum,1);
	end
end
function Login:loginImgEffect(Elapse)
	if loginImgNum <= 1 then
		loginLogo:SetScale(1.5-(loginImgNum/2),1.5-(loginImgNum/2));
		loginLogo.Opacity = loginImgNum;
		loginImgNum = loginImgNum + Elapse;
	end
end
--离开
function Login:onLeave()
	--播放背景音乐
	SoundManager:StopFightSound();
	--设置背景
	loginBackground.Image = nil;
	loginBackground:RemoveChild(armature);
	loginBackground.armature = nil;
	DestroyBrushAndImage(backgroundImage, 'background');
	for i = 1, 3 do
		if(removeBackGroundBursh[i]) then
			DestroyBrushAndImage('navi/' .. removeBackGroundBursh[i].. '.jpg', 'navi');
		end
	end
	--触发回收显存事件
	EventManager:FireEvent(EventType.RecoverDisplayMemory, true);
end

--sdk初始化结束计时器
function Login:onSDKInitFinished()
	if platformSDK.m_IsInit then --and platformSDK.m_Platform ~= '' and platformSDK.m_Platform ~= nil then
		timerManager:DestroyTimer(initFinishTimer);
		initFinishTimer = 0;
		platformSDK:OnLogin();
		return;
	end
	if platformSDK.m_Platform == "master" then
		timerManager:DestroyTimer(initFinishTimer);
		initFinishTimer = 0;
		self:gameLogin();
		return;
	end
end

--更新
function Login:Update( Elapse )
	if self.loginState == LoginState.connectRoute then
		--连接路由
		if networkManager:IsConnectSuccess() then
			--发送请求路由消息
			local msg = {};
			msg = cjson.encode(msg);
			networkManager:SendMsg(NetworkCmdType.req_rout, msg, false);
			self.loginState = LoginState.idle;
		end
	elseif self.loginState == LoginState.connectGateWay then
		--连接网关
		if networkManager:IsConnectSuccess() then
			--发送登陆网关消息
			local msg = {};
			msg.seskey = Network.serverData.seskey;
			msg = cjson.encode(msg);
			networkManager:SendMsg(NetworkCmdType.req_gw, msg, false);
			self.loginState = LoginState.idle;
		end
	end
	self:onChildMoved()
	self:startScaleEffect(Elapse)
end

--========================================================================
--功能函数
--========================================================================
--设置账户信息
function Login:SetAccountInfo( msg )
	self.accountData = msg;
	self.hostnum = self.accountData.hostnum;
	isBtnLoginValid = true
	btnLogout = loginPanel:GetLogicChild('logout');
	if btnLogout ~= nil and (platformSDK.m_Platform == 'appstore_' or platformSDK.m_Platform == 'common') then
		btnLogout.Visibility = Visibility.Visible;
		btnLogout:SubscribeScriptedEvent('Button::ClickEvent', 'Login:onEnterLogout');
	end
end

--账号管理
function Login:AccountManage()
	--切换到未登录状态
	loginPanel.Visibility = Visibility.Visible;
	accountPanel.Visibility = Visibility.Hidden;
	if platformSDK.m_System == "iOS" then
		platformSDK:OnRelogin();
	elseif platformSDK.m_System == "Android" then
		platformSDK:OnRelogin();
	end
end
--请求服务器列表
function Login:RequestServerList()
	local msg = {};
	--PC上请求服务器列表 or 开发调试模式
	if not debugandroid and platformSDK.m_System == "Win32" then
		msg.seskey = Network.serverData.seskey;
		Network:Send(NetworkCmdType.req_gslist, msg);
	else
		--手机上刷新服务器列表
		local sortServerList = {};
		for _, s in ipairs(VersionUpdate.hosts) do
			table.insert(sortServerList, s);
		end
		self.serverList = sortServerList;				--服务器列表
		self.recomServerList = {};						--火爆服务器列表
		for i = 1, #self.serverList do
			if self.serverList[i].recom_gslist and self.serverList[i].recom_gslist == 1 then
				table.insert(self.recomServerList, self.serverList[i]);
			end
			if #self.recomServerList == 10 then
				break;
			end
		end
		self:RefreshServerList();
	end
end

--win登陆
function Login:RefreshServerListWin(msg)
	--连外网服务器配置
	local sortServerList = {};
	self.recomServerList = {};	                   --火爆服务器列表
	for _, s in ipairs(msg.gslist) do
		table.insert(sortServerList, s);
	end
	if(msg.recom_gslist) then
		print(msg.recom_gslist)
		for _, s  in ipairs(msg.recom_gslist) do
			table.insert(self.recomServerList, s);
			if #self.recomServerList == 10 then
				break;
			end
		end
	end
	if #sortServerList == 0 then
		Debug.report("logining: " .. tostring(msg.gslist[1].name));
		table.insert(sortServerList,  { hostnum = 1, name = '誓约胜利之剑1', serid = 1, recom=true} );
	end

	self.serverList = sortServerList;				--服务器列表
	self:RefreshServerList();
end

--刷新服务器列表
function Login:RefreshServerPanel(Arg)
	local arg = UIControlEventArgs(Arg);
	local tag = arg.m_pControl.Tag;
	local serverInfo = {};
	local childIndex = 0;
	local stackPanel = serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	while stackPanel:GetLogicChild(childIndex) ~= nil do
		stackPanel:GetLogicChild(childIndex):GetLogicChild('curTitle').TextColor = QuadColor(Color(0, 14, 60, 255));
		childIndex = childIndex + 1;
	end 
	arg.m_pControl:GetLogicChild('curTitle').TextColor = QuadColor(Color(255, 255, 255, 255));
	if tag == 0 then
		serverInfo = self.recomServerList;
		serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('curTitle').Text = LANG_login_10
	else
		local tabCount = math.floor((#self.serverList + 9) / 10);
		local min = math.floor(10 * (tabCount - tag ));
		local max = math.min(min + 9, #self.serverList-1);
		if min == max then
			serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('curTitle').Text = min .. "区";
		else
			serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('curTitle').Text = min .. "-" .. max .. "区";	
		end
		for index = #self.serverList - 9 - 10*(math.floor((#self.serverList + 9)/10)-tag), #self.serverList - 10*(math.floor((#self.serverList + 9)/10)-tag) do
			if self.serverList[index] then
				table.insert(serverInfo, self.serverList[index]);
			end
		end
	end

	--刷新服务器列表信息
	for i = 1, 10 do
		if i <= #serverInfo then
			local loginItem = serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('serverPanel'):GetLogicChild( "LoginServer" .. i);
			loginItem.Visibility = Visibility.Visible;
			loginItem.CoverBrush = CreateTextureBrush('Welfare/Welfare_item_bg.ccz','Welfare');
			loginItem.NormalBrush = CreateTextureBrush('Welfare/Welfare_item_bg.ccz','Welfare');
			loginItem.pressBrush = CreateTextureBrush('Welfare/Welfare_item_bg.ccz','Welfare');
			loginItem:GetLogicChild('serverName').Text = serverInfo[i].name;
			local selectBtn = loginItem:GetLogicChild('selectBtn');
			selectBtn.Tag =  serverInfo[i].hostnum;
			selectBtn:SubscribeScriptedEvent('Button::ClickEvent', 'Login:onSelectServer');
			--serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('serverPanel'):GetLogicChild( "LoginServer" .. i).Visibility = Visibility.Visible;
			--serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('serverPanel'):GetLogicChild( "LoginServer" .. i).Text = serverInfo[i].name;
			--serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('serverPanel'):GetLogicChild( "LoginServer" .. i).Tag =  serverInfo[i].hostnum;
			--是否新服
			--serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('serverPanel'):GetLogicChild( "LoginServer" .. i):SubscribeScriptedEvent('Button::ClickEvent', 'Login:onSelectServer');
			--local brushNew = loginItem:GetLogicChild('new');
			local brushHot = loginItem:GetLogicChild('hot');
			if serverInfo[i].flag == NewServerFlag then
				--brushNew.Text = LANG_login_8;
				--brushNew.TextColor = QuadColor(Color(60, 137, 11, 255));
				--brushNew.Visibility = Visibility.Visible;
				brushHot.Background = CreateTextureBrush('login/login_server_new.ccz','login');
				brushHot.Visibility = Visibility.Visible
			elseif serverInfo[i].flag == HotServerFlag then
				brushHot.Background = CreateTextureBrush('login/login_server_hot.ccz','login');
				brushHot.Visibility = Visibility.Visible
				--brushNew.Visibility = Visibility.Visible;
				--brushNew.Text = LANG_login_9;
				--brushNew.TextColor = QuadColor(Color(232, 37, 74, 255));
			else
				brushHot.Visibility = Visibility.Hidden;
			end
		else
			loginPanel:GetLogicChild('selectServerPanel2'):GetLogicChild("serverPanel"):GetLogicChild('serverPanel'):GetLogicChild( "LoginServer" .. i).Visibility = Visibility.Hidden;
		end
		--[[
		if i%2 == 0 then
			if i < #serverInfo then
				serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('serverPanel'):GetLogicChild( "line" .. (i/2)).Visibility = Visibility.Visible;
			else
				serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('serverPanel'):GetLogicChild( "line" .. (i/2)).Visibility = Visibility.Hidden;
			end
		end
		]]
	end
end
--刷新服务器列表
function Login:RefreshServerList()

	--刷新选取单选按钮
	local stackPanel = serverlistPanel:GetLogicChild("serverPanel"):GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');

	--推荐服务器
	local recommend = uiSystem:CreateControl('serverTemplate');
	local recommendpanel = Panel(recommend:GetLogicChild(0));
	recommendpanel:GetLogicChild('curTitle').Text = LANG_login_10;
	recommendpanel.Visibility = Visibility.Visible;
	recommendpanel:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'Login:RefreshServerPanel');
	recommendpanel.Tag = 0;
	recommendpanel.SelectedBrush = CreateTextureBrush('login/login_item_select_1.ccz','login');
	stackPanel:AddChild(recommendpanel);

	--服务器列表
	local tabCount = math.floor((#self.serverList + 9) / 10);
	for index = 1, tabCount do
		local t = uiSystem:CreateControl('serverTemplate');
		local panel = Panel(t:GetLogicChild(0));
		panel.SelectedBrush = CreateTextureBrush('login/login_item_select_1.ccz','login');
		local min = math.floor(10 * (tabCount - index ));
		local max = math.min(min + 9, #self.serverList-1);
		if min == max then
			panel:GetLogicChild('curTitle').Text = "ワールド"..(min+1);
		else
			panel:GetLogicChild('curTitle').Text = "ワールド"..(min+1) .. "-" .. (max+1);	
		end
		panel.Visibility = Visibility.Visible;
		panel:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'Login:RefreshServerPanel');
		panel.Tag = index;
		stackPanel:AddChild(panel);
	end
	stackPanel:GetLogicChild(0).Selected = true;
	local connectServer;
	if self.accountData.hostnum ~= 0 then
		--之前登陆过
		for _,v in ipairs(self.serverList) do
			if v.hostnum == self.accountData.hostnum then
				connectServer = v;
			end
		end
		if connectServer == nil then
			for _,v in ipairs(self.recomServerList) do
				if v.hostnum == self.accountData.hostnum then
					connectServer = v;
				end
			end
		end
		--一般不会出现这种状态（上次登录的服务器不存在，选择最大服务器号）
		if connectServer == nil then
			--选择最新服务器（hostnum最大的）
			for _,v in ipairs(self.serverList) do
				if (connectServer == nil) or (v.hostnum > connectServer.hostnum) then
					connectServer = v;
				end
			end
		end
		--最近登录按钮
		lastLoginServer.Visibility = Visibility.Visible;
		lastLoginServer.Text = connectServer.name;
		lastLoginServer.Tag = connectServer.hostnum;
		--是否新服
		local brushNew = BrushElement( lastLoginServer:GetLogicChild('new') );
		if connectServer.flag == NewServerFlag then
			brushNew.Visibility = Visibility.Visible;
			brushNew.Background = CreateTextureBrush('login/login_server_new.ccz','login');
			--brushNew.Text = LANG_login_8;
			--brushNew.TextColor = QuadColor(Color(60, 137, 11, 255));
		elseif connectServer.flag == HotServerFlag then
			brushNew.Visibility = Visibility.Visible;
			brushNew.Background = CreateTextureBrush('login/login_server_hot.ccz','login');
			--brushNew.Text = LANG_login_9;
			--brushNew.TextColor = QuadColor(Color(232, 37, 74, 255));
		else
			brushNew.Visibility = Visibility.Hidden;
		end

	else
		--没有提示最近登录显示注册账号选角色
		for i = 1, 3, 1 do
			local child = naviList:GetLogicChild(i - 1);
			child.Visibility = Visibility.Hidden;
			local naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(100 + i));
			local naviImage = naviInfo['role_path'];
			local naviBg = naviInfo['bg_path'];
			child.AutoSize = false;
			-- child.Background = CreateTextureBrush('navi/' .. naviImage .. '.png', 'login');
			roleBackgrounds[i].Background = CreateTextureBrush('navi/' .. naviBg.. '.jpg', 'navi');
			roleBackgrounds[i].Visibility = Visibility.Visible;
		end

		--选择最新服务器（hostnum最大的）
		for _,v in ipairs(self.serverList) do
			if (connectServer == nil) or (v.hostnum > connectServer.hostnum) then
				connectServer = v;
			end
		end
	end
	--默认登录界面
	curServer.Text = connectServer.name;
	curServer.Tag = connectServer.hostnum;
	self.hostnum = connectServer.hostnum;
	--信息获取完成显示按钮
	curServer.Visibility = Visibility.Visible;
	btnLogin.Visibility = Visibility.Visible;
	isBtnLoginValid = true;
	self.scaleImgShow = true;
	loginLogo.Visibility = Visibility.Visible;
end

--刷新角色列表, isFrist表示是否第一次刷新
function Login:RefreshRoleList( msg, isFirst )
	--显示默认登录界面
	self.roleList = msg.rolelist;

	local full = tostring(self:getServer(self.hostnum).full);

	if isFirst and #self.roleList == 0 then
		if full == '1' then
			MessageBox:ShowDialog(MessageBoxType.Ok, "当前服务器已经爆满，请选择其他服务器", okDelegate);
			return;
		end
		self:CreateRole();
		loginPanel.Visibility = Visibility.Hidden;
		accountPanel.Visibility = Visibility.Visible;
		--local soundName = resTableManager:GetValue(ResTable.npc,tostring(self.selectRoleResID),'vioce')
		--if roleSound ~= nil then
		--	soundManager:DestroySource(roleSound);
		--	roleSound = nil
		--end
		roleNameImg.Image = GetPicture('login/name_1.ccz');
		--roleSound = SoundManager:PlayVoice( tostring(soundName))
		return;
	end
	local roleInfo = self.roleList[1];
	self.roleInfo = roleInfo;
	self.uid = roleInfo.uid;
	self:onEnterGame();
	--向服务器发送统计数据
	NetworkMsg_GodsSenki:SendStatisticsData(0, 2);
end

--刷新角色选择
function Login:RefreshRoleSelect( )
	--重置为Hidden，后面根据是否有角色判断
	--设置角色列表
	for i = 1, 3 do
		local roleInfo = self.roleList[i];
		local actor = actors[i];
		if roleInfo == nil then
			actor.figure.Visibility	= Visibility.Visible;
			actor.unselected.Visibility	= Visibility.Visible;
			actor.avatar:Destroy();
			actor.selected1:Destroy();
			actor.selected2:Destroy();
		else
			actor.figure.Visibility	= Visibility.Hidden;
			if roleInfo.uid == self.uid then
				--[[AvatarManager:LoadFile(GlobalData.EffectPath .. 'chuangjianjuese_output/');
				actor.selected1:LoadArmature('chuangjianjuese_01');
				actor.selected1:SetAnimation('play');
				actor.selected2:LoadArmature('chuangjianjuese_02');
				actor.selected2:SetAnimation('play');]]--
				actor.unselected.Visibility	= Visibility.Hidden;
				self.selectRoleResID = roleInfo.resid;
			else
				actor.selected1:Destroy();
				actor.selected2:Destroy();
				actor.unselected.Visibility	= Visibility.Visible;
			end
		end
	end
end
--删除警告
--删除角色
--========================================================================
--界面响应
--========================================================================

--不进行平台登录，直接外网登录
function Login:gameLogin()
	local success;
	--内网登录
	if not debugandroid and platformSDK.m_System == "Win32" and Network.isInner then
		success = networkManager:Connect(Network.routeInnerIP, Network.routePort);
		--有自动更新时外网登录
	elseif VersionUpdate.EnabelUpdate then
		success = networkManager:Connect(VersionUpdate.route.ip, VersionUpdate.route.port);
		--无自动更新时外网登录
	else
		success = networkManager:Connect(Network.routeInnerIP, Network.routePort);
	end
	if not success then
		--连路由没有成功
		PrintLog('rout connect failed!');
		platformSDK:SendUmengEvent('ConnectRoutFail');
		local okDelegate = Delegate.new(Login, Login.gameLogin);
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_login_4, okDelegate);
		return;
	end
	--处于连接路由状态
	self.loginState = LoginState.connectRoute;
end

--返回登录界面
function Login:onReturnLogin()
	loginPanel.Visibility = Visibility.Visible;
	accountPanel.Visibility = Visibility.Hidden;
end

--更改服务器
function Login:onChangeServer()
	if not self.serverList then
		return
	end
	serverlistPanel:GetLogicChild('serverPanel'):GetLogicChild('bgBrush1').Background = CreateTextureBrush('Welfare/Welfare_bg_1.ccz','Welfare');
	serverlistPanel:GetLogicChild('serverPanel'):GetLogicChild('bgBrush2').Background = CreateTextureBrush('Welfare/Welfare_bg_2.ccz','Welfare');
	serverlistPanel.Visibility = Visibility.Visible;
	closeServerChoicePanel.Visibility = Visibility.Visible;
end

--关闭更改服务器
function Login:onCloseChangeServer()
	serverlistPanel.Visibility = Visibility.Hidden;
	closeServerChoicePanel.Visibility = Visibility.Hidden;
end
--选择角色
function Login:onSelectRole( Arg )
	local arg = UIControlEventArgs(Arg);
	self.uid = arg.m_pControl.Tag;
	self.index = arg.m_pControl.TagExt;
	self:RefreshRoleSelect();
end

--进入创建角色界面 或者 删除角色
function Login:onCreateRole( Arg )
	--向服务器发送统计数据
	NetworkMsg_GodsSenki:SendStatisticsData(0, 1);

	local arg = UIControlEventArgs(Arg);
	if arg.m_pControl.Tag == 0 then
		self:CreateRole( );
	else
		--删除角色
	end

end

function onPlayMp4Finish()
end

function Login:CreateRole( )

	if Login.isPlayMp4 and  (fileSystem:IsFileExist("assets/start.mp4") or platformSDK.m_System == "iOS") then
		platformSDK:playMp4("start.mp4");
	end
	--Login:randomChoiceName();                                       --上来就会随机一个名字
	--设置背景
	--createActorPanel.Background = CreateTextureBrush('background/chuangjianrenwu_beijin2.ccz', 'login', Rect(0,0,480,320));
	--创建角色
	--createActorPanel.Visibility = Visibility.Visible;
	for i = 1, 3, 1 do
		local child = naviList:GetLogicChild(i - 1);
		child.Visibility = Visibility.Hidden;
		local naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(100 + i));
		local naviImage = naviInfo['role_path'];
		local naviBg = naviInfo['bg_path'];
		removeBackGroundBursh[i] = naviBg;
		child.AutoSize = false;
		-- child.Background = CreateTextureBrush('navi/' .. naviImage .. '.png', 'login');
		roleBackgrounds[i].Background = CreateTextureBrush('navi/' .. naviBg.. '.jpg', 'navi');
		roleBackgrounds[i].Visibility = Visibility.Visible;
	end
	--随机生成101至103间的resid
	--local value = math.ceil(math.random()*3) ;
	local value = self.index or 0;
	self.selectRoleResID = value + 101;
end

function Login:onNaviChanged( Arg )
	--local index = naviList.ActivePageIndex;
	self.index = naviList.ActivePageIndex;
	s_changebgstate = true;
	self.selectRoleResID = 101 +  self.index;
	roleRadioButtons[ self.index + 1].Selected = true;
	--[[
	local soundName = resTableManager:GetValue(ResTable.npc,tostring(1000+self.selectRoleResID),'vioce')
	if roleSound ~= nil then
		soundManager:DestroySource(roleSound);
		roleSound = nil
	end
	roleSound = SoundManager:PlayVoice( tostring(soundName))
	]]
end


--取消选择角色
function Login:onCancelSelectRole()
	accountPanel.Visibility = Visibility.Hidden;
	loginPanel.Visibility = Visibility.Visible;	--选择服务器
end

--进入游戏
function Login:onEnterGame()
	if self.uid == 0 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_login_6);
		return;
	end
	local server = self:getServer(self.hostnum);
	local msg = {};
	msg.aid = self.accountData.aid;
	msg.uid = self.uid;
	msg.hostnum = server.hostnum;
	msg.serid = server.serid;
	msg.version = VersionUpdate.localGameVersion;
	msg.name = Login.name;
	--if platformSDK.m_System == "Win32" then
	--  msg.name = platformSDK:GetMacAddress();
	--elseif platformSDK.m_System == "Android" then
	--  msg.name = platformSDK.m_UserName;
	--else
	--  msg.name = platformSDK.m_UserName;
	--end
	msg.mac = platformSDK:GetMacAddress();
	msg.sys = GlobalData.system[platformSDK.m_System];
	msg.domain = platformSDK.m_Platform;
	msg.device = platformSDK.m_DeviceVersion;
	msg.os = platformSDK.m_SystemVersion;
	--记录登录数据
	loginArgs.zoneId = server.serid;
	loginArgs.zoneName = server.name;
	PrintLog ("NetworkCmdType.req_enter_game Login player name: " .. msg.name);
	Network:Send(NetworkCmdType.req_enter_game, msg);
	platformSDK:SendUmengEvent('EnterGame');

end

function Login:onGetLoginArgs()
	return loginArgs;
end

--创建完角色直接进游戏
function Login:onEnterGameAfterCreateRole(msg)
	self.roleInfo = msg.role;
	self.uid = msg.role.uid;
	self:onEnterGame();
	--向服务器发送统计数据
	NetworkMsg_GodsSenki:SendStatisticsData(0, 2);
end

--========================================================================
--发送网络消息
--========================================================================

--发送请求角色列表
function Login:SendRequestRoleList( )
	if not isBtnLoginValid then
		return;
	end
	if VersionUpdate.curLanguage == LanguageType.tw then
		for index, server in pairs(Login.serverList) do
			if server.hostnum == Login.hostnum then
				local hostName = server.name .. "|" .. tostring(Login.hostnum);
				platformSDK:TPRoleLogin(platformSDK.m_UserName, 'role', platformSDK.m_UserName, 1, hostName);
				break;
			end
		end
	end

	--开发调试模式
	loginBtnState = 1;
	if platformSDK.m_System == 'Win32' or loginBtnState == 1 then
		local msg = {};
		msg.aid = self.accountData.aid;
		msg.hostnum = self.hostnum;
		local server = self:getServer(self.hostnum);
		msg.serid = server.serid;
		Network:Send(NetworkCmdType.req_rolelist, msg);
	else
		if platformSDK.m_IsInit then --and platformSDK.m_Platform ~= '' and platformSDK.m_Platform ~= nil then
			--SDK初始化成功
			platformSDK:OnLogin();
		end
	end

	if not VersionUpdate.sdkLoginFinished and platformSDK.m_Platform == 'shangmi' then
		platformSDK:OnLogin();
	end
end

--获取服务器
function Login:getServer( hostnum )

	if self.recomServerList then
		for _,v in ipairs(self.recomServerList) do
			if v.hostnum == hostnum then
				return v;
			end
		end
	end

	if self.serverList then
		for _,v in ipairs(self.serverList) do
			if v.hostnum == hostnum then
				return v;
			end
		end
	end

	return nil;
end

--确定服务器
function Login:onSelectServer( Arg )
	serverlistPanel.Visibility = Visibility.Hidden;
	closeServerChoicePanel.Visibility = Visibility.Hidden;
	local arg = UIControlEventArgs(Arg);
	self.hostnum = arg.m_pControl.Tag;
	--当前服务器
	curServer.Text = self:getServer(self.hostnum).name;
end

--发送创建角色
local timer = 0;
function Login:SendCreateRole( Arg )
	--local namebox = createActorPanel:GetLogicChild('nameBox') ;
	local msg = {};
	msg.aid = self.accountData.aid;
	msg.hostnum = self.hostnum;
	msg.name = Login.namebox.Text;
	msg.resid = self.selectRoleResID;
	if(utf8.len(msg.name) > Configuration.HeroNameStrCount) then
		local msId = MessageBox:ShowDialog(MessageBoxType.Ok, LOGIN_NAMEISTOOLENGTH_4);
		MessageBox:SetQuedingShowName(msId,'ok');
		return;
	end
	if(#msg.name == 0) then
		MessageBox:ShowDialog(MessageBoxType.Ok, LOGIN_NAMEISNULL_1);
		return ;
	end
	if(s_limitname) then                                        --说明当前含有非法字符
		MessageBox:ShowDialog(MessageBoxType.Ok, LOGIN_NAMEISNOLEGAL_2);
		return;
	else
		Network:Send(NetworkCmdType.req_new_role, msg);
	end
end

function Login:onResumeInput(Args)
	if not empty_name_text then
		print("clear")
		local args = UIControlEventArgs(Args);
		local control = args.m_pControl
		control.Text = ""
		empty_name_text = true
	end
end

function Login:onTextChange(Args)
	local args = UIControlEventArgs(Args);
	local heroName;
	--print("length = " .. utf8.len(args.m_pControl.Text))
	if utf8.len(args.m_pControl.Text) > Configuration.HeroNameStrCount then
		--超过最大字符限制
		local msId = MessageBox:ShowDialog(MessageBoxType.Ok, LOGIN_NAMEISTOOLENGTH_4);
		MessageBox:SetQuedingShowName(msId,'ok');
	else
		--没有超过最大字符限制
		heroName = args.m_pControl.Text;
		s_limitname = LimitedWord:isLimited(heroName);
		if(s_limitname) then                                     --提示重新起名字
			MessageBox:ShowDialog(MessageBoxType.Ok, LOGIN_NAMEISNOLEGAL_2);
		end
	end
end
local toastList = {};
--Teeplay 用户中心
function Login:OpenTeeplayCenter()
	platformSDK:TPUserLogin("0", "0");
end

--Teeplay 绑定facebook
function Login:BindFacebook()
	platformSDK:TPUserLogin("0", "1");
end

--平台登录成功，回调方法
function onLoginSuccess()
	VersionUpdate.sdkLoginFinished = true;
	if not VersionUpdate.gameInitFinished then
		return;
	end

	--这边隐藏，防止登录过程连续点击，Back键关闭登录又可继续点击
	--btnLogin.Visibility = Visibility.Hidden;
	isBtnLoginValid = false;
	loginBtnState = 1;
	PrintLog("onLoginSuccess"..platformSDK.m_UserName);

	platformSDK:SendUmengEvent('LoginSuccess');

	Login:gameLogin();

	accountName.Text = '' .. platformSDK.m_UserName;

	--BI数据统计，玩家成功登录账号
	BIDataStatistics:SetIsLogEnabled(true);
	BIDataStatistics:UserLogin();
end

--平台登陆失败，回调方法
function onLoginFailture()
	local okDelegate = Delegate.new(Network, Network.onNetError, 0);
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_login_7, okDelegate);
end

--退出平台账号
function onPlatformLogout()
	PrintLog('onPlatformLogout');

	Network:onNetError(0);
end
