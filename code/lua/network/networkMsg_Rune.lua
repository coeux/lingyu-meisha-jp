--networkMsg_Rune.lua

--======================================================================
--符文

NetworkMsg_Rune =
	{
	};


--获取符文怪物列表
function NetworkMsg_Rune:onGetMonsters(msg)
	RuneHuntPanel:onGetMonsters(msg);
end

--吞噬符文或者移动符文
function NetworkMsg_Rune:onSwitchPosition(msg)
	
end

--吞噬背包内所有符文
function NetworkMsg_Rune:onEatAll(msg)
	
end

--猎一个魔
function NetworkMsg_Rune:onHuntSome(msg)
	RuneManager:onHuntSome(msg);
end

--符文增删，包括背包和人物
function NetworkMsg_Rune:onRuneChange(msg)
	RuneManager:onRuneChange(msg)
end

--召唤魔王
function NetworkMsg_Rune:onCallBoss( msg )
	RuneManager:onCallBoss(msg.monster);
end

--符文碎片改变
function NetworkMsg_Rune:onChipChange(msg)
	ActorManager.user_data.runechip = msg.now;
	uiSystem:UpdateDataBind();
end

--购买符文
function NetworkMsg_Rune:onRuneBuy(msg)
	
end	

-- 增加新符文
function NetworkMsg_Rune:addNewRune(msg)
	Rune:getNewRune(msg);
end

-- 镶嵌符文
function NetworkMsg_Rune:inlayRune(msg)
	Rune:inlayCallBack(msg);
	RuneInlayPanel:runeInlayCallBack(msg);
end

-- 卸下符文
function NetworkMsg_Rune:unlayRune(msg)
	Rune:unlayCallBack(msg);
	RuneInlayPanel:runeUnlayCallBack(msg);
end

function NetworkMsg_Rune:levelupRune(msg)
	Rune:levelupCallBack(msg);
	RuneComposePanel:levelupCallBack(msg);
end

function NetworkMsg_Rune:delRune(msg)
	Rune:delRune(msg);
	RuneComposePanel:refreshRuneList();
end

function NetworkMsg_Rune:composeRune(msg)
	Rune:composeCallBack(msg);
	RuneComposePanel:composeCallBack(msg);
	RuneComposePanel:refreshRuneList();
end

function NetworkMsg_Rune:avtiveCallBack(msg)
	Rune:activeCallBack(msg.pid);
	RuneInlayPanel:activeCallBack(msg.pid);
end
