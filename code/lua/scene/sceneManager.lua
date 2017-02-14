--sceneManager.lua

--========================================================================
--场景管理类

SceneManager =
  {
    curScene = nil;					--当前场景
    sceneList = {};					--场景列表
  }

--更新
function SceneManager:Update( Elapse )
  if self.curScene ~= nil then
    self.curScene:Update(Elapse);
  end
end

--加载场景
function SceneManager:LoadMainScene( sceneID )

  local scene = LuaMainScene.new(sceneID);


  sceneManager:AddScene( scene:GetCppObject() );
  self.sceneList[scene] = true;
  return scene

end


--加载Boss场景
function SceneManager:LoadBossScene( sceneID )

  local scene = LuaBossScene.new(sceneID);

  sceneManager:AddScene( scene:GetCppObject() );
  self.sceneList[scene] = true;
  return scene

end

--加载公会场景
function SceneManager:LoadUnionScene( sceneID )
  local scene = LuaUnionScene.new(sceneID);

  sceneManager:AddScene( scene:GetCppObject() );
  self.sceneList[scene] = true;
  return scene
end

--加载乱斗场场景
function SceneManager:LoadScuffleScene( sceneID )
  local scene = ScuffleScene.new(sceneID);

  sceneManager:AddScene( scene:GetCppObject() );
  self.sceneList[scene] = true;
  return scene
end

--加载剧情场景
function SceneManager:LoadPlotScene( sceneID )
  local scene = PlotScene.new(sceneID);

  sceneManager:AddScene( scene:GetCppObject() );
  self.sceneList[scene] = true;
  return scene
end

--加载战斗场景
function SceneManager:LoadFightScene( sceneID )
  local scene = LuaFightScene.new(sceneID);
  sceneManager:AddScene( scene:GetCppObject() );
  self.sceneList[scene] = true;
  return scene
end

--删除场景
function SceneManager:RemoveScene( scene )
  if nil == scene then
    return;
  end

  if scene == self.curScene then
    self:SetActiveScene(nil);
  end

  sceneManager:RemoveScene( scene:GetCppObject() );

  self.sceneList[scene] = nil;
  scene:Destroy();
end

--获取活动场景
function SceneManager:GetActiveScene()
  return self.curScene;
end

--设置活动场景
function SceneManager:SetActiveScene( scene )
  if self.curScene and self.curScene.Leave then
    self.curScene:Leave();
  end

  self.curScene = scene;

  if scene == nil then
    sceneManager.ActiveScene = nil;
    return
  end

  if self.curScene and self.curScene.Enter then
    self.curScene:Enter();
  end

  sceneManager.ActiveScene = scene:GetCppObject();

  local camera = sceneManager.ActiveScene.Camera;

  local radio = appFramework.ScreenWidth / appFramework.ScreenHeight;

  local visualHeight = scene.height;
  local visualWidth = scene.width;

  local rate = 2;
  if scene.isMainScene then
    visualHeight = 640;
    visualWidth = radio * visualHeight;
    rate = 2 * 1.35; --主城中人物扩大到1.35倍
  end

  local width = radio * visualHeight;
  local winWidth = width / rate;
  local winHeight = visualHeight / rate;

  camera.ViewFrustum = Frustum(-winWidth, winWidth, -winHeight, winHeight, 1, 100, true);

  if ActorManager.hero and (scene.isMainScene or scene.isUnionScene) then
    ActorManager.hero:SetStartPosition( ActorManager.hero:GetPosition() ) ;
  end
end
