
--========================================================================

local debug = true;

local obb = false;

local hotfixCode = nil;

function Print( Arg )
	if debug then
		print(Arg)
	end
end

--========================================================================

--设置桌面尺寸
function SetDesktopSize( desktop )

	local uiCamera = desktop.Camera;
	local radio = appFramework.ScreenWidth / appFramework.ScreenHeight;
	local orthographicSize;

	--if radio < 1.5 then
  if false then --强制上下填充
		--小于3:2的分辨率，以左右填满，上下留边
		--以960为基准
		local scale = 960 / appFramework.ScreenWidth;
		local height = appFramework.ScreenHeight * scale;
		height = math.ceil(height);
		desktop.Size = Size(960, height);

		orthographicSize = height * 0.5;
	else
		--以640为基准
		local scale = 640 / appFramework.ScreenHeight;
		local width = appFramework.ScreenWidth * scale;
		width = math.ceil(width);
		desktop.Size = Size(width, 640);

		orthographicSize = 640 * 0.5;
	end

	uiCamera.OrthographicSize = orthographicSize;
	uiCamera.Aspect = desktop.Width / desktop.Height;

end

--========================================================================
--版本更新类


local uiIndex = -1;		--UI触控索引(UI只允许单一点击)


--界面元素
local desktop;
local percent;
local percentText;
local tip;
local messageBox;
local ok;
local cancel;
local queren;
local backgroundImage = '';
local background;
local msg;
local serverMaintain;
local serverMaintainMsg;
local netError;

local step = 0;
local timer = 0;
local missionFinished = false;
local curSpeed = 100;
local curPercent = 0;
local curMaxPercent = 0;

local needUpdate = false;			--是否需要更新

local downloadingSize = 0;			--下载中的大小
local downloadedSize = 0;			--当前已经下载的大小
local totalSize = 0;				--需要下载的大小

local initGameCO = nil;			--初始化游戏协程
local timeoutTimer = 0;			--超时计时器

local changBGTime = 0;
local changBGIndex = 0;
local isChangeBG = false;

HostUrl =
{
	---[[
	cn		= 'http://jp.ericagame.com:8030';		--大陆
	tw		= 'http://jp.ericagame.com:8030';		--台湾
	--]]
	--[[
	cn 		= 'http://niceadm.cgmars.com:8030';
	tw 		= 'http://niceadm.cgmars.com:8030';
	--]]
};


--销毁
function VersionUpdate:Destroy()
	isChangeBG = false;
	background.Background = nil;
	DestroyBrushAndImage(backgroundImage, 'update');

	uiSystem:DestroyControl(desktop);
	uiSystem:DestroyAllFont();
	uiSystem:UnloadResource('update');

	--清除一次纹理缓存
	imageManager:ReleaseUnusedImageFile();

	appFramework:DestroyRenderStep('updateStep');
end

--========================================================================

--更新
function VersionUpdate:Update( Elapse )
	
	uiSystem:Update(Elapse);
	if isChangeBG then
		if changBGTime >= 5 then
			VersionUpdate:changeBg();
			changBGTime = 0;
		end
		changBGTime = changBGTime + Elapse;
	end
	if timer ~= 0 then
		return;
	end

	if step == 1 then
		if obb then
			curMaxPercent = platformSDK:GetExtraInfo("copy","");
			curMaxPercent = tonumber(curMaxPercent);
		else
			curMaxPercent = appFramework.Progress;
		end
	elseif step == 2 then
		curMaxPercent = math.floor( (downloadedSize + downloadingSize) * 100 / totalSize );
	elseif step == 3 then
		curMaxPercent = appFramework.Progress;
		curPercent = curMaxPercent;
		coroutine.resume(initGameCO);
	end

	curPercent = curPercent + curSpeed * Elapse;
	if curPercent > curMaxPercent then
		curPercent = curMaxPercent;
	end
	local v = math.floor(curPercent);
	percent.CurValue = v;
	percentText.Text = v .. '%';

	if curPercent >= 100 then
		timer = timerManager:CreateTimer(0.1, 'VersionUpdate:loadingFinished', 0);
	end
end

--渲染
function VersionUpdate:Render()
	uiSystem:Render();
end

--触控开始
function VersionUpdate:TouchBegan( touch, event )
	if uiSystem:TouchBegan(touch, event) then
		uiIndex = touch.ID;
		return true;
	end

	return false;
end

--触控移动
function VersionUpdate:TouchMoved( touch, event )
	if uiIndex == touch.ID then
		return uiSystem:TouchMoved(touch, event);
	end

	return false;
end

--触控结束
function VersionUpdate:TouchEnded( touch, event )
	if uiIndex == touch.ID then
		return uiSystem:TouchEnded(touch, event);
	end

	return false;
end

--触控取消
function VersionUpdate:TouchCancelled( touch, event )
	if uiIndex == touch.ID then
		return uiSystem:TouchCancelled(touch, event);
	end

	return false;
end

--========================================================================
--功能函数

--初始化实现
function VersionUpdate:initImp()

	if self.curLanguage == LanguageType.tw then
		self.serverUrl = HostUrl.tw;
	elseif self.curLanguage == LanguageType.cn then
		self.serverUrl = HostUrl.cn;
	end

	self.urlAddress[1] = self.serverUrl .. '/ceshiup.php';
	self.urlAddress[2] = self.serverUrl .. '/ceshiup.php';
	self.urlAddress[3] = self.serverUrl .. '/ceshiup.php';

	--设置非异步加载
	renderer.AsyncLoadFlag = false;

	--设置url移除处理地址
	curlManager:SetHttpScriptRequestErrorHandler('VersionUpdate:getWWWAddressError');

	--设置初始进度
	appFramework.Progress = 0;

	local renderStep = appFramework:CreateScriptRenderStep('updateStep');
	renderStep.Priority = 0;
	renderStep:SetUpdateFunc(VersionUpdate, 'VersionUpdate:Update');
	renderStep:SetRenderFunc(VersionUpdate, 'VersionUpdate:Render');
	renderStep:SetTouchBeganFunc(VersionUpdate, 'VersionUpdate:TouchBegan');
	renderStep:SetTouchMovedFunc(VersionUpdate, 'VersionUpdate:TouchMoved');
	renderStep:SetTouchEndedFunc(VersionUpdate, 'VersionUpdate:TouchEnded');
	renderStep:SetTouchCancelledFunc(VersionUpdate, 'VersionUpdate:TouchCancelled');

	uiSystem:LoadResourceXML('versionUpdate_merge.res');
	uiSystem:LoadSchemeXML('versionUpdate.lay');

	uiSystem:LoadResource('update');
	desktop = uiSystem:GetDesktop('versionUpdate');
	uiSystem:SwitchToDesktop(desktop);
	SetDesktopSize(desktop);

	--控件
	percent = desktop:GetLogicChild('percent');
	percent.CurValue = 0;
	percentText = desktop:GetLogicChild('percentText');
	percentText.Text = '0%';
	tip = desktop:GetLogicChild('tip');
	messageBox = desktop:GetLogicChild('messageBox');
	ok = messageBox:GetLogicChild('ok');
	cancel = messageBox:GetLogicChild('cancel');
	queren = messageBox:GetLogicChild('queren');
	msg = messageBox:GetLogicChild('msg');
	background = desktop:GetLogicChild('background');
	--设置背景图片
	if VersionUpdate.curLanguage == LanguageType.cn then
		if platformSDK.m_Platform == 'liulian'  or platformSDK.m_Platform == 'jituo1' or platformSDK.m_Platform == 'jituo2' or platformSDK.m_Platform == 'chaoyou' then
			backgroundImage = 'versionUpdate_merge/H022_card_03.jpg';
		elseif platformSDK.m_Platform == 'djzj' then
			backgroundImage = 'versionUpdate_merge/H022_card_04.jpg';
		elseif platformSDK.m_Platform == 'xuegao1' or platformSDK.m_Platform == 'xuegao2' then
			backgroundImage = 'versionUpdate_merge/H022_card_05.jpg';
		elseif platformSDK.m_Platform == 'soga' then
			backgroundImage = 'versionUpdate_merge/H022_card_07.jpg';
		elseif platformSDK.m_Platform == 'zhanji' then
			backgroundImage = 'versionUpdate_merge/H022_card_08.jpg';
		else
			math.randomseed(tostring(os.time()):reverse():sub(1, 6));
			local bgIndex = math.random(0,2);
			if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
	          backgroundImage = 'versionUpdate_merge/H022_card_02_pad_'..bgIndex..'.jpg';
	        else
	          backgroundImage = 'versionUpdate_merge/H022_card_02_'..bgIndex..'.jpg';
	        end
		end
	elseif VersionUpdate.curLanguage == LanguageType.tw then
		if platformSDK.m_Platform == 'teeplay' then
			backgroundImage = 'versionUpdate_merge/H022_card_02_0.jpg';
		else
			backgroundImage = 'versionUpdate_merge/H022_card_02_0.jpg';
		end
	end

	local image = uiSystem:CreateFileImage(backgroundImage, backgroundImage);
    --local image = CreateTextureBrush(backgroundImage, 'login', Rect(0,0,960,640));

	local picBrush = uiSystem:CreateTextureBrush('update', backgroundImage, backgroundImage);
	local asyncLoadFlag = renderer.AsyncLoadFlag;
	renderer.AsyncLoadFlag = false;
	picBrush:Load();
	renderer.AsyncLoadFlag = asyncLoadFlag;
	background.Background = picBrush;

	messageBox.Visibility = Visibility.Hidden;

	serverMaintain = desktop:GetLogicChild('serverMaintain');
	serverMaintain.Visibility = Visibility.Hidden;
	serverMaintainMsg = serverMaintain:GetLogicChild('msg');

	netError = desktop:GetLogicChild('netError');
	netError.Visibility = Visibility.Hidden;

	timerManager:CreateTimer(0.1, 'VersionUpdate:delayInit', 0, true);

	--卸载已经加载的文件系统
	fileSystem:Unload();

end
function VersionUpdate:changeBg()
	
end
--延迟初始化
function VersionUpdate:delayInit()
	if self.EnabelUpdate then
		if self:firstStart() then
			self:getWWWAddress();
		end
	else
		--跳过更新
		if self:firstStart() then
			self:nextInit();
		end
	end
end

--加载结束
function VersionUpdate:loadingFinished()

	if step == 1 then

		if timer ~= 0 then
			timerManager:DestroyTimer(timer);
			timer = 0;
		end

		--写第一次成功的文件
		local successFileName = appFramework:GetDocumentPath() .. self.successName;
		local file = io.open(successFileName, 'w');
		file:close();

		platformSDK:SendUmengEvent('UnzipFinished');

		curPercent = 0;
		step = 2;
		totalSize = 100;

		if self.EnabelUpdate then
			self:getWWWAddress();
		else
			--跳过更新
			self:nextInit();
		end

	elseif step == 2 then

		if timer ~= 0 then
			timerManager:DestroyTimer(timer);
			timer = 0;
		end

		--切换到游戏状态
		self:UpdateOver();

	elseif step == 3 then
		if timer ~= 0 then
			timerManager:DestroyTimer(timer);
			timer = 0;
		end

		self:Destroy();
		Login:InitRenderStep();
		Login:InitPanel();

		Game:SwitchState(GameState.loginState);
		initGameCO = nil;

		platformSDK:SendUmengEvent('GameInitFinished');
	end

end

--自动更新结束
function VersionUpdate:UpdateOver()
	self:nextInit();
end

--后续初始化
function VersionUpdate:nextInit()

	while not threadPool:IsThreadFuncFinished() do
		--等待后台合并完成
	end

	platformSDK:SendUmengEvent('VersionUpdateFinished');

	--有新版本更新过
	if needUpdate then
		fileSystem:Unload();
		appFramework:Reset();
		return;
	end

	step = 3;
	appFramework.Progress = 0;

	tip.Text = LANG_versionUpdate_1;

	--设置异步加载
	renderer.AsyncLoadFlag = true;

	--清除超时计时器
	timerManager:DestroyTimer(timeoutTimer);
	timeoutTimer = 0;

	--先卸载文件系统，再加载文件系统（因为可能之前已经加载了，会一直保留版本号和目录树）
	fileSystem:Unload();
	fileSystem:Load(appFramework:GetDocumentPath(), appFramework:GetPKGFileName(), FileVersion.ms_InvalidFileVersion);

	initGameCO = coroutine.create(self.initGame);
	coroutine.resume(initGameCO);

end

--协程初始化游戏
function VersionUpdate:initGame()

	--清除url移除处理
	curlManager:SetHttpScriptRequestErrorHandler('');

	appFramework.Progress = 5;
	coroutine.yield();

	--获取本地版本
	local version = FileVersion();
	version.m_MajorVersion = 1;
	version.m_MinorVersion = 0;
	version.m_CompatibleVersion = 0;
	fileSystem:GetCurFileVersion(version);
	VersionUpdate.localGameVersion = version.m_MajorVersion .. '.' .. version.m_MinorVersion .. '.' .. version.m_CompatibleVersion;

	appFramework.Progress = 15;
	coroutine.yield();

	--加载lua文件
	RecursivelyLoadLuaScript('lua/base/', false);

	appFramework.Progress = 20;
	coroutine.yield();

	RecursivelyLoadLuaScript('lua/', false);

  doReplace();

	appFramework.Progress = 50;
	coroutine.yield();

	--切换到登陆状态
	Game:AddState(GameState.loginState, Login);

	appFramework.Progress = 80;
	coroutine.yield();

	GlobalData:InitGlobalDir();

	Login:InitSystem();

	appFramework.Progress = 100;
	coroutine.yield();

end

--第一次启动处理
function VersionUpdate:firstStart()

	tip.Text = LANG_versionUpdate_2;

	if platformSDK.m_System == "Android" then
		--android需要复制zip包中文件
		local successFileName = appFramework:GetDocumentPath() .. self.successName;
		local file = appFramework:GetDocumentPath() .. appFramework:GetPKGFileName() .. '.pkg';

		if not OperationSystem.IsPathExist(file) or not OperationSystem.IsPathExist(successFileName) then
			OperationSystem.DeleteFile(successFileName);
			step = 1;
			platformSDK:SendUmengEvent('UnzipStart');

			--创建目录并复制
			OperationSystem.CreatePath( appFramework:GetDocumentPath(), 755 );
			PrintLog("getObb");
			if obb then
				platformSDK:SendUmengEvent('getObb');
			else
			appFramework:CopyAppFile('assets/package.pkg', file);
			end
			return false;
		else
			--获取zip包中版本
			local fileContent = appFramework:GetAppFileContent('assets/version.txt');
			local apkVersion = StringUtil.Split(fileContent, '.');

			--获取本地版本
			local localVersion = StringUtil.Split( fileSystem:GetMaxFileVersion(file), '.' );

			--比较包和本地版本
			if VersionCompareFunc(localVersion, apkVersion) == -1 then
				--本地版本较老，要从apk中考出
				step = 1;
				OperationSystem.DeleteFile(successFileName);
				platformSDK:SendUmengEvent('UnzipStart');

				--创建目录并复制
				OperationSystem.CreatePath( appFramework:GetDocumentPath(), 755 );
				appFramework:CopyAppFile('assets/package.pkg', file);
				return false;
			end
		end
	elseif platformSDK.m_System == "iOS" then
		--iOS需要复制文件
		local successFileName = appFramework:GetDocumentPath() .. self.successName;
		local file = appFramework:GetDocumentPath() .. appFramework:GetPKGFileName() .. '.pkg';

		if not OperationSystem.IsPathExist(file) or not OperationSystem.IsPathExist(successFileName) then
			OperationSystem.DeleteFile(successFileName);
			step = 1;
			platformSDK:SendUmengEvent('UnzipStart');

			appFramework:CopyAppFile('package.pkg', file);
			return false;
		else
			--获取包中版本
			local fileContent = appFramework:GetAppFileContent( 'version.txt' );
			local apkVersion = StringUtil.Split(fileContent, '.');

			--获取本地版本
			local localVersion = StringUtil.Split( fileSystem:GetMaxFileVersion(file), '.' );

			--比较包和本地版本
			if VersionCompareFunc(localVersion, apkVersion) == -1 then
				--本地版本较老，要从app中考出
				step = 1;
				OperationSystem.DeleteFile(successFileName);
				platformSDK:SendUmengEvent('UnzipStart');

				--创建目录并复制
				OperationSystem.CreatePath( appFramework:GetDocumentPath(), 755 );
					appFramework:CopyAppFile('package.pkg', file);
				return false;
			end
		end
	end

	step = 2;
	totalSize = 100;
	return true;

end

--url获取失败
function VersionUpdate:getWWWAddressError()
	platformSDK:SendUmengEvent('VersionUpdateError');

	self.urlIndex = self.urlIndex + 1;
	if self.urlIndex > #self.urlAddress then
		--3个url地址都没有连通
		netError.Visibility = Visibility.Visible;
		tip.Text = '';
	else
		self:getWWWAddress();
	end
end

--获取更新地址
function VersionUpdate:getWWWAddress()
	platformSDK:SendUmengEvent('VersionUpdateStart');

	tip.Text = LANG_versionUpdate_3;
	self:sendUrlRequest();

	--创建超时计时器
	if timeoutTimer == 0 then
		timeoutTimer = timerManager:CreateTimer(20, 'VersionUpdate:onTimeOut', 0, true);
	end
end

--发送url请求
function VersionUpdate:sendUrlRequest()
	local msg = {};

	--备注：只需要得到当前本地的文件版本，不需要更新后的版本号（用处是发大版本的时候让服务器具有分辨出是否是测试用户）
	local filePath = appFramework:GetDocumentPath() .. appFramework:GetPKGFileName() .. '.pkg';
	local version = fileSystem:GetMaxFileVersion(filePath);
	version = StringUtil.Split(version, '.');
	msg.version = version[1] .. '.' .. version[2] .. '.' .. version[3];

	msg.mac =  platformSDK:GetMacAddress();

	msg.system = platformSDK.m_System;
	msg.debug = appFramework:GetVMVersion();
  local domain = platformSDK.m_Platform;
  if domain == "" then
    if platformSDK.m_System == "Android" or platformSDK.m_System == "Win32" then
      domain = "common";
    elseif platformSDK.m_System == "iOS" then
      domain = "apple";
    end
  end

  msg.domain = domain;

	msg = cjson.encode(msg);
	curlManager:SendHttpScriptRequest(self.urlAddress[self.urlIndex], '', 'VersionUpdate:onWWWAddress', 3, msg, '', 0);
end

--检查版本
function VersionUpdate:onWWWAddress( request )

	--清除超时计时器
	timerManager:DestroyTimer(timeoutTimer);
	timeoutTimer = 0;
	netError.Visibility = Visibility.Hidden;

	if request.m_Data ~= nil then

    print(request.m_Data);
		local data = cjson.decode(request.m_Data);
		if data.state == 1 then
			if data.info == nil then
				data.info = LANG_versionUpdate_4;
			end

			platformSDK:SendUmengEvent('VersionUpdateFinished');

			--服务器维护中
			serverMaintain.Visibility = Visibility.Visible;
			serverMaintainMsg.Text = data.info;
			tip.Text = data.info;
			return;
		end

		self.ip = data.ip;
		self.route = data.route;
		self.appUrl = data.appUrl;
		self.pkgUrl = data.pkgUrl;
		self.version = cjson.decode(data.versionFile);		--版本列表

		--hotfix code
		hotfixCode = data.hotfix;
		self.hosts = data.hosts;				--服务器列表


		local newVersion;

		if platformSDK.m_System == "Android" then
			newVersion = StringUtil.Split(self.version.appAndroidVersion, '.');
		elseif platformSDK.m_System == "iOS" then
			newVersion = StringUtil.Split(self.version.appiOSVersion, '.');
		elseif platformSDK.m_System == "Win32" then
			newVersion = StringUtil.Split(self.version.appWinVersion, '.');
		end

		local curVersion = StringUtil.Split(appFramework:GetVMVersion(), '.');

		--比较vm版本
		---[[
		if VersionCompareFunc(newVersion, curVersion) == 1 then
			--有更新版本，弹出提示窗口
			msg.Text = LANG_versionUpdate_5;
			messageBox.Visibility = Visibility.Visible;
			ok.Visibility = Visibility.Hidden;
			cancel.Visibility = Visibility.Hidden;
			queren.Visibility = Visibility.Visible;
			return;
		end
		--]]

		--比较game版本
		newVersion = StringUtil.Split(self.version.gameCurVersion, '.');

		--获取本地版本
		local filePath = appFramework:GetDocumentPath() .. appFramework:GetPKGFileName() .. '.pkg';

		if not OperationSystem.IsPathExist(filePath) then
			--本地文件不存在，则从最初开始下载
			self.versionIndex = #self.version.gameOldVersions;
			needUpdate = true;
		else
			--本地文件存在
			local curVersion = StringUtil.Split( fileSystem:GetMaxFileVersion(filePath), '.' );

			if VersionCompareFunc(newVersion, curVersion) == 1 then
				needUpdate = true;
			end

			if needUpdate then
				--需要更新，确定更新版本
				local version = curVersion[1] .. '.' .. curVersion[2] .. '.' .. curVersion[3];
				for k, v in ipairs(self.version.gameOldVersions) do
					if v.Version == version then
						self.versionIndex = k;
						break;
					end
				end

				self.versionIndex = self.versionIndex - 1;
			end
		end

		if needUpdate then
			--下载更新，弹出提示窗口
			step = 2;
			totalSize = 0;

			local v;
			local vFile;
			for i = 1, self.versionIndex do

				v = self.version.gameOldVersions[self.versionIndex - i + 1];
				vFile = appFramework:GetCachePath() .. v.Version .. '.pkg';
				if OperationSystem.IsPathExist(vFile) then
					local attr = FileAttribute();
					OperationSystem.GetFileAttribute(vFile, attr);

					if attr.m_Size ~= v.Size then
						totalSize = totalSize + v.Size - attr.m_Size;
					end
				else
					totalSize = totalSize + v.Size;
				end

			end
			
			isChangeBG = true;

			if platformSDK:GetNetStatus() == 'Wifi' then
				--wifi自动更新，不用提示
				tip.Text = LANG_versionUpdate_6;
				self:downloadFile(self.versionIndex);
			else
				local len = math.floor(totalSize / 1024 * 100) / 100;
				local text = LANG_versionUpdate_7 .. len .. 'K';
				msg.Text = text;
				messageBox.Visibility = Visibility.Visible;
				ok.Visibility = Visibility.Visible;
				cancel.Visibility = Visibility.Visible;
				queren.Visibility = Visibility.Hidden;
				--tip.Text = LANG_versionUpdate_6;
				--self:downloadFile(self.versionIndex);
			end
		else
			--不用更新
			curPercent = 100;
			downloadedSize = 100;
		end
	else
		--返回错误
		netError.Visibility = Visibility.Visible;
		tip.Text = '';
	end

end

--下载完成
function VersionUpdate:downloadComplete( request )
  print("downloadComplete");

	local dstfile = appFramework:GetDocumentPath() .. appFramework:GetPKGFileName() .. '.pkg';
	appFramework:MergeFileSystem(request.m_LocalFile, dstfile);

	while not threadPool:IsThreadFuncFinished() do
        --等待后台合并完成
    end

	downloadingSize = 0;
	downloadedSize = downloadedSize + request.m_DownloadTotal;

	self.versionIndex = self.versionIndex - 1;
	if self.versionIndex > 0 then
		VersionUpdate:downloadFile(self.versionIndex);
	end

end

--下载进度
function VersionUpdate:downloadProgress( request )
	downloadingSize = request.m_DownloadProgress * request.m_DownloadTotal;

	local curLen = math.floor( (downloadedSize + downloadingSize) / 1024 );
	local totalLen = math.floor(totalSize / 1024);
	tip.Text = LANG_versionUpdate_6 .. ' ' .. curLen .. 'K/' .. totalLen .. 'K';
end

--下载文件
function VersionUpdate:downloadFile( index )
	if not OperationSystem.IsPathExist( appFramework:GetCachePath() ) then
		OperationSystem.CreatePath( appFramework:GetCachePath(), 755 );
	end

	local version = self.version.gameOldVersions[index].Version;
	local fileName = version .. '.pkg';
	local srcfile = self.pkgUrl .. version .. '/' .. fileName;
	local dstfile = appFramework:GetCachePath() .. fileName;
	curlManager:SendHttpScriptDownloadFile(srcfile, dstfile, 'VersionUpdate:downloadComplete', 0, 'VersionUpdate:downloadProgress', 0);
end

--登陆超时
function VersionUpdate:onTimeOut()
	netError.Visibility = Visibility.Visible;
	tip.Text = '';
end

--========================================================================
--界面响应

--下载app更新按钮确定
function VersionUpdate:onAppUpdateClick()
	messageBox.msg = LANG_versionUpdate_8;
	appFramework:OpenUrl(self.appUrl);
end

--下载游戏更新按钮确定
function VersionUpdate:onGameUpdateClick()
	tip.Text = LANG_versionUpdate_9;
	messageBox.Visibility = Visibility.Hidden;
	self:downloadFile(self.versionIndex);
end

--下载游戏更新按钮取消
function VersionUpdate:onGameUpdateCancelClick()
	appFramework:Terminate();
end

--服务器维护
function VersionUpdate:onServerMaintainClick()
	appFramework:Terminate();
end

--网络错误
function VersionUpdate:onNetError()
	appFramework:Reset();
end

function doReplace()

  print("hook begin...");
  UIRenderStep.TouchEnded      = Debug.hook(UIRenderStep.TouchEnded);
  UIRenderStep.TouchBegan      = Debug.hook(UIRenderStep.TouchBegan);
  UIRenderStep.Update          = Debug.hook(UIRenderStep.Update);
  UIRenderStep.Render          = Debug.hook(UIRenderStep.Render);
  UIRenderStep.TouchMoved      = Debug.hook(UIRenderStep.TouchMoved);
  UIRenderStep.TouchCancelled  = Debug.hook(UIRenderStep.TouchCancelled);

  BottomRenderStep.Update      = Debug.hook(BottomRenderStep.Update);
  BottomRenderStep.Render      = Debug.hook(BottomRenderStep.Render);
  BottomRenderStep.TouchBegan  = Debug.hook(BottomRenderStep.TouchBegan);
  BottomRenderStep.TouchEnded  = Debug.hook(BottomRenderStep.TouchEnded);
  BottomRenderStep.TouchMoved  = Debug.hook(BottomRenderStep.TouchMoved);

  TopRenderStep.Update         = Debug.hook(TopRenderStep.Update);
  TopRenderStep.Render         = Debug.hook(TopRenderStep.Render);
  TopRenderStep.TouchBegan     = Debug.hook(TopRenderStep.TouchBegan);
  TopRenderStep.TouchMoved     = Debug.hook(TopRenderStep.TouchMoved);
  TopRenderStep.TouchEnded     = Debug.hook(TopRenderStep.TouchEnded);
  TopRenderStep.TouchCancelled = Debug.hook(TopRenderStep.TouchCancelled);

  SceneRenderStep.Update       = Debug.hook(SceneRenderStep.Update);
  SceneRenderStep.Render       = Debug.hook(SceneRenderStep.Render);
  SceneRenderStep.TouchBegan   = Debug.hook(SceneRenderStep.TouchBegan);

  Game.Update                  = Debug.hook(Game.Update);

  DamageEffect                 = Debug.hook(DamageEffect);
  EffectManager.CreateTraceEffect = Debug.hook(EffectManager.CreateTraceEffect);


  local hookDebugInfo = function(str)
     --print(str);
  end

  ActivityAllPanel.GetSumConsumeReward = Debug.hook(ActivityAllPanel.GetSumConsumeReward); hookDebugInfo('ActivityAllPanel.GetSumConsumeReward hooked')
  ActivityAllPanel.OnChangeTextInvite = Debug.hook(ActivityAllPanel.OnChangeTextInvite); hookDebugInfo('ActivityAllPanel.OnChangeTextInvite hooked')
  ActivityAllPanel.OnClose = Debug.hook(ActivityAllPanel.OnClose); hookDebugInfo('ActivityAllPanel.OnClose hooked')
  ActivityAllPanel.OnExchangeGift = Debug.hook(ActivityAllPanel.OnExchangeGift); hookDebugInfo('ActivityAllPanel.OnExchangeGift hooked')
  ActivityAllPanel.OnInviteVerify = Debug.hook(ActivityAllPanel.OnInviteVerify); hookDebugInfo('ActivityAllPanel.OnInviteVerify hooked')
  ActivityAllPanel.OnShow = Debug.hook(ActivityAllPanel.OnShow); hookDebugInfo('ActivityAllPanel.OnShow hooked')
  ActivityAllPanel.OpenInvasionBoss = Debug.hook(ActivityAllPanel.OpenInvasionBoss); hookDebugInfo('ActivityAllPanel.OpenInvasionBoss hooked')
  ActivityAllPanel.getGrowingReward = Debug.hook(ActivityAllPanel.getGrowingReward); hookDebugInfo('ActivityAllPanel.getGrowingReward hooked')
  ActivityAllPanel.onBuyGrowingReward = Debug.hook(ActivityAllPanel.onBuyGrowingReward); hookDebugInfo('ActivityAllPanel.onBuyGrowingReward hooked')
  ActivityAllPanel.onEatClick = Debug.hook(ActivityAllPanel.onEatClick); hookDebugInfo('ActivityAllPanel.onEatClick hooked')
  ActivityAllPanel.onGetFightRewardClick = Debug.hook(ActivityAllPanel.onGetFightRewardClick); hookDebugInfo('ActivityAllPanel.onGetFightRewardClick hooked')
  ActivityAllPanel.onGetInviteRewardClick = Debug.hook(ActivityAllPanel.onGetInviteRewardClick); hookDebugInfo('ActivityAllPanel.onGetInviteRewardClick hooked')
  ActivityAllPanel.onGetLevelRewardClick = Debug.hook(ActivityAllPanel.onGetLevelRewardClick); hookDebugInfo('ActivityAllPanel.onGetLevelRewardClick hooked')
  ActivityAllPanel.onGetReward = Debug.hook(ActivityAllPanel.onGetReward); hookDebugInfo('ActivityAllPanel.onGetReward hooked')
  ActivityRechargePanel.GetLimitReward = Debug.hook(ActivityRechargePanel.GetLimitReward); hookDebugInfo('ActivityRechargePanel.GetLimitReward hooked')
  ActivityRechargePanel.GetLuckyBagReward = Debug.hook(ActivityRechargePanel.GetLuckyBagReward); hookDebugInfo('ActivityRechargePanel.GetLuckyBagReward hooked')
  ActivityRechargePanel.OnClose = Debug.hook(ActivityRechargePanel.OnClose); hookDebugInfo('ActivityRechargePanel.OnClose hooked')
  ActivityRechargePanel.OnShow = Debug.hook(ActivityRechargePanel.OnShow); hookDebugInfo('ActivityRechargePanel.OnShow hooked')
  ActivityRechargePanel.gotoFight = Debug.hook(ActivityRechargePanel.gotoFight); hookDebugInfo('ActivityRechargePanel.gotoFight hooked')
  ActivityRechargePanel.gotoWing = Debug.hook(ActivityRechargePanel.gotoWing); hookDebugInfo('ActivityRechargePanel.gotoWing hooked')
  ActivityRechargePanel.gotoZhaomu = Debug.hook(ActivityRechargePanel.gotoZhaomu); hookDebugInfo('ActivityRechargePanel.gotoZhaomu hooked')
  ActivityRechargePanel.onShowRechargePanel = Debug.hook(ActivityRechargePanel.onShowRechargePanel); hookDebugInfo('ActivityRechargePanel.onShowRechargePanel hooked')
  AllRolePanel.onClick = Debug.hook(AllRolePanel.onClick); hookDebugInfo('AllRolePanel.onClick hooked')
  AllRolePanel.onClose = Debug.hook(AllRolePanel.onClose); hookDebugInfo('AllRolePanel.onClose hooked')
  AllRolePanel.onPageChanged = Debug.hook(AllRolePanel.onPageChanged); hookDebugInfo('AllRolePanel.onPageChanged hooked')
  ArenaDialogPanel.onClose = Debug.hook(ArenaDialogPanel.onClose); hookDebugInfo('ArenaDialogPanel.onClose hooked')
  ArenaDialogPanel.onPlayback = Debug.hook(ArenaDialogPanel.onPlayback); hookDebugInfo('ArenaDialogPanel.onPlayback hooked')
  ArenaDialogPanel.onShare = Debug.hook(ArenaDialogPanel.onShare); hookDebugInfo('ArenaDialogPanel.onShare hooked')
  ArenaPanel.closeTeamInfoPanel = Debug.hook(ArenaPanel.closeTeamInfoPanel); hookDebugInfo('ArenaPanel.closeTeamInfoPanel hooked')
  ArenaPanel.onBuy = Debug.hook(ArenaPanel.onBuy); hookDebugInfo('ArenaPanel.onBuy hooked')
  ArenaPanel.onChallenge = Debug.hook(ArenaPanel.onChallenge); hookDebugInfo('ArenaPanel.onChallenge hooked')
  ArenaPanel.onChangeTeam = Debug.hook(ArenaPanel.onChangeTeam); hookDebugInfo('ArenaPanel.onChangeTeam hooked')
  ArenaPanel.onCloseExplain = Debug.hook(ArenaPanel.onCloseExplain); hookDebugInfo('ArenaPanel.onCloseExplain hooked')
  ArenaPanel.onExplainClick = Debug.hook(ArenaPanel.onExplainClick); hookDebugInfo('ArenaPanel.onExplainClick hooked')
  ArenaPanel.onRank = Debug.hook(ArenaPanel.onRank); hookDebugInfo('ArenaPanel.onRank hooked')
  ArenaPanel.onRecord = Debug.hook(ArenaPanel.onRecord); hookDebugInfo('ArenaPanel.onRecord hooked')
  ArenaPanel.onReturn = Debug.hook(ArenaPanel.onReturn); hookDebugInfo('ArenaPanel.onReturn hooked')
  ArenaPanel.onShop = Debug.hook(ArenaPanel.onShop); hookDebugInfo('ArenaPanel.onShop hooked')
  ArenaPanel.showExplainPanel = Debug.hook(ArenaPanel.showExplainPanel); hookDebugInfo('ArenaPanel.showExplainPanel hooked')
  ArenaPanel.showTeamInfoPanel = Debug.hook(ArenaPanel.showTeamInfoPanel); hookDebugInfo('ArenaPanel.showTeamInfoPanel hooked')
  ArmoryPanel.onAddFriend = Debug.hook(ArmoryPanel.onAddFriend); hookDebugInfo('ArmoryPanel.onAddFriend hooked')
  ArmoryPanel.onChat = Debug.hook(ArmoryPanel.onChat); hookDebugInfo('ArmoryPanel.onChat hooked')
  ArmoryPanel.onClose = Debug.hook(ArmoryPanel.onClose); hookDebugInfo('ArmoryPanel.onClose hooked')
  ArmoryPanel.onInfoPopupMenuLoseFocus = Debug.hook(ArmoryPanel.onInfoPopupMenuLoseFocus); hookDebugInfo('ArmoryPanel.onInfoPopupMenuLoseFocus hooked')
  ArmoryPanel.onLookOverPlayerInfo = Debug.hook(ArmoryPanel.onLookOverPlayerInfo); hookDebugInfo('ArmoryPanel.onLookOverPlayerInfo hooked')
  ArmoryPanel.onPageChange = Debug.hook(ArmoryPanel.onPageChange); hookDebugInfo('ArmoryPanel.onPageChange hooked')
  ArmoryPanel.onPlayerClick = Debug.hook(ArmoryPanel.onPlayerClick); hookDebugInfo('ArmoryPanel.onPlayerClick hooked')
  ArmoryPanel.onShowRewardTips = Debug.hook(ArmoryPanel.onShowRewardTips); hookDebugInfo('ArmoryPanel.onShowRewardTips hooked')
  AutoBattleInfoPanel.onPveAutoBattleOk = Debug.hook(AutoBattleInfoPanel.onPveAutoBattleOk); hookDebugInfo('AutoBattleInfoPanel.onPveAutoBattleOk hooked')
  BagListPanel.onChangeRadio = Debug.hook(BagListPanel.onChangeRadio); hookDebugInfo('BagListPanel.onChangeRadio hooked')
  BuyCountPanel.onBuy = Debug.hook(BuyCountPanel.onBuy); hookDebugInfo('BuyCountPanel.onBuy hooked')
  BuyCountPanel.onClose = Debug.hook(BuyCountPanel.onClose); hookDebugInfo('BuyCountPanel.onClose hooked')
  BuyPowerPanel.onClose = Debug.hook(BuyPowerPanel.onClose); hookDebugInfo('BuyPowerPanel.onClose hooked')
  BuyPowerPanel.onGoldClick = Debug.hook(BuyPowerPanel.onGoldClick); hookDebugInfo('BuyPowerPanel.onGoldClick hooked')
  BuyUniversalPanel.onAdd = Debug.hook(BuyUniversalPanel.onAdd); hookDebugInfo('BuyUniversalPanel.onAdd hooked')
  BuyUniversalPanel.onBuy = Debug.hook(BuyUniversalPanel.onBuy); hookDebugInfo('BuyUniversalPanel.onBuy hooked')
  BuyUniversalPanel.onClose = Debug.hook(BuyUniversalPanel.onClose); hookDebugInfo('BuyUniversalPanel.onClose hooked')
  BuyUniversalPanel.onMax = Debug.hook(BuyUniversalPanel.onMax); hookDebugInfo('BuyUniversalPanel.onMax hooked')
  BuyUniversalPanel.onMin = Debug.hook(BuyUniversalPanel.onMin); hookDebugInfo('BuyUniversalPanel.onMin hooked')
  BuyUniversalPanel.onTextChange = Debug.hook(BuyUniversalPanel.onTextChange); hookDebugInfo('BuyUniversalPanel.onTextChange hooked')
  CardCommentPanel.ClickText = Debug.hook(CardCommentPanel.ClickText); hookDebugInfo('CardCommentPanel.ClickText hooked')
  CardCommentPanel.closeHaveRolePanel = Debug.hook(CardCommentPanel.closeHaveRolePanel); hookDebugInfo('CardCommentPanel.closeHaveRolePanel hooked')
  CardCommentPanel.closeMainRolePanel = Debug.hook(CardCommentPanel.closeMainRolePanel); hookDebugInfo('CardCommentPanel.closeMainRolePanel hooked')
  CardCommentPanel.closeNoRolePanel = Debug.hook(CardCommentPanel.closeNoRolePanel); hookDebugInfo('CardCommentPanel.closeNoRolePanel hooked')
  CardCommentPanel.displayUserInfo = Debug.hook(CardCommentPanel.displayUserInfo); hookDebugInfo('CardCommentPanel.displayUserInfo hooked')
  CardCommentPanel.onChangeRadio = Debug.hook(CardCommentPanel.onChangeRadio); hookDebugInfo('CardCommentPanel.onChangeRadio hooked')
  CardCommentPanel.onCheckBoxChanged = Debug.hook(CardCommentPanel.onCheckBoxChanged); hookDebugInfo('CardCommentPanel.onCheckBoxChanged hooked')
  CardCommentPanel.onClose = Debug.hook(CardCommentPanel.onClose); hookDebugInfo('CardCommentPanel.onClose hooked')
  CardCommentPanel.onPraise = Debug.hook(CardCommentPanel.onPraise); hookDebugInfo('CardCommentPanel.onPraise hooked')
  CardCommentPanel.onTextChange = Debug.hook(CardCommentPanel.onTextChange); hookDebugInfo('CardCommentPanel.onTextChange hooked')
  CardCommentPanel.sendComment = Debug.hook(CardCommentPanel.sendComment); hookDebugInfo('CardCommentPanel.sendComment hooked')
  CardDetailPanel.GetMaterialPathItem = Debug.hook(CardDetailPanel.GetMaterialPathItem); hookDebugInfo('CardDetailPanel.GetMaterialPathItem hooked')
  CardDetailPanel.TaskClick = Debug.hook(CardDetailPanel.TaskClick); hookDebugInfo('CardDetailPanel.TaskClick hooked')
--  CardDetailPanel.ceshi1 = Debug.hook(CardDetailPanel.ceshi1); hookDebugInfo('CardDetailPanel.ceshi1 hooked')
  CardDetailPanel.getRoleClick = Debug.hook(CardDetailPanel.getRoleClick); hookDebugInfo('CardDetailPanel.getRoleClick hooked')
  CardDetailPanel.gotoLovePanel = Debug.hook(CardDetailPanel.gotoLovePanel); hookDebugInfo('CardDetailPanel.gotoLovePanel hooked')
  CardDetailPanel.inPutCardListPanel = Debug.hook(CardDetailPanel.inPutCardListPanel); hookDebugInfo('CardDetailPanel.inPutCardListPanel hooked')
  CardDetailPanel.onBack = Debug.hook(CardDetailPanel.onBack); hookDebugInfo('CardDetailPanel.onBack hooked')
  CardDetailPanel.onClickAttribute = Debug.hook(CardDetailPanel.onClickAttribute); hookDebugInfo('CardDetailPanel.onClickAttribute hooked')
  CardDetailPanel.onClickComment = Debug.hook(CardDetailPanel.onClickComment); hookDebugInfo('CardDetailPanel.onClickComment hooked')
  CardDetailPanel.onClickEquip = Debug.hook(CardDetailPanel.onClickEquip); hookDebugInfo('CardDetailPanel.onClickEquip hooked')
  CardDetailPanel.onClickGem = Debug.hook(CardDetailPanel.onClickGem); hookDebugInfo('CardDetailPanel.onClickGem hooked')
  CardDetailPanel.onClickLovePhase = Debug.hook(CardDetailPanel.onClickLovePhase); hookDebugInfo('CardDetailPanel.onClickLovePhase hooked')
  CardDetailPanel.onClickSkill = Debug.hook(CardDetailPanel.onClickSkill); hookDebugInfo('CardDetailPanel.onClickSkill hooked')
  CardDetailPanel.onClickWing = Debug.hook(CardDetailPanel.onClickWing); hookDebugInfo('CardDetailPanel.onClickWing hooked')
  CardDetailPanel.playAcotor = Debug.hook(CardDetailPanel.playAcotor); hookDebugInfo('CardDetailPanel.playAcotor hooked')
  CardDetailPanel.roleClick = Debug.hook(CardDetailPanel.roleClick); hookDebugInfo('CardDetailPanel.roleClick hooked')
  CardDetailPanel.roleCloseClick = Debug.hook(CardDetailPanel.roleCloseClick); hookDebugInfo('CardDetailPanel.roleCloseClick hooked')
  CardDetailPanel.roundNotOpen = Debug.hook(CardDetailPanel.roundNotOpen); hookDebugInfo('CardDetailPanel.roundNotOpen hooked')
  CardDetailPanel.setKanban = Debug.hook(CardDetailPanel.setKanban); hookDebugInfo('CardDetailPanel.setKanban hooked')
  CardEventPanel.enterActorPanel = Debug.hook(CardEventPanel.enterActorPanel); hookDebugInfo('CardEventPanel.enterActorPanel hooked')
  CardEventPanel.hideLevelSelect = Debug.hook(CardEventPanel.hideLevelSelect); hookDebugInfo('CardEventPanel.hideLevelSelect hooked')
  CardEventPanel.ilDown = Debug.hook(CardEventPanel.ilDown); hookDebugInfo('CardEventPanel.ilDown hooked')
  CardEventPanel.ilUp = Debug.hook(CardEventPanel.ilUp); hookDebugInfo('CardEventPanel.ilUp hooked')
  CardEventPanel.onChangeRadio = Debug.hook(CardEventPanel.onChangeRadio); hookDebugInfo('CardEventPanel.onChangeRadio hooked')
  CardEventPanel.onClose = Debug.hook(CardEventPanel.onClose); hookDebugInfo('CardEventPanel.onClose hooked')
  CardEventPanel.onDownEvent = Debug.hook(CardEventPanel.onDownEvent); hookDebugInfo('CardEventPanel.onDownEvent hooked')
  CardEventPanel.onHideIll = Debug.hook(CardEventPanel.onHideIll); hookDebugInfo('CardEventPanel.onHideIll hooked')
  CardEventPanel.onMouseUp = Debug.hook(CardEventPanel.onMouseUp); hookDebugInfo('CardEventPanel.onMouseUp hooked')
  CardEventPanel.onOpen = Debug.hook(CardEventPanel.onOpen); hookDebugInfo('CardEventPanel.onOpen hooked')
  CardEventPanel.onUpEvent = Debug.hook(CardEventPanel.onUpEvent); hookDebugInfo('CardEventPanel.onUpEvent hooked')
  CardEventPanel.rankDown = Debug.hook(CardEventPanel.rankDown); hookDebugInfo('CardEventPanel.rankDown hooked')
  CardEventPanel.rankUp = Debug.hook(CardEventPanel.rankUp); hookDebugInfo('CardEventPanel.rankUp hooked')
  CardEventPanel.rewardDown = Debug.hook(CardEventPanel.rewardDown); hookDebugInfo('CardEventPanel.rewardDown hooked')
  CardEventPanel.rewardUp = Debug.hook(CardEventPanel.rewardUp); hookDebugInfo('CardEventPanel.rewardUp hooked')
--  CardEventPanel.selectLv = Debug.hook(CardEventPanel.selectLv); hookDebugInfo('CardEventPanel.selectLv hooked')
  CardListPanel.closeCardPanel = Debug.hook(CardListPanel.closeCardPanel); hookDebugInfo('CardListPanel.closeCardPanel hooked')
  CardListPanel.onChangeRadio = Debug.hook(CardListPanel.onChangeRadio); hookDebugInfo('CardListPanel.onChangeRadio hooked')
--  CardListPanel.onClickCard = Debug.hook(CardListPanel.onClickCard); hookDebugInfo('CardListPanel.onClickCard hooked')
  CardLvlupPanel.EnterDailyTask = Debug.hook(CardLvlupPanel.EnterDailyTask); hookDebugInfo('CardLvlupPanel.EnterDailyTask hooked')
  CardLvlupPanel.EnterPvE = Debug.hook(CardLvlupPanel.EnterPvE); hookDebugInfo('CardLvlupPanel.EnterPvE hooked')
  CardLvlupPanel.onCram = Debug.hook(CardLvlupPanel.onCram); hookDebugInfo('CardLvlupPanel.onCram hooked')
  CardLvlupPanel.onEat = Debug.hook(CardLvlupPanel.onEat); hookDebugInfo('CardLvlupPanel.onEat hooked')
  CardRankupPanel.TaskClick = Debug.hook(CardRankupPanel.TaskClick); hookDebugInfo('CardRankupPanel.TaskClick hooked')
  CardRankupPanel.onCloseClick = Debug.hook(CardRankupPanel.onCloseClick); hookDebugInfo('CardRankupPanel.onCloseClick hooked')
  CardRankupPanel.rankUp = Debug.hook(CardRankupPanel.rankUp); hookDebugInfo('CardRankupPanel.rankUp hooked')
  ChatPanel.ClickText = Debug.hook(ChatPanel.ClickText); hookDebugInfo('ChatPanel.ClickText hooked')
  ChatPanel.Hide = Debug.hook(ChatPanel.Hide); hookDebugInfo('ChatPanel.Hide hooked')
  ChatPanel.Send = Debug.hook(ChatPanel.Send); hookDebugInfo('ChatPanel.Send hooked')
  ChatPanel.checkBtnClickEvent = Debug.hook(ChatPanel.checkBtnClickEvent); hookDebugInfo('ChatPanel.checkBtnClickEvent hooked')
  ChatPanel.onBtnExpressionClick = Debug.hook(ChatPanel.onBtnExpressionClick); hookDebugInfo('ChatPanel.onBtnExpressionClick hooked')
--  ChatPanel.onClickInfoPlayer = Debug.hook(ChatPanel.onClickInfoPlayer); hookDebugInfo('ChatPanel.onClickInfoPlayer hooked')
  ChatPanel.onExpressionClick = Debug.hook(ChatPanel.onExpressionClick); hookDebugInfo('ChatPanel.onExpressionClick hooked')
  ChatPanel.onExpressionLoseFocus = Debug.hook(ChatPanel.onExpressionLoseFocus); hookDebugInfo('ChatPanel.onExpressionLoseFocus hooked')
  ChatPanel.onTabPageChange = Debug.hook(ChatPanel.onTabPageChange); hookDebugInfo('ChatPanel.onTabPageChange hooked')
  ChatPanel.onTextChange = Debug.hook(ChatPanel.onTextChange); hookDebugInfo('ChatPanel.onTextChange hooked')
  ChatPanel.onwindowPanelLoseFocus = Debug.hook(ChatPanel.onwindowPanelLoseFocus); hookDebugInfo('ChatPanel.onwindowPanelLoseFocus hooked')
  ChipSelectPanel.onBatchSelect = Debug.hook(ChipSelectPanel.onBatchSelect); hookDebugInfo('ChipSelectPanel.onBatchSelect hooked')
  ChipSelectPanel.onClose = Debug.hook(ChipSelectPanel.onClose); hookDebugInfo('ChipSelectPanel.onClose hooked')
  ChipSelectPanel.onShow = Debug.hook(ChipSelectPanel.onShow); hookDebugInfo('ChipSelectPanel.onShow hooked')
  ChroniclePanel.CloseRewardPanel = Debug.hook(ChroniclePanel.CloseRewardPanel); hookDebugInfo('ChroniclePanel.CloseRewardPanel hooked')
  ChroniclePanel.onChange = Debug.hook(ChroniclePanel.onChange); hookDebugInfo('ChroniclePanel.onChange hooked')
  ChroniclePanel.onClose = Debug.hook(ChroniclePanel.onClose); hookDebugInfo('ChroniclePanel.onClose hooked')
  ChroniclePanel.onDetail = Debug.hook(ChroniclePanel.onDetail); hookDebugInfo('ChroniclePanel.onDetail hooked')
  ChroniclePanel.onHistory = Debug.hook(ChroniclePanel.onHistory); hookDebugInfo('ChroniclePanel.onHistory hooked')
  ChroniclePanel.onMove = Debug.hook(ChroniclePanel.onMove); hookDebugInfo('ChroniclePanel.onMove hooked')
  ChroniclePanel.onRetrieve = Debug.hook(ChroniclePanel.onRetrieve); hookDebugInfo('ChroniclePanel.onRetrieve hooked')
  ChroniclePanel.onShowStory = Debug.hook(ChroniclePanel.onShowStory); hookDebugInfo('ChroniclePanel.onShowStory hooked')
  ChroniclePanel.onToday = Debug.hook(ChroniclePanel.onToday); hookDebugInfo('ChroniclePanel.onToday hooked')
  CoinNotEnoughPanel.onCancel = Debug.hook(CoinNotEnoughPanel.onCancel); hookDebugInfo('CoinNotEnoughPanel.onCancel hooked')
  CoinNotEnoughPanel.onGold = Debug.hook(CoinNotEnoughPanel.onGold); hookDebugInfo('CoinNotEnoughPanel.onGold hooked')
  ConvertPackagePanel.onClose = Debug.hook(ConvertPackagePanel.onClose); hookDebugInfo('ConvertPackagePanel.onClose hooked')
  ConvertPackagePanel.onConvert = Debug.hook(ConvertPackagePanel.onConvert); hookDebugInfo('ConvertPackagePanel.onConvert hooked')
  DailySignPanel.cancelRemedy = Debug.hook(DailySignPanel.cancelRemedy); hookDebugInfo('DailySignPanel.cancelRemedy hooked')
  DailySignPanel.getSignReward = Debug.hook(DailySignPanel.getSignReward); hookDebugInfo('DailySignPanel.getSignReward hooked')
  DailySignPanel.meredyClick = Debug.hook(DailySignPanel.meredyClick); hookDebugInfo('DailySignPanel.meredyClick hooked')
  DailySignPanel.onClose = Debug.hook(DailySignPanel.onClose); hookDebugInfo('DailySignPanel.onClose hooked')
  DailySignPanel.onNotice = Debug.hook(DailySignPanel.onNotice); hookDebugInfo('DailySignPanel.onNotice hooked')
  DailySignPanel.onNoticeClose = Debug.hook(DailySignPanel.onNoticeClose); hookDebugInfo('DailySignPanel.onNoticeClose hooked')
  DailySignPanel.reqRemedyReward = Debug.hook(DailySignPanel.reqRemedyReward); hookDebugInfo('DailySignPanel.reqRemedyReward hooked')
  DailySignPanel.reqSignInfo = Debug.hook(DailySignPanel.reqSignInfo); hookDebugInfo('DailySignPanel.reqSignInfo hooked')
  DoubleFirstChargePanel.Charge10 = Debug.hook(DoubleFirstChargePanel.Charge10); hookDebugInfo('DoubleFirstChargePanel.Charge10 hooked')
  DoubleFirstChargePanel.Charge50 = Debug.hook(DoubleFirstChargePanel.Charge50); hookDebugInfo('DoubleFirstChargePanel.Charge50 hooked')
  DoubleFirstChargePanel.onClose = Debug.hook(DoubleFirstChargePanel.onClose); hookDebugInfo('DoubleFirstChargePanel.onClose hooked')
  DrawingSynthesisPanel.DoGeneratePaper = Debug.hook(DrawingSynthesisPanel.DoGeneratePaper); hookDebugInfo('DrawingSynthesisPanel.DoGeneratePaper hooked')
  DrawingSynthesisPanel.OnClose = Debug.hook(DrawingSynthesisPanel.OnClose); hookDebugInfo('DrawingSynthesisPanel.OnClose hooked')
  DrawingSynthesisPanel.OnSelectPaper = Debug.hook(DrawingSynthesisPanel.OnSelectPaper); hookDebugInfo('DrawingSynthesisPanel.OnSelectPaper hooked')
  DrawingSynthesisPanel.OnUnSelectPaper = Debug.hook(DrawingSynthesisPanel.OnUnSelectPaper); hookDebugInfo('DrawingSynthesisPanel.OnUnSelectPaper hooked')
  EmailCheckPanel.onGet = Debug.hook(EmailCheckPanel.onGet); hookDebugInfo('EmailCheckPanel.onGet hooked')
  EmailPanel.GetAllReward = Debug.hook(EmailPanel.GetAllReward); hookDebugInfo('EmailPanel.GetAllReward hooked')
  EmailPanel.delete = Debug.hook(EmailPanel.delete); hookDebugInfo('EmailPanel.delete hooked')
  EmailPanel.onClose = Debug.hook(EmailPanel.onClose); hookDebugInfo('EmailPanel.onClose hooked')
  EmailPanel.onDeleteAll = Debug.hook(EmailPanel.onDeleteAll); hookDebugInfo('EmailPanel.onDeleteAll hooked')
--  EmailPanel.onFeedback = Debug.hook(EmailPanel.onFeedback); hookDebugInfo('EmailPanel.onFeedback hooked')
  EmailPanel.onGet = Debug.hook(EmailPanel.onGet); hookDebugInfo('EmailPanel.onGet hooked')
  EmailPanel.onRequestEmail = Debug.hook(EmailPanel.onRequestEmail); hookDebugInfo('EmailPanel.onRequestEmail hooked')
  EmailPanel.onShowMail = Debug.hook(EmailPanel.onShowMail); hookDebugInfo('EmailPanel.onShowMail hooked')
  EquipStrengthPanel.UpdateAdvInfo = Debug.hook(EquipStrengthPanel.UpdateAdvInfo); hookDebugInfo('EquipStrengthPanel.UpdateAdvInfo hooked')
  EquipStrengthPanel.UpdateInfo = Debug.hook(EquipStrengthPanel.UpdateInfo); hookDebugInfo('EquipStrengthPanel.UpdateInfo hooked')
  EquipStrengthPanel.onAdvance = Debug.hook(EquipStrengthPanel.onAdvance); hookDebugInfo('EquipStrengthPanel.onAdvance hooked')
  EquipStrengthPanel.onClose = Debug.hook(EquipStrengthPanel.onClose); hookDebugInfo('EquipStrengthPanel.onClose hooked')
  EquipStrengthPanel.onPageChange = Debug.hook(EquipStrengthPanel.onPageChange); hookDebugInfo('EquipStrengthPanel.onPageChange hooked')
  EquipStrengthPanel.onStrength = Debug.hook(EquipStrengthPanel.onStrength); hookDebugInfo('EquipStrengthPanel.onStrength hooked')
  EquipStrengthPanel.onStrengthTen = Debug.hook(EquipStrengthPanel.onStrengthTen); hookDebugInfo('EquipStrengthPanel.onStrengthTen hooked')
  EquipStrengthPanel.userGuide = Debug.hook(EquipStrengthPanel.userGuide); hookDebugInfo('EquipStrengthPanel.userGuide hooked')
  ExpeditionPanel.notOpenOrPassed = Debug.hook(ExpeditionPanel.notOpenOrPassed); hookDebugInfo('ExpeditionPanel.notOpenOrPassed hooked')
  ExpeditionPanel.onClickReset = Debug.hook(ExpeditionPanel.onClickReset); hookDebugInfo('ExpeditionPanel.onClickReset hooked')
  ExpeditionPanel.onClose = Debug.hook(ExpeditionPanel.onClose); hookDebugInfo('ExpeditionPanel.onClose hooked')
  ExpeditionPanel.onCloseExplain = Debug.hook(ExpeditionPanel.onCloseExplain); hookDebugInfo('ExpeditionPanel.onCloseExplain hooked')
  ExpeditionPanel.onFight = Debug.hook(ExpeditionPanel.onFight); hookDebugInfo('ExpeditionPanel.onFight hooked')
  ExpeditionPanel.onMove = Debug.hook(ExpeditionPanel.onMove); hookDebugInfo('ExpeditionPanel.onMove hooked')
  ExpeditionPanel.onOk = Debug.hook(ExpeditionPanel.onOk); hookDebugInfo('ExpeditionPanel.onOk hooked')
  ExpeditionPanel.onOpen = Debug.hook(ExpeditionPanel.onOpen); hookDebugInfo('ExpeditionPanel.onOpen hooked')
  ExpeditionPanel.onShow = Debug.hook(ExpeditionPanel.onShow); hookDebugInfo('ExpeditionPanel.onShow hooked')
  ExpeditionPanel.showExplainPanel = Debug.hook(ExpeditionPanel.showExplainPanel); hookDebugInfo('ExpeditionPanel.showExplainPanel hooked')
  ExpeditionPanel.showVipPanel = Debug.hook(ExpeditionPanel.showVipPanel); hookDebugInfo('ExpeditionPanel.showVipPanel hooked')
  ExpeditionShopPanel.onBuy = Debug.hook(ExpeditionShopPanel.onBuy); hookDebugInfo('ExpeditionShopPanel.onBuy hooked')
  ExpeditionShopPanel.onClick = Debug.hook(ExpeditionShopPanel.onClick); hookDebugInfo('ExpeditionShopPanel.onClick hooked')
  ExpeditionShopPanel.onClose = Debug.hook(ExpeditionShopPanel.onClose); hookDebugInfo('ExpeditionShopPanel.onClose hooked')
  ExpeditionShopPanel.onShow = Debug.hook(ExpeditionShopPanel.onShow); hookDebugInfo('ExpeditionShopPanel.onShow hooked')
  FbIntroductionPanel.onClickAchievement = Debug.hook(FbIntroductionPanel.onClickAchievement); hookDebugInfo('FbIntroductionPanel.onClickAchievement hooked')
  FbIntroductionPanel.onClickBack = Debug.hook(FbIntroductionPanel.onClickBack); hookDebugInfo('FbIntroductionPanel.onClickBack hooked')
  FbIntroductionPanel.onClickBiandui = Debug.hook(FbIntroductionPanel.onClickBiandui); hookDebugInfo('FbIntroductionPanel.onClickBiandui hooked')
  FbIntroductionPanel.onClickFight = Debug.hook(FbIntroductionPanel.onClickFight); hookDebugInfo('FbIntroductionPanel.onClickFight hooked')
  FbIntroductionPanel.onClickSaodang = Debug.hook(FbIntroductionPanel.onClickSaodang); hookDebugInfo('FbIntroductionPanel.onClickSaodang hooked')
  FbIntroductionPanel.onSelectNext = Debug.hook(FbIntroductionPanel.onSelectNext); hookDebugInfo('FbIntroductionPanel.onSelectNext hooked')
  FbIntroductionPanel.onSelectPrevious = Debug.hook(FbIntroductionPanel.onSelectPrevious); hookDebugInfo('FbIntroductionPanel.onSelectPrevious hooked')
  FbIntroductionPanel.saodangOk = Debug.hook(FbIntroductionPanel.saodangOk); hookDebugInfo('FbIntroductionPanel.saodangOk hooked')
  FbIntroductionPanel.setSwipeTimes = Debug.hook(FbIntroductionPanel.setSwipeTimes); hookDebugInfo('FbIntroductionPanel.setSwipeTimes hooked')
  FbIntroductionPanel.teamChange = Debug.hook(FbIntroductionPanel.teamChange); hookDebugInfo('FbIntroductionPanel.teamChange hooked')
  FightComboLinkManager.onHide = Debug.hook(FightComboLinkManager.onHide); hookDebugInfo('FightComboLinkManager.onHide hooked')
  FightComboQueue.onFadeout = Debug.hook(FightComboQueue.onFadeout); hookDebugInfo('FightComboQueue.onFadeout hooked')
  FightConfigPanel.OnAnimOff = Debug.hook(FightConfigPanel.OnAnimOff); hookDebugInfo('FightConfigPanel.OnAnimOff hooked')
  FightConfigPanel.OnAnimOn = Debug.hook(FightConfigPanel.OnAnimOn); hookDebugInfo('FightConfigPanel.OnAnimOn hooked')
  FightConfigPanel.OnBulletOff = Debug.hook(FightConfigPanel.OnBulletOff); hookDebugInfo('FightConfigPanel.OnBulletOff hooked')
  FightConfigPanel.OnBulletOn = Debug.hook(FightConfigPanel.OnBulletOn); hookDebugInfo('FightConfigPanel.OnBulletOn hooked')
  FightImageGuidePanel.onClose = Debug.hook(FightImageGuidePanel.onClose); hookDebugInfo('FightImageGuidePanel.onClose hooked')
  FightOverUIManager.OnBackToCity = Debug.hook(FightOverUIManager.OnBackToCity); hookDebugInfo('FightOverUIManager.OnBackToCity hooked')
  FightOverUIManager.OnBackToPveBarrier = Debug.hook(FightOverUIManager.OnBackToPveBarrier); hookDebugInfo('FightOverUIManager.OnBackToPveBarrier hooked')
  FightOverUIManager.OnTryAgain = Debug.hook(FightOverUIManager.OnTryAgain); hookDebugInfo('FightOverUIManager.OnTryAgain hooked')
  FightQTEManager.Skip = Debug.hook(FightQTEManager.Skip); hookDebugInfo('FightQTEManager.Skip hooked')
  FightSkillCardManager.onCardFlyOut = Debug.hook(FightSkillCardManager.onCardFlyOut); hookDebugInfo('FightSkillCardManager.onCardFlyOut hooked')
  FightSkillCardManager.onClickCard = Debug.hook(FightSkillCardManager.onClickCard); hookDebugInfo('FightSkillCardManager.onClickCard hooked')
  FightUIManager.debugClearCardCallback = Debug.hook(FightUIManager.debugClearCardCallback); hookDebugInfo('FightUIManager.debugClearCardCallback hooked')
  FightUIManager.debugSkillCardCallback = Debug.hook(FightUIManager.debugSkillCardCallback); hookDebugInfo('FightUIManager.debugSkillCardCallback hooked')
  Fighter.SetDebugDie = Debug.hook(Fighter.SetDebugDie); hookDebugInfo('Fighter.SetDebugDie hooked')
  FirstPassRoundRewardPanel.onClose = Debug.hook(FirstPassRoundRewardPanel.onClose); hookDebugInfo('FirstPassRoundRewardPanel.onClose hooked')
  FirstRechargePanel.onButtonClick = Debug.hook(FirstRechargePanel.onButtonClick); hookDebugInfo('FirstRechargePanel.onButtonClick hooked')
  FirstRechargePanel.onClose = Debug.hook(FirstRechargePanel.onClose); hookDebugInfo('FirstRechargePanel.onClose hooked')
  FirstRechargePanel.onShowFirstRechargePanel = Debug.hook(FirstRechargePanel.onShowFirstRechargePanel); hookDebugInfo('FirstRechargePanel.onShowFirstRechargePanel hooked')
  FriendAddPanel.onAddClick = Debug.hook(FriendAddPanel.onAddClick); hookDebugInfo('FriendAddPanel.onAddClick hooked')
  FriendAddPanel.onClose = Debug.hook(FriendAddPanel.onClose); hookDebugInfo('FriendAddPanel.onClose hooked')
  FriendAddPanel.onSearchClick = Debug.hook(FriendAddPanel.onSearchClick); hookDebugInfo('FriendAddPanel.onSearchClick hooked')
  FriendAddPanel.onShowFriendAdd = Debug.hook(FriendAddPanel.onShowFriendAdd); hookDebugInfo('FriendAddPanel.onShowFriendAdd hooked')
  FriendApplyPanel.onAgree = Debug.hook(FriendApplyPanel.onAgree); hookDebugInfo('FriendApplyPanel.onAgree hooked')
  FriendApplyPanel.onClose = Debug.hook(FriendApplyPanel.onClose); hookDebugInfo('FriendApplyPanel.onClose hooked')
  FriendApplyPanel.onIgnore = Debug.hook(FriendApplyPanel.onIgnore); hookDebugInfo('FriendApplyPanel.onIgnore hooked')
  FriendApplyPanel.onIgnoreAll = Debug.hook(FriendApplyPanel.onIgnoreAll); hookDebugInfo('FriendApplyPanel.onIgnoreAll hooked')
  FriendAssistPanel.onAssistPanelPageLeft = Debug.hook(FriendAssistPanel.onAssistPanelPageLeft); hookDebugInfo('FriendAssistPanel.onAssistPanelPageLeft hooked')
  FriendAssistPanel.onAssistPanelPageRight = Debug.hook(FriendAssistPanel.onAssistPanelPageRight); hookDebugInfo('FriendAssistPanel.onAssistPanelPageRight hooked')
  FriendAssistPanel.onClose = Debug.hook(FriendAssistPanel.onClose); hookDebugInfo('FriendAssistPanel.onClose hooked')
  FriendAssistPanel.onSelectAssist = Debug.hook(FriendAssistPanel.onSelectAssist); hookDebugInfo('FriendAssistPanel.onSelectAssist hooked')
  FriendAssistPanel.onShowFriendAssist = Debug.hook(FriendAssistPanel.onShowFriendAssist); hookDebugInfo('FriendAssistPanel.onShowFriendAssist hooked')
  FriendFlowerPanel.accept = Debug.hook(FriendFlowerPanel.accept); hookDebugInfo('FriendFlowerPanel.accept hooked')
  FriendFlowerPanel.accpetAll = Debug.hook(FriendFlowerPanel.accpetAll); hookDebugInfo('FriendFlowerPanel.accpetAll hooked')
  FriendFlowerPanel.onClose = Debug.hook(FriendFlowerPanel.onClose); hookDebugInfo('FriendFlowerPanel.onClose hooked')
  FriendListPanel.Show = Debug.hook(FriendListPanel.Show); hookDebugInfo('FriendListPanel.Show hooked')
  FriendListPanel.findFriend = Debug.hook(FriendListPanel.findFriend); hookDebugInfo('FriendListPanel.findFriend hooked')
  FriendListPanel.onChat = Debug.hook(FriendListPanel.onChat); hookDebugInfo('FriendListPanel.onChat hooked')
  FriendListPanel.onClickApplyList = Debug.hook(FriendListPanel.onClickApplyList); hookDebugInfo('FriendListPanel.onClickApplyList hooked')
  FriendListPanel.onClickGetFlower = Debug.hook(FriendListPanel.onClickGetFlower); hookDebugInfo('FriendListPanel.onClickGetFlower hooked')
  FriendListPanel.onClose = Debug.hook(FriendListPanel.onClose); hookDebugInfo('FriendListPanel.onClose hooked')
  FriendListPanel.onDelFriend = Debug.hook(FriendListPanel.onDelFriend); hookDebugInfo('FriendListPanel.onDelFriend hooked')
  FriendListPanel.onDetailFriend = Debug.hook(FriendListPanel.onDetailFriend); hookDebugInfo('FriendListPanel.onDetailFriend hooked')
  FriendListPanel.onFriendListScroll = Debug.hook(FriendListPanel.onFriendListScroll); hookDebugInfo('FriendListPanel.onFriendListScroll hooked')
  FriendListPanel.onResumeInput = Debug.hook(FriendListPanel.onResumeInput); hookDebugInfo('FriendListPanel.onResumeInput hooked')
  FriendListPanel.onSelectFriend = Debug.hook(FriendListPanel.onSelectFriend); hookDebugInfo('FriendListPanel.onSelectFriend hooked')
  FriendListPanel.onTextChange = Debug.hook(FriendListPanel.onTextChange); hookDebugInfo('FriendListPanel.onTextChange hooked')
  FriendListPanel.sendFlower = Debug.hook(FriendListPanel.sendFlower); hookDebugInfo('FriendListPanel.sendFlower hooked')
  FriendPanel.onChallange = Debug.hook(FriendPanel.onChallange); hookDebugInfo('FriendPanel.onChallange hooked')
  FriendPanel.onChat = Debug.hook(FriendPanel.onChat); hookDebugInfo('FriendPanel.onChat hooked')
  FriendPanel.onClose = Debug.hook(FriendPanel.onClose); hookDebugInfo('FriendPanel.onClose hooked')
  FriendPanel.onDeleteFriend = Debug.hook(FriendPanel.onDeleteFriend); hookDebugInfo('FriendPanel.onDeleteFriend hooked')
  FriendPanel.onFriendClick = Debug.hook(FriendPanel.onFriendClick); hookDebugInfo('FriendPanel.onFriendClick hooked')
  FriendPanel.onFriendListScroll = Debug.hook(FriendPanel.onFriendListScroll); hookDebugInfo('FriendPanel.onFriendListScroll hooked')
  FriendPanel.onLookOverFriendInfo = Debug.hook(FriendPanel.onLookOverFriendInfo); hookDebugInfo('FriendPanel.onLookOverFriendInfo hooked')
  FriendPanel.onRequestClick = Debug.hook(FriendPanel.onRequestClick); hookDebugInfo('FriendPanel.onRequestClick hooked')
  FriendPanel.onSureLoseFocus = Debug.hook(FriendPanel.onSureLoseFocus); hookDebugInfo('FriendPanel.onSureLoseFocus hooked')
  FriendPanel.onTextChange = Debug.hook(FriendPanel.onTextChange); hookDebugInfo('FriendPanel.onTextChange hooked')
  FriendPanel.onTextFocuse = Debug.hook(FriendPanel.onTextFocuse); hookDebugInfo('FriendPanel.onTextFocuse hooked')
  FriendPanel.onVerify = Debug.hook(FriendPanel.onVerify); hookDebugInfo('FriendPanel.onVerify hooked')
  FriendRequestPanel.onAcceptRequest = Debug.hook(FriendRequestPanel.onAcceptRequest); hookDebugInfo('FriendRequestPanel.onAcceptRequest hooked')
  FriendRequestPanel.onClose = Debug.hook(FriendRequestPanel.onClose); hookDebugInfo('FriendRequestPanel.onClose hooked')
  FriendRequestPanel.onRejectRequest = Debug.hook(FriendRequestPanel.onRejectRequest); hookDebugInfo('FriendRequestPanel.onRejectRequest hooked')
  GemPanel.buyGem = Debug.hook(GemPanel.buyGem); hookDebugInfo('GemPanel.buyGem hooked')
  GemPanel.clickGemType = Debug.hook(GemPanel.clickGemType); hookDebugInfo('GemPanel.clickGemType hooked')
  GemPanel.closeSynPanel = Debug.hook(GemPanel.closeSynPanel); hookDebugInfo('GemPanel.closeSynPanel hooked')
  GemPanel.debusAll = Debug.hook(GemPanel.debusAll); hookDebugInfo('GemPanel.debusAll hooked')
  GemPanel.inlayAll = Debug.hook(GemPanel.inlayAll); hookDebugInfo('GemPanel.inlayAll hooked')
--  GemPanel.onChooseMosGem = Debug.hook(GemPanel.onChooseMosGem); hookDebugInfo('GemPanel.onChooseMosGem hooked')
  GemPanel.onClickSyn = Debug.hook(GemPanel.onClickSyn); hookDebugInfo('GemPanel.onClickSyn hooked')
  GemPanel.onClose = Debug.hook(GemPanel.onClose); hookDebugInfo('GemPanel.onClose hooked')
  GemPanel.onDebus = Debug.hook(GemPanel.onDebus); hookDebugInfo('GemPanel.onDebus hooked')
--  GemPanel.onDismantle = Debug.hook(GemPanel.onDismantle); hookDebugInfo('GemPanel.onDismantle hooked')
  GemPanel.onInlay = Debug.hook(GemPanel.onInlay); hookDebugInfo('GemPanel.onInlay hooked')
--  GemPanel.onPageChange = Debug.hook(GemPanel.onPageChange); hookDebugInfo('GemPanel.onPageChange hooked')
  GemPanel.onRoleClick = Debug.hook(GemPanel.onRoleClick); hookDebugInfo('GemPanel.onRoleClick hooked')
--  GemPanel.onShowFromTips = Debug.hook(GemPanel.onShowFromTips); hookDebugInfo('GemPanel.onShowFromTips hooked')
--  GemPanel.onShowQuick = Debug.hook(GemPanel.onShowQuick); hookDebugInfo('GemPanel.onShowQuick hooked')
  GemPanel.synAll = Debug.hook(GemPanel.synAll); hookDebugInfo('GemPanel.synAll hooked')
  GemPanel.synGem = Debug.hook(GemPanel.synGem); hookDebugInfo('GemPanel.synGem hooked')
  GemSelectPanel.Show = Debug.hook(GemSelectPanel.Show); hookDebugInfo('GemSelectPanel.Show hooked')
  GemSelectPanel.onBuy = Debug.hook(GemSelectPanel.onBuy); hookDebugInfo('GemSelectPanel.onBuy hooked')
  GemSelectPanel.onClose = Debug.hook(GemSelectPanel.onClose); hookDebugInfo('GemSelectPanel.onClose hooked')
  GemSelectPanel.onSureLoseFocus = Debug.hook(GemSelectPanel.onSureLoseFocus); hookDebugInfo('GemSelectPanel.onSureLoseFocus hooked')
  GemSelectPanel.onSynthetise = Debug.hook(GemSelectPanel.onSynthetise); hookDebugInfo('GemSelectPanel.onSynthetise hooked')
  GemSynResultPanel.onClose = Debug.hook(GemSynResultPanel.onClose); hookDebugInfo('GemSynResultPanel.onClose hooked')
  GodPartnerForLimitTimePanel.OnClose = Debug.hook(GodPartnerForLimitTimePanel.OnClose); hookDebugInfo('GodPartnerForLimitTimePanel.OnClose hooked')
  GoodsFalldownManager.PickGoods = Debug.hook(GoodsFalldownManager.PickGoods); hookDebugInfo('GoodsFalldownManager.PickGoods hooked')
  HelpPanel.onClick = Debug.hook(HelpPanel.onClick); hookDebugInfo('HelpPanel.onClick hooked')
  HelpPanel.onClose = Debug.hook(HelpPanel.onClose); hookDebugInfo('HelpPanel.onClose hooked')
  HomePanel.ListClick = Debug.hook(HomePanel.ListClick); hookDebugInfo('HomePanel.ListClick hooked')
  HomePanel.NaviClick = Debug.hook(HomePanel.NaviClick); hookDebugInfo('HomePanel.NaviClick hooked')
  HomePanel.ShowRoleInfo = Debug.hook(HomePanel.ShowRoleInfo); hookDebugInfo('HomePanel.ShowRoleInfo hooked')
  HomePanel.onBagClick = Debug.hook(HomePanel.onBagClick); hookDebugInfo('HomePanel.onBagClick hooked')
  HomePanel.onChangeRadio = Debug.hook(HomePanel.onChangeRadio); hookDebugInfo('HomePanel.onChangeRadio hooked')
  HomePanel.onClickBack = Debug.hook(HomePanel.onClickBack); hookDebugInfo('HomePanel.onClickBack hooked')
  HomePanel.onClickHistory = Debug.hook(HomePanel.onClickHistory); hookDebugInfo('HomePanel.onClickHistory hooked')
  HomePanel.onClickTeam = Debug.hook(HomePanel.onClickTeam); hookDebugInfo('HomePanel.onClickTeam hooked')
  HomePanel.onEnterHomePanel = Debug.hook(HomePanel.onEnterHomePanel); hookDebugInfo('HomePanel.onEnterHomePanel hooked')
  HomePanel.switchStatus = Debug.hook(HomePanel.switchStatus); hookDebugInfo('HomePanel.switchStatus hooked')
  HomePanel.turnPageChange = Debug.hook(HomePanel.turnPageChange); hookDebugInfo('HomePanel.turnPageChange hooked')
  HunShiLevelUpPanel.onClose = Debug.hook(HunShiLevelUpPanel.onClose); hookDebugInfo('HunShiLevelUpPanel.onClose hooked')
  HunShiPanel.RuleExplainHide = Debug.hook(HunShiPanel.RuleExplainHide); hookDebugInfo('HunShiPanel.RuleExplainHide hooked')
  HunShiPanel.RuleExplainShow = Debug.hook(HunShiPanel.RuleExplainShow); hookDebugInfo('HunShiPanel.RuleExplainShow hooked')
  HunShiPanel.attBtnOnClick = Debug.hook(HunShiPanel.attBtnOnClick); hookDebugInfo('HunShiPanel.attBtnOnClick hooked')
  HunShiPanel.examBtnOnClick = Debug.hook(HunShiPanel.examBtnOnClick); hookDebugInfo('HunShiPanel.examBtnOnClick hooked')
  HunShiPanel.imgOnClick = Debug.hook(HunShiPanel.imgOnClick); hookDebugInfo('HunShiPanel.imgOnClick hooked')
  HunShiPanel.onClose = Debug.hook(HunShiPanel.onClose); hookDebugInfo('HunShiPanel.onClose hooked')
  HunShiPanel.onShow = Debug.hook(HunShiPanel.onShow); hookDebugInfo('HunShiPanel.onShow hooked')
  HunShiPanel.tipPanelHide = Debug.hook(HunShiPanel.tipPanelHide); hookDebugInfo('HunShiPanel.tipPanelHide hooked')
  HunShiPanel.upPanelHide = Debug.hook(HunShiPanel.upPanelHide); hookDebugInfo('HunShiPanel.upPanelHide hooked')
  InnerTestPackPanel.onClose = Debug.hook(InnerTestPackPanel.onClose); hookDebugInfo('InnerTestPackPanel.onClose hooked')
  InnerTestPackPanel.onShow = Debug.hook(InnerTestPackPanel.onShow); hookDebugInfo('InnerTestPackPanel.onShow hooked')
  InviteFriendPanel.onClose = Debug.hook(InviteFriendPanel.onClose); hookDebugInfo('InviteFriendPanel.onClose hooked')
  LimitTaskPanel.Hide = Debug.hook(LimitTaskPanel.Hide); hookDebugInfo('LimitTaskPanel.Hide hooked')
  LimitTaskPanel.onClick = Debug.hook(LimitTaskPanel.onClick); hookDebugInfo('LimitTaskPanel.onClick hooked')
  LimitTaskPanel.partnerHide = Debug.hook(LimitTaskPanel.partnerHide); hookDebugInfo('LimitTaskPanel.partnerHide hooked')
  LimitTaskPanel.partnerOnClick = Debug.hook(LimitTaskPanel.partnerOnClick); hookDebugInfo('LimitTaskPanel.partnerOnClick hooked')
  Login.RefreshServerPanel = Debug.hook(Login.RefreshServerPanel); hookDebugInfo('Login.RefreshServerPanel hooked')
  Login.SendRequestRoleList = Debug.hook(Login.SendRequestRoleList); hookDebugInfo('Login.SendRequestRoleList hooked')
  Login.onCancelSelectRole = Debug.hook(Login.onCancelSelectRole); hookDebugInfo('Login.onCancelSelectRole hooked')
  Login.onChangeServer = Debug.hook(Login.onChangeServer); hookDebugInfo('Login.onChangeServer hooked')
  Login.onCloseChangeServer = Debug.hook(Login.onCloseChangeServer); hookDebugInfo('Login.onCloseChangeServer hooked')
  Login.onLeftButton = Debug.hook(Login.onLeftButton); hookDebugInfo('Login.onLeftButton hooked')
  Login.onNaviChanged = Debug.hook(Login.onNaviChanged); hookDebugInfo('Login.onNaviChanged hooked')
  Login.onRadinButton = Debug.hook(Login.onRadinButton); hookDebugInfo('Login.onRadinButton hooked')
  Login.onResumeInput = Debug.hook(Login.onResumeInput); hookDebugInfo('Login.onResumeInput hooked')
  Login.onRightButton = Debug.hook(Login.onRightButton); hookDebugInfo('Login.onRightButton hooked')
  Login.onSelectServer = Debug.hook(Login.onSelectServer); hookDebugInfo('Login.onSelectServer hooked')
  Login.onTextChange = Debug.hook(Login.onTextChange); hookDebugInfo('Login.onTextChange hooked')
  Login.randomChoiceName = Debug.hook(Login.randomChoiceName); hookDebugInfo('Login.randomChoiceName hooked')
  LoginRewardGetPanel.onClose = Debug.hook(LoginRewardGetPanel.onClose); hookDebugInfo('LoginRewardGetPanel.onClose hooked')
  LoginRewardPanel.onClose = Debug.hook(LoginRewardPanel.onClose); hookDebugInfo('LoginRewardPanel.onClose hooked')
  LoveMaxPanel.onClose = Debug.hook(LoveMaxPanel.onClose); hookDebugInfo('LoveMaxPanel.onClose hooked')
  LoveMaxPanel.onGotoLove = Debug.hook(LoveMaxPanel.onGotoLove); hookDebugInfo('LoveMaxPanel.onGotoLove hooked')
  LovePanel.LoveTipPanelClick = Debug.hook(LovePanel.LoveTipPanelClick); hookDebugInfo('LovePanel.LoveTipPanelClick hooked')
  LovePanel.ShowPlot = Debug.hook(LovePanel.ShowPlot); hookDebugInfo('LovePanel.ShowPlot hooked')
  LovePanel.onClose = Debug.hook(LovePanel.onClose); hookDebugInfo('LovePanel.onClose hooked')
  LovePanel.onHide = Debug.hook(LovePanel.onHide); hookDebugInfo('LovePanel.onHide hooked')
  LovePanel.onMaterialClick = Debug.hook(LovePanel.onMaterialClick); hookDebugInfo('LovePanel.onMaterialClick hooked')
  LovePanel.onPlot = Debug.hook(LovePanel.onPlot); hookDebugInfo('LovePanel.onPlot hooked')
  LovePanel.onReqCommit = Debug.hook(LovePanel.onReqCommit); hookDebugInfo('LovePanel.onReqCommit hooked')
  LovePanel.onSwitch = Debug.hook(LovePanel.onSwitch); hookDebugInfo('LovePanel.onSwitch hooked')
  LovePanel.refreshPictureList = Debug.hook(LovePanel.refreshPictureList); hookDebugInfo('LovePanel.refreshPictureList hooked')
  MainUI.OnStarMapUI = Debug.hook(MainUI.OnStarMapUI); hookDebugInfo('MainUI.OnStarMapUI hooked')
  MainUI.RequestUnionScene = Debug.hook(MainUI.RequestUnionScene); hookDebugInfo('MainUI.RequestUnionScene hooked')
  MainUI.ReturnToMainCity = Debug.hook(MainUI.ReturnToMainCity); hookDebugInfo('MainUI.ReturnToMainCity hooked')
  MainUI.ShowUpdateInfo = Debug.hook(MainUI.ShowUpdateInfo); hookDebugInfo('MainUI.ShowUpdateInfo hooked')
  MainUI.ViewLetter = Debug.hook(MainUI.ViewLetter); hookDebugInfo('MainUI.ViewLetter hooked')
  MainUI.onBaoShiClick = Debug.hook(MainUI.onBaoShiClick); hookDebugInfo('MainUI.onBaoShiClick hooked')
  MainUI.onBeiBaoClick = Debug.hook(MainUI.onBeiBaoClick); hookDebugInfo('MainUI.onBeiBaoClick hooked')
  MainUI.onBuyGold = Debug.hook(MainUI.onBuyGold); hookDebugInfo('MainUI.onBuyGold hooked')
  MainUI.onBuyPower = Debug.hook(MainUI.onBuyPower); hookDebugInfo('MainUI.onBuyPower hooked')
  MainUI.onChat = Debug.hook(MainUI.onChat); hookDebugInfo('MainUI.onChat hooked')
  MainUI.onDragDrop = Debug.hook(MainUI.onDragDrop); hookDebugInfo('MainUI.onDragDrop hooked')
  MainUI.onDragDropCancel = Debug.hook(MainUI.onDragDropCancel); hookDebugInfo('MainUI.onDragDropCancel hooked')
  MainUI.onDragStart = Debug.hook(MainUI.onDragStart); hookDebugInfo('MainUI.onDragStart hooked')
  MainUI.onDuiWuClick = Debug.hook(MainUI.onDuiWuClick); hookDebugInfo('MainUI.onDuiWuClick hooked')
  MainUI.onEliteClick = Debug.hook(MainUI.onEliteClick); hookDebugInfo('MainUI.onEliteClick hooked')
  MainUI.onFuWenClick = Debug.hook(MainUI.onFuWenClick); hookDebugInfo('MainUI.onFuWenClick hooked')
  MainUI.onHelp = Debug.hook(MainUI.onHelp); hookDebugInfo('MainUI.onHelp hooked')
  MainUI.onJiNengClick = Debug.hook(MainUI.onJiNengClick); hookDebugInfo('MainUI.onJiNengClick hooked')
  MainUI.onJiangJiChangClick = Debug.hook(MainUI.onJiangJiChangClick); hookDebugInfo('MainUI.onJiangJiChangClick hooked')
  MainUI.onJuLongBaoKuClick = Debug.hook(MainUI.onJuLongBaoKuClick); hookDebugInfo('MainUI.onJuLongBaoKuClick hooked')
  MainUI.onLimitRound = Debug.hook(MainUI.onLimitRound); hookDebugInfo('MainUI.onLimitRound hooked')
  MainUI.onMiKu = Debug.hook(MainUI.onMiKu); hookDebugInfo('MainUI.onMiKu hooked')
  MainUI.onOnlieReward = Debug.hook(MainUI.onOnlieReward); hookDebugInfo('MainUI.onOnlieReward hooked')
  MainUI.onQianLi = Debug.hook(MainUI.onQianLi); hookDebugInfo('MainUI.onQianLi hooked')
--  MainUI.onQiangHuaClick = Debug.hook(MainUI.onQiangHuaClick); hookDebugInfo('MainUI.onQiangHuaClick hooked')
  MainUI.onRenWuClick = Debug.hook(MainUI.onRenWuClick); hookDebugInfo('MainUI.onRenWuClick hooked')
  MainUI.onRoleAdvanceClick = Debug.hook(MainUI.onRoleAdvanceClick); hookDebugInfo('MainUI.onRoleAdvanceClick hooked')
  MainUI.onScuffleClick = Debug.hook(MainUI.onScuffleClick); hookDebugInfo('MainUI.onScuffleClick hooked')
  MainUI.onShiErGongClick = Debug.hook(MainUI.onShiErGongClick); hookDebugInfo('MainUI.onShiErGongClick hooked')
  MainUI.onShopClick = Debug.hook(MainUI.onShopClick); hookDebugInfo('MainUI.onShopClick hooked')
  MainUI.onShowFriend = Debug.hook(MainUI.onShowFriend); hookDebugInfo('MainUI.onShowFriend hooked')
  MainUI.onShowUnion = Debug.hook(MainUI.onShowUnion); hookDebugInfo('MainUI.onShowUnion hooked')
  MainUI.onSystem = Debug.hook(MainUI.onSystem); hookDebugInfo('MainUI.onSystem hooked')
  MainUI.onTask = Debug.hook(MainUI.onTask); hookDebugInfo('MainUI.onTask hooked')
  MainUI.onTrial = Debug.hook(MainUI.onTrial); hookDebugInfo('MainUI.onTrial hooked')
  MainUI.onUnionBossClick = Debug.hook(MainUI.onUnionBossClick); hookDebugInfo('MainUI.onUnionBossClick hooked')
  MainUI.onWing = Debug.hook(MainUI.onWing); hookDebugInfo('MainUI.onWing hooked')
  MainUI.onWorldClick = Debug.hook(MainUI.onWorldClick); hookDebugInfo('MainUI.onWorldClick hooked')
  MainUI.onXunLianChangClick = Debug.hook(MainUI.onXunLianChangClick); hookDebugInfo('MainUI.onXunLianChangClick hooked')
  MainUI.onYingLingDian = Debug.hook(MainUI.onYingLingDian); hookDebugInfo('MainUI.onYingLingDian hooked')
  MenuPanel.Ceshi = Debug.hook(MenuPanel.Ceshi); hookDebugInfo('MenuPanel.Ceshi hooked')
  MenuPanel.EventCard = Debug.hook(MenuPanel.EventCard); hookDebugInfo('MenuPanel.EventCard hooked')
  MenuPanel.onCloseSubMenu = Debug.hook(MenuPanel.onCloseSubMenu); hookDebugInfo('MenuPanel.onCloseSubMenu hooked')
  MenuPanel.onExtentClick = Debug.hook(MenuPanel.onExtentClick); hookDebugInfo('MenuPanel.onExtentClick hooked')
  MenuPanel.onExtentClickOne = Debug.hook(MenuPanel.onExtentClickOne); hookDebugInfo('MenuPanel.onExtentClickOne hooked')
  MenuPanel.onExtentClickTwo = Debug.hook(MenuPanel.onExtentClickTwo); hookDebugInfo('MenuPanel.onExtentClickTwo hooked')
  MenuPanel.onShowSettingPanel = Debug.hook(MenuPanel.onShowSettingPanel); hookDebugInfo('MenuPanel.onShowSettingPanel hooked')
  MessageBox.onCancel = Debug.hook(MessageBox.onCancel); hookDebugInfo('MessageBox.onCancel hooked')
  MessageBox.onOK = Debug.hook(MessageBox.onOK); hookDebugInfo('MessageBox.onOK hooked')
  MessageBox.onQueDing = Debug.hook(MessageBox.onQueDing); hookDebugInfo('MessageBox.onQueDing hooked')
  MorePanel.onChangeRole = Debug.hook(MorePanel.onChangeRole); hookDebugInfo('MorePanel.onChangeRole hooked')
  MorePanel.onClose = Debug.hook(MorePanel.onClose); hookDebugInfo('MorePanel.onClose hooked')
  MorePanel.onPersonalCenter = Debug.hook(MorePanel.onPersonalCenter); hookDebugInfo('MorePanel.onPersonalCenter hooked')
  MorePanel.onShowMore = Debug.hook(MorePanel.onShowMore); hookDebugInfo('MorePanel.onShowMore hooked')
  NpcShopPanel.GetbuyShow = Debug.hook(NpcShopPanel.GetbuyShow); hookDebugInfo('NpcShopPanel.GetbuyShow hooked')
  NpcShopPanel.buyClick = Debug.hook(NpcShopPanel.buyClick); hookDebugInfo('NpcShopPanel.buyClick hooked')
  NpcShopPanel.buyClickHide = Debug.hook(NpcShopPanel.buyClickHide); hookDebugInfo('NpcShopPanel.buyClickHide hooked')
  NpcShopPanel.buyHide = Debug.hook(NpcShopPanel.buyHide); hookDebugInfo('NpcShopPanel.buyHide hooked')
  NpcShopPanel.onBuy = Debug.hook(NpcShopPanel.onBuy); hookDebugInfo('NpcShopPanel.onBuy hooked')
  NpcShopPanel.onClose = Debug.hook(NpcShopPanel.onClose); hookDebugInfo('NpcShopPanel.onClose hooked')
  NpcShopPanel.reqRefresh = Debug.hook(NpcShopPanel.reqRefresh); hookDebugInfo('NpcShopPanel.reqRefresh hooked')
  OpenPackPanel.onItemCellClick = Debug.hook(OpenPackPanel.onItemCellClick); hookDebugInfo('OpenPackPanel.onItemCellClick hooked')
  OpenPackPanel.onOkClick = Debug.hook(OpenPackPanel.onOkClick); hookDebugInfo('OpenPackPanel.onOkClick hooked')
  OpenPackPanel.onReceive = Debug.hook(OpenPackPanel.onReceive); hookDebugInfo('OpenPackPanel.onReceive hooked')
  OpenPackPanel.onReopenClick = Debug.hook(OpenPackPanel.onReopenClick); hookDebugInfo('OpenPackPanel.onReopenClick hooked')
  OpenServiceRewardPanel.onClose = Debug.hook(OpenServiceRewardPanel.onClose); hookDebugInfo('OpenServiceRewardPanel.onClose hooked')
  OpenServiceRewardPanel.onGetReward = Debug.hook(OpenServiceRewardPanel.onGetReward); hookDebugInfo('OpenServiceRewardPanel.onGetReward hooked')
  OpenServiceRewardPanel.onShow = Debug.hook(OpenServiceRewardPanel.onShow); hookDebugInfo('OpenServiceRewardPanel.onShow hooked')
  Package.onChipExchangeClick = Debug.hook(Package.onChipExchangeClick); hookDebugInfo('Package.onChipExchangeClick hooked')
  Package.onChipItemClick = Debug.hook(Package.onChipItemClick); hookDebugInfo('Package.onChipItemClick hooked')
  PackagePanel.onBuyPackageClick = Debug.hook(PackagePanel.onBuyPackageClick); hookDebugInfo('PackagePanel.onBuyPackageClick hooked')
  PackagePanel.onClose = Debug.hook(PackagePanel.onClose); hookDebugInfo('PackagePanel.onClose hooked')
  PackagePanel.onItemClick = Debug.hook(PackagePanel.onItemClick); hookDebugInfo('PackagePanel.onItemClick hooked')
  PackagePanel.onPageChange = Debug.hook(PackagePanel.onPageChange); hookDebugInfo('PackagePanel.onPageChange hooked')
  PackagePanel.onTipChipClick = Debug.hook(PackagePanel.onTipChipClick); hookDebugInfo('PackagePanel.onTipChipClick hooked')
  PartnerFirePanel.onClose = Debug.hook(PartnerFirePanel.onClose); hookDebugInfo('PartnerFirePanel.onClose hooked')
  PartnerFirePanel.onRequestFire = Debug.hook(PartnerFirePanel.onRequestFire); hookDebugInfo('PartnerFirePanel.onRequestFire hooked')
  PersonInfoPanel.AddFriend = Debug.hook(PersonInfoPanel.AddFriend); hookDebugInfo('PersonInfoPanel.AddFriend hooked')
  PersonInfoPanel.closeChangeName = Debug.hook(PersonInfoPanel.closeChangeName); hookDebugInfo('PersonInfoPanel.closeChangeName hooked')
  PersonInfoPanel.onClose = Debug.hook(PersonInfoPanel.onClose); hookDebugInfo('PersonInfoPanel.onClose hooked')
  PersonInfoPanel.onClosePanel = Debug.hook(PersonInfoPanel.onClosePanel); hookDebugInfo('PersonInfoPanel.onClosePanel hooked')
  PersonInfoPanel.onCloseSwitchAccountPanel = Debug.hook(PersonInfoPanel.onCloseSwitchAccountPanel); hookDebugInfo('PersonInfoPanel.onCloseSwitchAccountPanel hooked')
  PersonInfoPanel.onResumeInput = Debug.hook(PersonInfoPanel.onResumeInput); hookDebugInfo('PersonInfoPanel.onResumeInput hooked')
  PersonInfoPanel.onShowHonourDescribePanel = Debug.hook(PersonInfoPanel.onShowHonourDescribePanel); hookDebugInfo('PersonInfoPanel.onShowHonourDescribePanel hooked')
  PersonInfoPanel.onShowJoinUsPanel = Debug.hook(PersonInfoPanel.onShowJoinUsPanel); hookDebugInfo('PersonInfoPanel.onShowJoinUsPanel hooked')
  PersonInfoPanel.onShowSwitchAccountPanel = Debug.hook(PersonInfoPanel.onShowSwitchAccountPanel); hookDebugInfo('PersonInfoPanel.onShowSwitchAccountPanel hooked')
  PersonInfoPanel.onSwitchAccount = Debug.hook(PersonInfoPanel.onSwitchAccount); hookDebugInfo('PersonInfoPanel.onSwitchAccount hooked')
  PersonInfoPanel.onTextChange = Debug.hook(PersonInfoPanel.onTextChange); hookDebugInfo('PersonInfoPanel.onTextChange hooked')
  PersonInfoPanel.realChangeName = Debug.hook(PersonInfoPanel.realChangeName); hookDebugInfo('PersonInfoPanel.realChangeName hooked')
  PersonInfoPanel.selfInfo = Debug.hook(PersonInfoPanel.selfInfo); hookDebugInfo('PersonInfoPanel.selfInfo hooked')
  PersonInfoPanel.showChangeName = Debug.hook(PersonInfoPanel.showChangeName); hookDebugInfo('PersonInfoPanel.showChangeName hooked')
  PlayerInfoPanel.onBodyEquipClick = Debug.hook(PlayerInfoPanel.onBodyEquipClick); hookDebugInfo('PlayerInfoPanel.onBodyEquipClick hooked')
  PlayerInfoPanel.onClose = Debug.hook(PlayerInfoPanel.onClose); hookDebugInfo('PlayerInfoPanel.onClose hooked')
  PlayerInfoPanel.onRoleClick = Debug.hook(PlayerInfoPanel.onRoleClick); hookDebugInfo('PlayerInfoPanel.onRoleClick hooked')
  PlotPanel.guideEquipHide = Debug.hook(PlotPanel.guideEquipHide); hookDebugInfo('PlotPanel.guideEquipHide hooked')
  PlotPanel.onClickDialog = Debug.hook(PlotPanel.onClickDialog); hookDebugInfo('PlotPanel.onClickDialog hooked')
  PlotPanel.onClickDialogTw = Debug.hook(PlotPanel.onClickDialogTw); hookDebugInfo('PlotPanel.onClickDialogTw hooked')
  PlotPanel.onClickShade = Debug.hook(PlotPanel.onClickShade); hookDebugInfo('PlotPanel.onClickShade hooked')
  PlotPanel.onNext = Debug.hook(PlotPanel.onNext); hookDebugInfo('PlotPanel.onNext hooked')
  PlotTaskPanel.RefreshDailyTask = Debug.hook(PlotTaskPanel.RefreshDailyTask); hookDebugInfo('PlotTaskPanel.RefreshDailyTask hooked')
  PlotTaskPanel.RefreshPlotTask = Debug.hook(PlotTaskPanel.RefreshPlotTask); hookDebugInfo('PlotTaskPanel.RefreshPlotTask hooked')
  PlotTaskPanel.UnselectPub = Debug.hook(PlotTaskPanel.UnselectPub); hookDebugInfo('PlotTaskPanel.UnselectPub hooked')
  PlotTaskPanel.onClose = Debug.hook(PlotTaskPanel.onClose); hookDebugInfo('PlotTaskPanel.onClose hooked')
  PlotTaskPanel.onGetToAchievementClick = Debug.hook(PlotTaskPanel.onGetToAchievementClick); hookDebugInfo('PlotTaskPanel.onGetToAchievementClick hooked')
  PlotTaskPanel.onGetToClick = Debug.hook(PlotTaskPanel.onGetToClick); hookDebugInfo('PlotTaskPanel.onGetToClick hooked')
  PlotTaskPanel.onGetToDailyClick = Debug.hook(PlotTaskPanel.onGetToDailyClick); hookDebugInfo('PlotTaskPanel.onGetToDailyClick hooked')
  PlotTaskPanel.onGoToAchievementClick = Debug.hook(PlotTaskPanel.onGoToAchievementClick); hookDebugInfo('PlotTaskPanel.onGoToAchievementClick hooked')
  PlotTaskPanel.onGoToClick = Debug.hook(PlotTaskPanel.onGoToClick); hookDebugInfo('PlotTaskPanel.onGoToClick hooked')
  PlotTaskPanel.onGoToDailyClick = Debug.hook(PlotTaskPanel.onGoToDailyClick); hookDebugInfo('PlotTaskPanel.onGoToDailyClick hooked')
  PlotTaskPanel.showchengzhangtask = Debug.hook(PlotTaskPanel.showchengzhangtask); hookDebugInfo('PlotTaskPanel.showchengzhangtask hooked')
  PlotTaskPanel.showpeiyangtask = Debug.hook(PlotTaskPanel.showpeiyangtask); hookDebugInfo('PlotTaskPanel.showpeiyangtask hooked')
  PrestigeShopPanel.onBuyItem = Debug.hook(PrestigeShopPanel.onBuyItem); hookDebugInfo('PrestigeShopPanel.onBuyItem hooked')
  PrestigeShopPanel.onClose = Debug.hook(PrestigeShopPanel.onClose); hookDebugInfo('PrestigeShopPanel.onClose hooked')
  PromotionGoldPanel.onApplyGoldInfo = Debug.hook(PromotionGoldPanel.onApplyGoldInfo); hookDebugInfo('PromotionGoldPanel.onApplyGoldInfo hooked')
  PromotionGoldPanel.onClose = Debug.hook(PromotionGoldPanel.onClose); hookDebugInfo('PromotionGoldPanel.onClose hooked')
  PromotionGoldPanel.onGoldClick = Debug.hook(PromotionGoldPanel.onGoldClick); hookDebugInfo('PromotionGoldPanel.onGoldClick hooked')
  PromotionPizzaPanel.onClose = Debug.hook(PromotionPizzaPanel.onClose); hookDebugInfo('PromotionPizzaPanel.onClose hooked')
  PromotionPizzaPanel.onEatClick = Debug.hook(PromotionPizzaPanel.onEatClick); hookDebugInfo('PromotionPizzaPanel.onEatClick hooked')
  PromotionPizzaPanel.onShow = Debug.hook(PromotionPizzaPanel.onShow); hookDebugInfo('PromotionPizzaPanel.onShow hooked')
  PropertyRoundPanel.closeExplainPanel = Debug.hook(PropertyRoundPanel.closeExplainPanel); hookDebugInfo('PropertyRoundPanel.closeExplainPanel hooked')
--  PropertyRoundPanel.onChallenge = Debug.hook(PropertyRoundPanel.onChallenge); hookDebugInfo('PropertyRoundPanel.onChallenge hooked')
  PropertyRoundPanel.onCloseFight = Debug.hook(PropertyRoundPanel.onCloseFight); hookDebugInfo('PropertyRoundPanel.onCloseFight hooked')
  PropertyRoundPanel.onFight = Debug.hook(PropertyRoundPanel.onFight); hookDebugInfo('PropertyRoundPanel.onFight hooked')
  PropertyRoundPanel.onReqFight = Debug.hook(PropertyRoundPanel.onReqFight); hookDebugInfo('PropertyRoundPanel.onReqFight hooked')
  PropertyRoundPanel.onReturn = Debug.hook(PropertyRoundPanel.onReturn); hookDebugInfo('PropertyRoundPanel.onReturn hooked')
  PropertyRoundPanel.onShow = Debug.hook(PropertyRoundPanel.onShow); hookDebugInfo('PropertyRoundPanel.onShow hooked')
  PropertyRoundPanel.showExplainPanel = Debug.hook(PropertyRoundPanel.showExplainPanel); hookDebugInfo('PropertyRoundPanel.showExplainPanel hooked')


  --[[
  PubHeroPlayPanel.ContinueRefresh = Debug.hook(PubHeroPlayPanel.ContinueRefresh); hookDebugInfo('PubHeroPlayPanel.ContinueRefresh hooked')
  PubHeroPlayPanel.OnClick = Debug.hook(PubHeroPlayPanel.OnClick); hookDebugInfo('PubHeroPlayPanel.OnClick hooked')
  PubHeroPlayPanel.SkipShowPlayer = Debug.hook(PubHeroPlayPanel.SkipShowPlayer); hookDebugInfo('PubHeroPlayPanel.SkipShowPlayer hooked')

  PubNewPanel.OnClickOne = Debug.hook(PubNewPanel.OnClickOne); hookDebugInfo('PubNewPanel.OnClickOne hooked')
  PubNewPanel.OnClickTen = Debug.hook(PubNewPanel.OnClickTen); hookDebugInfo('PubNewPanel.OnClickTen hooked')
  PubNewPanel.OnClose = Debug.hook(PubNewPanel.OnClose); hookDebugInfo('PubNewPanel.OnClose hooked')
  PubNewPanel.OnShuijingRefresh = Debug.hook(PubNewPanel.OnShuijingRefresh); hookDebugInfo('PubNewPanel.OnShuijingRefresh hooked')
  PubNewPanel.OnYouqingRefresh = Debug.hook(PubNewPanel.OnYouqingRefresh); hookDebugInfo('PubNewPanel.OnYouqingRefresh hooked')
  PubNewPanel.OnZhizunRefresh = Debug.hook(PubNewPanel.OnZhizunRefresh); hookDebugInfo('PubNewPanel.OnZhizunRefresh hooked')
  PubNewPanel.onTuJian = Debug.hook(PubNewPanel.onTuJian); hookDebugInfo('PubNewPanel.onTuJian hooked')

  PubPanel.onHirePartner = Debug.hook(PubPanel.onHirePartner); hookDebugInfo('PubPanel.onHirePartner hooked')

  PubRefreshPanel.OnClose = Debug.hook(PubRefreshPanel.OnClose); hookDebugInfo('PubRefreshPanel.OnClose hooked')
  PubRefreshPanel.OnShowZizhunHeroInfo = Debug.hook(PubRefreshPanel.OnShowZizhunHeroInfo); hookDebugInfo('PubRefreshPanel.OnShowZizhunHeroInfo hooked')

  PubSuccessPanel.onClose = Debug.hook(PubSuccessPanel.onClose); hookDebugInfo('PubSuccessPanel.onClose hooked')
  PubSuccessPanel.onRoleProperty = Debug.hook(PubSuccessPanel.onRoleProperty); hookDebugInfo('PubSuccessPanel.onRoleProperty hooked')
          --]]
  PveAutoBattlePanel.onAddHangUpTimes = Debug.hook(PveAutoBattlePanel.onAddHangUpTimes); hookDebugInfo('PveAutoBattlePanel.onAddHangUpTimes hooked')
  PveAutoBattlePanel.onHangUp = Debug.hook(PveAutoBattlePanel.onHangUp); hookDebugInfo('PveAutoBattlePanel.onHangUp hooked')
  PveAutoBattlePanel.onMaxHangUpTimes = Debug.hook(PveAutoBattlePanel.onMaxHangUpTimes); hookDebugInfo('PveAutoBattlePanel.onMaxHangUpTimes hooked')
  PveAutoBattlePanel.onMinusHangUpTimes = Debug.hook(PveAutoBattlePanel.onMinusHangUpTimes); hookDebugInfo('PveAutoBattlePanel.onMinusHangUpTimes hooked')
  PveAutoBattlePanel.onPveAutoBattlePanelClose = Debug.hook(PveAutoBattlePanel.onPveAutoBattlePanelClose); hookDebugInfo('PveAutoBattlePanel.onPveAutoBattlePanelClose hooked')
  PveBarrierInfoPanel.onChallenge = Debug.hook(PveBarrierInfoPanel.onChallenge); hookDebugInfo('PveBarrierInfoPanel.onChallenge hooked')
  PveBarrierInfoPanel.onChallengeClick = Debug.hook(PveBarrierInfoPanel.onChallengeClick); hookDebugInfo('PveBarrierInfoPanel.onChallengeClick hooked')
  PveBarrierInfoPanel.onCloseGuardsPanel = Debug.hook(PveBarrierInfoPanel.onCloseGuardsPanel); hookDebugInfo('PveBarrierInfoPanel.onCloseGuardsPanel hooked')
  PveBarrierInfoPanel.onFriendClick = Debug.hook(PveBarrierInfoPanel.onFriendClick); hookDebugInfo('PveBarrierInfoPanel.onFriendClick hooked')
  PveBarrierInfoPanel.onHnagUpClick = Debug.hook(PveBarrierInfoPanel.onHnagUpClick); hookDebugInfo('PveBarrierInfoPanel.onHnagUpClick hooked')
  PveBarrierInfoPanel.onIconClick = Debug.hook(PveBarrierInfoPanel.onIconClick); hookDebugInfo('PveBarrierInfoPanel.onIconClick hooked')
  PveBarrierInfoPanel.onMonsterKind = Debug.hook(PveBarrierInfoPanel.onMonsterKind); hookDebugInfo('PveBarrierInfoPanel.onMonsterKind hooked')
  PveBarrierInfoPanel.onPveBarrierEnterInfoClose = Debug.hook(PveBarrierInfoPanel.onPveBarrierEnterInfoClose); hookDebugInfo('PveBarrierInfoPanel.onPveBarrierEnterInfoClose hooked')
  PveBarrierPanel.buyAp = Debug.hook(PveBarrierPanel.buyAp); hookDebugInfo('PveBarrierPanel.buyAp hooked')
  PveBarrierPanel.buyYb = Debug.hook(PveBarrierPanel.buyYb); hookDebugInfo('PveBarrierPanel.buyYb hooked')
  PveBarrierPanel.changeFuben = Debug.hook(PveBarrierPanel.changeFuben); hookDebugInfo('PveBarrierPanel.changeFuben hooked')
  PveBarrierPanel.getReward = Debug.hook(PveBarrierPanel.getReward); hookDebugInfo('PveBarrierPanel.getReward hooked')
  PveBarrierPanel.onBackToMainCity = Debug.hook(PveBarrierPanel.onBackToMainCity); hookDebugInfo('PveBarrierPanel.onBackToMainCity hooked')
  PveBarrierPanel.onCanelReset = Debug.hook(PveBarrierPanel.onCanelReset); hookDebugInfo('PveBarrierPanel.onCanelReset hooked')
  PveBarrierPanel.onClickBack = Debug.hook(PveBarrierPanel.onClickBack); hookDebugInfo('PveBarrierPanel.onClickBack hooked')
  PveBarrierPanel.onEnterPveBarrier = Debug.hook(PveBarrierPanel.onEnterPveBarrier); hookDebugInfo('PveBarrierPanel.onEnterPveBarrier hooked')
  PveBarrierPanel.onEnterPveBattle = Debug.hook(PveBarrierPanel.onEnterPveBattle); hookDebugInfo('PveBarrierPanel.onEnterPveBattle hooked')
  PveBarrierPanel.onHiddenRewardPanel = Debug.hook(PveBarrierPanel.onHiddenRewardPanel); hookDebugInfo('PveBarrierPanel.onHiddenRewardPanel hooked')
  PveBarrierPanel.onNextPage = Debug.hook(PveBarrierPanel.onNextPage); hookDebugInfo('PveBarrierPanel.onNextPage hooked')
  PveBarrierPanel.onOkReset = Debug.hook(PveBarrierPanel.onOkReset); hookDebugInfo('PveBarrierPanel.onOkReset hooked')
--  PveBarrierPanel.onOpenWorld = Debug.hook(PveBarrierPanel.onOpenWorld); hookDebugInfo('PveBarrierPanel.onOpenWorld hooked')
  PveBarrierPanel.onPrePage = Debug.hook(PveBarrierPanel.onPrePage); hookDebugInfo('PveBarrierPanel.onPrePage hooked')
  PveBarrierPanel.onShowRewardPanel = Debug.hook(PveBarrierPanel.onShowRewardPanel); hookDebugInfo('PveBarrierPanel.onShowRewardPanel hooked')
  PveEliteBarrierPanel.onActivityReset = Debug.hook(PveEliteBarrierPanel.onActivityReset); hookDebugInfo('PveEliteBarrierPanel.onActivityReset hooked')
  PveEliteBarrierPanel.onBack = Debug.hook(PveEliteBarrierPanel.onBack); hookDebugInfo('PveEliteBarrierPanel.onBack hooked')
  PveEliteBarrierPanel.onClose = Debug.hook(PveEliteBarrierPanel.onClose); hookDebugInfo('PveEliteBarrierPanel.onClose hooked')
  PveEliteBarrierPanel.onEnterElite = Debug.hook(PveEliteBarrierPanel.onEnterElite); hookDebugInfo('PveEliteBarrierPanel.onEnterElite hooked')
  PveEliteBarrierPanel.onFront = Debug.hook(PveEliteBarrierPanel.onFront); hookDebugInfo('PveEliteBarrierPanel.onFront hooked')
  PveEliteBarrierPanel.onPageBack = Debug.hook(PveEliteBarrierPanel.onPageBack); hookDebugInfo('PveEliteBarrierPanel.onPageBack hooked')
  PveEliteBarrierPanel.onPageFront = Debug.hook(PveEliteBarrierPanel.onPageFront); hookDebugInfo('PveEliteBarrierPanel.onPageFront hooked')
  PveEliteBarrierPanel.onResetElite = Debug.hook(PveEliteBarrierPanel.onResetElite); hookDebugInfo('PveEliteBarrierPanel.onResetElite hooked')
  PveLosePanel.onEquipStrengthClick = Debug.hook(PveLosePanel.onEquipStrengthClick); hookDebugInfo('PveLosePanel.onEquipStrengthClick hooked')
  PveMutipleTeamPanel.onClose = Debug.hook(PveMutipleTeamPanel.onClose); hookDebugInfo('PveMutipleTeamPanel.onClose hooked')
  PveStarRewardPanel.onClose = Debug.hook(PveStarRewardPanel.onClose); hookDebugInfo('PveStarRewardPanel.onClose hooked')
  PveStarRewardPanel.onGetRewardClick = Debug.hook(PveStarRewardPanel.onGetRewardClick); hookDebugInfo('PveStarRewardPanel.onGetRewardClick hooked')
  PveSweepPanel.onReChanllenge = Debug.hook(PveSweepPanel.onReChanllenge); hookDebugInfo('PveSweepPanel.onReChanllenge hooked')
  PveSweepPanel.onSureClick = Debug.hook(PveSweepPanel.onSureClick); hookDebugInfo('PveSweepPanel.onSureClick hooked')
  QianliPanel.onClickLevelup = Debug.hook(QianliPanel.onClickLevelup); hookDebugInfo('QianliPanel.onClickLevelup hooked')
  QuestPanel.onClose = Debug.hook(QuestPanel.onClose); hookDebugInfo('QuestPanel.onClose hooked')
  RankPanel.OnPopMenuClick = Debug.hook(RankPanel.OnPopMenuClick); hookDebugInfo('RankPanel.OnPopMenuClick hooked')
  RankPanel.RankingTemplateClick = Debug.hook(RankPanel.RankingTemplateClick); hookDebugInfo('RankPanel.RankingTemplateClick hooked')
  RankPanel.ShowRankPanel = Debug.hook(RankPanel.ShowRankPanel); hookDebugInfo('RankPanel.ShowRankPanel hooked')
  RankPanel.onClose = Debug.hook(RankPanel.onClose); hookDebugInfo('RankPanel.onClose hooked')
  RankPanel.onPopMenuPanelLoseFocus = Debug.hook(RankPanel.onPopMenuPanelLoseFocus); hookDebugInfo('RankPanel.onPopMenuPanelLoseFocus hooked')
  RankPanel.onTabControlPageChange = Debug.hook(RankPanel.onTabControlPageChange); hookDebugInfo('RankPanel.onTabControlPageChange hooked')
  RankSelectActorPanel.DuanWeiUpPanelHide = Debug.hook(RankSelectActorPanel.DuanWeiUpPanelHide); hookDebugInfo('RankSelectActorPanel.DuanWeiUpPanelHide hooked')
  RankSelectActorPanel.DuanweiRewardHide = Debug.hook(RankSelectActorPanel.DuanweiRewardHide); hookDebugInfo('RankSelectActorPanel.DuanweiRewardHide hooked')
  RankSelectActorPanel.RuleExplainHide = Debug.hook(RankSelectActorPanel.RuleExplainHide); hookDebugInfo('RankSelectActorPanel.RuleExplainHide hooked')
  RankSelectActorPanel.RuleExplainShow = Debug.hook(RankSelectActorPanel.RuleExplainShow); hookDebugInfo('RankSelectActorPanel.RuleExplainShow hooked')
  RankSelectActorPanel.ShopShow = Debug.hook(RankSelectActorPanel.ShopShow); hookDebugInfo('RankSelectActorPanel.ShopShow hooked')
  RankSelectActorPanel.ShowDuanweiRewardPanel = Debug.hook(RankSelectActorPanel.ShowDuanweiRewardPanel); hookDebugInfo('RankSelectActorPanel.ShowDuanweiRewardPanel hooked')
  RankSelectActorPanel.Unselected = Debug.hook(RankSelectActorPanel.Unselected); hookDebugInfo('RankSelectActorPanel.Unselected hooked')
  RankSelectActorPanel.duanDetailsHide = Debug.hook(RankSelectActorPanel.duanDetailsHide); hookDebugInfo('RankSelectActorPanel.duanDetailsHide hooked')
  RankSelectActorPanel.duanDetailsShow = Debug.hook(RankSelectActorPanel.duanDetailsShow); hookDebugInfo('RankSelectActorPanel.duanDetailsShow hooked')
  RankSelectActorPanel.onAll = Debug.hook(RankSelectActorPanel.onAll); hookDebugInfo('RankSelectActorPanel.onAll hooked')
  RankSelectActorPanel.onBack = Debug.hook(RankSelectActorPanel.onBack); hookDebugInfo('RankSelectActorPanel.onBack hooked')
  RankSelectActorPanel.onCenter = Debug.hook(RankSelectActorPanel.onCenter); hookDebugInfo('RankSelectActorPanel.onCenter hooked')
  RankSelectActorPanel.onFight = Debug.hook(RankSelectActorPanel.onFight); hookDebugInfo('RankSelectActorPanel.onFight hooked')
  RankSelectActorPanel.onFront = Debug.hook(RankSelectActorPanel.onFront); hookDebugInfo('RankSelectActorPanel.onFront hooked')
  RankSelectActorPanel.onRadioButton = Debug.hook(RankSelectActorPanel.onRadioButton); hookDebugInfo('RankSelectActorPanel.onRadioButton hooked')
  RankSelectActorPanel.onReturn = Debug.hook(RankSelectActorPanel.onReturn); hookDebugInfo('RankSelectActorPanel.onReturn hooked')
  RankSelectActorPanel.pipeiCancel = Debug.hook(RankSelectActorPanel.pipeiCancel); hookDebugInfo('RankSelectActorPanel.pipeiCancel hooked')
  RankSelectActorPanel.reqEnterRankPanel = Debug.hook(RankSelectActorPanel.reqEnterRankPanel); hookDebugInfo('RankSelectActorPanel.reqEnterRankPanel hooked')
  RankSelectActorPanel.roleDetailsClick = Debug.hook(RankSelectActorPanel.roleDetailsClick); hookDebugInfo('RankSelectActorPanel.roleDetailsClick hooked')
  RankSelectActorPanel.roleDetailsHide = Debug.hook(RankSelectActorPanel.roleDetailsHide); hookDebugInfo('RankSelectActorPanel.roleDetailsHide hooked')
  RankSelectActorPanel.roleSelected = Debug.hook(RankSelectActorPanel.roleSelected); hookDebugInfo('RankSelectActorPanel.roleSelected hooked')
  RankSelectActorPanel.skillSelected = Debug.hook(RankSelectActorPanel.skillSelected); hookDebugInfo('RankSelectActorPanel.skillSelected hooked')
  RechargePanel.ApplyMCardReward = Debug.hook(RechargePanel.ApplyMCardReward); hookDebugInfo('RechargePanel.ApplyMCardReward hooked')
  RechargePanel.onClose = Debug.hook(RechargePanel.onClose); hookDebugInfo('RechargePanel.onClose hooked')
  RechargePanel.onRecharge = Debug.hook(RechargePanel.onRecharge); hookDebugInfo('RechargePanel.onRecharge hooked')
  RechargePanel.onShowRechargePanel = Debug.hook(RechargePanel.onShowRechargePanel); hookDebugInfo('RechargePanel.onShowRechargePanel hooked')

  --[[
  RewardArenaPanel.RequestGetArenaReward = Debug.hook(RewardArenaPanel.RequestGetArenaReward); hookDebugInfo('RewardArenaPanel.RequestGetArenaReward hooked')
  RewardArenaPanel.onClose = Debug.hook(RewardArenaPanel.onClose); hookDebugInfo('RewardArenaPanel.onClose hooked')
  --]]
  RewardOnlinePanel.OpenOnlineReward = Debug.hook(RewardOnlinePanel.OpenOnlineReward); hookDebugInfo('RewardOnlinePanel.OpenOnlineReward hooked')
  RmbNotEnoughPanel.onCancel = Debug.hook(RmbNotEnoughPanel.onCancel); hookDebugInfo('RmbNotEnoughPanel.onCancel hooked')
  RmbNotEnoughPanel.onRecharge = Debug.hook(RmbNotEnoughPanel.onRecharge); hookDebugInfo('RmbNotEnoughPanel.onRecharge hooked')
  RoleAdvanceInfoPanel.onClose = Debug.hook(RoleAdvanceInfoPanel.onClose); hookDebugInfo('RoleAdvanceInfoPanel.onClose hooked')
  RoleAdvancePanel.onAdvanceClick = Debug.hook(RoleAdvancePanel.onAdvanceClick); hookDebugInfo('RoleAdvancePanel.onAdvanceClick hooked')
  RoleAdvancePanel.onClose = Debug.hook(RoleAdvancePanel.onClose); hookDebugInfo('RoleAdvancePanel.onClose hooked')
  RoleAdvancePanel.onRoleClick = Debug.hook(RoleAdvancePanel.onRoleClick); hookDebugInfo('RoleAdvancePanel.onRoleClick hooked')
  RoleAdvanceSoulPanel.onClose = Debug.hook(RoleAdvanceSoulPanel.onClose); hookDebugInfo('RoleAdvanceSoulPanel.onClose hooked')
  RoleAdvanceSoulPanel.onExchangeClick = Debug.hook(RoleAdvanceSoulPanel.onExchangeClick); hookDebugInfo('RoleAdvanceSoulPanel.onExchangeClick hooked')
  RoleAdvanceSoulPanel.onShow = Debug.hook(RoleAdvanceSoulPanel.onShow); hookDebugInfo('RoleAdvanceSoulPanel.onShow hooked')
  RoleInfoPanel.OnClickPlayer = Debug.hook(RoleInfoPanel.OnClickPlayer); hookDebugInfo('RoleInfoPanel.OnClickPlayer hooked')
  RoleInfoPanel.onBodyEquipClick = Debug.hook(RoleInfoPanel.onBodyEquipClick); hookDebugInfo('RoleInfoPanel.onBodyEquipClick hooked')
  RoleInfoPanel.onChangePropsPanel = Debug.hook(RoleInfoPanel.onChangePropsPanel); hookDebugInfo('RoleInfoPanel.onChangePropsPanel hooked')
  RoleInfoPanel.onClose = Debug.hook(RoleInfoPanel.onClose); hookDebugInfo('RoleInfoPanel.onClose hooked')
  RoleInfoPanel.onEquipPanelPageLeft = Debug.hook(RoleInfoPanel.onEquipPanelPageLeft); hookDebugInfo('RoleInfoPanel.onEquipPanelPageLeft hooked')
  RoleInfoPanel.onEquipPanelPageRight = Debug.hook(RoleInfoPanel.onEquipPanelPageRight); hookDebugInfo('RoleInfoPanel.onEquipPanelPageRight hooked')
  RoleInfoPanel.onFire = Debug.hook(RoleInfoPanel.onFire); hookDebugInfo('RoleInfoPanel.onFire hooked')
  RoleInfoPanel.onMouseClick = Debug.hook(RoleInfoPanel.onMouseClick); hookDebugInfo('RoleInfoPanel.onMouseClick hooked')
  RoleInfoPanel.onMouseDown = Debug.hook(RoleInfoPanel.onMouseDown); hookDebugInfo('RoleInfoPanel.onMouseDown hooked')
  RoleInfoPanel.onMouseMove = Debug.hook(RoleInfoPanel.onMouseMove); hookDebugInfo('RoleInfoPanel.onMouseMove hooked')
  RoleInfoPanel.onMouseUp = Debug.hook(RoleInfoPanel.onMouseUp); hookDebugInfo('RoleInfoPanel.onMouseUp hooked')
  RoleInfoPanel.onOneKey = Debug.hook(RoleInfoPanel.onOneKey); hookDebugInfo('RoleInfoPanel.onOneKey hooked')
  RoleInfoPanel.onRoleClick = Debug.hook(RoleInfoPanel.onRoleClick); hookDebugInfo('RoleInfoPanel.onRoleClick hooked')
--  RoleInfoPanel.onShowRefinePanel = Debug.hook(RoleInfoPanel.onShowRefinePanel); hookDebugInfo('RoleInfoPanel.onShowRefinePanel hooked')
  RoleLevelUpPanel.onClose = Debug.hook(RoleLevelUpPanel.onClose); hookDebugInfo('RoleLevelUpPanel.onClose hooked')
  RoleMiKuInfoPanel.onChallengeClick = Debug.hook(RoleMiKuInfoPanel.onChallengeClick); hookDebugInfo('RoleMiKuInfoPanel.onChallengeClick hooked')
  RoleMiKuInfoPanel.onClose = Debug.hook(RoleMiKuInfoPanel.onClose); hookDebugInfo('RoleMiKuInfoPanel.onClose hooked')
  RoleMiKuInfoPanel.onCloseGuardsPanel = Debug.hook(RoleMiKuInfoPanel.onCloseGuardsPanel); hookDebugInfo('RoleMiKuInfoPanel.onCloseGuardsPanel hooked')
  RoleMiKuInfoPanel.onFriendClick = Debug.hook(RoleMiKuInfoPanel.onFriendClick); hookDebugInfo('RoleMiKuInfoPanel.onFriendClick hooked')
  RoleMiKuInfoPanel.onHnagUpClick = Debug.hook(RoleMiKuInfoPanel.onHnagUpClick); hookDebugInfo('RoleMiKuInfoPanel.onHnagUpClick hooked')
  RoleMiKuInfoPanel.onItemKind = Debug.hook(RoleMiKuInfoPanel.onItemKind); hookDebugInfo('RoleMiKuInfoPanel.onItemKind hooked')
  RoleMiKuInfoPanel.onReset = Debug.hook(RoleMiKuInfoPanel.onReset); hookDebugInfo('RoleMiKuInfoPanel.onReset hooked')
  RoleMiKuPanel.onClick = Debug.hook(RoleMiKuPanel.onClick); hookDebugInfo('RoleMiKuPanel.onClick hooked')
  RoleMiKuPanel.onClose = Debug.hook(RoleMiKuPanel.onClose); hookDebugInfo('RoleMiKuPanel.onClose hooked')
  RoleMiKuPanel.onNextPage = Debug.hook(RoleMiKuPanel.onNextPage); hookDebugInfo('RoleMiKuPanel.onNextPage hooked')
  RoleMiKuPanel.onPrePage = Debug.hook(RoleMiKuPanel.onPrePage); hookDebugInfo('RoleMiKuPanel.onPrePage hooked')
  RolePortraitPanel.GoVipPanel = Debug.hook(RolePortraitPanel.GoVipPanel); hookDebugInfo('RolePortraitPanel.GoVipPanel hooked')
  RolePortraitPanel.onExpChange = Debug.hook(RolePortraitPanel.onExpChange); hookDebugInfo('RolePortraitPanel.onExpChange hooked')
  RolePortraitPanel.onShowTomorrowRewardPanel = Debug.hook(RolePortraitPanel.onShowTomorrowRewardPanel); hookDebugInfo('RolePortraitPanel.onShowTomorrowRewardPanel hooked')
  RoleRefinementPanel.onClose = Debug.hook(RoleRefinementPanel.onClose); hookDebugInfo('RoleRefinementPanel.onClose hooked')
  RoleRefinementPanel.onNormalClick = Debug.hook(RoleRefinementPanel.onNormalClick); hookDebugInfo('RoleRefinementPanel.onNormalClick hooked')
  RoleRefinementPanel.onRoleClick = Debug.hook(RoleRefinementPanel.onRoleClick); hookDebugInfo('RoleRefinementPanel.onRoleClick hooked')
  RoleRefinementPanel.onSuperClick = Debug.hook(RoleRefinementPanel.onSuperClick); hookDebugInfo('RoleRefinementPanel.onSuperClick hooked')
  RolechangePanelPanel.Hide = Debug.hook(RolechangePanelPanel.Hide); hookDebugInfo('RolechangePanelPanel.Hide hooked')
  RolechangePanelPanel.Show = Debug.hook(RolechangePanelPanel.Show); hookDebugInfo('RolechangePanelPanel.Show hooked')
  RolechangePanelPanel.change_roletype = Debug.hook(RolechangePanelPanel.change_roletype); hookDebugInfo('RolechangePanelPanel.change_roletype hooked')
  RuneEatAllPromptPanel.onClose = Debug.hook(RuneEatAllPromptPanel.onClose); hookDebugInfo('RuneEatAllPromptPanel.onClose hooked')
  RuneEatAllPromptPanel.onEatAll = Debug.hook(RuneEatAllPromptPanel.onEatAll); hookDebugInfo('RuneEatAllPromptPanel.onEatAll hooked')
  RuneEatPromptPanel.onClose = Debug.hook(RuneEatPromptPanel.onClose); hookDebugInfo('RuneEatPromptPanel.onClose hooked')
  RuneEatPromptPanel.onEat = Debug.hook(RuneEatPromptPanel.onEat); hookDebugInfo('RuneEatPromptPanel.onEat hooked')
  RuneExchangePanel.onClose = Debug.hook(RuneExchangePanel.onClose); hookDebugInfo('RuneExchangePanel.onClose hooked')
  RuneExchangePanel.onItemClick = Debug.hook(RuneExchangePanel.onItemClick); hookDebugInfo('RuneExchangePanel.onItemClick hooked')
  RuneExchangePanel.onShow = Debug.hook(RuneExchangePanel.onShow); hookDebugInfo('RuneExchangePanel.onShow hooked')
  RuneHuntPanel.CheckChange = Debug.hook(RuneHuntPanel.CheckChange); hookDebugInfo('RuneHuntPanel.CheckChange hooked')
  RuneHuntPanel.MergeOptionChange = Debug.hook(RuneHuntPanel.MergeOptionChange); hookDebugInfo('RuneHuntPanel.MergeOptionChange hooked')
  RuneHuntPanel.onAutoHunt = Debug.hook(RuneHuntPanel.onAutoHunt); hookDebugInfo('RuneHuntPanel.onAutoHunt hooked')
  RuneHuntPanel.onGoRune = Debug.hook(RuneHuntPanel.onGoRune); hookDebugInfo('RuneHuntPanel.onGoRune hooked')
  RuneHuntPanel.onHuntKing = Debug.hook(RuneHuntPanel.onHuntKing); hookDebugInfo('RuneHuntPanel.onHuntKing hooked')
  RuneHuntPanel.onShow = Debug.hook(RuneHuntPanel.onShow); hookDebugInfo('RuneHuntPanel.onShow hooked')
  RunePackageFullPanel.onGoRune = Debug.hook(RunePackageFullPanel.onGoRune); hookDebugInfo('RunePackageFullPanel.onGoRune hooked')
  RunePanel.onCellClick = Debug.hook(RunePanel.onCellClick); hookDebugInfo('RunePanel.onCellClick hooked')
  RunePanel.onClose = Debug.hook(RunePanel.onClose); hookDebugInfo('RunePanel.onClose hooked')
  RunePanel.onEatAll = Debug.hook(RunePanel.onEatAll); hookDebugInfo('RunePanel.onEatAll hooked')
  RunePanel.onRoleClick = Debug.hook(RunePanel.onRoleClick); hookDebugInfo('RunePanel.onRoleClick hooked')
  RunePanel.onShuoMing = Debug.hook(RunePanel.onShuoMing); hookDebugInfo('RunePanel.onShuoMing hooked')

  --[[
  ScuffleChampionPanel.onClose = Debug.hook(ScuffleChampionPanel.onClose); hookDebugInfo('ScuffleChampionPanel.onClose hooked')
  --]]
  ScufflePanel.onHelp = Debug.hook(ScufflePanel.onHelp); hookDebugInfo('ScufflePanel.onHelp hooked')
  ScufflePanel.onInspire = Debug.hook(ScufflePanel.onInspire); hookDebugInfo('ScufflePanel.onInspire hooked')
  ScufflePanel.onRevive = Debug.hook(ScufflePanel.onRevive); hookDebugInfo('ScufflePanel.onRevive hooked')
  SelectActorPanel.Selected = Debug.hook(SelectActorPanel.Selected); hookDebugInfo('SelectActorPanel.Selected hooked')
  SelectActorPanel.Unselected = Debug.hook(SelectActorPanel.Unselected); hookDebugInfo('SelectActorPanel.Unselected hooked')
  SelectActorPanel.onAll = Debug.hook(SelectActorPanel.onAll); hookDebugInfo('SelectActorPanel.onAll hooked')
  SelectActorPanel.onBack = Debug.hook(SelectActorPanel.onBack); hookDebugInfo('SelectActorPanel.onBack hooked')
  SelectActorPanel.onCenter = Debug.hook(SelectActorPanel.onCenter); hookDebugInfo('SelectActorPanel.onCenter hooked')
  SelectActorPanel.onFight = Debug.hook(SelectActorPanel.onFight); hookDebugInfo('SelectActorPanel.onFight hooked')
  SelectActorPanel.onFront = Debug.hook(SelectActorPanel.onFront); hookDebugInfo('SelectActorPanel.onFront hooked')
  SelectActorPanel.onReturn = Debug.hook(SelectActorPanel.onReturn); hookDebugInfo('SelectActorPanel.onReturn hooked')
  SettingPanel.onClose = Debug.hook(SettingPanel.onClose); hookDebugInfo('SettingPanel.onClose hooked')
  SettingPanel.onSoundOFF = Debug.hook(SettingPanel.onSoundOFF); hookDebugInfo('SettingPanel.onSoundOFF hooked')
  SettingPanel.onSoundON = Debug.hook(SettingPanel.onSoundON); hookDebugInfo('SettingPanel.onSoundON hooked')
  SettingPanel.onSwitchAccount = Debug.hook(SettingPanel.onSwitchAccount); hookDebugInfo('SettingPanel.onSwitchAccount hooked')
  ShopBuyPanel.onClose = Debug.hook(ShopBuyPanel.onClose); hookDebugInfo('ShopBuyPanel.onClose hooked')
  ShopPanel.onBuy = Debug.hook(ShopPanel.onBuy); hookDebugInfo('ShopPanel.onBuy hooked')
  ShopPanel.onClose = Debug.hook(ShopPanel.onClose); hookDebugInfo('ShopPanel.onClose hooked')

  --[[
  SignPanel.onClose = Debug.hook(SignPanel.onClose); hookDebugInfo('SignPanel.onClose hooked')
  SignPanel.onFastSweepClick = Debug.hook(SignPanel.onFastSweepClick); hookDebugInfo('SignPanel.onFastSweepClick hooked')
  --]]
  SkillPanel.onAdvance = Debug.hook(SkillPanel.onAdvance); hookDebugInfo('SkillPanel.onAdvance hooked')
  SkillPanel.onRoleClick = Debug.hook(SkillPanel.onRoleClick); hookDebugInfo('SkillPanel.onRoleClick hooked')
  SkillPanel.onUpLevel = Debug.hook(SkillPanel.onUpLevel); hookDebugInfo('SkillPanel.onUpLevel hooked')
  SkillStrPanel.UpdateAdvInfo = Debug.hook(SkillStrPanel.UpdateAdvInfo); hookDebugInfo('SkillStrPanel.UpdateAdvInfo hooked')
  SkillStrPanel.UpdateInfo = Debug.hook(SkillStrPanel.UpdateInfo); hookDebugInfo('SkillStrPanel.UpdateInfo hooked')
  SkillStrPanel.onAdvance = Debug.hook(SkillStrPanel.onAdvance); hookDebugInfo('SkillStrPanel.onAdvance hooked')
  SkillStrPanel.onClose = Debug.hook(SkillStrPanel.onClose); hookDebugInfo('SkillStrPanel.onClose hooked')
  SkillStrPanel.onPageChange = Debug.hook(SkillStrPanel.onPageChange); hookDebugInfo('SkillStrPanel.onPageChange hooked')
  SkillStrPanel.onStrength = Debug.hook(SkillStrPanel.onStrength); hookDebugInfo('SkillStrPanel.onStrength hooked')
  SkillStrPanel.onStrengthTen = Debug.hook(SkillStrPanel.onStrengthTen); hookDebugInfo('SkillStrPanel.onStrengthTen hooked')
  SoulPanel.get_reward = Debug.hook(SoulPanel.get_reward); hookDebugInfo('SoulPanel.get_reward hooked')
  SoulPanel.hideInfo = Debug.hook(SoulPanel.hideInfo); hookDebugInfo('SoulPanel.hideInfo hooked')
  SoulPanel.hunt = Debug.hook(SoulPanel.hunt); hookDebugInfo('SoulPanel.hunt hooked')
  SoulPanel.onClose = Debug.hook(SoulPanel.onClose); hookDebugInfo('SoulPanel.onClose hooked')
  SoulPanel.onShow = Debug.hook(SoulPanel.onShow); hookDebugInfo('SoulPanel.onShow hooked')
  SoulPanel.rankup = Debug.hook(SoulPanel.rankup); hookDebugInfo('SoulPanel.rankup hooked')
  SoulPanel.showInfo = Debug.hook(SoulPanel.showInfo); hookDebugInfo('SoulPanel.showInfo hooked')
  StarMapPanel.DoRefreshWork = Debug.hook(StarMapPanel.DoRefreshWork); hookDebugInfo('StarMapPanel.DoRefreshWork hooked')
  StarMapPanel.KeepOld = Debug.hook(StarMapPanel.KeepOld); hookDebugInfo('StarMapPanel.KeepOld hooked')
  StarMapPanel.OnClickStarBtn = Debug.hook(StarMapPanel.OnClickStarBtn); hookDebugInfo('StarMapPanel.OnClickStarBtn hooked')
  StarMapPanel.OnClose = Debug.hook(StarMapPanel.OnClose); hookDebugInfo('StarMapPanel.OnClose hooked')
  StarMapPanel.OnSelectRole = Debug.hook(StarMapPanel.OnSelectRole); hookDebugInfo('StarMapPanel.OnSelectRole hooked')
  StarMapPanel.UseTheNewAttr = Debug.hook(StarMapPanel.UseTheNewAttr); hookDebugInfo('StarMapPanel.UseTheNewAttr hooked')
  StarMapPanel.onShuoMing = Debug.hook(StarMapPanel.onShuoMing); hookDebugInfo('StarMapPanel.onShuoMing hooked')
--  SystemPanel.onChangeRole = Debug.hook(SystemPanel.onChangeRole); hookDebugInfo('SystemPanel.onChangeRole hooked')
  SystemPanel.onClose = Debug.hook(SystemPanel.onClose); hookDebugInfo('SystemPanel.onClose hooked')
  SystemPanel.onConnectCustom = Debug.hook(SystemPanel.onConnectCustom); hookDebugInfo('SystemPanel.onConnectCustom hooked')
  SystemPanel.onEnergyFullPushChange = Debug.hook(SystemPanel.onEnergyFullPushChange); hookDebugInfo('SystemPanel.onEnergyFullPushChange hooked')
  SystemPanel.onPisaPushAmChange = Debug.hook(SystemPanel.onPisaPushAmChange); hookDebugInfo('SystemPanel.onPisaPushAmChange hooked')
  SystemPanel.onPisaPushPmChange = Debug.hook(SystemPanel.onPisaPushPmChange); hookDebugInfo('SystemPanel.onPisaPushPmChange hooked')
  SystemPanel.onSoundChange = Debug.hook(SystemPanel.onSoundChange); hookDebugInfo('SystemPanel.onSoundChange hooked')
  SystemPanel.onSoundEffectChange = Debug.hook(SystemPanel.onSoundEffectChange); hookDebugInfo('SystemPanel.onSoundEffectChange hooked')
  Task.GuideInMainUI = Debug.hook(Task.GuideInMainUI); hookDebugInfo('Task.GuideInMainUI hooked')
  TaskAcceptAndRewardPanel.Disappear = Debug.hook(TaskAcceptAndRewardPanel.Disappear); hookDebugInfo('TaskAcceptAndRewardPanel.Disappear hooked')
  TaskAcceptAndRewardPanel.onGo = Debug.hook(TaskAcceptAndRewardPanel.onGo); hookDebugInfo('TaskAcceptAndRewardPanel.onGo hooked')
  TaskDialogPanel.NpcShopClick = Debug.hook(TaskDialogPanel.NpcShopClick); hookDebugInfo('TaskDialogPanel.NpcShopClick hooked')
  TaskDialogPanel.SpShopClick = Debug.hook(TaskDialogPanel.SpShopClick); hookDebugInfo('TaskDialogPanel.SpShopClick hooked')
  TaskDialogPanel.TestPlot = Debug.hook(TaskDialogPanel.TestPlot); hookDebugInfo('TaskDialogPanel.TestPlot hooked')
  TaskDialogPanel.onClose = Debug.hook(TaskDialogPanel.onClose); hookDebugInfo('TaskDialogPanel.onClose hooked')
  TaskDialogPanel.onNext = Debug.hook(TaskDialogPanel.onNext); hookDebugInfo('TaskDialogPanel.onNext hooked')
  TaskDialogPanel.onOptionClick = Debug.hook(TaskDialogPanel.onOptionClick); hookDebugInfo('TaskDialogPanel.onOptionClick hooked')
  TaskDialogPanel.onSkip = Debug.hook(TaskDialogPanel.onSkip); hookDebugInfo('TaskDialogPanel.onSkip hooked')
  TaskGuidePanel.onDown = Debug.hook(TaskGuidePanel.onDown); hookDebugInfo('TaskGuidePanel.onDown hooked')
  TaskGuidePanel.onUp = Debug.hook(TaskGuidePanel.onUp); hookDebugInfo('TaskGuidePanel.onUp hooked')

  --[[
  TaskPanel.onClose = Debug.hook(TaskPanel.onClose); hookDebugInfo('TaskPanel.onClose hooked')
  TaskPanel.onRewardClick = Debug.hook(TaskPanel.onRewardClick); hookDebugInfo('TaskPanel.onRewardClick hooked')
  --]]

  TaskTipPanel.Revert = Debug.hook(TaskTipPanel.Revert); hookDebugInfo('TaskTipPanel.Revert hooked')
  TaskTipPanel.onAuto = Debug.hook(TaskTipPanel.onAuto); hookDebugInfo('TaskTipPanel.onAuto hooked')
  TaskTipPanel.onClick = Debug.hook(TaskTipPanel.onClick); hookDebugInfo('TaskTipPanel.onClick hooked')
  TeamComprisePanel.onCancelClear = Debug.hook(TeamComprisePanel.onCancelClear); hookDebugInfo('TeamComprisePanel.onCancelClear hooked')
  TeamComprisePanel.onClearup = Debug.hook(TeamComprisePanel.onClearup); hookDebugInfo('TeamComprisePanel.onClearup hooked')
  TeamComprisePanel.onClickMember = Debug.hook(TeamComprisePanel.onClickMember); hookDebugInfo('TeamComprisePanel.onClickMember hooked')
  TeamComprisePanel.onClickReturn = Debug.hook(TeamComprisePanel.onClickReturn); hookDebugInfo('TeamComprisePanel.onClickReturn hooked')
  TeamComprisePanel.onRename = Debug.hook(TeamComprisePanel.onRename); hookDebugInfo('TeamComprisePanel.onRename hooked')
  TeamComprisePanel.onSureClear = Debug.hook(TeamComprisePanel.onSureClear); hookDebugInfo('TeamComprisePanel.onSureClear hooked')
  TeamComprisePanel.setDefault = Debug.hook(TeamComprisePanel.setDefault); hookDebugInfo('TeamComprisePanel.setDefault hooked')
  TeamMemberSelectPanel.onClickPropertyFrame = Debug.hook(TeamMemberSelectPanel.onClickPropertyFrame); hookDebugInfo('TeamMemberSelectPanel.onClickPropertyFrame hooked')
  TeamMemberSelectPanel.onClickPullFrame = Debug.hook(TeamMemberSelectPanel.onClickPullFrame); hookDebugInfo('TeamMemberSelectPanel.onClickPullFrame hooked')
  TeamMemberSelectPanel.onClosePopWindow = Debug.hook(TeamMemberSelectPanel.onClosePopWindow); hookDebugInfo('TeamMemberSelectPanel.onClosePopWindow hooked')
  TeamMemberSelectPanel.onReturn = Debug.hook(TeamMemberSelectPanel.onReturn); hookDebugInfo('TeamMemberSelectPanel.onReturn hooked')
  TeamMemberSelectPanel.onSelectPropertyItem = Debug.hook(TeamMemberSelectPanel.onSelectPropertyItem); hookDebugInfo('TeamMemberSelectPanel.onSelectPropertyItem hooked')
  TeamMemberSelectPanel.onSelectSortItem = Debug.hook(TeamMemberSelectPanel.onSelectSortItem); hookDebugInfo('TeamMemberSelectPanel.onSelectSortItem hooked')
  TeamMemberSelectPanel.onSureClick = Debug.hook(TeamMemberSelectPanel.onSureClick); hookDebugInfo('TeamMemberSelectPanel.onSureClick hooked')
  TeamOrderPanel.onClose = Debug.hook(TeamOrderPanel.onClose); hookDebugInfo('TeamOrderPanel.onClose hooked')
  TeamOrderPanel.onFellowInTeamClick = Debug.hook(TeamOrderPanel.onFellowInTeamClick); hookDebugInfo('TeamOrderPanel.onFellowInTeamClick hooked')
  TeamOrderPanel.onLeaveTeam = Debug.hook(TeamOrderPanel.onLeaveTeam); hookDebugInfo('TeamOrderPanel.onLeaveTeam hooked')
  TeamOrderPanel.onRoleClick = Debug.hook(TeamOrderPanel.onRoleClick); hookDebugInfo('TeamOrderPanel.onRoleClick hooked')
  TeamOrderPanel.onRoleInTeamClick = Debug.hook(TeamOrderPanel.onRoleInTeamClick); hookDebugInfo('TeamOrderPanel.onRoleInTeamClick hooked')
  TeamOrderPanel.onTeamPageLeft = Debug.hook(TeamOrderPanel.onTeamPageLeft); hookDebugInfo('TeamOrderPanel.onTeamPageLeft hooked')
  TeamOrderPanel.onTeamPageRight = Debug.hook(TeamOrderPanel.onTeamPageRight); hookDebugInfo('TeamOrderPanel.onTeamPageRight hooked')
  TeamPanel.HideInfo = Debug.hook(TeamPanel.HideInfo); hookDebugInfo('TeamPanel.HideInfo hooked')
  TeamPanel.SelectAll = Debug.hook(TeamPanel.SelectAll); hookDebugInfo('TeamPanel.SelectAll hooked')
  TeamPanel.SelectBack = Debug.hook(TeamPanel.SelectBack); hookDebugInfo('TeamPanel.SelectBack hooked')
  TeamPanel.SelectCenter = Debug.hook(TeamPanel.SelectCenter); hookDebugInfo('TeamPanel.SelectCenter hooked')
  TeamPanel.SelectEvent = Debug.hook(TeamPanel.SelectEvent); hookDebugInfo('TeamPanel.SelectEvent hooked')
  TeamPanel.SelectFront = Debug.hook(TeamPanel.SelectFront); hookDebugInfo('TeamPanel.SelectFront hooked')
  TeamPanel.ShowInfo = Debug.hook(TeamPanel.ShowInfo); hookDebugInfo('TeamPanel.ShowInfo hooked')
  TeamPanel.cancelChangeTeamName = Debug.hook(TeamPanel.cancelChangeTeamName); hookDebugInfo('TeamPanel.cancelChangeTeamName hooked')
  TeamPanel.okChangeTeamName = Debug.hook(TeamPanel.okChangeTeamName); hookDebugInfo('TeamPanel.okChangeTeamName hooked')
  TeamPanel.onClickBack = Debug.hook(TeamPanel.onClickBack); hookDebugInfo('TeamPanel.onClickBack hooked')
  TeamPanel.onNextPage = Debug.hook(TeamPanel.onNextPage); hookDebugInfo('TeamPanel.onNextPage hooked')
  TeamPanel.onPrePage = Debug.hook(TeamPanel.onPrePage); hookDebugInfo('TeamPanel.onPrePage hooked')
  TeamPanel.roleDetailsClick = Debug.hook(TeamPanel.roleDetailsClick); hookDebugInfo('TeamPanel.roleDetailsClick hooked')
  TeamPanel.roleDetailsHide = Debug.hook(TeamPanel.roleDetailsHide); hookDebugInfo('TeamPanel.roleDetailsHide hooked')
  TeamPanel.roleSelected = Debug.hook(TeamPanel.roleSelected); hookDebugInfo('TeamPanel.roleSelected hooked')
  TeamPanel.setDefault = Debug.hook(TeamPanel.setDefault); hookDebugInfo('TeamPanel.setDefault hooked')
  TeamPanel.showTeamNameChange = Debug.hook(TeamPanel.showTeamNameChange); hookDebugInfo('TeamPanel.showTeamNameChange hooked')
  TeamPanel.skillSelected = Debug.hook(TeamPanel.skillSelected); hookDebugInfo('TeamPanel.skillSelected hooked')
  TeamPanel.teamChange = Debug.hook(TeamPanel.teamChange); hookDebugInfo('TeamPanel.teamChange hooked')
  TeamPanel.withdrawHero = Debug.hook(TeamPanel.withdrawHero); hookDebugInfo('TeamPanel.withdrawHero hooked')
  TeamSelectPanel.onClose = Debug.hook(TeamSelectPanel.onClose); hookDebugInfo('TeamSelectPanel.onClose hooked')
  TeamSelectPanel.selectTeam = Debug.hook(TeamSelectPanel.selectTeam); hookDebugInfo('TeamSelectPanel.selectTeam hooked')
  TipsPanel.fromIconShow = Debug.hook(TipsPanel.fromIconShow); hookDebugInfo('TipsPanel.fromIconShow hooked')
  TipsPanel.onClose = Debug.hook(TipsPanel.onClose); hookDebugInfo('TipsPanel.onClose hooked')
  TomorrowRewardPanel.onClose = Debug.hook(TomorrowRewardPanel.onClose); hookDebugInfo('TomorrowRewardPanel.onClose hooked')
  TomorrowRewardPanel.onGetReward = Debug.hook(TomorrowRewardPanel.onGetReward); hookDebugInfo('TomorrowRewardPanel.onGetReward hooked')
  TomorrowRewardPanel.onShowLoginRewardPanel = Debug.hook(TomorrowRewardPanel.onShowLoginRewardPanel); hookDebugInfo('TomorrowRewardPanel.onShowLoginRewardPanel hooked')
  TooltipPanel.DoUseItem = Debug.hook(TooltipPanel.DoUseItem); hookDebugInfo('TooltipPanel.DoUseItem hooked')
  TooltipPanel.GetMaterialPathItem = Debug.hook(TooltipPanel.GetMaterialPathItem); hookDebugInfo('TooltipPanel.GetMaterialPathItem hooked')
  TooltipPanel.RequestOpenAllPacks = Debug.hook(TooltipPanel.RequestOpenAllPacks); hookDebugInfo('TooltipPanel.RequestOpenAllPacks hooked')
  TooltipPanel.RequestOpenPacks = Debug.hook(TooltipPanel.RequestOpenPacks); hookDebugInfo('TooltipPanel.RequestOpenPacks hooked')
  TooltipPanel.TaskClick = Debug.hook(TooltipPanel.TaskClick); hookDebugInfo('TooltipPanel.TaskClick hooked')
  TooltipPanel.UseItem = Debug.hook(TooltipPanel.UseItem); hookDebugInfo('TooltipPanel.UseItem hooked')
  TooltipPanel.drawingSynthesis = Debug.hook(TooltipPanel.drawingSynthesis); hookDebugInfo('TooltipPanel.drawingSynthesis hooked')
  TooltipPanel.equipItem = Debug.hook(TooltipPanel.equipItem); hookDebugInfo('TooltipPanel.equipItem hooked')
  TooltipPanel.materialPanelClose = Debug.hook(TooltipPanel.materialPanelClose); hookDebugInfo('TooltipPanel.materialPanelClose hooked')
  TooltipPanel.mergeChip = Debug.hook(TooltipPanel.mergeChip); hookDebugInfo('TooltipPanel.mergeChip hooked')
  TooltipPanel.obtainChip = Debug.hook(TooltipPanel.obtainChip); hookDebugInfo('TooltipPanel.obtainChip hooked')
  TooltipPanel.obtainMaterial = Debug.hook(TooltipPanel.obtainMaterial); hookDebugInfo('TooltipPanel.obtainMaterial hooked')
  TooltipPanel.onClose = Debug.hook(TooltipPanel.onClose); hookDebugInfo('TooltipPanel.onClose hooked')
  TooltipPanel.onLostFocus = Debug.hook(TooltipPanel.onLostFocus); hookDebugInfo('TooltipPanel.onLostFocus hooked')
  TooltipPanel.roundNotOpen = Debug.hook(TooltipPanel.roundNotOpen); hookDebugInfo('TooltipPanel.roundNotOpen hooked')
  TooltipPanel.runeExchange = Debug.hook(TooltipPanel.runeExchange); hookDebugInfo('TooltipPanel.runeExchange hooked')
  TooltipPanel.runeItemAct = Debug.hook(TooltipPanel.runeItemAct); hookDebugInfo('TooltipPanel.runeItemAct hooked')
  TooltipPanel.sellItem = Debug.hook(TooltipPanel.sellItem); hookDebugInfo('TooltipPanel.sellItem hooked')
  TooltipPanel.takeOffEquipItem = Debug.hook(TooltipPanel.takeOffEquipItem); hookDebugInfo('TooltipPanel.takeOffEquipItem hooked')
  TopRenderStep.onReportDebugInfo = Debug.hook(TopRenderStep.onReportDebugInfo); hookDebugInfo('TopRenderStep.onReportDebugInfo hooked')

--  TopRenderStep.onReqHire = Debug.hook(TopRenderStep.onReqHire); hookDebugInfo('TopRenderStep.onReqHire hooked')
  TotalRechargePanel.onClose = Debug.hook(TotalRechargePanel.onClose); hookDebugInfo('TotalRechargePanel.onClose hooked')
  TotalRechargePanel.onGetReward = Debug.hook(TotalRechargePanel.onGetReward); hookDebugInfo('TotalRechargePanel.onGetReward hooked')
  TotalRechargePanel.onYaDianNaClick = Debug.hook(TotalRechargePanel.onYaDianNaClick); hookDebugInfo('TotalRechargePanel.onYaDianNaClick hooked')
  TrainPanel.onChooseParnter = Debug.hook(TrainPanel.onChooseParnter); hookDebugInfo('TrainPanel.onChooseParnter hooked')
  TrainPanel.onChooseType = Debug.hook(TrainPanel.onChooseType); hookDebugInfo('TrainPanel.onChooseType hooked')
  TrainPanel.onClickChooseType = Debug.hook(TrainPanel.onClickChooseType); hookDebugInfo('TrainPanel.onClickChooseType hooked')
  TrainPanel.onClose = Debug.hook(TrainPanel.onClose); hookDebugInfo('TrainPanel.onClose hooked')
  TrainPanel.onMenuLoseFocuse = Debug.hook(TrainPanel.onMenuLoseFocuse); hookDebugInfo('TrainPanel.onMenuLoseFocuse hooked')
  TrainPanel.onStartToTrain = Debug.hook(TrainPanel.onStartToTrain); hookDebugInfo('TrainPanel.onStartToTrain hooked')
  TreasurePanel.onCancel = Debug.hook(TreasurePanel.onCancel); hookDebugInfo('TreasurePanel.onCancel hooked')
  TreasurePanel.onCancelGiveupHelp = Debug.hook(TreasurePanel.onCancelGiveupHelp); hookDebugInfo('TreasurePanel.onCancelGiveupHelp hooked')
  TreasurePanel.onCancelGiveupToOccupy = Debug.hook(TreasurePanel.onCancelGiveupToOccupy); hookDebugInfo('TreasurePanel.onCancelGiveupToOccupy hooked')
  TreasurePanel.onChallenge = Debug.hook(TreasurePanel.onChallenge); hookDebugInfo('TreasurePanel.onChallenge hooked')
  TreasurePanel.onChangeTeam = Debug.hook(TreasurePanel.onChangeTeam); hookDebugInfo('TreasurePanel.onChangeTeam hooked')
  TreasurePanel.onCloseExplainPanel = Debug.hook(TreasurePanel.onCloseExplainPanel); hookDebugInfo('TreasurePanel.onCloseExplainPanel hooked')
  TreasurePanel.onCloseHelperInfo = Debug.hook(TreasurePanel.onCloseHelperInfo); hookDebugInfo('TreasurePanel.onCloseHelperInfo hooked')
  TreasurePanel.onCloseHelperInfoPanel = Debug.hook(TreasurePanel.onCloseHelperInfoPanel); hookDebugInfo('TreasurePanel.onCloseHelperInfoPanel hooked')
  TreasurePanel.onCloseResetPanel = Debug.hook(TreasurePanel.onCloseResetPanel); hookDebugInfo('TreasurePanel.onCloseResetPanel hooked')
  TreasurePanel.onCloseRewardPanel = Debug.hook(TreasurePanel.onCloseRewardPanel); hookDebugInfo('TreasurePanel.onCloseRewardPanel hooked')
  TreasurePanel.onCloseTeamInfo = Debug.hook(TreasurePanel.onCloseTeamInfo); hookDebugInfo('TreasurePanel.onCloseTeamInfo hooked')
  TreasurePanel.onCloseTreasureRecords = Debug.hook(TreasurePanel.onCloseTreasureRecords); hookDebugInfo('TreasurePanel.onCloseTreasureRecords hooked')
  TreasurePanel.onCreateTeam = Debug.hook(TreasurePanel.onCreateTeam); hookDebugInfo('TreasurePanel.onCreateTeam hooked')
  TreasurePanel.onGiveup = Debug.hook(TreasurePanel.onGiveup); hookDebugInfo('TreasurePanel.onGiveup hooked')
  TreasurePanel.onGiveupHelp = Debug.hook(TreasurePanel.onGiveupHelp); hookDebugInfo('TreasurePanel.onGiveupHelp hooked')
  TreasurePanel.onGotoVip = Debug.hook(TreasurePanel.onGotoVip); hookDebugInfo('TreasurePanel.onGotoVip hooked')
  TreasurePanel.onHelp = Debug.hook(TreasurePanel.onHelp); hookDebugInfo('TreasurePanel.onHelp hooked')
  TreasurePanel.onIllustrate = Debug.hook(TreasurePanel.onIllustrate); hookDebugInfo('TreasurePanel.onIllustrate hooked')
  TreasurePanel.onMouseUp = Debug.hook(TreasurePanel.onMouseUp); hookDebugInfo('TreasurePanel.onMouseUp hooked')
  TreasurePanel.onOccupy2 = Debug.hook(TreasurePanel.onOccupy2); hookDebugInfo('TreasurePanel.onOccupy2 hooked')
  TreasurePanel.onOccupy3 = Debug.hook(TreasurePanel.onOccupy3); hookDebugInfo('TreasurePanel.onOccupy3 hooked')
  TreasurePanel.onOk = Debug.hook(TreasurePanel.onOk); hookDebugInfo('TreasurePanel.onOk hooked')
  TreasurePanel.onPageChange = Debug.hook(TreasurePanel.onPageChange); hookDebugInfo('TreasurePanel.onPageChange hooked')
  TreasurePanel.onRadioButton = Debug.hook(TreasurePanel.onRadioButton); hookDebugInfo('TreasurePanel.onRadioButton hooked')
  TreasurePanel.onReport = Debug.hook(TreasurePanel.onReport); hookDebugInfo('TreasurePanel.onReport hooked')
  TreasurePanel.onReturn = Debug.hook(TreasurePanel.onReturn); hookDebugInfo('TreasurePanel.onReturn hooked')
  TreasurePanel.onRevengeOccupy = Debug.hook(TreasurePanel.onRevengeOccupy); hookDebugInfo('TreasurePanel.onRevengeOccupy hooked')
  TreasurePanel.onRevengeRob = Debug.hook(TreasurePanel.onRevengeRob); hookDebugInfo('TreasurePanel.onRevengeRob hooked')
  TreasurePanel.onRob = Debug.hook(TreasurePanel.onRob); hookDebugInfo('TreasurePanel.onRob hooked')
  TreasurePanel.onScrollEvent = Debug.hook(TreasurePanel.onScrollEvent); hookDebugInfo('TreasurePanel.onScrollEvent hooked')
  TreasurePanel.onShowHelperInfo = Debug.hook(TreasurePanel.onShowHelperInfo); hookDebugInfo('TreasurePanel.onShowHelperInfo hooked')
  TreasurePanel.onShowResetPanel = Debug.hook(TreasurePanel.onShowResetPanel); hookDebugInfo('TreasurePanel.onShowResetPanel hooked')
  TreasurePanel.onShowTreasure = Debug.hook(TreasurePanel.onShowTreasure); hookDebugInfo('TreasurePanel.onShowTreasure hooked')
  TreasurePanel.onShowVipPanel = Debug.hook(TreasurePanel.onShowVipPanel); hookDebugInfo('TreasurePanel.onShowVipPanel hooked')
  TreasurePanel.onSureGiveupHelp = Debug.hook(TreasurePanel.onSureGiveupHelp); hookDebugInfo('TreasurePanel.onSureGiveupHelp hooked')
  TreasurePanel.onSureGiveupToOccupy = Debug.hook(TreasurePanel.onSureGiveupToOccupy); hookDebugInfo('TreasurePanel.onSureGiveupToOccupy hooked')
  TreasurePanel.onSweep = Debug.hook(TreasurePanel.onSweep); hookDebugInfo('TreasurePanel.onSweep hooked')
  TreasurePanel.onTreasureSlotClick = Debug.hook(TreasurePanel.onTreasureSlotClick); hookDebugInfo('TreasurePanel.onTreasureSlotClick hooked')
  TreasurePanel.showDefencerInfo = Debug.hook(TreasurePanel.showDefencerInfo); hookDebugInfo('TreasurePanel.showDefencerInfo hooked')
  TrialFieldPanel.onBuyEnergy = Debug.hook(TrialFieldPanel.onBuyEnergy); hookDebugInfo('TrialFieldPanel.onBuyEnergy hooked')
  TrialFieldPanel.onClose = Debug.hook(TrialFieldPanel.onClose); hookDebugInfo('TrialFieldPanel.onClose hooked')
  TrialFieldPanel.onFightClick = Debug.hook(TrialFieldPanel.onFightClick); hookDebugInfo('TrialFieldPanel.onFightClick hooked')
  TrialFieldPanel.onRefreshClick = Debug.hook(TrialFieldPanel.onRefreshClick); hookDebugInfo('TrialFieldPanel.onRefreshClick hooked')
  TrialTaskPanel.onClose = Debug.hook(TrialTaskPanel.onClose); hookDebugInfo('TrialTaskPanel.onClose hooked')
  TrialTaskPanel.onFightClick = Debug.hook(TrialTaskPanel.onFightClick); hookDebugInfo('TrialTaskPanel.onFightClick hooked')
  TrialTaskPanel.onGiveupOrRewardClick = Debug.hook(TrialTaskPanel.onGiveupOrRewardClick); hookDebugInfo('TrialTaskPanel.onGiveupOrRewardClick hooked')
  TrialTaskPanel.onLookOverPlayerInfo = Debug.hook(TrialTaskPanel.onLookOverPlayerInfo); hookDebugInfo('TrialTaskPanel.onLookOverPlayerInfo hooked')
  TrialTaskPanel.onRefreshClick = Debug.hook(TrialTaskPanel.onRefreshClick); hookDebugInfo('TrialTaskPanel.onRefreshClick hooked')
  UnionAdjustPosition.onLostFocus = Debug.hook(UnionAdjustPosition.onLostFocus); hookDebugInfo('UnionAdjustPosition.onLostFocus hooked')
  UnionAdjustPosition.onOptPosition = Debug.hook(UnionAdjustPosition.onOptPosition); hookDebugInfo('UnionAdjustPosition.onOptPosition hooked')
  UnionAdjustPosition.onTransfer = Debug.hook(UnionAdjustPosition.onTransfer); hookDebugInfo('UnionAdjustPosition.onTransfer hooked')
  UnionAlterPanel.onClose = Debug.hook(UnionAlterPanel.onClose); hookDebugInfo('UnionAlterPanel.onClose hooked')
  UnionAlterPanel.onDonate = Debug.hook(UnionAlterPanel.onDonate); hookDebugInfo('UnionAlterPanel.onDonate hooked')
  UnionAlterPanel.onSacrifice = Debug.hook(UnionAlterPanel.onSacrifice); hookDebugInfo('UnionAlterPanel.onSacrifice hooked')
  UnionApplyPanel.onAddFriend = Debug.hook(UnionApplyPanel.onAddFriend); hookDebugInfo('UnionApplyPanel.onAddFriend hooked')
  UnionApplyPanel.onAgree = Debug.hook(UnionApplyPanel.onAgree); hookDebugInfo('UnionApplyPanel.onAgree hooked')
  UnionApplyPanel.onClickWisper = Debug.hook(UnionApplyPanel.onClickWisper); hookDebugInfo('UnionApplyPanel.onClickWisper hooked')
  UnionApplyPanel.onClose = Debug.hook(UnionApplyPanel.onClose); hookDebugInfo('UnionApplyPanel.onClose hooked')
  UnionApplyPanel.onLookOverPlayerInfo = Debug.hook(UnionApplyPanel.onLookOverPlayerInfo); hookDebugInfo('UnionApplyPanel.onLookOverPlayerInfo hooked')
  UnionApplyPanel.onMemberList = Debug.hook(UnionApplyPanel.onMemberList); hookDebugInfo('UnionApplyPanel.onMemberList hooked')
  UnionApplyPanel.onPopupMenuLoseFocus = Debug.hook(UnionApplyPanel.onPopupMenuLoseFocus); hookDebugInfo('UnionApplyPanel.onPopupMenuLoseFocus hooked')
  UnionApplyPanel.onRefuse = Debug.hook(UnionApplyPanel.onRefuse); hookDebugInfo('UnionApplyPanel.onRefuse hooked')
  UnionApplyPanel.onRoleClick = Debug.hook(UnionApplyPanel.onRoleClick); hookDebugInfo('UnionApplyPanel.onRoleClick hooked')
  UnionBattlePanel.ShowBattleRank = Debug.hook(UnionBattlePanel.ShowBattleRank); hookDebugInfo('UnionBattlePanel.ShowBattleRank hooked')
  UnionBattlePanel.ShowBuZhen = Debug.hook(UnionBattlePanel.ShowBuZhen); hookDebugInfo('UnionBattlePanel.ShowBuZhen hooked')
  UnionBattlePanel.ShowZhanBao = Debug.hook(UnionBattlePanel.ShowZhanBao); hookDebugInfo('UnionBattlePanel.ShowZhanBao hooked')
  UnionBattlePanel.ZhanBaoHide = Debug.hook(UnionBattlePanel.ZhanBaoHide); hookDebugInfo('UnionBattlePanel.ZhanBaoHide hooked')
  UnionBattlePanel.battleDetails = Debug.hook(UnionBattlePanel.battleDetails); hookDebugInfo('UnionBattlePanel.battleDetails hooked')
  UnionBattlePanel.battleDetailsHide = Debug.hook(UnionBattlePanel.battleDetailsHide); hookDebugInfo('UnionBattlePanel.battleDetailsHide hooked')
  UnionBattlePanel.onBattleRankClose = Debug.hook(UnionBattlePanel.onBattleRankClose); hookDebugInfo('UnionBattlePanel.onBattleRankClose hooked')
  UnionBattlePanel.onBuy = Debug.hook(UnionBattlePanel.onBuy); hookDebugInfo('UnionBattlePanel.onBuy hooked')
  UnionBattlePanel.onCloseExplain = Debug.hook(UnionBattlePanel.onCloseExplain); hookDebugInfo('UnionBattlePanel.onCloseExplain hooked')
  UnionBattlePanel.onReturn = Debug.hook(UnionBattlePanel.onReturn); hookDebugInfo('UnionBattlePanel.onReturn hooked')
  UnionBattlePanel.showExplainPanel = Debug.hook(UnionBattlePanel.showExplainPanel); hookDebugInfo('UnionBattlePanel.showExplainPanel hooked')
--  UnionBuZhenPanel.ShowDialog = Debug.hook(UnionBuZhenPanel.ShowDialog); hookDebugInfo('UnionBuZhenPanel.ShowDialog hooked')
  UnionBuZhenPanel.onReturn = Debug.hook(UnionBuZhenPanel.onReturn); hookDebugInfo('UnionBuZhenPanel.onReturn hooked')
  UnionCreatePanel.onClose = Debug.hook(UnionCreatePanel.onClose); hookDebugInfo('UnionCreatePanel.onClose hooked')
  UnionCreatePanel.onCreate = Debug.hook(UnionCreatePanel.onCreate); hookDebugInfo('UnionCreatePanel.onCreate hooked')
  UnionCreatePanel.onTextChange = Debug.hook(UnionCreatePanel.onTextChange); hookDebugInfo('UnionCreatePanel.onTextChange hooked')
  UnionDonatePanel.onClose = Debug.hook(UnionDonatePanel.onClose); hookDebugInfo('UnionDonatePanel.onClose hooked')
  UnionDonatePanel.onDonate = Debug.hook(UnionDonatePanel.onDonate); hookDebugInfo('UnionDonatePanel.onDonate hooked')
  UnionExplainPanel.onCloseExplainPanel = Debug.hook(UnionExplainPanel.onCloseExplainPanel); hookDebugInfo('UnionExplainPanel.onCloseExplainPanel hooked')
  UnionInputPanel.onClose = Debug.hook(UnionInputPanel.onClose); hookDebugInfo('UnionInputPanel.onClose hooked')
  UnionInputPanel.onOk = Debug.hook(UnionInputPanel.onOk); hookDebugInfo('UnionInputPanel.onOk hooked')
  UnionInputPanel.onTextChange = Debug.hook(UnionInputPanel.onTextChange); hookDebugInfo('UnionInputPanel.onTextChange hooked')
  UnionListPanel.onApplyJoin = Debug.hook(UnionListPanel.onApplyJoin); hookDebugInfo('UnionListPanel.onApplyJoin hooked')
  UnionListPanel.onClose = Debug.hook(UnionListPanel.onClose); hookDebugInfo('UnionListPanel.onClose hooked')
  UnionListPanel.onCreateUnion = Debug.hook(UnionListPanel.onCreateUnion); hookDebugInfo('UnionListPanel.onCreateUnion hooked')
  UnionListPanel.onMouseUp = Debug.hook(UnionListPanel.onMouseUp); hookDebugInfo('UnionListPanel.onMouseUp hooked')
  UnionListPanel.onScrolled = Debug.hook(UnionListPanel.onScrolled); hookDebugInfo('UnionListPanel.onScrolled hooked')
  UnionListPanel.onSearch = Debug.hook(UnionListPanel.onSearch); hookDebugInfo('UnionListPanel.onSearch hooked')
  UnionMemberPanel.onAddFriend = Debug.hook(UnionMemberPanel.onAddFriend); hookDebugInfo('UnionMemberPanel.onAddFriend hooked')
  UnionMemberPanel.onClickWisper = Debug.hook(UnionMemberPanel.onClickWisper); hookDebugInfo('UnionMemberPanel.onClickWisper hooked')
  UnionMemberPanel.onClose = Debug.hook(UnionMemberPanel.onClose); hookDebugInfo('UnionMemberPanel.onClose hooked')
  UnionMemberPanel.onKick = Debug.hook(UnionMemberPanel.onKick); hookDebugInfo('UnionMemberPanel.onKick hooked')
  UnionMemberPanel.onLookOverPlayerInfo = Debug.hook(UnionMemberPanel.onLookOverPlayerInfo); hookDebugInfo('UnionMemberPanel.onLookOverPlayerInfo hooked')
  UnionMemberPanel.onMouseUp = Debug.hook(UnionMemberPanel.onMouseUp); hookDebugInfo('UnionMemberPanel.onMouseUp hooked')
  UnionMemberPanel.onPopupMenuLoseFocus = Debug.hook(UnionMemberPanel.onPopupMenuLoseFocus); hookDebugInfo('UnionMemberPanel.onPopupMenuLoseFocus hooked')
  UnionMemberPanel.onPositionAdjustment = Debug.hook(UnionMemberPanel.onPositionAdjustment); hookDebugInfo('UnionMemberPanel.onPositionAdjustment hooked')
  UnionMemberPanel.onRoleClick = Debug.hook(UnionMemberPanel.onRoleClick); hookDebugInfo('UnionMemberPanel.onRoleClick hooked')
  UnionMemberPanel.onScrolled = Debug.hook(UnionMemberPanel.onScrolled); hookDebugInfo('UnionMemberPanel.onScrolled hooked')
  UnionMemberPanel.onShowApplyList = Debug.hook(UnionMemberPanel.onShowApplyList); hookDebugInfo('UnionMemberPanel.onShowApplyList hooked')
  UnionPanel.onClose = Debug.hook(UnionPanel.onClose); hookDebugInfo('UnionPanel.onClose hooked')
  UnionPanel.onLookoverOtherUnion = Debug.hook(UnionPanel.onLookoverOtherUnion); hookDebugInfo('UnionPanel.onLookoverOtherUnion hooked')
  UnionPanel.onMemberList = Debug.hook(UnionPanel.onMemberList); hookDebugInfo('UnionPanel.onMemberList hooked')
  UnionPanel.onModifyNotice = Debug.hook(UnionPanel.onModifyNotice); hookDebugInfo('UnionPanel.onModifyNotice hooked')
  UnionPanel.onQuitOrDissolve = Debug.hook(UnionPanel.onQuitOrDissolve); hookDebugInfo('UnionPanel.onQuitOrDissolve hooked')
  UnionPanel.onRequestShowUnionPanel = Debug.hook(UnionPanel.onRequestShowUnionPanel); hookDebugInfo('UnionPanel.onRequestShowUnionPanel hooked')
  UnionPanel.onSendMessage = Debug.hook(UnionPanel.onSendMessage); hookDebugInfo('UnionPanel.onSendMessage hooked')
  UnionPanel.onShowAlter = Debug.hook(UnionPanel.onShowAlter); hookDebugInfo('UnionPanel.onShowAlter hooked')
  UnionPanel.onUnionSkillClick = Debug.hook(UnionPanel.onUnionSkillClick); hookDebugInfo('UnionPanel.onUnionSkillClick hooked')
  UnionSetBossTimePanel.SetBossTime = Debug.hook(UnionSetBossTimePanel.SetBossTime); hookDebugInfo('UnionSetBossTimePanel.SetBossTime hooked')
  UnionSetBossTimePanel.onBossTimeChange = Debug.hook(UnionSetBossTimePanel.onBossTimeChange); hookDebugInfo('UnionSetBossTimePanel.onBossTimeChange hooked')
  UnionSetBossTimePanel.onClose = Debug.hook(UnionSetBossTimePanel.onClose); hookDebugInfo('UnionSetBossTimePanel.onClose hooked')
  UnionSkillPanel.onAdvanceSkill = Debug.hook(UnionSkillPanel.onAdvanceSkill); hookDebugInfo('UnionSkillPanel.onAdvanceSkill hooked')
  UnionSkillPanel.onClose = Debug.hook(UnionSkillPanel.onClose); hookDebugInfo('UnionSkillPanel.onClose hooked')
  UnionSkillPanel.onDonate = Debug.hook(UnionSkillPanel.onDonate); hookDebugInfo('UnionSkillPanel.onDonate hooked')
  UpdateInfoPanel.onClose = Debug.hook(UpdateInfoPanel.onClose); hookDebugInfo('UpdateInfoPanel.onClose hooked')
  UserGuidePanel.Hide = Debug.hook(UserGuidePanel.Hide); hookDebugInfo('UserGuidePanel.Hide hooked')
  UserGuidePanel.HideGuideTalk = Debug.hook(UserGuidePanel.HideGuideTalk); hookDebugInfo('UserGuidePanel.HideGuideTalk hooked')
  UserGuidePanel.onSkip = Debug.hook(UserGuidePanel.onSkip); hookDebugInfo('UserGuidePanel.onSkip hooked')
  UserGuidePanel.startuseGuide = Debug.hook(UserGuidePanel.startuseGuide); hookDebugInfo('UserGuidePanel.startuseGuide hooked')
  UserGuidePartnerPanel.onClose = Debug.hook(UserGuidePartnerPanel.onClose); hookDebugInfo('UserGuidePartnerPanel.onClose hooked')
  UserGuideRenamePanel.onRandomNameClick = Debug.hook(UserGuideRenamePanel.onRandomNameClick); hookDebugInfo('UserGuideRenamePanel.onRandomNameClick hooked')
  UserGuideRenamePanel.onRenameClick = Debug.hook(UserGuideRenamePanel.onRenameClick); hookDebugInfo('UserGuideRenamePanel.onRenameClick hooked')
  UserGuideRenamePanel.onTextChange = Debug.hook(UserGuideRenamePanel.onTextChange); hookDebugInfo('UserGuideRenamePanel.onTextChange hooked')
  VipPanel.TurnLeft = Debug.hook(VipPanel.TurnLeft); hookDebugInfo('VipPanel.TurnLeft hooked')
  VipPanel.TurnRight = Debug.hook(VipPanel.TurnRight); hookDebugInfo('VipPanel.TurnRight hooked')
  VipPanel.onClose = Debug.hook(VipPanel.onClose); hookDebugInfo('VipPanel.onClose hooked')
  VipPanel.onOpenVip = Debug.hook(VipPanel.onOpenVip); hookDebugInfo('VipPanel.onOpenVip hooked')
  VipPanel.onShowVipPanel = Debug.hook(VipPanel.onShowVipPanel); hookDebugInfo('VipPanel.onShowVipPanel hooked')
  WOUBossPanel.FightNow = Debug.hook(WOUBossPanel.FightNow); hookDebugInfo('WOUBossPanel.FightNow hooked')
  WOUBossPanel.Inspire = Debug.hook(WOUBossPanel.Inspire); hookDebugInfo('WOUBossPanel.Inspire hooked')
  WOUBossPanel.LeaveBossScene = Debug.hook(WOUBossPanel.LeaveBossScene); hookDebugInfo('WOUBossPanel.LeaveBossScene hooked')
  WOUBossPanel.RankHide = Debug.hook(WOUBossPanel.RankHide); hookDebugInfo('WOUBossPanel.RankHide hooked')
  WOUBossPanel.RankShow = Debug.hook(WOUBossPanel.RankShow); hookDebugInfo('WOUBossPanel.RankShow hooked')
  WOUBossPanel.fightRightNow = Debug.hook(WOUBossPanel.fightRightNow); hookDebugInfo('WOUBossPanel.fightRightNow hooked')
  WOUBossPanel.onCheckAuto = Debug.hook(WOUBossPanel.onCheckAuto); hookDebugInfo('WOUBossPanel.onCheckAuto hooked')
  WOUBossPanel.onCloseClick = Debug.hook(WOUBossPanel.onCloseClick); hookDebugInfo('WOUBossPanel.onCloseClick hooked')
  WingActivityInfoPanel.Hide = Debug.hook(WingActivityInfoPanel.Hide); hookDebugInfo('WingActivityInfoPanel.Hide hooked')
  WingActivityInfoPanel.Show = Debug.hook(WingActivityInfoPanel.Show); hookDebugInfo('WingActivityInfoPanel.Show hooked')
  WingActivityPanel.GachaForWing = Debug.hook(WingActivityPanel.GachaForWing); hookDebugInfo('WingActivityPanel.GachaForWing hooked')
  WingActivityPanel.GetWingReward = Debug.hook(WingActivityPanel.GetWingReward); hookDebugInfo('WingActivityPanel.GetWingReward hooked')
  WingActivityPanel.OnClickRewardItem = Debug.hook(WingActivityPanel.OnClickRewardItem); hookDebugInfo('WingActivityPanel.OnClickRewardItem hooked')
  WingActivityPanel.OnPopUI = Debug.hook(WingActivityPanel.OnPopUI); hookDebugInfo('WingActivityPanel.OnPopUI hooked')
  WingActivityPanel.OnShowMainUI = Debug.hook(WingActivityPanel.OnShowMainUI); hookDebugInfo('WingActivityPanel.OnShowMainUI hooked')
  WingDismissPanel.onClose = Debug.hook(WingDismissPanel.onClose); hookDebugInfo('WingDismissPanel.onClose hooked')
  WingDismissPanel.onDismiss = Debug.hook(WingDismissPanel.onDismiss); hookDebugInfo('WingDismissPanel.onDismiss hooked')
  WingPanel.cancelDecompose = Debug.hook(WingPanel.cancelDecompose); hookDebugInfo('WingPanel.cancelDecompose hooked')
  WingPanel.gotoShop = Debug.hook(WingPanel.gotoShop); hookDebugInfo('WingPanel.gotoShop hooked')
  WingPanel.hideIllustrate = Debug.hook(WingPanel.hideIllustrate); hookDebugInfo('WingPanel.hideIllustrate hooked')
  WingPanel.onClose = Debug.hook(WingPanel.onClose); hookDebugInfo('WingPanel.onClose hooked')
  WingPanel.onCompose = Debug.hook(WingPanel.onCompose); hookDebugInfo('WingPanel.onCompose hooked')
  WingPanel.onDebus = Debug.hook(WingPanel.onDebus); hookDebugInfo('WingPanel.onDebus hooked')
  WingPanel.onDecompos = Debug.hook(WingPanel.onDecompos); hookDebugInfo('WingPanel.onDecompos hooked')
  WingPanel.onEquip = Debug.hook(WingPanel.onEquip); hookDebugInfo('WingPanel.onEquip hooked')
  WingPanel.onSelectWing = Debug.hook(WingPanel.onSelectWing); hookDebugInfo('WingPanel.onSelectWing hooked')
  WingPanel.onShow = Debug.hook(WingPanel.onShow); hookDebugInfo('WingPanel.onShow hooked')
  WingPanel.showIllustrate = Debug.hook(WingPanel.showIllustrate); hookDebugInfo('WingPanel.showIllustrate hooked')
  WingPanel.sureForDecompose = Debug.hook(WingPanel.sureForDecompose); hookDebugInfo('WingPanel.sureForDecompose hooked')
  WorldMapPanel.EnterTask = Debug.hook(WorldMapPanel.EnterTask); hookDebugInfo('WorldMapPanel.EnterTask hooked')
  WorldMapPanel.onClose = Debug.hook(WorldMapPanel.onClose); hookDebugInfo('WorldMapPanel.onClose hooked')
  WorldMapPanel.onEnterWorldMapPanel = Debug.hook(WorldMapPanel.onEnterWorldMapPanel); hookDebugInfo('WorldMapPanel.onEnterWorldMapPanel hooked')
  WorldPanel.onClose = Debug.hook(WorldPanel.onClose); hookDebugInfo('WorldPanel.onClose hooked')
  WorldPanel.onSwitchScene = Debug.hook(WorldPanel.onSwitchScene); hookDebugInfo('WorldPanel.onSwitchScene hooked')
  XinghunPanel.closePop = Debug.hook(XinghunPanel.closePop); hookDebugInfo('XinghunPanel.closePop hooked')
  XinghunPanel.conFirmClick = Debug.hook(XinghunPanel.conFirmClick); hookDebugInfo('XinghunPanel.conFirmClick hooked')
  XinghunPanel.onChangeProperty = Debug.hook(XinghunPanel.onChangeProperty); hookDebugInfo('XinghunPanel.onChangeProperty hooked')
  XinghunPanel.onCheckBoxChanged = Debug.hook(XinghunPanel.onCheckBoxChanged); hookDebugInfo('XinghunPanel.onCheckBoxChanged hooked')
  XinghunPanel.onClickStar = Debug.hook(XinghunPanel.onClickStar); hookDebugInfo('XinghunPanel.onClickStar hooked')
  XinghunPanel.onRefresh = Debug.hook(XinghunPanel.onRefresh); hookDebugInfo('XinghunPanel.onRefresh hooked')
  XinghunPanel.onReplace = Debug.hook(XinghunPanel.onReplace); hookDebugInfo('XinghunPanel.onReplace hooked')
  XinghunPanel.onSecondRefresh = Debug.hook(XinghunPanel.onSecondRefresh); hookDebugInfo('XinghunPanel.onSecondRefresh hooked')
  ZhaomuPanel.SelectPub = Debug.hook(ZhaomuPanel.SelectPub); hookDebugInfo('ZhaomuPanel.SelectPub hooked')
  ZhaomuPanel.UnselectPub = Debug.hook(ZhaomuPanel.UnselectPub); hookDebugInfo('ZhaomuPanel.UnselectPub hooked')
  ZhaomuPanel.onClose = Debug.hook(ZhaomuPanel.onClose); hookDebugInfo('ZhaomuPanel.onClose hooked')
  ZhaomuPanel.on_one_pub = Debug.hook(ZhaomuPanel.on_one_pub); hookDebugInfo('ZhaomuPanel.on_one_pub hooked')
  ZhaomuPanel.on_ten_pub = Debug.hook(ZhaomuPanel.on_ten_pub); hookDebugInfo('ZhaomuPanel.on_ten_pub hooked')
  ZhaomuResultPanel.gotoSkip = Debug.hook(ZhaomuResultPanel.gotoSkip); hookDebugInfo('ZhaomuResultPanel.gotoSkip hooked')
  ZhaomuResultPanel.onOne = Debug.hook(ZhaomuResultPanel.onOne); hookDebugInfo('ZhaomuResultPanel.onOne hooked')
  ZhaomuResultPanel.onSure = Debug.hook(ZhaomuResultPanel.onSure); hookDebugInfo('ZhaomuResultPanel.onSure hooked')
  ZhaomuResultPanel.onTen = Debug.hook(ZhaomuResultPanel.onTen); hookDebugInfo('ZhaomuResultPanel.onTen hooked')
  ZhaomuResultPanel.onback = Debug.hook(ZhaomuResultPanel.onback); hookDebugInfo('ZhaomuResultPanel.onback hooked')
  ZodiacSignPanel.onActivityReset = Debug.hook(ZodiacSignPanel.onActivityReset); hookDebugInfo('ZodiacSignPanel.onActivityReset hooked')
  ZodiacSignPanel.onEnterSign = Debug.hook(ZodiacSignPanel.onEnterSign); hookDebugInfo('ZodiacSignPanel.onEnterSign hooked')
  ZodiacSignPanel.onReset = Debug.hook(ZodiacSignPanel.onReset); hookDebugInfo('ZodiacSignPanel.onReset hooked')
  ZodiacSignPanel.onReturn = Debug.hook(ZodiacSignPanel.onReturn); hookDebugInfo('ZodiacSignPanel.onReturn hooked')
  ZodiacSignPanel.onShuoMing = Debug.hook(ZodiacSignPanel.onShuoMing); hookDebugInfo('ZodiacSignPanel.onShuoMing hooked')


  cardPropertyPanel.Hide = Debug.hook(cardPropertyPanel.Hide); hookDebugInfo('cardPropertyPanel.Hide hooked')
  okCanelPanel.Close = Debug.hook(okCanelPanel.Close); hookDebugInfo('okCanelPanel.Close hooked')
  okCanelPanel.DoMsgOk = Debug.hook(okCanelPanel.DoMsgOk); hookDebugInfo('okCanelPanel.DoMsgOk hooked')


  if hotfixCode and  #hotfixCode > 0  then
    loadstring(hotfixCode)();
  end

 print("hook end\nWelcome to Meixing Shaqi");

end
