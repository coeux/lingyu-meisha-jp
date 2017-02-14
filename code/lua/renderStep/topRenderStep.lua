--topRenderStep.lua

--顶层渲染步骤
TopRenderStep = {};

topDesktop = {};

local uiIndex = -1;		--UI触控索引(UI只允许单一点击)

local showTip = false;
local littleTip = false;
local fps;
local memory;
local uid;
local mask;
local hireall;
local input;

--初始化
function TopRenderStep:Init()

	local renderStep = appFramework:CreateScriptRenderStep('topStep');
	renderStep.Priority = 3;
	renderStep:SetUpdateFunc(TopRenderStep, 'TopRenderStep:Update');
	renderStep:SetRenderFunc(TopRenderStep, 'TopRenderStep:Render');
	renderStep:SetTouchBeganFunc(TopRenderStep, 'TopRenderStep:TouchBegan');
	renderStep:SetTouchMovedFunc(TopRenderStep, 'TopRenderStep:TouchMoved');
	renderStep:SetTouchEndedFunc(TopRenderStep, 'TopRenderStep:TouchEnded');
	renderStep:SetTouchCancelledFunc(TopRenderStep, 'TopRenderStep:TouchCancelled');
	
	topDesktop = Desktop( uiSystem:CreateControl('Desktop') );
	topDesktop.Name = 'top';
	uiSystem:AddDesktop(topDesktop);
	
	SetDesktopSize(topDesktop);
	
	if platformSDK.m_Platform == 'uc' or platformSDK.m_Platform == 'downjoy' then littleTip = false; end
	if littleTip then
		local tip = uiSystem:CreateControl('Button');
		tip.NormalBrush = Converter.String2Brush("EidolonSystem.DarkCyan")
		tip.CoverBrush = Converter.String2Brush("EidolonSystem.DarkCyan")
		tip.PressBrush = Converter.String2Brush("EidolonSystem.DarkOrange")
		tip:SetSize(60, 25)
		tip.Margin = Rect(10, 614, 0, 0);
		tip.Text = '错误报告';
		tip.Pick = true;
		tip.TextColor = QuadColor(Color.Black);
		tip.Font = uiSystem:FindFont('huakang_14_noborder');

		tip:SubscribeScriptedEvent('Button::ClickEvent', 'TopRenderStep:onReportDebugInfo');

		topDesktop:AddChild(tip);
	end

	if showTip or debugmode then
		--创建fps显示
		fps = uiSystem:CreateControl('TextElement');
		fps.Margin = Rect(20, 470, 0, 0);
		fps.Pick = false;
		fps.TextColor = QuadColor(Color.White);
		fps.Font = uiSystem:FindFont('huakang_13');
		topDesktop:AddChild(fps);
		
		--创建内、显存显示
		memory = uiSystem:CreateControl('Label');
		memory.Margin = Rect(20, 490, 0, 0);
		memory.Size = Size(200, 200);
		memory.Pick = false;
		memory.TextAlignStyle = TextFormat.TopLeft;
		memory.TextColor = QuadColor(Color.White);
		memory.Font = uiSystem:FindFont('huakang_13');
		topDesktop:AddChild(memory);

		uid = uiSystem:CreateControl('Label');
		uid.Margin = Rect(20, 450, 0, 0);
		uid.Size = Size(200, 200);
		uid.Pick = false;
		uid.TextAlignStyle = TextFormat.TopLeft;
		uid.TextColor = QuadColor(Color.White);
		uid.Font = uiSystem:FindFont('huakang_13');
		topDesktop:AddChild(uid);

		--[[
		hireall = uiSystem:CreateControl('Button');
		hireall.Horizontal = ControlLayout.H_RIGHT;
		hireall.Vertical = ControlLayout.V_TOP;
		hireall.Size = Size(200, 30);
		hireall.Font = uiSystem:FindFont('huakang_13');
		hireall.TextColor = QuadColor(Color.White);
		hireall.Text = "GM-雇佣伙伴";
  	hireall:SubscribeScriptedEvent('Button::ClickEvent', 'TopRenderStep:onReqHire');
		topDesktop:AddChild(hireall);
		--]]
	end
	
	mask = uiSystem:CreateControl('Panel');
	mask.Margin = Rect(0, 450, 0, 0);
	mask.Size = Size(4000, 2000);
	mask.HorizontalLayout = 'H_STRETCH';
	mask.VerticalLayout = 'V_STRETCH';
	mask.Visibility = Visibility.Hidden;
	topDesktop:AddChild(mask);
	
end

--销毁
function TopRenderStep:Destroy()
	uiSystem:DestroyControl(topDesktop);
	appFramework:DestroyRenderStep('topStep');
end

--[[
function TopRenderStep:onReqHire()
	local okDelegate = Delegate.new(TopRenderStep, TopRenderStep.onHire, 0);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, "GM:进入游戏后再点击,否则会坏掉,点击取消!", okDelegate, nil);
end
--]]



function TopRenderStep:onHire()
  Network:Send(NetworkCmdType.req_hire_all_partner, {});
	MessageBox:ShowDialog(MessageBoxType.Ok, "重新进入游戏即有ID 1~25 的伙伴!", nil);
end


--==========================================================
function TopRenderStep:onPlotTest() -- 策划用于测试剧情用
	if not showTip then return nil end;
	input = uiSystem:CreateControl('TextBox');
	input.Background = Converter.String2Brush("EidolonSystem.BlanchedAlmond");
	input.Size = Size(130, 30);
	input.Horizontal = ControlLayout.H_RIGHT;
	input.Vertical = ControlLayout.V_TOP;
	input.Margin = Rect(0, 30, 0, 0);
	input.TextColor = QuadColor(Color.White);

	local btn = uiSystem:CreateControl('Button');
	btn.Horizontal = ControlLayout.H_RIGHT;
	btn.Vertical = ControlLayout.V_TOP;
	btn.Size = Size(130, 30);
	btn.Margin = Rect(0, 60, 0, 0);
	btn.TextColor = QuadColor(Color.White);
	btn.Text = "开始剧情对话";
  btn:SubscribeScriptedEvent('Button::ClickEvent', 'TaskDialogPanel:TestPlot');
	return input, btn;
end

function TopRenderStep:getPlotId()
	return tonumber(input.Text);
end
--==========================================================

--更新
function TopRenderStep:Update( Elapse )
	if showTip then
		fps.Text = 'fps:' .. appFramework.FPS;
		
		local memorySize = memoryManager.CurMemorySize / 1048576;
		local renderSize = renderer.CurDisplayMemorySize / 1048576;
		local luaSize = collectgarbage('count') / 1024;
		local text =	LANG_topRenderStep_1 .. appFramework:GetTotalControlCount() .. '\n' ..
						LANG_topRenderStep_2 .. math.floor(memorySize) .. 'M\n' ..
						'lua：' .. math.floor(luaSize) .. 'M\n' ..
						LANG_topRenderStep_3 .. math.floor(renderSize) .. 'M\n' ..
						LANG_topRenderStep_4 .. math.floor( memorySize + renderSize + luaSize ) .. 'M';
		memory.Text = text;
		uid.Text = "uid = " .. tostring(ActorManager.user_data.uid);
	end
	
	topDesktop:Update(Elapse);
end

--渲染
function TopRenderStep:Render()
	renderer:ClearRenderList();
	renderer:SetQueuingFlag(true);
	topDesktop:Render(1);
	renderer:SetActiveCamera(topDesktop.Camera);
	renderer:Render();
end

--触控开始
function TopRenderStep:TouchBegan( touch, event )
	--local pt = touch:LocationInView();							--屏幕坐标
    --local ctrl = uiSystem:PickControl(pt.x, pt.y)
    --print("top-ctrl = " .. ctrl.Name)
    if touch.ID > 0 then return false end --多点屏蔽

	if uiIndex == -1 and topDesktop:TouchBegan(touch, event) then
		uiIndex = touch.ID;		
		return true;
	else
		if Game:GetCurState() == GameState.runningState and NaviLogic:getNaviState() then
		
			local pt = touch:LocationInView();
			print('x:' .. pt.x .. '  y:' .. pt.y)
			NaviLogic:Click(pt.x, pt.y);
			return false;
		end
	end	
	
	return false;

end

--触控移动
function TopRenderStep:TouchMoved( touch, event )
		
	if uiIndex == touch.ID then
		return topDesktop:TouchMoved(touch, event);
	end	
	
	return false;

end

--触控结束
function TopRenderStep:TouchEnded( touch, event )
	
	if uiIndex == touch.ID then
		uiIndex = -1;
		return topDesktop:TouchEnded(touch, event);
	end		
	
	return false;
end

--触控取消
function TopRenderStep:TouchCancelled( touch, event )
	
	if uiIndex == touch.ID then
		uiIndex = -1;
		return topDesktop:TouchCancelled(touch, event);
	end

	return false;
end

--加全屏透明遮罩
function TopRenderStep:AddScreenMask()
	mask.Visibility = Visibility.Visible;
end

--去除全屏透明遮罩
function TopRenderStep:RemoveScreenMask()
	mask.Visibility = Visibility.Hidden;
end


function TopRenderStep:onReport()
  if platformSDK.m_System ~= "Win32" then
    local debug_file_path = appFramework:GetCachePath() .. "debug.txt";
    local content = _readContent(debug_file_path);
    if content ~= false then 

      local memorySize = memoryManager.CurMemorySize / 1048576;
      local renderSize = renderer.CurDisplayMemorySize / 1048576;
      local luaSize = collectgarbage('count') / 1024;
      local text =	"control count:" .. appFramework:GetTotalControlCount() .. '\n' ..
      "memorySize:" .. math.floor(memorySize) .. 'M\n' ..
      'lua:' .. math.floor(luaSize) .. 'M\n' ..
      "renderSize:" .. math.floor(renderSize) .. 'M\n' ..
      "total:" .. math.floor( memorySize + renderSize + luaSize ) .. 'M';

      content = string.sub(content, -10240);
      Debug.report_debuglog(content .. "\n" .. text);
    end
    os.remove(debug_file_path);
  end
end

function TopRenderStep:onReportOK()
  self:onReport();
end

function TopRenderStep:onReportCancle()
  if platformSDK:GetNetStatus() == 'Wifi' then
    self:onReport();
  end
end

function TopRenderStep:onReportDebugInfo()

	local okDelegate = Delegate.new(TopRenderStep, TopRenderStep.onReportOK, 0);	
	local cancleDelegate = Delegate.new(TopRenderStep, TopRenderStep.onReportCancle, 0);	
	local text = '游戏有问题？请加群450301692反馈bug获大量钻石';

        local id = MessageBox:ShowDialog(MessageBoxType.OkCancel, text, okDelegate, cancleDelegate);
	MessageBox:SetOkShowName(id, "上传日志");
end

