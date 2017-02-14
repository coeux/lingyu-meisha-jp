--limittaskPanel.lua
--========================================================================
--限时任务界面

LimitTaskPanel =
	{
		currentNpc;	-- 当前对话NPC，自动寻路或点击NPC时指定
		isPause = false;
		getPartenerList = {} --游戏加载时有没有可以获得的卡牌
	};	
local taskNews = 
{
	LANG_limit_task_1;	--'可以免费吃披萨了'
	LANG_limit_task_4;	--'npc商店'				
	LANG_limit_arena;   --'竞技场'
	LANG_limit_achievement1; --'收集任务'
	LANG_limit_achievement2; --'成长任务'
	LANG_limit_fightreward;	 --'战斗力礼包'
	LANG_limit_levelreward;	 --'等级礼包'
	LANG_limit_getpartner;  --'获得伙伴'
	LANG_limit_worldboss;	--世界boss
	LANG_limit_scuffle;
}

local taskImage = 
{
	'userGuide/tasktip2.ccz';	--'可以免费吃披萨了'
	'userGuide/tasktip1.ccz';	--'npc商店'			
	'worldmap/worldmap_03.ccz';   --'竞技场'
	'userGuide/task_03.ccz'; --'收集任务'
	'userGuide/task_04.ccz'; --'成长任务'
	'userGuide/tasktip3.ccz';	 --'战斗力礼包'
	'userGuide/tasktip3.ccz';	 --'等级礼包'
	'';
	'userGuide/userguide_img20.ccz';	--世界boss
	'userGuide/userguide_img30.ccz';
}
--控件
local mainDesktop;
local taskPanel;
local newsIndex = 0;

local closeBtn;
local goBtn;
local msgPanel;
local msgLabel;
local iconImage;

local partnerPanel
local partnerCloseBtn
local partnerGoBtn
local partnerMsgPanel
local partnerMsgLabel
local partnerIconPanel
local removeResid
--变量初始化
local tasks = {};
local index = 0;
local isGetPartner;
--初始化面板
function LimitTaskPanel:InitPanel(desktop)
	--变量初始化
	tasks = {};
	index = 0;
	self.isPause = false;
	isGetPartner = false
	removeResid = nil
	--界面初始化
	mainDesktop = desktop;
	taskPanel = Panel(desktop:GetLogicChild('TipPanel'));
	taskPanel:IncRefCount();
	
	partnerPanel    = Panel(desktop:GetLogicChild('TipPartnerPanel'));
	partnerCloseBtn = partnerPanel:GetLogicChild('closeButton');
	partnerGoBtn    = partnerPanel:GetLogicChild('goButton');
	partnerMsgPanel = partnerPanel:GetLogicChild('messagePanel');
	partnerMsgLabel = partnerMsgPanel:GetLogicChild('message');
	partnerIconPanel= partnerPanel:GetLogicChild('iconPanel');
	partnerCloseBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','LimitTaskPanel:partnerHide');
	partnerGoBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','LimitTaskPanel:partnerOnClick');
	partnerPanel.Visibility = Visibility.Hidden
	
	closeBtn = taskPanel:GetLogicChild('closeButton');
	closeBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','LimitTaskPanel:Hide');
	goBtn = taskPanel:GetLogicChild('goButton');
	iconImage = taskPanel:GetLogicChild('iconImage');
	goBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','LimitTaskPanel:onClick');

	msgPanel = taskPanel:GetLogicChild('messagePanel');
	msgLabel = msgPanel:GetLogicChild('message');
	taskPanel.Visibility = Visibility.Hidden;	
	
	for i = 1,#self.getPartenerList do
		self:GetNewNews(LimitNews.getpartner)
	end
end
function LimitTaskPanel:partnerHide()
	self:Hide()
end
function LimitTaskPanel:partnerOnClick()
	self:goPartnerButton()
	--[[
	table.remove(tasks, index);
	table.remove(self.getPartenerList,#self.getPartenerList);
	if #self.getPartenerList == 0 then
		partnerPanel.Visibility = Visibility.Hidden
	end
	index = #tasks;
	self:PrintPartner('partnerOnClick')
	if index == 0 then
		LimitTaskPanel:Hide()	
	else
		if tasks[#tasks] == LimitNews.getpartner then
			taskPanel.Visibility = Visibility.Hidden
			partnerPanel.Visibility = Visibility.Visible
			]]
			--partnerMsgLabel.Text = taskNews[tasks[#tasks]];
			--self:initPartnerIcon()
		--else
			--msgLabel.Text = tostring(taskNews[tasks[#tasks]]);
			--taskPanel.Visibility = Visibility.Visible
			--partnerPanel.Visibility = Visibility.Hidden
		--end
	--end
	
end
function LimitTaskPanel:goPartnerButton()
	HomePanel:onEnterHomePanel();
	local roleId = self.getPartenerList[#self.getPartenerList]
	local role = ResTable:createRoleNoHave(roleId);
	HomePanel:setPartnerInfo(role)
	HomePanel:setNaviInfo(role)
end
function LimitTaskPanel:getUserGuideGoBtn()
	return goBtn;
end


function LimitTaskPanel:getUserGuidePartnerGoBtn()
	return partnerGoBtn;
end

--销毁
function LimitTaskPanel:Destroy()
	taskPanel:IncRefCount();
	taskPanel = nil;
end

--显示
function LimitTaskPanel:Show()
	if FightManager.mFightType == FightType.noviceBattle then	
		taskPanel.Visibility = Visibility.Hidden
	end
	if isGetPartner then
		self:initPartnerIcon()
		taskPanel.Visibility = Visibility.Hidden
		partnerPanel.Visibility = Visibility.Visible
	else
		taskPanel.Visibility = Visibility.Visible
		partnerPanel.Visibility = Visibility.Hidden
	end
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		taskPanel:SetScale(factor,factor);
		taskPanel.Translate = Vector2(200*(1-factor)/2,130*(1-factor)/2);
		partnerPanel:SetScale(factor,factor);
		partnerPanel.Translate = Vector2(200*(1-factor)/2,130*(1-factor)/2);
	end
	if UserGuidePanel:IsInGuidence(UserGuideIndex.npcshop, 1) then
		UserGuidePanel:ShowGuideShade( LimitTaskPanel:getUserGuideGoBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0);
	end
end

--隐藏
function LimitTaskPanel:Hide()	
	taskPanel.Visibility = Visibility.Hidden;
	partnerPanel.Visibility = Visibility.Hidden;
	self.getPartenerList = {}
	tasks = {};
	index = 0;
end
function LimitTaskPanel:initPartnerIcon()
	partnerIconPanel:RemoveAllChildren()
	local roleId = self.getPartenerList[#self.getPartenerList]
	local role = ResTable:createRoleNoHave(roleId);
	local roleIcon = customUserControl.new(partnerIconPanel, 'cardHeadTemplate')
	roleIcon.initWithNotExistRole(role, 55, false);
	roleIcon.ctrl:GetLogicChild('shadow').Visibility = Visibility.Hidden
end

--获得新的推荐
function LimitTaskPanel:GetNewNews(num)
	if ActorManager.user_data.role.lvl.level <= 8 and LimitNews.getpartner ~= num then
		return 
	end
	if num ~= LimitNews.getpartner then
		for _,index in ipairs(tasks) do
			if index == num then
				return
			end
		end
		isGetPartner = false
	else
		isGetPartner = true
	end
	table.insert(tasks,num);
	--worldBoss
	if WorldMapPanel.worldBossFlag == 1 and ActorManager.user_data.role.lvl.level > 22 then
		for _,index in ipairs(tasks) do
			if index == LimitNews.worldBoss then
				table.remove(tasks,index);
				break;
			end
		end
		table.insert(tasks,LimitNews.worldBoss);
		isGetPartner = false;
		num = LimitNews.worldBoss;
	end
	if isGetPartner then
		partnerMsgLabel.Text = taskNews[tasks[#tasks]];
	else
		msgLabel.Text = taskNews[tasks[#tasks]];
		iconImage.Image = GetPicture(taskImage[tasks[#tasks]]);
		if tasks[#tasks] == 3 then
			iconImage.Scale = Vector2(1.4, 1.2);
		else
			iconImage.Scale = Vector2(1, 1);
		end
	end
	index = #tasks;
	if index == 1 then
		LimitTaskPanel:Show();
	else
		if  num == LimitNews.getpartner then
			taskPanel.Visibility = Visibility.Hidden
			partnerPanel.Visibility = Visibility.Visible
			partnerMsgLabel.Text = taskNews[tasks[#tasks]];
			self:initPartnerIcon()
		else
			msgLabel.Text = tostring(taskNews[tasks[#tasks]]);
			iconImage.Image = GetPicture(taskImage[tasks[#tasks]]);
			if tasks[#tasks] == 3 then
				iconImage.Scale = Vector2(1.4, 1.2);
			else
				iconImage.Scale = Vector2(1, 1);
			end
			taskPanel.Visibility = Visibility.Visible;
			partnerPanel.Visibility = Visibility.Hidden
		end
	end
end
function LimitTaskPanel:updatePartnerTask(num,resid)
	removeResid = resid
	self:updateTask(num)
	
end
function LimitTaskPanel:updateTask(num)
	if #tasks > 0 then
		for i=1, #tasks do
			if num == tasks[i] then
				table.remove(tasks, i);
				break;
			end
		end
	end
	for i = 1,#self.getPartenerList do
		if removeResid and self.getPartenerList[i] == removeResid then
			table.remove(self.getPartenerList,i)
			removeResid = 0
			break
		end
	end
	if #self.getPartenerList == 0 then
		partnerPanel.Visibility = Visibility.Hidden
	end

	for i=#tasks, 1, -1 do 
		if tasks[i] == LimitNews.worldBoss then 
			table.remove(tasks,i) 
        end 
    end 

	if #tasks > 0 then
		if tasks[#tasks] == LimitNews.getpartner then
			taskPanel.Visibility = Visibility.Hidden
			partnerPanel.Visibility = Visibility.Visible
			partnerMsgLabel.Text = taskNews[tasks[#tasks]];
			self:initPartnerIcon()
		else
			msgLabel.Text = tostring(taskNews[tasks[#tasks]]);
			iconImage.Image = GetPicture(taskImage[tasks[#tasks]]);
			if tasks[#tasks] == 3 then
				iconImage.Scale = Vector2(1.4, 1.2);
			else
				iconImage.Scale = Vector2(1, 1);
			end
			taskPanel.Visibility = Visibility.Visible
			partnerPanel.Visibility = Visibility.Hidden
		end
		index = #tasks;
	else
		self:Hide();
	end
end

--立即前往点击
function LimitTaskPanel:onClick()
	if tasks[index] == LimitNews.fightreward then
		self.isPause = true;
	end
	LimitTaskPanel:goNews(tasks[index]);
	table.remove(tasks, index);
	--worldBoss
	if WorldMapPanel.worldBossFlag == 1 and ActorManager.user_data.role.lvl.level > 22 then
		for _,index in ipairs(tasks) do
			if index == LimitNews.worldBoss then
				table.remove(tasks,index);
				break;
			end
		end
		table.insert(tasks,LimitNews.worldBoss);
	end
	index = #tasks;

	if index == 0 then
		LimitTaskPanel:Hide()	
	else
		if tasks[index] == LimitNews.getpartner then
			taskPanel.Visibility = Visibility.Hidden
			partnerPanel.Visibility = Visibility.Visible
			partnerMsgLabel.Text = taskNews[tasks[#tasks]];
			self:initPartnerIcon()
		else
			msgLabel.Text = taskNews[tasks[#tasks]];
			iconImage.Image = GetPicture(taskImage[tasks[#tasks]]);
			if tasks[#tasks] == 3 then
				iconImage.Scale = Vector2(1.4, 1.2);
			else
				iconImage.Scale = Vector2(1, 1);
			end
			taskPanel.Visibility = Visibility.Visible
			partnerPanel.Visibility = Visibility.Hidden
		end
	end
	if UserGuidePanel:IsInGuidence(UserGuideIndex.npcshop, 1) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.npcshop);
	end
end
--加入相关限时信息
function LimitTaskPanel:goNews(num)
	if num == LimitNews.addpower then
		ActivityAllPanel:OnShow();
	elseif num == LimitNews.npcshop then
		LimitTaskPanel:NpcShop();
	elseif num == LimitNews.arena then
		MainUI:onJiangJiChangClick()
		LuaTimerManager.isShowArena = false
	elseif num == LimitNews.achievement1 then
		PlotTaskPanel:onShow();
		PlotTaskPanel:checktaskindex(3);
	elseif num == LimitNews.achievement2 then
		PlotTaskPanel:onShow();
		PlotTaskPanel:checktaskindex(4);
	elseif num == LimitNews.fightreward then
		ActivityAllPanel:OnShow();
		ActivityAllPanel:FightReward();
	elseif num == LimitNews.levelreward then
		ActivityAllPanel:OnShow();
		ActivityAllPanel:LevelReward();
	elseif num == LimitNews.worldBoss then
		self:WroldBoss();
	elseif num == LimitNews.scuffle then
		ScufflePanel:rqScuffleState();
	end
end

function LimitTaskPanel:WroldBoss()
	MainUI:onWorldClick();
end

function LimitTaskPanel:NpcShop()
	LimitTaskPanel:findNpc(103, FindPathType.npcshop)
end

function LimitTaskPanel:CityBoss()
	LimitTaskPanel:findNpc(201, FindPathType.barrier)
end

function LimitTaskPanel:UnionHongbao()
	MenuPanel:Ceshi();
--	LimitTaskPanel:findNpc(113, FindPathType.npcshop)
end

--自动寻路
function LimitTaskPanel:isHeroStandInNpc(npcid)
	local pos = ActorManager.hero:GetPosition();
	local cor = resTableManager:GetValue(ResTable.npc, tostring(npcid), 'coord');
	if cor[2] > GlobalData.UnionSceneMaxY then
		cor[2] = GlobalData.UnionSceneMaxY;
	end
	if pos.x == cor[1] and pos.y == cor[2] then
		return true;
	else	
		return false;
	end
end

--
function LimitTaskPanel:findNpc(npcid, type)
	if nil ~= npcid then		
		--寻找NPC和当前NPC是同一个人，不需要寻路
		if self:isHeroStandInNpc(npcid) then
			TaskDialogPanel:onPopUpNpcDialog();
			return;
		end
		self.currentNpc = npcid;
		--标示自动寻路，弹出NPC对话框或向关卡出发时重新置为no
	--	ActorManager.hero:SetFindPathType(FindPathType.union);
		ActorManager.hero:SetFindPathType(type);
		local data = resTableManager:GetRowValue(ResTable.npc, tostring(npcid));
		local sceneid = data['city_id'];
		--同一个主城
		if ActorManager.user_data.sceneid == sceneid then
			--显示自动寻路面板
			if true ~= noFindPathPanel then
				TaskFindPathPanel:Show();	
			end	
			local x,y = VerifyScenePos(MainUI:GetSceneType(), data['coord'][1], data['coord'][2]);		
			--直接寻路到传送点
			local pos = Vector2(x, y);
			--通知服务器移动到指定位置
			local msg = {};
			msg.uid = ActorManager.user_data.uid;
			msg.sceneid = ActorManager.user_data.sceneid;
			msg.x = math.floor(pos.x);
			msg.y = math.floor(pos.y);
			Network:Send(NetworkCmdType.nt_move, msg, true);	
			ActorManager.hero:MoveTo(pos);
		--不同主城
		else
			--弹出世界地图
			WorldPanel:onFindPathScene(sceneid);
			local x,y = VerifyScenePos(MainUI:GetSceneType(), data['coord'][1], data['coord'][2]);
			--直接寻路到传送点
			local pos = Vector2(x, y);
			ActorManager.hero:MoveTo(pos);
		end
	end
end

