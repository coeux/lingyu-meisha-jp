--damageLabelManager.lua

--========================================================================
--伤害显示标签管理者类

DamageLabelManager = 
	{
		usedLabelList = {};
		leftLabelList = {};
		animationData = {};	
		totalTime = 0;				--伤害数字持续时间		
	};


--初始化
function DamageLabelManager:Initialize(desktop)
	
	--伤害显示标签初始缓存个数
	self.bufferCount = 20;
	self.normalBrush = uiSystem:FindResource('damageBackground', 'fight');
	self.criticalBrush = uiSystem:FindResource('stormsHitBrush', 'fight');
	self.missBrush = uiSystem:FindResource('missBrush', 'fight');	
	self.normalFont = uiSystem:FindFont('damageFont');
	self.skillFont = uiSystem:FindFont('skillDamageFont');
	self.recoverFont = uiSystem:FindFont('recoverFont');
	self.desktop = desktop;
	self.activeScene = FightManager.scene;
	self.sceneCamera = self.activeScene:GetCamera();
	self.uiCamera = self.desktop.Camera;
	
	for index = 1, self.bufferCount do	
		table.insert(self.leftLabelList, self:createLabelItem());		--预创建标签
	end
	--加载伤害显示特效
	self:LoadXmlFile(GlobalData:GetResDir() .. 'resource/other/damageShow/hp_animation.xml');
	
end

--创建标签
function DamageLabelManager:createLabelItem()
	--创建标签
	local showLabel = Label(uiSystem:CreateControl('Label'));		
	showLabel.Size = Size(150, 60);
	showLabel.TextAlignStyle = TextFormat.MiddleCenter;
	showLabel.Pick = false;
	showLabel.Visibility = Visibility.Hidden;
	
	--添加到ui界面
	self.desktop:AddChild(showLabel);	
	
	return {label = showLabel; time = 0};
end

--获取标签项
function DamageLabelManager:getLabelItem()
	if 0 ~= #(self.leftLabelList) then
		local item = self.leftLabelList[1];
		table.remove(self.leftLabelList, 1);
		return item;
	else
		return self:createLabelItem();
	end
end

--创建普通伤害标签
function DamageLabelManager:addNormalLabel(actor, value, skillType)
	local labelItem = self:getLabelItem();
	labelItem.label.Visibility = Visibility.Visible;			--显示标签
	labelItem.dir = actor:GetDirection();						--设置漂浮方向
	
	labelItem.label.Size = Size(250, 60);
	labelItem.label.Background = self.normalBrush;
	labelItem.label.Text = tostring(value);
	
	if SkillType.normalAttack == skillType then
		labelItem.label.Font = self.normalFont;
	else
		labelItem.label.Font = self.skillFont;
	end

	--将场景坐标转换成ui坐标
	local uiPosition = SceneToUiPT(self.sceneCamera, self.uiCamera, actor:GetPosition());
	labelItem.firstPosition = Vector2(uiPosition.x - 125 + math.random(-10, 10), uiPosition.y - actor:GetHeight() - math.random(-9, 10));
	labelItem.label.Translate = labelItem.firstPosition;
	labelItem.label:ForceLayout();
	
	table.insert(self.usedLabelList, labelItem);
end

--创建闪避标签
function DamageLabelManager:addMissLabel(actor)
	local labelItem = self:getLabelItem();
	labelItem.label.Visibility = Visibility.Visible;			--显示标签
	labelItem.dir = actor:GetDirection();						--设置漂浮方向
	
	labelItem.label.Size = Size(54, 29);
	labelItem.label.Background = self.missBrush;
	labelItem.label.Text = '';
	
	--将场景坐标转换成ui坐标
	local uiPosition = SceneToUiPT(self.sceneCamera, self.uiCamera, actor:GetPosition());	
	labelItem.firstPosition = Vector2(uiPosition.x - 27 + math.random(-10, 10), uiPosition.y - actor:GetHeight() - math.random(-9, 10));
	if FightManager:GetFightType() == FightType.noviceBattle and tonumber(actor:GetResID()) == 8006 then
		labelItem.firstPosition = Vector2(uiPosition.x - 200, uiPosition.y - actor:GetHeight()*3/4 );
	end
	labelItem.label.Translate = labelItem.firstPosition;
	labelItem.label:ForceLayout();
	
	table.insert(self.usedLabelList, labelItem);
end

--创建暴击标签
function DamageLabelManager:addCriticalLabel(actor, value, skillType)
	local labelItem = self:getLabelItem();
	labelItem.label.Visibility = Visibility.Visible;			--显示标签
	labelItem.dir = actor:GetDirection();						--设置漂浮方向

	labelItem.label.Background = self.criticalBrush;
	labelItem.label.Text = tostring(value);	
	
	if SkillType.normalAttack == skillType then	
		labelItem.label.Size = Size(154, 89);
		labelItem.label.Font = self.normalFont;
	else
		labelItem.label.Size = Size(200, 115);
		labelItem.label.Font = self.skillFont;
	end

	--将场景坐标转换成ui坐标
	local uiPosition = SceneToUiPT(self.sceneCamera, self.uiCamera, actor:GetPosition());
	labelItem.firstPosition = Vector2(uiPosition.x - 77 + math.random(-10, 10), uiPosition.y - actor:GetHeight() - math.random(-9, 10));
	if FightManager:GetFightType() == FightType.noviceBattle and tonumber(actor:GetResID()) == 8006 then
		labelItem.firstPosition = Vector2(uiPosition.x - 200, uiPosition.y - actor:GetHeight()*3/4 );
	end
	labelItem.label.Translate = labelItem.firstPosition;
	labelItem.label:ForceLayout();
	
	table.insert(self.usedLabelList, labelItem);
end

--创建恢复HP标签
function DamageLabelManager:addRecoverHPLabel(actor, value)
	local labelItem = self:getLabelItem();
	labelItem.label.Visibility = Visibility.Visible;			--显示标签
	labelItem.dir = actor:GetDirection();						--设置漂浮方向
	
	labelItem.label.Size = Size(250, 60);
	labelItem.label.Background = self.normalBrush;
	labelItem.label.Text = '+' .. value;
	labelItem.label.Font = self.recoverFont;	

	--将场景坐标转换成ui坐标
	local uiPosition = SceneToUiPT(self.sceneCamera, self.uiCamera, actor:GetPosition());
	labelItem.firstPosition = Vector2(uiPosition.x - 125 + math.random(-10, 10), uiPosition.y - actor:GetHeight() - math.random(-9, 10));
	labelItem.label.Translate = labelItem.firstPosition;
	labelItem.label:ForceLayout();
	
	table.insert(self.usedLabelList, labelItem);
end

--添加伤害显示标签
function DamageLabelManager:Add(actor, damageItem, skillType)
	--做整数处理 把伤害转化为整数
	damageItem.data = math.floor(damageItem.data);
	
	if damageItem.state == AttackState.normal then
		self:addNormalLabel(actor, damageItem.data, skillType);			--添加普通伤害标签
		
	elseif damageItem.state == AttackState.critical then
		self:addCriticalLabel(actor, damageItem.data, skillType);		--添加暴击伤害标签
		
	elseif damageItem.state == AttackState.miss then
		self:addMissLabel(actor);											--添加闪避标签
		
	elseif damageItem.state == AttackState.RecoverHP then
		self:addRecoverHPLabel(actor, damageItem.data);					--添加恢复血量标签
			
	else

	end
end


--伤害显示结束
function DamageLabelManager:FinishDamageShow(labelItem, index)
	
	labelItem.time = 0;	
	labelItem.label.Scale = Vector2(1, 1);
	labelItem.label.Visibility = Visibility.Hidden;
	table.insert(self.leftLabelList, labelItem);
	table.remove(self.usedLabelList, index);
	
end

--更新伤害显示标签
function DamageLabelManager:Update(elapse)
	
	--记录显示结束的标签个数
	local timeoutCount = 0;	

	for _,labelItem in ipairs(self.usedLabelList) do
		
		labelItem.time = labelItem.time + elapse / appFramework.TimeScale;
		
		if labelItem.time > self.totalTime then
			--伤害显示结束
			timeoutCount = timeoutCount + 1;
		else
			--当前帧数
			local index = Math.Floor(labelItem.time * GlobalData.FPS * 0.9) + 1;
			local keyFrameData = self.animationData[index];
			if nil ~= keyFrameData.translate then
				if DirectionType.faceleft == labelItem.dir then
					labelItem.label.Translate = Vector2(labelItem.firstPosition.x - keyFrameData.translate.x, labelItem.firstPosition.y + keyFrameData.translate.y);
				else
					labelItem.label.Translate = Vector2(labelItem.firstPosition.x + keyFrameData.translate.x, labelItem.firstPosition.y + keyFrameData.translate.y);
				end	
			end
			if nil ~= keyFrameData.color then
				local color = Color(keyFrameData.color);
				if color then
					local quadColor = QuadColor(color);
					if quadColor then
						labelItem.label.TextColor = quadColor;
					end
				end
			end
			--[[if nil ~= keyFrameData.scale then	
				labelItem.label.Scale = Vector2(keyFrameData.scale.x, keyFrameData.scale.y);
			end--]]
		end	
	end	

	--从伤害显示列表中删除显示结束的标签
	for index = 1, timeoutCount do
		self:FinishDamageShow(self.usedLabelList[1], 1);
	end		
end

--将标签半透显示
function DamageLabelManager:MakeTransparent()
	for _,labelItem in ipairs(self.usedLabelList) do
		labelItem.label.Opacity = 0.1;
	end
end

--恢复标签显示
function DamageLabelManager:ResumeTransparent()
	for _,labelItem in ipairs(self.usedLabelList) do
		labelItem.label.Opacity = 1;
	end
end

--退出
function DamageLabelManager:Destroy()

	--释放缓存标签
	for _,labelItem in ipairs(self.usedLabelList) do
		self.desktop:RemoveChild(labelItem.label);	
	end
	
	for _,labelItem in ipairs(self.leftLabelList) do
		self.desktop:RemoveChild(labelItem.label);	
	end
	
	self.usedLabelList = {};
	self.leftLabelList = {};
	self.animationData = {};

end

--加载伤害显示特效xml文件
function DamageLabelManager:LoadXmlFile(fileName)
	local xfile = xmlParseFile( fileName );
	xfile = xfile[1];
	local num = xfile.n;
	
	for i = 1, num do
		local keyFrame = xfile[i];
		local attr = keyFrame['attr'];
		local keyFrameData = {};
		
		keyFrameData.key = tonumber(attr.Key);		
		if attr.Scale ~= nil then
			keyFrameData.scale = Converter.String2Vector2(attr.Scale);
		end	
		if attr.Translate ~= nil then
			keyFrameData.translate = Converter.String2Vector2(attr.Translate);
		end
		if attr.Color ~= nil then
			keyFrameData.color = Converter.String2Hex(attr.Color);
		else
			keyFrameData.color = Converter.String2Hex('0xFFFFFFFF');
		end
		
		table.insert(self.animationData, keyFrameData);
	end		
	
	self.totalTime = #(self.animationData) / GlobalData.FPS;
end	
































