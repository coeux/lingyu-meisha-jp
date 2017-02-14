--goodsFalldownManager.lua
--========================================================================
--物品掉落管理者类

GoodsFalldownManager =
	{
		g = 1100;			--y方向加速度
		goodsList = {};
		maxXSpeed =300;
		minXSpeed = 50;
		maxYSpeed = 200;
		minYSpeed = 50;
		goodsStayTime = Configuration.GoodsStayTime;
	};

local displayLabelList = {};

--初始化
function GoodsFalldownManager:Initialize(desktop)
	self.desktop = desktop;
	self.activeScene = FightManager.scene;
	self.sceneCamera = self.activeScene:GetCamera();
	self.uiCamera = self.desktop.Camera;
	self.terminalPosition = Vector2(70, self.desktop.Height - 70);
end

--添加物品掉落
function GoodsFalldownManager:AddFallGoods(position, goodsID)
	if goodsID ~= nil then
		--从场景坐标转换成ui坐标
		local uiPosition = SceneToUiPT(self.sceneCamera, self.uiCamera, position);
		local goodsItem = {};
		goodsItem.id = goodsID;
		goodsItem.flyingTime = 0;
		goodsItem.goodsStayTime = 0;
		goodsItem.isDisplay = false;
		goodsItem.firstPosition = position;			--物品标签初始位置
		goodsItem.xSpeed = self:randomXSpeed();
		goodsItem.ySpeed = self:randomYSpeed();
		goodsItem.bottomY = self.desktop.Height - Configuration.GoodsFinalYPosition;
		local goodsImageElement = ImageElement(uiSystem:CreateControl('ImageElement'));
		--设置初始位置
		goodsImageElement.Translate = uiPosition;
		--设置图片自动调整大小
		goodsImageElement.AutoSize = true;
		goodsImageElement.Scale = Vector2(0.8, 0.8);

		--迷窟掉落物品换成特殊icon
		local iconId;
		if goodsID >= ItemIDSection.RoleChipBegin and goodsID <= ItemIDSection.RoleChipEnd then
			iconId = 1207;
		else
			iconId = resTableManager:GetValue(ResTable.item, tostring(goodsID), 'icon');
		end

		--设置图片
		goodsImageElement.Image = GetPicture('icon/' .. iconId .. '.ccz');

		--显示
		goodsImageElement.Visibility = Visibility.Visible;

		goodsItem.imageElement = goodsImageElement;
		table.insert(self.goodsList, goodsItem);
		--添加tag，为该ImageElement在列表的下标
		goodsItem.imageElement.Tag = #(self.goodsList);
		self.desktop:AddChild(goodsItem.imageElement);
	end
end


--随机生成X轴初始速度
function GoodsFalldownManager:randomXSpeed()
	return Math.RangeRandom(self.minXSpeed, self.maxXSpeed);
end


--随即生成Y轴初始速度
function GoodsFalldownManager:randomYSpeed()
	return Math.RangeRandom(self.minYSpeed, self.maxYSpeed);
end


--根据初始位置、运行时间和xy轴速度计算当前坐标
function GoodsFalldownManager:caculatePosition(position, xSpeed, ySpeed, time)
	local scenePosition = Vector3(position.x + xSpeed * time, position.y + ySpeed * time - 0.5 * self.g * time * time, 0);
	return scenePosition;
end


--计算物品被拾起后的飞行时间
function GoodsFalldownManager:caculatePickUpTime(length, xMoveSpeed, addSpeed)
   local time = CheckDiv((-xMoveSpeed + Math.Sqrt(xMoveSpeed*xMoveSpeed + 2*addSpeed*length))/addSpeed);
	return time;
end


--更新物品移动
function GoodsFalldownManager:Update(elapse)
	for _, goodsItem in ipairs(self.goodsList) do
		--删除点击事件
		if -1 == goodsItem.imageElement.Tag then
			goodsItem.imageElement:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'GoodsFalldownManager:PickGoods');
		end

		if goodsItem.goodsStayTime >= self.goodsStayTime then
			if goodsItem.goodsOpacity > 0 then
				goodsItem.goodsOpacity = goodsItem.goodsOpacity - 0.015;
				goodsItem.imageElement.Opacity = goodsItem.goodsOpacity;
			else
				if not goodsItem.isDisplay then
					self:displayAddGoods(goodsItem.imageElement.Translate);
					goodsItem.isDisplay = true;
				end

				goodsItem.imageElement.Visibility = Visibility.Hidden;
			end


		elseif goodsItem.goodsStayTime > 0 then
			--物品已经落地，保持不动
			goodsItem.goodsStayTime = goodsItem.goodsStayTime + elapse;
			local uiPosition = 	SceneToUiPT(self.sceneCamera, self.uiCamera, goodsItem.firstPosition);
			--更新掉落物品的坐标
			goodsItem.imageElement.Translate = Vector2(uiPosition.x, uiPosition.y);
		else
			--物品掉落
			goodsItem.flyingTime = goodsItem.flyingTime + elapse;
			local scenePosition = self:caculatePosition(goodsItem.firstPosition, goodsItem.xSpeed, goodsItem.ySpeed, goodsItem.flyingTime);
			if (FightManager.rightPos.x < scenePosition.x) then
				scenePosition.x = 2 * FightManager.rightPos.x - scenePosition.x;
			end

			local uiPosition = 	SceneToUiPT(self.sceneCamera, self.uiCamera, scenePosition);
			if uiPosition.y >= goodsItem.bottomY then
				--将最初位置设置成落地位置;
				goodsItem.firstPosition = scenePosition;
				--开始计算物品保持落地时间
				goodsItem.goodsStayTime = goodsItem.goodsStayTime + elapse;
				--物品的显示透明度
				goodsItem.goodsOpacity = 1;
				--添加物品点击事件
				goodsItem.imageElement:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'GoodsFalldownManager:PickGoods');
			end

			--更新掉落物品的坐标
			goodsItem.imageElement.Translate = Vector2(uiPosition.x, uiPosition.y);
		end
	end
end


--物品拾起
function GoodsFalldownManager:PickGoods(Args)
	local args = UIControlEventArgs(Args);
	local imageElement = ImageElement(args.m_pControl);
	local tag = imageElement.Tag;
	--更改goodsItem.goodsStayTime 时间，使之大于保持落地时间即可
	local goodsItem = self.goodsList[tag];
	goodsItem.goodsStayTime = self.goodsStayTime;
	--注销该ImageElement的点击事件
	goodsItem.imageElement.Tag = -1;
end

--显示获得物品的加号
function GoodsFalldownManager:displayAddGoods(position)
	local textElement = uiSystem:CreateControl('TextElement');
	textElement.Text = '+ 1';
	textElement.Font = uiSystem:FindFont('recoverFont');
	textElement.Margin = Rect(position.x, position.y, 0, 0);
	textElement.Storyboard = 'storyboard.goodsDisappear';
	self.desktop:AddChild(textElement);
	table.insert(displayLabelList, textElement);
end

--删除
function GoodsFalldownManager:Destroy()
	for _,goodsItem in ipairs(self.goodsList) do
		self.desktop:RemoveChild(goodsItem.imageElement);
	end

	for _,textElement in ipairs(displayLabelList) do
		self.desktop:RemoveChild(textElement);
	end

	self.goodsList = {};
	displayLabelList = {};
end
