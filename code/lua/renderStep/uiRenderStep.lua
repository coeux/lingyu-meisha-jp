--uiRenderStep.lua

--UI渲染步骤
UIRenderStep = {};

local uiIndex = -1;		--UI触控索引(UI只允许单一点击)

local startPoint;			--滑动开始点
local prePoint;				--上一点

local touchTail;

--初始化
function UIRenderStep:Init()
   local renderStep = appFramework:CreateScriptRenderStep('uiStep');
   renderStep.Priority = 2;
   renderStep:SetUpdateFunc(UIRenderStep, 'UIRenderStep:Update');
   renderStep:SetRenderFunc(UIRenderStep, 'UIRenderStep:Render');
   renderStep:SetTouchBeganFunc(UIRenderStep, 'UIRenderStep:TouchBegan');
   renderStep:SetTouchMovedFunc(UIRenderStep, 'UIRenderStep:TouchMoved');
   renderStep:SetTouchEndedFunc(UIRenderStep, 'UIRenderStep:TouchEnded');
   renderStep:SetTouchCancelledFunc(UIRenderStep, 'UIRenderStep:TouchCancelled');
end

--销毁
function UIRenderStep:Destroy()
   appFramework:DestroyRenderStep('uiStep');
end

--更新
function UIRenderStep:Update( Elapse )
   uiSystem:Update(Elapse);
end

--渲染
function UIRenderStep:Render()
   uiSystem:Render();
end

--触控开始
function UIRenderStep:TouchBegan( touch, event )
--[[   
   local pt = touch:LocationInView();							--屏幕坐标

   local ctrl = uiSystem:PickControl(pt.x, pt.y)
   print("ctrl = " .. ctrl.Name)--]]

   if touch.ID > 0 then return false end --多点屏蔽
   
   self.index = touch.ID;
   if index == 1 then
      return false;
   end
	--local pt = touch:LocationInView();							--屏幕坐标
    --local ctrl = uiSystem:PickControl(pt.x, pt.y)
    --print("ui-ctrl = " .. ctrl.Name)

   --local pt = touch:LocationInView();							--屏幕坐标

   --local ctrl = uiSystem:PickControl(pt.x, pt.y)
   --print("ctrl = " .. ctrl.Name)

   if uiIndex == -1 and uiSystem:TouchBegan(touch, event) then
      uiIndex = touch.ID;

      if FightManager.state ~= FightState.none then						--战斗状态
         local pt = touch:LocationInView();							--屏幕坐标
         local uiCamera = FightManager.desktop.Camera;				--ui相机
         startPoint = uiCamera:ScreenToWorldPT(pt);

         if (FightState.pauseState == FightManager.state) and (FightQTEManager.isHeartAppear) then			--QTE状态
            prePoint = startPoint;

            if FightQTEManager:GetState() == 4 then
               FightQTEManager:EndPassQTE();							--触发开始QTE
            end
         end
      end

	  --[[
      if RuneHuntPanel.isHunt and not RuneHuntPanel.isAutoHunt then
         touchID = touch.ID;
         local pt = touch:LocationInView();

         --全屏手势技能
         local uiPT = bottomDesktop.Camera:ScreenToWorldPT(pt);
         touchTail:Push(uiPT);

         RuneManager:SetTouchBeganPoint( uiPT );
      end
	  --]]

      return true;
   end

   return false;
end

--触控移动
function UIRenderStep:TouchMoved( touch, event )
   if self.index == 1 then
      return false;
   end

   if uiIndex == touch.ID then

      if FightManager.state ~= FightState.none then						--战斗状态
         local pt = touch:LocationInView();							--屏幕坐标
         local uiCamera = FightManager.desktop.Camera;				--ui相机
         local curPoint = uiCamera:ScreenToWorldPT(pt);				--当前坐标点

         if (FightState.pauseState == FightManager.state) and (FightQTEManager.isHeartAppear) then			--QTE状态
            if (FightQTEManager:GetState() == 4) then
               FightQTEManager:EndPassQTE();							--触发开始QTE
               startPoint = curPoint;
            else
               --判断是否转折
               if (curPoint.x >= prePoint.x) ~= (curPoint.x >= startPoint.x) then
                  FightQTEManager:PlayScratchTraceEffect(startPoint, curPoint);		--播放滑动轨迹特效

                  if RectContainLine(startPoint, curPoint, FightQTEManager:GetRect()) then
                     FightQTEManager:ScratchHeart();					--滑到心脏，连击次数，伤血更新
                  end

                  if curPoint.x >= prePoint.x then					--左滑
                     PlaySound('swipe1');
                  else												--右滑
                     PlaySound('swipe2');
                  end

                  startPoint = curPoint;
               end
            end

            prePoint = curPoint;										--更换上次滑动的坐标点
         end
      end

	  --[[
      if RuneHuntPanel.isHunt and not RuneHuntPanel.isAutoHunt then
         if touchID == touch.ID then
            local pt = touch:LocationInView();

            --滑动全屏技能
            local uiPT = bottomDesktop.Camera:ScreenToWorldPT(pt);
            touchTail:Push(uiPT);

            RuneManager:TouchMove( uiPT );
         end
      end
	  --]]

      return uiSystem:TouchMoved(touch, event);
   end

   return false;
end

--触控结束
function UIRenderStep:TouchEnded( touch, event )

   if uiIndex == touch.ID then

      if FightManager.state ~= FightState.none then								--战斗状态
         local pt = touch:LocationInView();									--屏幕坐标
         local uiCamera = FightManager.desktop.Camera;						--ui相机
         local curPoint = uiCamera:ScreenToWorldPT(pt);						--当前坐标点

         if (FightState.pauseState == FightManager.state) and (FightQTEManager.isHeartAppear) then			--QTE状态
            FightQTEManager:PlayScratchTraceEffect(startPoint, curPoint);		--播放滑动轨迹特效

            if RectContainLine(startPoint, curPoint, FightQTEManager:GetRect()) then
               FightQTEManager:ScratchHeart();									--滑到心脏，连击次数，伤血更新
            end
         end
      end

	  --[[
      if RuneHuntPanel.isHunt then
         if touchID == touch.ID then
            --重置
            touchID = -1;
         end

         local pt = touch:LocationInView();
         local uiPT = bottomDesktop.Camera:ScreenToWorldPT(pt);
      end
	  --]]

      uiIndex = -1;
      return uiSystem:TouchEnded(touch, event);
   end

   uiIndex = -1;
   return false;
end

--触控取消
function UIRenderStep:TouchCancelled( touch, event )
   if uiIndex == touch.ID then
      return uiSystem:TouchCancelled(touch, event);
   end

   return false;
end

--创建拖尾效果
function UIRenderStep:CreateTouchTail(panel)
   --创建拖尾效果
   touchTail = uiSystem:CreateControl('TouchTail');
   touchTail.ZOrder = 1;
   panel:AddChild(touchTail);
   touchTail.MaxLife = 0.3;

   touchTail:SetImage( GlobalData:GetResDir() .. 'resource/other/touchtail.ccz', Rect(0, 0, 128, 16) );
end
