--bossPanel.lua

--========================================================================
--Boss面板

BossPanel =
	{
	};

--控件
local mainDesktop;
local bossDemageList;


--初始化
function BossPanel:InitPanel( desktop )
	
	mainDesktop 	= desktop;
	bossDemageList	= Panel( desktop:GetLogicChild('bossDemageList') );
	bossDemageList:IncRefCount();

	--初始化时隐藏panel
	bossDemageList.Visibility = Visibility.Hidden;

end

--销毁
function BossPanel:Destroy()
	bossDemageList:DecRefCount();
	bossDemageList = nil;
end

--显示
function BossPanel:Show()
	bossDemageList.Visibility = Visibility.Visible;
end

--隐藏
function BossPanel:Hide()
	bossDemageList.Visibility = Visibility.Hidden;
end

--========================================================================
--功能函数
--========================================================================

--刷新排行榜
function BossPanel:RefreshDemageRanking( rank )

	--保留第一行（排名  伤害）
	local firstPtr = bossDemageList:GetLogicChild(0);
	bossDemageList:RemoveAllChildren();
	bossDemageList:AddChild(firstPtr);
	
	--添加伤害排名
	for k,v in ipairs(rank) do
		local item = uiSystem:CreateControl('demageBossTemplate');
		local panel = item:GetLogicChild(0);

		item.num = panel:GetLogicChild('num');
		item.name = panel:GetLogicChild('name');
		item.demage = panel:GetLogicChild('demage');
		item.percent = panel:GetLogicChild('percent');
		
		item.num.Text = k .. '、';
		item.name.Text = v.nickname;
		item.demage.Text = tostring(v.damage);
		
		bossDemageList:AddChild(item);
	end

end


--========================================================================
--事件
--========================================================================
