--toastPanel.lua

--========================================================================
--提示界面

Toast =
	{
		TimeLength_Longlong = 2;
		TimeLength_Long = 1.5;
		TimeLength_Short = 1;
	};

local toastList = {};			--toast队列
local toastKeepRadio = 0.6;		--toast透明度不变的时间占总时间的比例

local mainDesktop;

--显示的信息
local info1;
local info2;
local info3;
local info4;


--初始化面板
function Toast:InitPanel(desktop)
	--类变量初始化
	Toast.TimeLength_Long = 1.5;
	Toast.TimeLength_Short = 1;
	Toast.TimeLength_Longlong = 2;
	
	--变量初始化
	toastList = {};			--toast队列
	toastKeepRadio = 0.6;		--toast透明度不变的时间占总时间的比例

	--界面初始化
	mainDesktop = desktop;
	toastList = {};
end

--销毁
function Toast:Destroy()
	
end

--创建toast
function Toast:createToast(text1, color1, text2, color2, text3, color3, text4, color4)
	local toastCtrl = UserControl(uiSystem:CreateControl('ToastTemplate'));

	toastCtrl.Horizontal = ControlLayout.H_CENTER;
	toastCtrl.Vertical = ControlLayout.V_CENTER;
--	toastCtrl.Margin = Rect(0, mainDesktop.Height * 0.17, 0, 0);
	toastCtrl.Margin = Rect(0, mainDesktop.Height * -0.3, 0, 0);
	toastCtrl.ZOrder = 100;				--置于最上面

	local stackpanel = toastCtrl:GetLogicChild('tips'):GetLogicChild('stackpanel');
	local textElement1 = stackpanel:GetLogicChild('1');
	local textElement2 = stackpanel:GetLogicChild('2');
	local textElement3 = stackpanel:GetLogicChild('3');
	local textElement4 = stackpanel:GetLogicChild('4');
	
	textElement1.Pick = false;
	textElement2.Pick = false;
	textElement3.Pick = false;
	textElement4.Pick = false;
	
	info1 = text1;
	info2 = text2;
	info3 = text3;
	info4 = text4;
	
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
	
	toastCtrl.Visibility = Visibility.Hidden;
	stackpanel.Pick = false;
	toastCtrl.Pick = false;
	topDesktop:AddChild(toastCtrl);
	return toastCtrl;
end

--显示
function Toast:MakeToast(lastTime, text1, color1, text2, color2, text3, color3, text4, color4 )
	if ((nil == text1) and (nil == text2) and (nil == text3) and (nil == text4)) or (nil == lastTime) or (lastTime <= 0) then
		return;
	end
	
	--判断是否是重复信息
	if #toastList ~= 0 then
		if (info1 == text1) and (info2 == text2) and (info3 == text3) and (info4 == text4) then
			toastList[#toastList].showTime = 0;	--重新显示
			toastList[#toastList].ctrl.Opacity = 1;
			return;
		end
	end

	local toastItem = {};
	toastItem.totalTime = lastTime;						--保存显示时间
	toastItem.showTime = 0;								--已经显示时间
	toastItem.ctrl = self:createToast(text1, color1, text2, color2, text3, color3, text4, color4);			--创建toast
	
	table.insert(toastList, toastItem);
end	

--显示购买物品提示
function Toast:MakeToastGood(text1, text2, count, colorID, lastTime)

	--判断是否是重复信息
	if #toastList ~= 0 then
		if (info1 == text1) and (info2 == text2) and (info3 == nil) then
			toastList[#toastList].showTime = 0;	--重新显示
			toastList[#toastList].ctrl.Opacity = 1;
			return;
		end
	end
	
	local toastItem = {};
	toastItem.totalTime = lastTime;						--保存显示时间
	toastItem.showTime = 0;								--已经显示时间
	toastItem.ctrl = self:createToast(text1, nil, text2, QualityColor[colorID], '×' .. count);		--创建toast
	
	table.insert(toastList, toastItem);

end

--更新
function Toast:Update(Elapse)
	if (#toastList > 0) then

		local item = toastList[1];
		item.ctrl.Visibility = Visibility.Visible;
		item.showTime = item.showTime + Elapse;					--更新显示时间
		if (item.showTime >= item.totalTime) then				--toast的持续时间到了
			topDesktop:RemoveChild(item.ctrl);					--删除toast控件
			table.remove(toastList, 1);						--删除toast列表中的toast
			
			info1 = nil;	info2 = nil;	info3 = nil;		--清除缓存
		elseif (item.showTime > item.totalTime * toastKeepRadio) then 	--后一半时间透明度减小
			item.ctrl.Opacity = (item.totalTime - item.showTime) / (item.totalTime - item.totalTime * toastKeepRadio);
		else 													--前一半时间透明度不变

		end
	end
end
