--runeFalldownManager.lua
--========================================================================
--符文掉落管理类

RuneFalldownManager = 
	{
		g = 100;			--y方向加速度	
		dropsList = {};
		maxXSpeed =200;
		minXSpeed = 10;
		maxYSpeed = 200;
		minYSpeed = 50;		
	};	

local lineMonsterIdMap = {};
local DropMoveSpeed	= 900;				--掉落移动速度
local RuneStayTime = 1;					--掉落停留时间

local effectList = {};

--更新
function RuneFalldownManager:Update( Elapse )

	--更新动画
	for _, rune in pairs(self.dropsList) do
		if rune.moveToPackage then
			self:updateDropMove(rune, Elapse);
		else
			self:updateDropMoveToPkg(rune, Elapse);
		end
	end
	
end

--添加物品掉落
function RuneFalldownManager:addDrop(position, runeId, drop, line)
	if runeId ~= nil then
		local rune = {};
		local runeDropImage = ImageElement(uiSystem:CreateControl('ImageElement'));
		--设置初始位置
		runeDropImage.Translate = position;
		--设置图片自动调整大小
		runeDropImage.AutoSize = true;
		runeDropImage.Scale = Vector2(0.8, 0.8);
		--设置图片
		local iconId;
		if drop == 1 then
			iconId = resTableManager:GetValue(ResTable.item, '10006', 'icon');
		else
			local data = resTableManager:GetRowValue(ResTable.rune, tostring(drop));
			iconId = data['icon'];
			if 1 == data['effect'] then
				self:createEffect(runeDropImage, data['path'], data['icon'])
			end
		end

		runeDropImage.Image = GetPicture('icon/' .. iconId .. '.ccz');
		--显示
		runeDropImage.Visibility = Visibility.Visible;
		rune.runeId = runeId;
		rune.runeDropImage = runeDropImage;
		rune.firstPosition = position;			--物品标签初始位置	
		rune.maxY = position.y + 20;
		rune.runeStayTime = 0;
		rune.netSuccess = false;
		rune.xSpeed = self:randomXSpeed();		
		rune.ySpeed = self:randomYSpeed();
		rune.flyingTime = 0;
		rune.line = line;
		rune.moveToPackage = false;
		lineMonsterIdMap[line] = runeId;
		self.dropsList[runeId] = rune;
		local color = resTableManager:GetValue(ResTable.rune, tostring(drop), 'quality');
		--紫色和金色显示特效
		if 4 == color or 5 == color then
			RuneHuntPanel:createEffect(runeDropImage, RuneEffectType.drop, Vector2(runeDropImage.Width * 0.5, runeDropImage.Height * 0.5));
		end

		RuneHuntPanel:getDropsPanel():AddChild(runeDropImage);
	end	
end

--掉落符文特效
function RuneFalldownManager:createEffect(parentNode, path, armatureName)
	local aniPath = GlobalData.EffectPath .. path .. '/';
	AvatarManager:LoadFile(aniPath);
	local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	armatureUI:LoadArmature(armatureName);
	armatureUI:SetAnimation('play');
	armatureUI.Translate = Vector2(0, -parentNode.Height * 1);
	parentNode:AddChild(armatureUI);
	table.insert(effectList, {parent = parentNode, armature = armatureUI});
end

--删除掉落符文特效
function RuneFalldownManager:destroyEffect()
	for _,v in ipairs(effectList) do
		v.parent:RemoveChild(v.armature);
	end
	effectList = {};
end

--更新掉落移动到地上
function RuneFalldownManager:updateDropMove( rune, elapse )
	local curPos3 = rune.runeDropImage.Translate;
	local curPos2 = Vector2(curPos3.x, curPos3.y);
	local targetPos = RuneHuntPanel:getDropsTarget();
	local dir = targetPos - curPos2;
	local length = dir:Normalise();
	local dis = DropMoveSpeed * elapse;
	
	if dis >= length then
		--到达目标
		rune.runeDropImage.Translate = targetPos;
		self:removeDrop(rune);
	else

		--没有到达，就移动
		dis = dir * dis;
		curPos2 = curPos2 + dis;
		rune.runeDropImage.Translate = curPos2;

	end
end

--该线成功，掉落飞行背包
function RuneFalldownManager:lineSuccess( line )
	local runeId = lineMonsterIdMap[line];
	local rune = self.dropsList[runeId];
	--该符文服务器处理完成
	rune.netSuccess = true;
	if rune.runeStayTime > RuneStayTime then
		rune.moveToPackage = true;
	end
end

--更新掉落移动到背包
function RuneFalldownManager:updateDropMoveToPkg( rune, elapse )
	local curPos3 = rune.runeDropImage.Translate;
	local curPos2 = Vector2(curPos3.x, curPos3.y);
	rune.flyingTime = rune.flyingTime + elapse;
	local uiPosition = self:caculatePosition(curPos2, rune.xSpeed, rune.ySpeed, rune.flyingTime);	
	if uiPosition.y < rune.maxY then	
		rune.runeDropImage.Translate = uiPosition;
	else
		rune.runeStayTime = rune.runeStayTime + elapse;
		if rune.runeStayTime > RuneStayTime and rune.netSuccess then
			rune.moveToPackage = true;
		end
	end
end


function RuneFalldownManager:removeDrop( rune )
	RuneHuntPanel:getDropsPanel():RemoveChild(rune.runeDropImage);
	self.dropsList[rune.runeId] = nil;
end

--随机生成X轴初始速度
function RuneFalldownManager:randomXSpeed()
	return Math.RangeRandom(self.minXSpeed, self.maxXSpeed) * 0.01;
end


--随即生成Y轴初始速度
function RuneFalldownManager:randomYSpeed()
	return Math.RangeRandom(self.minYSpeed, self.maxYSpeed) * 0.01;
end


--根据初始位置、运行时间和xy轴速度计算当前坐标
function RuneFalldownManager:caculatePosition(position, xSpeed, ySpeed, time)
	local scenePosition = Vector2(position.x + xSpeed * time, (position.y - ySpeed * time + 0.5 * self.g * time * time));	
	return scenePosition;
end

--删除
function RuneFalldownManager:Destroy()
	for _,drop in ipairs(self.dropsList) do
		RuneHuntPanel:getDropsPanel():RemoveChild(drop.runeDropImage);
	end
	
	self.dropsList = {};
end














