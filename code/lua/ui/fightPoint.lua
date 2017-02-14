--fightPoint.lua

--========================================================================
--战力类

FightPoint =
	{
		parent = topDesktop;
	};

local fpStackPanel;			--战力显示


--初始化
function FightPoint:InitPanel( desktop )
	self.parent = topDesktop
end

--销毁
function FightPoint:Destroy()
end

function FightPoint:Update( elapse )

	if fpStackPanel == nil or not fpStackPanel.enable then
		return;
	end

	fpStackPanel.cur = fpStackPanel.cur + elapse * fpStackPanel.speed + 10000 * fpStackPanel.speed2 * elapse;

	if fpStackPanel.cur >= fpStackPanel.target then
		fpStackPanel.fpTextElement.Text = tostring(fpStackPanel.target);
		fpStackPanel.enable = false;

		timerManager:CreateTimer(2, 'FightPoint:onClose', 0, true);
		return;
	end
	
	-- fpStackPanel.Translate = Vector2(0, fpStackPanel.Translate.y - elapse * fpStackPanel.vspeed);
	fpStackPanel.fpTextElement.Text = tostring( math.ceil(fpStackPanel.cur) );

end

--战力显示
function FightPoint:ShowFP( fp, hor, ver, margin )
	--新手引导相关处理
	if Task:getMainTaskId() <= 100002 then
		return;
	end
	if fp == 0 or fpStackPanel ~= nil then
		return;
	end
	
	fpStackPanel = uiSystem:CreateControl( 'StackPanel' );
	fpStackPanel.Horizontal = ControlLayout.H_CENTER;
	fpStackPanel.Vertical = ControlLayout.V_CENTER;
	fpStackPanel.Orientation = Orientation.Horizontal;
	fpStackPanel.Alignment = Alignment.Center;
	fpStackPanel.Margin = Rect(0, topDesktop.RenderSize.Height * 0.118, 0, 0);

	fpStackPanel.ZOrder = 100000
	-- if parent then
	-- 	self.parent = parent
	-- 	fpStackPanel.Margin = Rect(0,0,0,0)
	-- end

	if hor then
		fpStackPanel.Horizontal = hor
	end
	if ver then
		fpStackPanel.Vertical = ver
	end
	if margin then
		fpStackPanel.Margin = margin
	end
	
	fpStackPanel.enable = true;
	
	local font = uiSystem:FindFont('homeFont');
	
	if fp > 0 then
		
		local textElement = uiSystem:CreateControl( 'TextElement' );
		textElement.Font = font
		-- textElement.TextColor = QuadColor(Color(250, 255, 108, 255), Color(255, 187, 2, 255), Color(250, 255, 108, 255), Color(255, 187, 2, 255));
		textElement.Text = LANG_fightPoint_1;
		fpStackPanel:AddChild(textElement);
		
		local fpTextElement = uiSystem:CreateControl( 'TextElement' );
		fpTextElement.Font = font;
		-- fpTextElement.TextColor = QuadColor(Color(250, 255, 108, 255), Color(255, 187, 2, 255), Color(250, 255, 108, 255), Color(255, 187, 2, 255));
		fpTextElement.Text = '0';
		
		fpStackPanel:AddChild(fpTextElement);
		
		fpStackPanel.target = fp;
		fpStackPanel.cur = 0;
		fpStackPanel.fpTextElement = fpTextElement;
		
		local low = fp % 10000;
		fpStackPanel.speed = low;
		fpStackPanel.speed2 = fp / 10000;
		fpStackPanel.vspeed = 80;				--垂直方向移动速度
		
		fpStackPanel.AutoSize = true;
		fpTextElement.Text = tostring(fpStackPanel.target);
		fpStackPanel:ForceLayout();
		fpTextElement.Text = '0';
		fpStackPanel.AutoSize = false;

	else

		local textElement = uiSystem:CreateControl( 'TextElement' );
		textElement.Font = font;
		-- textElement.TextColor = QuadColor(Color(250, 255, 108, 255), Color(255, 187, 2, 255), Color(250, 255, 108, 255), Color(255, 187, 2, 255));
		textElement.Text = LANG_fightPoint_2;
		textElement.ShaderType = IRenderer.UI_NormalShader;
		
		fpStackPanel:AddChild(textElement);
		
		local fpTextElement = uiSystem:CreateControl( 'TextElement' );
		fpTextElement.Font = font;
		-- fpTextElement.TextColor = QuadColor(Color(250, 255, 108, 255), Color(255, 187, 2, 255), Color(250, 255, 108, 255), Color(255, 187, 2, 255));
		fpTextElement.Text = tostring(fp);
		fpTextElement.ShaderType = IRenderer.UI_NormalShader;
		
		fpStackPanel:AddChild(fpTextElement);
		
		fpStackPanel.target = fp;
		fpStackPanel.cur = fp;
		fpStackPanel.speed = 0;
		fpStackPanel.speed2 = 0;
		fpStackPanel.vspeed = 0;
		fpStackPanel.fpTextElement = fpTextElement;
		
		fpStackPanel.AutoSize = true;
		fpStackPanel:ForceLayout();
		fpStackPanel.AutoSize = false;
		
	end

	topDesktop:AddChild(fpStackPanel);
end

--关闭战力显示
function FightPoint:onClose()
	topDesktop:RemoveChild(fpStackPanel);
	-- self.parent = topDesktop
	fpStackPanel = nil;
end
