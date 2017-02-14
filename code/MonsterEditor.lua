
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

local desktop = nil;
--default account(董)
account_config = {
  user_name = 'abcd12345';
  server_port = 41104;
}
VersionUpdate = {}

local sceneID = 1001

local uiIndex = -1;		--UI触控索引(UI只允许单一点击)
--设置桌面尺寸
function SetDesktopSize( desktop )

  local uiCamera = desktop.Camera;
  local radio = appFramework.ScreenWidth / appFramework.ScreenHeight;
  local orthographicSize;

  if radio < 1.5 then
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
--
--初始化
function Init()
  --设置背景色
  --SetDesktopSize(desktop);

  appFramework:DoScriptFile('language/language_cn.lua');
  RecursivelyLoadLuaScript('lua/base/', false);
  RecursivelyLoadLuaScript('lua/', false);

  ResTable:Init();
  AvatarManager:Init();


  Game:AddState(GameState.runningState, Editor);
  Game:SwitchState(GameState.runningState);
end


Editor = {
  monster_ids = {};
}

function Editor:onEnter()
end

function Editor:Init()
  appFramework:SetClearColor( Color.Black );

  --手机上设置强制聚焦
  uiSystem.Focusable = true;

  --win下初始化窗口大小
  if platformSDK.m_System == "Win32" then
    --local width = 960 * 1.5;
    --local height = 640 * 1.5;

    local width = 1600
    local height = 280
    ChangeWinSize(width, height);
    uiSystem:Resize(width, height);
  end

  --版本更新初始化

  renderer.AsyncLoadFlag = false;
  local renderStep = appFramework:CreateScriptRenderStep('Monster');
  renderStep.Priority = 0;
  renderStep:SetUpdateFunc(Editor, 'Editor:Update');
  renderStep:SetRenderFunc(Editor, 'Editor:Render');
  renderStep:SetTouchBeganFunc(Editor, 'Editor:TouchBegan');
  renderStep:SetTouchMovedFunc(Editor, 'Editor:TouchMoved');
  renderStep:SetTouchEndedFunc(Editor, 'Editor:TouchEnded');
  renderStep:SetTouchCancelledFunc(Editor, 'Editor:TouchCancelled');

  uiSystem:SetWorkingPath('tools/MonsterEditor/');
  uiSystem:LoadResourceXML('Monster.res');
  uiSystem:LoadSchemeXML('Monster.lay');

  desktop = uiSystem:GetDesktop('Monster');
  uiSystem:SwitchToDesktop(desktop);

	SceneRenderStep:Init();	
	BottomRenderStep:Init();
	UIRenderStep:Init();
	TopRenderStep:Init();

  self:changeToScene(1001);

  self:initTables();
end

function Editor:initTables()
  self.rounds = {}
  self.monsters = {}
  local roundTableId = 20001;
  local monsterTableId = 20002;

	resTableManager:LoadTable(roundTableId, 'table/round.txt', '');
	local rowNum = resTableManager:GetRowNum(roundTableId);
	
	for i = 1, rowNum do
		local id = resTableManager:GetValue(roundTableId, i-1, 'id');
    table.insert(self.rounds, id);
  end

	resTableManager:LoadTable(monsterTableId, 'table/monster.txt', '');
	local rowNum = resTableManager:GetRowNum(monsterTableId);
	
	for i = 1, rowNum do
		local monsterData = resTableManager:GetValue(monsterTableId, i-1, {'id', 'img'});
    local id = tostring(monsterData['id']);
    local name = monsterData['img']
    self.monsters[ id ] = name;
  end


end

function Editor:changeToScene(id)
  sceneID = id;
  scene = SceneManager:LoadFightScene(sceneID);
  SceneManager:SetActiveScene(scene);
end

function Editor:Update(Elapse)
  uiSystem:Update(Elapse);
  SceneManager:Update(Elapse);
  EffectManager:Update(Elapse);
end


function Editor:Render()
  uiSystem:Render();
end

function Editor:TouchBegan( touch, event )
  if uiSystem:TouchBegan(touch, event) then
    uiIndex = touch.ID;
    return true;
  end

  return false;
end

function Editor:TouchMoved( touch, event )
  if uiIndex == touch.ID then
    return uiSystem:TouchMoved(touch, event);
  end

  return false;
end

function Editor:TouchEnded( touch, event )

  local monsterid = desktop:GetLogicChild('monsterID').Text
  if not monsterid or #monsterid == 0 or not self.monsters[monsterid] then
    print("error" .. monsterid)
  else

    name = self.monsters[monsterid];
    local pt = touch:LocationInView();
    local camera = sceneManager.ActiveScene.Camera;
    local origin = Vector3();
    local dir = Vector3();
    camera:ScreenPTToRay(pt.x, pt.y, origin, dir);

    local y = origin.y;
    local x = origin.x;
    x,y = VerifyScenePos(MainUI:GetSceneType(), x, y);
    print(y)

    local scene = SceneManager:GetActiveScene();
    local pos = Vector2(math.floor(x), math.floor(y));


    local path = GlobalData.AnimationPath .. name .. '_output/';
    AvatarManager:LoadFile(path);
    local info = {level = 1; actorType = ActorType.monster}
    local actor		= ActorManager:CreateMFighter(monsterid, info);
    actor:SetPosition (Vector3(x, y, 0))
    actor:LoadArmature(name);
    actor:SetScale(-1, 1, 1);
    actor:SetAnimation(AnimationType.f_run);
    --创建新玩家

    scene:AddSceneNode(actor);								--添加到场景中,之后角色更新跟随场景更新

    function getIndex(y)
      local yOrderList         = Configuration.YOrderList;
      local delta = yOrderList[1] - yOrderList[2];
      if y > yOrderList[1] - delta then
        return 1
      elseif y > yOrderList[2] - delta then
        return 2
      elseif y > yOrderList[3] - delta then
        return 3
      elseif y > yOrderList[4] - delta then
        return 4
      else
        return 5;
      end
    end

    table.insert(self.monster_ids, {id = monsterid, posx = math.floor(x), posy = getIndex(y)});

    --self:printArray();
  end

  if uiIndex == touch.ID then
    return uiSystem:TouchEnded(touch, event);
  end

  return false;
end

function Editor:TouchCancelled( touch, event )
  if uiIndex == touch.ID then
    return uiSystem:TouchCancelled(touch, event);
  end

  return false;
end

function Editor:OnChangeScene()
  local id = desktop:GetLogicChild('sceneID').Text
  self:changeToScene(tonumber(id))
end

function Editor:printArray()
  local output = io.open("monster_info.txt", "a")


  local ids = {}

  local monster_str = "[";
  for _, v in ipairs(self.monster_ids) do 
    ids[v.id] = true;
    monster_str = monster_str .. "[" .. v.id .. "," .. v.posx .. "," .. v.posy .. "],";
  end
  monster_str = string.gsub(monster_str, ",$", "]");


  local str = tostring(sceneID) .. ":\t" .. "[";
  for k, _ in pairs(ids) do
    str = str ..  k .. "," 
  end
  str = string.gsub(str, ",$", "]");

  output:write(str .. "\t");
  output:write(monster_str .. "\n")
  output:flush()
  output:close();
end
