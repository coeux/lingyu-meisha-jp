--toastMovePanel.lua

--========================================================================
--移动提示界面

ToastMove =
	{
		TipsMaxShowCount	= 3;				--最大显示数量
		TipsMinSpaceTime	= 0.3;				--两个提示最小出现间隔
		TipsLastTime		= 1;				--提示的持续时间（包括飞行时间）
		TipsMoveLastTime	= 0.25;				--提示的移动时间
		TipsMoveSpeed		= 150;				--飞行速度
		TipsLineList		= {0, -35, -70};
	};

local needShowList = {};			--待显示的列表
local showingList = {};			--已经显示的列表
local preAppearLastTime = 1;		--上一次tip出现到现在经过的时间（如果时间大于0.5秒，显示新的）


--更新物品获得提示显示
function ToastMove:Update( Elapse )
	preAppearLastTime = preAppearLastTime + Elapse;							--更新时间

	local index = 1;
	while index <= #showingList do
		local tipItem = showingList[index];
		if tipItem.lastTime > ToastMove.TipsLastTime then					--持续时间到了，删除显示
			topDesktop:RemoveChild(tipItem.ctrl);							--删除控件
			table.remove(showingList, index);
		else
			tipItem.lastTime = tipItem.lastTime + Elapse;					--更新持续时间
			trans = tipItem.ctrl.Translate;
			if trans.y > tipItem.targetLine then
				tipItem.ctrl.Translate = Vector2(trans.x, trans.y - Elapse * ToastMove.TipsMoveSpeed)
				if tipItem.ctrl.Translate.y < tipItem.targetLine then
					tipItem.ctrl.Translate = Vector2(trans.x, tipItem.targetLine);
				end
			end

			index = index + 1;												--指向下一个提示
		end
	end

	if (preAppearLastTime > ToastMove.TipsMinSpaceTime) and (#needShowList > 0) then	--添加新的物品提示
		preAppearLastTime = 0;
		if #showingList == ToastMove.TipsMaxShowCount then					--如果当前显示已经达到最大值，要删除最前面的一个
			topDesktop:RemoveChild(showingList[1].ctrl);					--删除控件
			table.remove(showingList, 1);									--删除第一个
		end

		for index, tipItem in ipairs(showingList) do
			tipItem.targetLine = ToastMove.TipsLineList[index + 1];
		end

		needShowList[1].ctrl.Margin = Rect(0, topDesktop.Height/6, 0, 0);
		needShowList[1].ctrl.Horizontal	= ControlLayout.H_CENTER;
		needShowList[1].ctrl.Vertical = ControlLayout.V_CENTER;
		needShowList[1].ctrl.Translate = Vector2(0, -ToastMove.TipsLineList[2]);
		topDesktop:AddChild(needShowList[1].ctrl);
		table.insert(showingList, 1, needShowList[1]);
		table.remove(needShowList, 1);
	end
end

--创建toast
function ToastMove:CreateToast(text1, color1, text2, color2, text3, color3, text4, color4, font)
	local tipsControl = uiSystem:CreateControl('ToastTemplate');			--创建自定义控件
	local tips = tipsControl:GetLogicChild('tips');
	local stackpanel = tips:GetLogicChild('stackpanel');
	local textElement1 = stackpanel:GetLogicChild('1');
	local textElement2 = stackpanel:GetLogicChild('2');
	local textElement3 = stackpanel:GetLogicChild('3');
	local textElement4 = stackpanel:GetLogicChild('4');
	
	if text1 ~= nil then
		textElement1.Text = text1;
		if (color1 ~= nil) then
			textElement1.TextColor = color1;
		else
			textElement1.TextColor = Configuration.WhiteColor;
		end
	else
		textElement1.Text = '';
	end
	
	if text2 ~= nil then
		textElement2.Text = text2;
		if (color2 ~= nil) then
			textElement2.TextColor = color2;
		else
			textElement2.TextColor = Configuration.WhiteColor;
		end
		if font and font[2] then
			textElement2.Font = uiSystem:FindFont(font[2]);
		else
			textElement2.Font = uiSystem:FindFont('huakang_20');
		end
	else
		textElement2.Text = '';
	end
	
	if text3 ~= nil then
		textElement3.Text = text3;
		if (color3 ~= nil) then
			textElement3.TextColor = color3;
		else
			textElement3.TextColor = Configuration.WhiteColor;
		end
	else
		textElement3.Text = '';
	end	
	
	if text4 ~= nil then
		textElement4.Text = text4;
		if (color4 ~= nil) then
			textElement4.TextColor = color4;
		else
			textElement4.TextColor = Configuration.WhiteColor;
		end
	else
		textElement4.Text = '';
	end	
	
	tipsControl.Visibility = Visibility.Visible;
	stackpanel.Pick = false;
	tipsControl.Pick = false;
	textElement1.Pick = false;
	textElement2.Pick = false;
	textElement3.Pick = false;
	
	table.insert(needShowList, {ctrl = tipsControl, lastTime = 0, targetLine = ToastMove.TipsLineList[1]});	--插入链表
end


--========================================================================
--快捷功能提示
--========================================================================

--添加获得物品提示
function ToastMove:AddGoodsGetTip(resid, itemCount)

	local item = {};
	local text2;
	local color2;
	if (resid < 10000) then		--角色
		item = resTableManager:GetValue(ResTable.actor, tostring(resid), {'name', 'rare'});	
		text2 = item['name'];
		color2 = QualityColor[item['rare']];
	else
		if resid == 16005 then
			text2 = LANG_toastMovePanel_3;
		else
			item = resTableManager:GetValue(ResTable.item, tostring(resid), {'name', 'quality'});	
			text2 = item['name'];
		end
		
		color2 = QualityColor[item['quality']];	
	end
	
	self:CreateToast( LANG_toastMovePanel_1, nil, text2, color2, '×' .. itemCount );

end

--添加世界boss逃跑提示
function ToastMove:AddBossEscapeTip(bossResid)
	local text1 = resTableManager:GetValue(ResTable.monster, tostring(bossResid), 'name');
	self:CreateToast(text1, Configuration.RedColor, LANG_toastMovePanel_2);
end
