--loading.lua

--========================================================================
--加载类

Loading =
	{
		loadingImageNum	= 2;		--loading图片的数量
		curImageName	= '';		--当前图片名
		moveSpeed		= 8;		--增长速度
		
		waitMsgNum		= 0;		--等待消息数
		
		loadType		= LoadType.none;		--等待类型
		loadingCount    = 0;		--加载次数
	};


--界面元素
local desktop;
local bottomDesktop;
local percentText;
local tip;
local bg;
local jinduBg;

local timer = 0;
local missionFinished = false;
local curSpeed = 0;
local curPercent = 0;
local curMaxPercent = 0;
local arriveCurMaxPercentTime = 0;
local progressBar;
local tips ;
--local alltips = {'萌动游戏商务合作请联系suny qq214929973'};
local alltips = {'您可以手动选择技能目标集中攻击对方特定角色',
'可以使用带有沉默，眩晕，混乱等效果的技能打断对方的技能',
'技能进阶可以大幅提升技能效果',
'根据角色的combo技能和元素属性搭配出战卡牌是获胜的关键' };

--初始化
function Loading:Init()

	uiSystem:LoadSchemeXML('loading.lay');
	desktop = uiSystem:GetDesktop('loading');
	SetDesktopSize(desktop);
	
	bottomDesktop = uiSystem:GetDesktop('bottom');
	percentText = desktop:GetLogicChild('percent');
	tip = desktop:GetLogicChild('tip');
	tip.Margin = Rect(31, 8, 0, 0);
	bg = desktop:GetLogicChild('panel');
	bg.Pick = false;
	jinduBg =desktop:GetLogicChild('panel1');
	jinduBg.Pick = false;
	jinduBg.Background = CreateTextureBrush('scale9/loading_diban.ccz', 'scale9');
	progressBar = desktop:GetLogicChild('bar');
    tips = desktop:GetLogicChild('tip2');  
    tips.Text = alltips[math.random(1, #alltips)];

    self.loadingCount = 0;
	desktop:GetLogicChild('warningPanel'):GetLogicChild('text0').Text = LANG_WARNING_TIP_0;
	desktop:GetLogicChild('warningPanel'):GetLogicChild('text1').Text = LANG_WARNING_TIP_1;
	desktop:GetLogicChild('warningPanel'):GetLogicChild('text2').Text = LANG_WARNING_TIP_2;
	desktop:GetLogicChild('warningPanel'):GetLogicChild('text3').Text = LANG_WARNING_TIP_3;
	desktop:GetLogicChild('warningPanel'):GetLogicChild('text4').Text = LANG_WARNING_TIP_4;
	desktop:GetLogicChild('warningPanel'):GetLogicChild('text5').Text = LANG_WARNING_TIP_5;
	desktop:GetLogicChild('warningPanel').Visibility = Visibility.Hidden;
end

--销毁
function Loading:Destroy()
	uiSystem:DestroyControl(desktop);
end

--进入
function Loading:onEnter(flag)
	if flag then
		desktop:GetLogicChild('warningPanel').Visibility = Visibility.Visible;
	else
		desktop:GetLogicChild('warningPanel').Visibility = Visibility.Hidden;
	end

	--隐藏网络发送等待界面
	Network.showWaiting = false;
	-- 
	--隐藏底层桌面
	bottomDesktop.Visibility = Visibility.Hidden;
	
	--加载登陆UI
	uiSystem:LoadResource('loading');

	self.loadingCount = self.loadingCount + 1;

	--初始化变量
	timer = 0;
	missionFinished = false;
	curSpeed = self.moveSpeed;
	curPercent = 0;
	curMaxPercent = 92;		--默认设置跑到92%
	arriveCurMaxPercentTime = 0;
	local index = 1;
	if self.loadingCount == 1 then      --登录时随机
		index = math.random(1,2);
	else
		--游戏中轮流加载
		index = math.mod(self.loadingCount, 2) + 1;
	end

	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		if platformSDK.m_Platform == 'liulian' or platformSDK.m_Platform == 'jituo1' or platformSDK.m_Platform == 'jituo2' then
			self.imgPath = 'background/login_bg0' .. index ..'.jpg';
		elseif platformSDK.m_Platform == 'djzj' then
			self.imgPath = 'background/login_bg1' .. index ..'.jpg';
		elseif platformSDK.m_Platform == 'xuegao1' or platformSDK.m_Platform == 'xuegao2' then
			self.imgPath = 'background/login_bg2' .. index ..'.jpg';
		elseif platformSDK.m_Platform == 'soga' then
			self.imgPath = 'background/login_bg4' .. index ..'.jpg';
		elseif platformSDK.m_Platform == 'zhanji' then
			self.imgPath = 'background/login_bg5' .. index ..'.jpg';
		elseif platformSDK.m_Platform == 'chaoyou' then
			self.imgPath = 'background/login_bg0' .. index ..'.jpg';
		else
			self.imgPath = 'background/login_bg' .. index ..'_pad.jpg';
		end
	else
		if platformSDK.m_Platform == 'liulian' or platformSDK.m_Platform == 'jituo1' or platformSDK.m_Platform == 'jituo2' then
			self.imgPath = 'background/login_bg0' .. index ..'.jpg';
		elseif platformSDK.m_Platform == 'djzj' then
			self.imgPath = 'background/login_bg1' .. index ..'.jpg';
		elseif platformSDK.m_Platform == 'xuegao1' or platformSDK.m_Platform == 'xuegao2' then
			self.imgPath = 'background/login_bg2' .. index ..'.jpg';
		elseif platformSDK.m_Platform == 'soga' then
			self.imgPath = 'background/login_bg4' .. index ..'.jpg';
		elseif platformSDK.m_Platform == 'zhanji' then
			self.imgPath = 'background/login_bg5' .. index ..'.jpg';
		elseif platformSDK.m_Platform == 'chaoyou' then
			self.imgPath = 'background/login_bg0' .. index ..'.jpg';
		else
			self.imgPath = 'background/login_bg' .. index ..'.jpg';
		end
	end
    bg.Background = CreateTextureBrush(self.imgPath, 'loading');
	--随机选择一个tip
	local id = Math.IRangeRandom(1, Loading.loadingImageNum);
--	Loading.curImageName = 'background/loading_'.. 4 .. '.ccz';
--	tip.Image = GetPicture(Loading.curImageName);
    
   -- local path = GlobalData.AnimationPath .. 'H020_output/';
	--AvatarManager:LoadFile(path);
	--print(path)
	--local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI'));
	--armatureUI.Horizontal = ControlLayout.H_CENTER;
	--armatureUI.Vertical = ControlLayout.V_CENTER;
	--armatureUI.Translate = Vector2(1, 0);
	--armatureUI:LoadArmature('H020');
	--armatureUI:SetAnimation(AnimationType.run);
	--desktop:AddChild(armatureUI);
    --tip.Image:AddChild(armatureUI) 
	--切换场景和桌面
	SceneManager:SetActiveScene(nil);
	uiSystem:SwitchToDesktop(desktop);	
	--触发加载开始
	EventManager:FireEvent(EventType.StartLoading);
end

--离开
function Loading:onLeave()
	--显示底层桌面
	bottomDesktop.Visibility = Visibility.Visible;
	--卸载用到的资源
	tip.Image = nil;
	uiSystem:UnloadResource('loading');
	--显示网络发送等待界面
	Network.showWaiting = true;
--TODO:公会返回家界面程序崩溃
	DestroyBrushAndImage(self.imgPath, 'loading');
	bg.Background = Converter.String2Brush('EidolonSystem.Black');
end

function Loading:loadingFinished()
	timerManager:DestroyTimer(timer);
	timer = 0;
	if desktop:GetLogicChild('warningPanel').Visibility == Visibility.Visible then
		return;
	end
	--切换到游戏状态
	Game:SwitchState(GameState.runningState);
end

--loading状态出错，退回到主城界面
function Loading:LoadingQuit()
	local okDelegate = Delegate.new(Loading, Loading.realLoadingQuit, 0);
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_loading_2, okDelegate);
end

--真正退出loading
function Loading:realLoadingQuit()
	if desktop:GetLogicChild('warningPanel').Visibility == Visibility.Visible then
		return;
	end
	Game:SwitchState(GameState.runningState);
end

--更新
local timetag = 1;
function Loading:Update( Elapse )
	timetag = timetag + 1;
	if timer ~= 0 then
		return;
	end

	curPercent = curPercent + curSpeed * Elapse;
	if curPercent >= curMaxPercent then
		curPercent = curMaxPercent;
		arriveCurMaxPercentTime = arriveCurMaxPercentTime + Elapse;
		
		if (arriveCurMaxPercentTime > 1) and (curMaxPercent < 99) then
			--大于1秒就进一步
			curMaxPercent = curMaxPercent + 1;
			
		end
	else
		arriveCurMaxPercentTime = 0;
	end

	local percent = math.floor(curPercent);
	percentText.Text = 'Loading ...';
	--progressBar.Text = percent .. '%';
	progressBar.CurValue = percent;	
	if curPercent >= 100 then
	  percentText.Text = 'LoadingFinished ...';
    --Loading:loadingFinished();
		timer = timerManager:CreateTimer(0.5, 'Loading:loadingFinished', 0, true);
		return;
	end

	--等待异步任务都完成
	if (self.waitMsgNum == 0) and (not missionFinished) and threadPool:IsThreadFuncFinished() then
		missionFinished = true;
		curSpeed = self.moveSpeed * 10;
		self:SetProgress(100);
	end	
end

--========================================================================
--功能函数

function Loading:DecWaitNum()
	self.waitMsgNum = self.waitMsgNum - 1;
end

--更新
function Loading:SetProgress( value )
	if value > 50 then
		curSpeed = curSpeed * 1.5;
	end
	if value > curMaxPercent then
		curMaxPercent = value;
	end
end

--设置loading类型
function Loading:SetLoadType(flag)
	self.loadType = flag;
end
