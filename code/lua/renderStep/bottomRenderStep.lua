--bottomRenderStep.lua

--底层渲染步骤
BottomRenderStep = {};

bottomDesktop = {};

local uiIndex = -1;		--UI触控索引(UI只允许单一点击)
local touchBeginState = false;	--场景中鼠标点击事件是否有效
local touchEnable = true;		--拖尾是否有效开关

local prePoint;				--上一点
local touchTail;
local touchID = -1;
local recognizer = GeometricRecognizer();
local mouseGesturePoint = {}


--============================================================================
--添加圆

local path = Path2D();
path:push_back(Vector2(127, 141));
path:push_back(Vector2(124, 140));
path:push_back(Vector2(120, 139));
path:push_back(Vector2(118, 139));
path:push_back(Vector2(116, 139));
path:push_back(Vector2(111, 140));
path:push_back(Vector2(109, 141));
path:push_back(Vector2(104, 144));
path:push_back(Vector2(100, 147));
path:push_back(Vector2(96, 152));
path:push_back(Vector2(93, 157));
path:push_back(Vector2(90, 163));
path:push_back(Vector2(87, 169));
path:push_back(Vector2(85, 175));
path:push_back(Vector2(83, 181));
path:push_back(Vector2(82, 190));
path:push_back(Vector2(82, 195));
path:push_back(Vector2(83, 200));
path:push_back(Vector2(84, 205));
path:push_back(Vector2(88, 213));
path:push_back(Vector2(91, 216));
path:push_back(Vector2(96, 219));
path:push_back(Vector2(103, 222));
path:push_back(Vector2(108, 224));
path:push_back(Vector2(111, 224));
path:push_back(Vector2(120, 224));
path:push_back(Vector2(133, 223));
path:push_back(Vector2(142, 222));
path:push_back(Vector2(152, 218));
path:push_back(Vector2(160, 214));
path:push_back(Vector2(167, 210));
path:push_back(Vector2(173, 204));
path:push_back(Vector2(178, 198));
path:push_back(Vector2(179, 196));
path:push_back(Vector2(182, 188));
path:push_back(Vector2(182, 177));
path:push_back(Vector2(178, 167));
path:push_back(Vector2(170, 150));
path:push_back(Vector2(163, 138));
path:push_back(Vector2(152, 130));
path:push_back(Vector2(143, 129));
path:push_back(Vector2(140, 131));
path:push_back(Vector2(129, 136));
path:push_back(Vector2(126, 139));

recognizer:addTemplate('Circle', path);
path:clear();

path:push_back(Vector2(126, 139));
path:push_back(Vector2(129, 136));
path:push_back(Vector2(140, 131));
path:push_back(Vector2(143, 129));
path:push_back(Vector2(152, 130));
path:push_back(Vector2(163, 138));
path:push_back(Vector2(170, 150));
path:push_back(Vector2(178, 167));
path:push_back(Vector2(182, 177));
path:push_back(Vector2(182, 188));
path:push_back(Vector2(179, 196));
path:push_back(Vector2(178, 198));
path:push_back(Vector2(173, 204));
path:push_back(Vector2(167, 210));
path:push_back(Vector2(160, 214));
path:push_back(Vector2(152, 218));
path:push_back(Vector2(142, 222));
path:push_back(Vector2(133, 223));
path:push_back(Vector2(120, 224));
path:push_back(Vector2(111, 224));
path:push_back(Vector2(108, 224));
path:push_back(Vector2(103, 222));
path:push_back(Vector2(96, 219));
path:push_back(Vector2(91, 216));
path:push_back(Vector2(88, 213));
path:push_back(Vector2(84, 205));
path:push_back(Vector2(83, 200));
path:push_back(Vector2(82, 195));
path:push_back(Vector2(82, 190));
path:push_back(Vector2(83, 181));
path:push_back(Vector2(85, 175));
path:push_back(Vector2(87, 169));
path:push_back(Vector2(90, 163));
path:push_back(Vector2(93, 157));
path:push_back(Vector2(96, 152));
path:push_back(Vector2(100, 147));
path:push_back(Vector2(104, 144));
path:push_back(Vector2(109, 141));
path:push_back(Vector2(111, 140));
path:push_back(Vector2(116, 139));
path:push_back(Vector2(118, 139));
path:push_back(Vector2(120, 139));
path:push_back(Vector2(124, 140));
path:push_back(Vector2(127, 141));

recognizer:addTemplate('Circle', path);
path:clear();

path:push_back(Vector2(127,141));
path:push_back(Vector2(124,140));
path:push_back(Vector2(120,139));
path:push_back(Vector2(118,139));
path:push_back(Vector2(116,139));
path:push_back(Vector2(111,140));
path:push_back(Vector2(109,141));
path:push_back(Vector2(104,144));
path:push_back(Vector2(100,147));
path:push_back(Vector2(96,152));
path:push_back(Vector2(93,157));
path:push_back(Vector2(90,163));
path:push_back(Vector2(87,169));
path:push_back(Vector2(85,175));
path:push_back(Vector2(83,181));
path:push_back(Vector2(82,190));
path:push_back(Vector2(82,195));
path:push_back(Vector2(83,200));
path:push_back(Vector2(84,205));
path:push_back(Vector2(88,213));
path:push_back(Vector2(91,216));
path:push_back(Vector2(96,219));
path:push_back(Vector2(103,222));
path:push_back(Vector2(108,224));
path:push_back(Vector2(111,224));
path:push_back(Vector2(120,224));
path:push_back(Vector2(133,223));
path:push_back(Vector2(142,222));
path:push_back(Vector2(152,218));
path:push_back(Vector2(160,214));
path:push_back(Vector2(167,210));
path:push_back(Vector2(173,204));
path:push_back(Vector2(178,198));
path:push_back(Vector2(179,196));
path:push_back(Vector2(182,188));
path:push_back(Vector2(182,177));
path:push_back(Vector2(178,167));
path:push_back(Vector2(170,150));
path:push_back(Vector2(163,138));
path:push_back(Vector2(152,130));
path:push_back(Vector2(143,129));
path:push_back(Vector2(140,131));
path:push_back(Vector2(129,136));
path:push_back(Vector2(126,139));
path:push_back(Vector2(127,141));
path:push_back(Vector2(124,140));
path:push_back(Vector2(120,139));
path:push_back(Vector2(118,139));
path:push_back(Vector2(116,139));
path:push_back(Vector2(111,140));
path:push_back(Vector2(109,141));
path:push_back(Vector2(104,144));
path:push_back(Vector2(100,147));
path:push_back(Vector2(96,152));
path:push_back(Vector2(93,157));
path:push_back(Vector2(90,163));
path:push_back(Vector2(87,169));
path:push_back(Vector2(85,175));
path:push_back(Vector2(83,181));
path:push_back(Vector2(82,190));
path:push_back(Vector2(82,195));
path:push_back(Vector2(83,200));
path:push_back(Vector2(84,205));
path:push_back(Vector2(88,213));
path:push_back(Vector2(91,216));
path:push_back(Vector2(96,219));
path:push_back(Vector2(103,222));

recognizer:addTemplate('Circle', path);
path:clear();

path:push_back(Vector2(126,139));
path:push_back(Vector2(129,136));
path:push_back(Vector2(140,131));
path:push_back(Vector2(143,129));
path:push_back(Vector2(152,130));
path:push_back(Vector2(163,138));
path:push_back(Vector2(170,150));
path:push_back(Vector2(178,167));
path:push_back(Vector2(182,177));
path:push_back(Vector2(182,188));
path:push_back(Vector2(179,196));
path:push_back(Vector2(178,198));
path:push_back(Vector2(173,204));
path:push_back(Vector2(167,210));
path:push_back(Vector2(160,214));
path:push_back(Vector2(152,218));
path:push_back(Vector2(142,222));
path:push_back(Vector2(133,223));
path:push_back(Vector2(120,224));
path:push_back(Vector2(111,224));
path:push_back(Vector2(108,224));
path:push_back(Vector2(103,222));
path:push_back(Vector2(96,219));
path:push_back(Vector2(91,216));
path:push_back(Vector2(88,213));
path:push_back(Vector2(84,205));
path:push_back(Vector2(83,200));
path:push_back(Vector2(82,195));
path:push_back(Vector2(82,190));
path:push_back(Vector2(83,181));
path:push_back(Vector2(85,175));
path:push_back(Vector2(87,169));
path:push_back(Vector2(90,163));
path:push_back(Vector2(93,157));
path:push_back(Vector2(96,152));
path:push_back(Vector2(100,147));
path:push_back(Vector2(104,144));
path:push_back(Vector2(109,141));
path:push_back(Vector2(111,140));
path:push_back(Vector2(116,139));
path:push_back(Vector2(118,139));
path:push_back(Vector2(120,139));
path:push_back(Vector2(124,140));
path:push_back(Vector2(127,141));
path:push_back(Vector2(126,139));
path:push_back(Vector2(129,136));
path:push_back(Vector2(140,131));
path:push_back(Vector2(143,129));
path:push_back(Vector2(152,130));
path:push_back(Vector2(163,138));
path:push_back(Vector2(170,150));
path:push_back(Vector2(178,167));
path:push_back(Vector2(182,177));
path:push_back(Vector2(182,188));
path:push_back(Vector2(179,196));
path:push_back(Vector2(178,198));
path:push_back(Vector2(173,204));
path:push_back(Vector2(167,210));
path:push_back(Vector2(160,214));
path:push_back(Vector2(152,218));

recognizer:addTemplate('Circle', path);
path:clear();

--============================================================================
--添加闪电

path:push_back(Vector2(100,200));
path:push_back(Vector2(100,195));
path:push_back(Vector2(100,190));
path:push_back(Vector2(100,185));
path:push_back(Vector2(100,180));
path:push_back(Vector2(100,175));
path:push_back(Vector2(100,170));
path:push_back(Vector2(100,165));
path:push_back(Vector2(100,160));
path:push_back(Vector2(100,155));
path:push_back(Vector2(100,150));
path:push_back(Vector2(100,145));
path:push_back(Vector2(100,140));
path:push_back(Vector2(100,135));
path:push_back(Vector2(100,130));
path:push_back(Vector2(100,125));
path:push_back(Vector2(100,120));
path:push_back(Vector2(100,115));
path:push_back(Vector2(100,110));
path:push_back(Vector2(100,105));
path:push_back(Vector2(100,100));

recognizer:addTemplate('Lighting', path);
path:clear();

path:push_back(Vector2(200,400));
path:push_back(Vector2(202,390));
path:push_back(Vector2(204,380));
path:push_back(Vector2(206,370));
path:push_back(Vector2(208,360));
path:push_back(Vector2(210,350));
path:push_back(Vector2(212,340));
path:push_back(Vector2(214,330));
path:push_back(Vector2(216,320));
path:push_back(Vector2(218,310));
path:push_back(Vector2(220,300));
path:push_back(Vector2(222,290));
path:push_back(Vector2(224,280));
path:push_back(Vector2(226,270));
path:push_back(Vector2(228,260));
path:push_back(Vector2(230,250));
path:push_back(Vector2(232,240));
path:push_back(Vector2(234,230));
path:push_back(Vector2(236,220));
path:push_back(Vector2(238,210));
path:push_back(Vector2(240,200));

recognizer:addTemplate('Lighting', path);
path:clear();

path:push_back(Vector2(200,400));
path:push_back(Vector2(198,390));
path:push_back(Vector2(196,380));
path:push_back(Vector2(194,370));
path:push_back(Vector2(192,360));
path:push_back(Vector2(190,350));
path:push_back(Vector2(188,340));
path:push_back(Vector2(186,330));
path:push_back(Vector2(184,320));
path:push_back(Vector2(182,310));
path:push_back(Vector2(180,300));
path:push_back(Vector2(178,290));
path:push_back(Vector2(176,280));
path:push_back(Vector2(174,270));
path:push_back(Vector2(172,260));
path:push_back(Vector2(170,250));
path:push_back(Vector2(168,240));
path:push_back(Vector2(166,230));
path:push_back(Vector2(164,220));
path:push_back(Vector2(162,210));
path:push_back(Vector2(160,200));

recognizer:addTemplate('Lighting', path);
path:clear();


--============================================================================
--添加V

path:push_back(Vector2(1, 21));
path:push_back(Vector2(2, 22));
path:push_back(Vector2(2, 23));
path:push_back(Vector2(3, 24));
path:push_back(Vector2(4, 25));
path:push_back(Vector2(4, 26));
path:push_back(Vector2(5, 27));
path:push_back(Vector2(5, 28));
path:push_back(Vector2(6, 29));
path:push_back(Vector2(7, 30));
path:push_back(Vector2(7, 31));
path:push_back(Vector2(8, 32));
path:push_back(Vector2(9, 33));
path:push_back(Vector2(10, 34));
path:push_back(Vector2(11, 35));
path:push_back(Vector2(11, 36));
path:push_back(Vector2(12, 37));
path:push_back(Vector2(13, 38));
path:push_back(Vector2(14, 39));
path:push_back(Vector2(15, 38));
path:push_back(Vector2(16, 37));
path:push_back(Vector2(17, 36));
path:push_back(Vector2(18, 35));
path:push_back(Vector2(19, 34));
path:push_back(Vector2(20, 33));
path:push_back(Vector2(21, 32));
path:push_back(Vector2(22, 31));
path:push_back(Vector2(23, 30));
path:push_back(Vector2(24, 29));
path:push_back(Vector2(25, 27));
path:push_back(Vector2(26, 26));
path:push_back(Vector2(27, 24));
path:push_back(Vector2(28, 23));
path:push_back(Vector2(29, 21));
path:push_back(Vector2(30, 20));
path:push_back(Vector2(31, 18));
path:push_back(Vector2(32, 17));
path:push_back(Vector2(33, 15));
path:push_back(Vector2(34, 14));
path:push_back(Vector2(35, 12));
path:push_back(Vector2(36, 11));
path:push_back(Vector2(37, 9));
path:push_back(Vector2(38, 8));
path:push_back(Vector2(39, 6));
path:push_back(Vector2(40, 5));

recognizer:addTemplate('V', path);
path:clear();

--============================================================================
--添加Z

path:push_back(Vector2(84, 145));
path:push_back(Vector2(90, 143));
path:push_back(Vector2(100, 148));
path:push_back(Vector2(110, 146));
path:push_back(Vector2(111, 141));
path:push_back(Vector2(119, 144));
path:push_back(Vector2(130, 145));
path:push_back(Vector2(139, 148));
path:push_back(Vector2(145, 147));
path:push_back(Vector2(160, 145));
path:push_back(Vector2(152, 153));
path:push_back(Vector2(140, 163));
path:push_back(Vector2(131, 172));
path:push_back(Vector2(121, 180));
path:push_back(Vector2(118, 188));
path:push_back(Vector2(108, 195));
path:push_back(Vector2(100, 200));
path:push_back(Vector2(91, 209));
path:push_back(Vector2(84, 214));
path:push_back(Vector2(91, 218));
path:push_back(Vector2(103, 211));
path:push_back(Vector2(110, 215));
path:push_back(Vector2(119, 213));
path:push_back(Vector2(125, 217));
path:push_back(Vector2(130, 214));
path:push_back(Vector2(140, 211));
path:push_back(Vector2(150, 212));
path:push_back(Vector2(160, 214));

recognizer:addTemplate('Z', path);
path:clear();

path:push_back(Vector2(84,115));
path:push_back(Vector2(90,118));
path:push_back(Vector2(100,122));
path:push_back(Vector2(110,124));
path:push_back(Vector2(111,127));
path:push_back(Vector2(119,130));
path:push_back(Vector2(130,134));
path:push_back(Vector2(139,138));
path:push_back(Vector2(145,142));
path:push_back(Vector2(160,145));
path:push_back(Vector2(152,153));
path:push_back(Vector2(140,163));
path:push_back(Vector2(131,172));
path:push_back(Vector2(121,180));
path:push_back(Vector2(118,188));
path:push_back(Vector2(108,195));
path:push_back(Vector2(100,200));
path:push_back(Vector2(91,209));
path:push_back(Vector2(84,214));
path:push_back(Vector2(91,218));
path:push_back(Vector2(103,218));
path:push_back(Vector2(110,215));
path:push_back(Vector2(119,213));
path:push_back(Vector2(125,217));
path:push_back(Vector2(130,214));
path:push_back(Vector2(140,211));
path:push_back(Vector2(150,212));
path:push_back(Vector2(160,214));

recognizer:addTemplate('Z', path);
path:clear();

path:push_back(Vector2(84,115));
path:push_back(Vector2(90,118));
path:push_back(Vector2(100,122));
path:push_back(Vector2(110,124));
path:push_back(Vector2(111,127));
path:push_back(Vector2(119,130));
path:push_back(Vector2(130,134));
path:push_back(Vector2(139,138));
path:push_back(Vector2(145,142));
path:push_back(Vector2(160,145));
path:push_back(Vector2(152,153));
path:push_back(Vector2(140,163));
path:push_back(Vector2(131,172));
path:push_back(Vector2(121,180));
path:push_back(Vector2(118,188));
path:push_back(Vector2(108,195));
path:push_back(Vector2(100,200));
path:push_back(Vector2(91,209));
path:push_back(Vector2(84,214));
path:push_back(Vector2(91,218));
path:push_back(Vector2(103,218));
path:push_back(Vector2(110,222));
path:push_back(Vector2(119,227));
path:push_back(Vector2(125,232));
path:push_back(Vector2(130,236));
path:push_back(Vector2(140,240));
path:push_back(Vector2(150,245));
path:push_back(Vector2(160,248));

recognizer:addTemplate('Z', path);
path:clear();

path:push_back(Vector2(84,145));
path:push_back(Vector2(90,143));
path:push_back(Vector2(100,148));
path:push_back(Vector2(110,146));
path:push_back(Vector2(111,141));
path:push_back(Vector2(119,144));
path:push_back(Vector2(130,145));
path:push_back(Vector2(139,148));
path:push_back(Vector2(145,147));
path:push_back(Vector2(160,145));
path:push_back(Vector2(152,153));
path:push_back(Vector2(140,163));
path:push_back(Vector2(131,172));
path:push_back(Vector2(121,180));
path:push_back(Vector2(118,188));
path:push_back(Vector2(108,195));
path:push_back(Vector2(100,200));
path:push_back(Vector2(91,209));
path:push_back(Vector2(84,214));
path:push_back(Vector2(91,218));
path:push_back(Vector2(103,218));
path:push_back(Vector2(110,222));
path:push_back(Vector2(119,227));
path:push_back(Vector2(125,232));
path:push_back(Vector2(130,236));
path:push_back(Vector2(140,240));
path:push_back(Vector2(150,245));
path:push_back(Vector2(160,248));

recognizer:addTemplate('Z', path);
path:clear();


--============================================================================
--============================================================================


--初始化
function BottomRenderStep:Init()
	local renderStep = appFramework:CreateScriptRenderStep('bottomStep');
	renderStep.Priority = 1;
	renderStep:SetUpdateFunc(BottomRenderStep, 'BottomRenderStep:Update');
	renderStep:SetRenderFunc(BottomRenderStep, 'BottomRenderStep:Render');
	renderStep:SetTouchBeganFunc(BottomRenderStep, 'BottomRenderStep:TouchBegan');
	renderStep:SetTouchMovedFunc(BottomRenderStep, 'BottomRenderStep:TouchMoved');
	renderStep:SetTouchEndedFunc(BottomRenderStep, 'BottomRenderStep:TouchEnded');
	renderStep:SetTouchCancelledFunc(BottomRenderStep, 'BottomRenderStep:TouchCancelled');
	
	bottomDesktop = Desktop( uiSystem:CreateControl('Desktop') );
	bottomDesktop.Name = 'bottom';
	uiSystem:AddDesktop(bottomDesktop);
	
	SetDesktopSize(bottomDesktop);
end

--销毁
function BottomRenderStep:Destroy()
	uiSystem:DestroyControl(bottomDesktop);
	appFramework:DestroyRenderStep('bottomStep');
end

--更新
function BottomRenderStep:Update( Elapse )
	--print('Elapse' .. Elapse)
	bottomDesktop:arrange();
	bottomDesktop:Update(Elapse);
end

--渲染
function BottomRenderStep:Render()
	renderer:ClearRenderList();
	renderer:SetQueuingFlag(true);
	bottomDesktop:Render(1);
	renderer:SetActiveCamera(bottomDesktop.Camera);
	renderer:Render();
end

--触控开始
function BottomRenderStep:TouchBegan( touch, event )

	if touch.ID > 0 then return false end --多点屏蔽
	
	self:SetTouchBeginState(true);
	
	if uiIndex == -1 and bottomDesktop:TouchBegan(touch, event) then
		uiIndex = touch.ID;	
		return true;
	end
	
	if Game:GetCurState() == GameState.runningState and FightManager.state ~= FightState.none then				--处于战斗状态
		if not FightManager.isOver then
			touchID = touch.ID;
			local pt = touch:LocationInView();
			
			--全屏手势技能
			local uiPT = bottomDesktop.Camera:ScreenToWorldPT(pt);
			if touchEnable then
				touchTail:Push(uiPT);
			end
			
			recognizer:ClearGesturePoint();					--清空手势路径点
			mouseGesturePoint = {}

			local camera = sceneManager.ActiveScene.Camera;
			local origin = Vector3();
			local dir = Vector3();
			camera:ScreenPTToRay(pt.x, pt.y, origin, dir);
			
			--英雄技能滑动
			prePoint = origin;
			--FightSkillCardManager:onScratchSkill(prePoint, nil);

      --手动选取目标
      FightManager:AddTag(origin.x, origin.y);

			return true;
		end
	end
	
	return false;

end

--触控移动
function BottomRenderStep:TouchMoved( touch, event )
		
	if uiIndex == touch.ID or not touchBeginState then
		return bottomDesktop:TouchMoved(touch, event);
	end

	if  Game:GetCurState() == GameState.runningState and FightManager.state ~= FightManager.none then
		if (not FightManager.isOver) then
			if touchID == touch.ID then
				local pt = touch:LocationInView();				
				
				--滑动全屏技能
				local uiPT = bottomDesktop.Camera:ScreenToWorldPT(pt);
				if touchEnable then
					touchTail:Push(uiPT);
				end
				
				local camera = sceneManager.ActiveScene.Camera;
				local origin = Vector3();
				local dir = Vector3();
				camera:ScreenPTToRay(pt.x, pt.y, origin, dir);

				--记录鼠标移动轨迹
				recognizer:AddGesturePoint(pt.x, pt.y);				--添加路径点
				table.insert(mouseGesturePoint, {pt.x, pt.y});
				
				--英雄技能滑动
				--FightSkillCardManager:onScratchSkill(prePoint, origin);
				prePoint = origin;
				
				return true;
			end
		end
	end
	
	return false;

end

--触控结束
function BottomRenderStep:TouchEnded( touch, event )
	
	if uiIndex == touch.ID or not touchBeginState then
		uiIndex = -1;
		return bottomDesktop:TouchEnded(touch, event);
	end

	if  Game:GetCurState() == GameState.runningState and FightManager.state ~= FightManager.none then
		if (not FightManager.isOver) then
			if touchID == touch.ID then
				local pt = touch:LocationInView();
				local camera = sceneManager.ActiveScene.Camera;
				local origin = Vector3();
				local dir = Vector3();
				camera:ScreenPTToRay(pt.x, pt.y, origin, dir);
				
				--滑动全屏技能
				local gesture = recognizer:RecognizeGesture();		--计算手势形状		
				if GestureType.Unknown ~= gesture.name then
					if (GestureType.V == gesture.name) and (gesture.score < 0.85) then

                    elseif (GestureType.Lighting == gesture.name)then
						local lightingEnable = self:JudgeLighting();
						if lightingEnable then
							FightUIManager:RunGestureSkill(gesture.name);
						end								
					elseif gesture.score >= 0.75 then
						FightUIManager:RunGestureSkill(gesture.name);
					end
				end
				
				--英雄技能滑动
				--FightSkillCardManager:onScratchSkill(prePoint, origin);
				prePoint = origin;
				
				--重置
				touchID = -1;
				
				return true;
			end
		end
	end
	
	return false;
end

function BottomRenderStep:JudgeLighting()
	local firstPt, middlePt, lastPt;
	local totoalPtNum = #mouseGesturePoint;
	
	if totoalPtNum < 3 then
		return false;
	end
	
	firstPt = mouseGesturePoint[1];
	lastPt = mouseGesturePoint[totoalPtNum];
	middlePt = mouseGesturePoint[math.floor(totoalPtNum/2)];
	
	local x1 = firstPt[1];
	local y1 = firstPt[2];
	local x2 = middlePt[1];
	local y2 = middlePt[2];
	local x3 = lastPt[1];
	local y3 = lastPt[2];
	
	-- 判断是不是从上往下滑动
	
	if y1 > y3 then    -- 从下往上滑动
		return false;
	end
	
	-- 判断距离
	if y3 - y1 < appFramework.ScreenHeight/5 then
		return false;
	end
	
	-- 判断滑动的角度  1/sqrt(3)
	if math.abs((x3-x1)/(y3-y1)) >  0.57737 then
		return false;
	end
	
	
	return true;
end

--触控取消
function BottomRenderStep:TouchCancelled( touch, event )
	touchID = -1;

	if uiIndex == touch.ID then
		uiIndex = -1;
		return bottomDesktop:TouchCancelled(touch, event);
	end

	return false;
end

--清空保存的鼠标事件ID
function BottomRenderStep:SetTouchBeginState(flag)
	touchBeginState = flag;
end

--拖尾是否有效
function BottomRenderStep:SetTouchEnable( flag )
	touchEnable = flag;
end

--创建拖尾效果
function BottomRenderStep:CreateTouchTail(desktop)
	--创建拖尾效果
	touchTail = uiSystem:CreateControl('TouchTail');
	desktop:AddChild(touchTail);
	touchTail.MaxLife = 0.3;
	touchTail:SetImage( GlobalData:GetResDir() .. 'resource/other/touchtail.ccz', Rect(0, 0, 128, 16) );
end
