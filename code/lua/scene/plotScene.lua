--plotScene.lua

--========================================================================
--依赖

LoadLuaFile("lua/scene/scene.lua");

--========================================================================
--========================================================================
--剧情场景

PlotScene = class(LuaScene);

local scene;

--初始化
function PlotScene:constructor( resID )

	self.width = GlobalData.MainSceneLogicWidth;					--宽度
	self.height = GlobalData.MainSceneLogicHeight;					--高度
	
	self.npcList = {};	

	local fileName = GlobalData:GetResDir() .. resTableManager:GetValue(ResTable.scene, self.resID, 'source');
	
	--背景图（1448*480 =》 1024*1024）
	--切分成2个区域（0,0,1024,480）和（0,480,424,960）
	local sprite = Sprite( sceneManager:CreateSceneNode('Sprite') );
	sprite:SetImage( fileName, Rect(0, 0, 1024, 480) );
	sprite.ZOrder = FightZOrderList.bottom;	--设置在最底层
	sprite.Translate = Vector3(-212, 0, 0);
	self:GetRootCppObject():AddChild(sprite);
	
	sprite = Sprite( sceneManager:CreateSceneNode('Sprite') );
	sprite:SetImage( fileName, Rect(0, 480, 424, 960) );
	sprite.ZOrder = FightZOrderList.bottom;	--设置在最底层
	sprite.Translate = Vector3(512, 0, 0);
	self:GetRootCppObject():AddChild(sprite);
	self:GetRootCppObject():SortChildren();
	self:InitCamera();
end	

--进入剧情场景
function PlotScene:onEnter()
	self.lastScene = SceneManager:GetActiveScene();
	scene = SceneManager:LoadPlotScene(SceneManager:GetActiveScene().resID);
	MainUI:SetSceneType(SceneType.Plot);
	SceneManager:SetActiveScene(scene);	
	bottomDesktop.Visibility = Visibility.Hidden;
	MainUI:HideMainUI();
end

--摄像头位置与主城一致
function PlotScene:InitCamera()
	local camera = self:GetCamera();
	local cameraPos = camera.Translate;

	local width = camera.ViewFrustum.Right;		--屏宽度的一半
	local sceneWidth = self.width * 0.5;
	local x = -300;	

	if x > 0 then
		if x + width > sceneWidth  then
			x = sceneWidth - width;
		end
	else
		if x - width < -sceneWidth then
			x = width - sceneWidth;
		end
	end
	
	camera.Translate = Vector3(x, cameraPos.y, cameraPos.z);
end

--退出剧情场景
function PlotScene:destroy()
	MainUI:SetSceneType(SceneType.MainCity);
	SceneManager:SetActiveScene(self.lastScene);		--恢复战斗前场景
	SceneManager:RemoveScene(scene);
	bottomDesktop.Visibility = Visibility.Visible;
	MainUI:ShowMainUI();
end
