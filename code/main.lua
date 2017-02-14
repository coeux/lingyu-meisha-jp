--========================================================================

uiSystem = UISystem.Instance();					--UI系统
soundManager = SoundManager.Instance();			--声音系统
sceneManager = SceneManager.Instance();			--场景管理
imageManager = ImageManager.Instance();			--图片管理者
mouseCursor = MouseCursor.Instance();			--鼠标
armatureManager = ArmatureManager.Instance();	--换装类
timerManager = TimerManager.Instance();			--计时器管理
effectScriptManager = EffectScriptManager.Instance();	--特效脚本管理
resTableManager = ResTableManager.Instance();	--资源管理
appFramework = AppFramework.Instance();			--应用框架
eventRecordManager = EventRecordManager.Instance();		--事件记录
curlManager = CurlManager.Instance();			--短连接管理
networkManager = NetworkManager.Instance();		--网络管理
platformSDK = PlatformSDK.Instance();			--平台SDK
fightResultManager = FightResultManager.Instance();		--战斗结果管理
renderer = uiSystem:GetRenderer();				--获取渲染器
asyncLoadManager = AsyncLoadManager.Instance();	--异步加载器
threadPool = ThreadPool.Instance();				--线程池
memoryManager = MemoryManager.Instance();		--内存管理者
fileSystem = FileSystem.Instance();				--文件系统

debugmode = false;

account_config = {
  user_name = '864502027176890';
  server_port = 61100;
}

if fileSystem:IsFileExist('account_config.lua') then
  --忽略这个配置文件!
  appFramework:DoScriptFile('account_config.lua')
end

--========================================================================
--
--初始化
--

--[[
function Init()
--  collectgarbage("collect");
--  collectgarbage("setpause", 100); 
--  collectgarbage("setstepmul", 5000); 

  local status, err = xpcall(BeginInit, __TRACKBACK__);
  if not status then
    error(err);
  end
end

function __TRACKBACK__(msg)
  local message = msg
  local msg = debug.traceback(msg, 3)
  print(msg)

  if buglyReortLuaException then 
    Debug.report("buglyReport now");
    buglyReportLuaException(message, debug.traceback())
  end

  return msg
end
]]
function Init()
  --设置背景色
  appFramework:SetClearColor( Color.Black );

  --手机上设置强制聚焦
  uiSystem.Focusable = true;

  --win下初始化窗口大小
  if platformSDK.m_System == "Win32" then
    -- local width = 960;
    -- local height = 640;

    local width = 960;
    local height = 640;

    ChangeWinSize(width, height);
    uiSystem:Resize(width, height);
  end

  --版本更新初始化
  VersionUpdate:Init();

end

--版本比较 返回值：
--	-1 : Ver1 < Ver2
--	0 : Ver1 == Ver2
--	1 : Ver1 > Ver2
function VersionCompareFunc( Ver1, Ver2 )
  for i = 1, 3 do
    local v1 = tonumber(Ver1[i]);
    local v2 = tonumber(Ver2[i]);

    if v1 < v2 then
      return -1;
    elseif v1 > v2 then
      return 1;
    end
  end

  return 0;
end

--========================================================================
--版本更新类

--语言类型
LanguageType =
  {
    cn		= 'cn';		--大陆
    tw		= 'tw';		--台湾
  };

VersionUpdate =
  {
    EnabelUpdate		= true;				--更新开关

    --win32下暂时不更新
    testmode			= false;			--测试开关
    localGameVersion	= nil;				--本地游戏版本
    version				= nil;				--版本数据
    versionIndex		= -1;				--版本索引
    successName			= 'success.dat';	--文件名
    urlIndex			= 1;				--url地址索引
    serverUrl			= nil;
    urlAddress			= {};		--url地址
    route				= nil;				--路由地址
    appUrl				= nil;				--app更新地址
    pkgUrl				= nil;				--pkg更新地址

    gameInitFinished	= false;			--游戏初始化完成
    sdkLoginFinished	= false;			--sdk登陆完成

    curLanguage			= LanguageType.cn;	--当前语言标示

  };


  if not debugandroid and platformSDK.m_System == "Win32" then
    VersionUpdate.EnabelUpdate = false;
  end

--初始化
function VersionUpdate:Init()

  self.gameInitFinished = false;
  self.sdkLoginFinished = false;

  --pkg包是否已经复制，设置加载pkg包里面的自动更新内容
  local loadAPKUpdate = true;		--默认从安装包中加载
  local successFileName = appFramework:GetDocumentPath() .. self.successName;
  local filePath = appFramework:GetDocumentPath() .. appFramework:GetPKGFileName() .. '.pkg';

  if OperationSystem.IsPathExist(successFileName) and OperationSystem.IsPathExist(filePath) then

    if platformSDK.m_System == "Android" then
      --获取zip包中版本
      local fileContent = appFramework:GetAppFileContent('assets/version.txt');
      local apkVersion = StringUtil.Split(fileContent, '.');

      --获取本地版本
      local localVersion = StringUtil.Split( fileSystem:GetMaxFileVersion(filePath), '.' );

      --比较包和本地版本
      if VersionCompareFunc(localVersion, apkVersion) == 1 then
        loadAPKUpdate = false;
      end
    elseif platformSDK.m_System == "iOS" then
      --获取包中版本
      local fileContent = appFramework:GetAppFileContent( 'version.txt' );
      local apkVersion = StringUtil.Split(fileContent, '.');

      --获取本地版本
      local localVersion = StringUtil.Split( fileSystem:GetMaxFileVersion(filePath), '.' );

      --比较包和本地版本
      if VersionCompareFunc(localVersion, apkVersion) == 1 then
        loadAPKUpdate = false;
      end
    end

  end

  if loadAPKUpdate then
    --从安装包中加载versionUpdate实现
    if platformSDK.m_System == "Android" then
      appFramework:DoScriptFile('assets/language/language_' .. self.curLanguage .. '.lua');
      appFramework:DoScriptFile('assets/versionUpdate.lua');

    elseif platformSDK.m_System == "iOS" then
      appFramework:DoScriptFile( appFramework:GetAppPath() .. 'language/language_' .. self.curLanguage .. '.lua');
      appFramework:DoScriptFile( appFramework:GetAppPath() .. 'versionUpdate.lua' );
    else  -- Win32 默认是用测试接口，多语言
      if VersionUpdate.testmode == true then  -- 程序开发使用
        local languageFileName = '../langResource/'.. self.curLanguage ..'/language/language_' .. self.curLanguage .. '.lua';
        appFramework:DoScriptFile(languageFileName);
      else --美术策划release用的
        appFramework:DoScriptFile('language/language_' .. self.curLanguage .. '.lua');
      end
      appFramework:DoScriptFile('versionUpdate.lua');
    end
  else
    --从PKG中加载
    fileSystem:Load(appFramework:GetDocumentPath(), appFramework:GetPKGFileName(), FileVersion.ms_InvalidFileVersion);
    uiSystem:SetWorkingPath('');

    appFramework:DoScriptFile('language/language_' .. self.curLanguage .. '.lua');
    appFramework:DoScriptFile('versionUpdate.lua');
  end

  --具体实现
  VersionUpdate:initImp();

end
