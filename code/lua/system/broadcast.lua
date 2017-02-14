--broadcast.lua
--===================================================================
--全局喊话

Broadcast =
	{
		broadcastList = {};
	};

local appearTime = 0.3;
local lastTime = 3;

--创建全局喊话
function Broadcast:createBroadcast(text)
	local label = uiSystem:CreateControl('Label');
	label.Background = uiSystem:FindResource('task_auto', 'godsSenki');
	label.Size = Size(700, 100);
	label.Text = text;
	label.TextAlignStyle = TextFormat.MiddleCenter;
	label.TextColor = Configuration.VipColor;
	label.Horizontal = ControlLayout.H_CENTER;
	label.Vertical = ControlLayout.V_CENTER;
	label.Font = uiSystem:FindFont('huakang_25');
	label.Pick = false;
	label.Margin = Rect(0,0,0,0);
	label.Opacity = 0;
	label.AutoNewLine = true;

	topDesktop:AddChild(label);

	return label;
end

--添加全局喊话
function Broadcast:AddBroadcast(text)
	local item = {};
	item.time = 0;
	item.label = self:createBroadcast(text);

	table.insert(self.broadcastList, item);
end

--更新全局喊话
function Broadcast:Update(elapse)
	if #self.broadcastList > 0 then
		local item = self.broadcastList[1];
		item.time = item.time + elapse;
		if item.time <= appearTime then
                   item.label.Opacity = CheckDiv(item.time / appearTime);
		elseif item.time <= lastTime + appearTime then
			item.label.Opacity = 1;
		elseif item.time <= lastTime + appearTime * 2 then
                   item.label.Opacity = CheckDiv((lastTime + appearTime * 2 - item.time) / appearTime);
		else
			topDesktop:RemoveChild(item.label);
			table.remove(self.broadcastList, 1);
		end
	end
end
