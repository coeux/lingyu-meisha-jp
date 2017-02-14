--killBoss.lua

--========================================================================
--杀星系统

local killBossMainScene;
local isKillCityBoss;
local killBossId;
local killBossReward = {};
local killCount;
local posx = 0;
local posy = 0;
local cityBossNum = {};
local killBossTime = {{}}
local resetBossTime = 0;
local totalKillCount = 5;

StarKillBossMgr =
{
	bossNum = 3,
	totalTime = 10,
	cityBosses = {},
	disAppearBossIds = {}
};

--初始化场景
function StarKillBossMgr:InitBossScene(mainScene)
	print("StarKillBossMgr:InitBossScene");
	killBossMainScene = mainScene;
	isKillCityBoss = false;
	killBossId = -1;
	-- load boss data first
	self:RequestBossData(mainScene.resID);
end

--将City boss加入场景
function StarKillBossMgr:AddNPCToScene(curCityBoss)
	npcId = curCityBoss.resid
	posx = curCityBoss.x
	posy = curCityBoss.y
	level = curCityBoss.level
	isBossFighting = curCityBoss.fighting
	local cityBoss = ActorManager:CreateCityBoss(npcId, curCityBoss.id, posx, posy);
	cityBoss:InitData();
	cityBoss:InitAvatar();
	cityBoss:InitHead();
	cityBoss:SetBossLevel(level);
	cityBoss:SetBossFighting(isBossFighting);

	cityBoss:SetAwaitAimation();
	killBossMainScene:AddSceneNode(cityBoss);

	--table.insert(killBossMainScene.bossList, cityBoss);
	killBossMainScene.bossList[cityBoss.orderId] = cityBoss
	--LuaMainScene:addSceneBoss(cityBoss);
end

function StarKillBossMgr:RemoveAllCityBoss()
	for k,boss in ipairs(killBossMainScene.bossList) do
		killBossMainScene:RemoveSceneNode(boss);
	end

	killBossMainScene.bossList = {}
	killBossMainScene:ClearBossRects();
	self.cityBosses = {}
	self.disAppearBossIds = {}
end

function StarKillBossMgr:ClearDeadBosses()
	local killedBosses = {}
	for bossId, curBoss in pairs(self.cityBosses) do
		local curCityBoss = self.cityBosses[bossId];
		local bossKillCount = curCityBoss.killcount;

		if bossKillCount ~= nil then
			if bossKillCount >= 20 then
				table.insert(killedBosses, curCityBoss.id);
			end
		end
	end

	StarKillBossMgr:ClearSceneBoss(killedBosses);
end

--进入击杀boss战斗
function StarKillBossMgr:OnKillCityBoss()
	self:RequestKillBoss();
end

--收到boss请求的回应
function StarKillBossMgr:GotRequestBossDataRes(msg)
	print("The boss data is: "..tostring(msg));
	self:RemoveAllCityBoss();
	self.cityBosses = {}
	killBossMainScene:ClearBossRects();

	local cd = msg.cd;
	killCount = msg.killcount;

	--self.cityBosses = msg.bosses;
	for k,boss in ipairs(msg.bosses) do
		self.cityBosses[boss.id] = boss;
	end
	cityBossNum[tostring(killBossMainScene.resID)] = #self.cityBosses

	if self:IsCurrentTimeKillBoss() == true then
		PromotionPanel:ShowKillBossBtn();
	else
		PromotionPanel:HideKillBossBtn();
	end

	if #msg.bosses > 0 then
		resetBossTime = LuaTimerManager:GetCurrentTime();
	end

	PromotionPanel:RefreshActivityStatus();

	for k, boss in  pairs(self.cityBosses) do
		self:AddNPCToScene(boss);
	end

	killBossMainScene:InitSceneBoss(self.cityBosses);
	StarKillBossMgr:ClearDeadBosses();
end

function StarKillBossMgr:IsCurrentTimeKillBoss()
	local serverCurentTime = LuaTimerManager:GetCurrentTime();
	local isBossTime = StarKillBossMgr:IsKillBossTime(serverCurentTime);

	if serverCurentTime - resetBossTime < 10 then
		return true;
	else
		return isBossTime
	end
end

function StarKillBossMgr:IsKillBossTime(curTime)
	if curTime == nil then
    print("killboss: curTime is nil")
		return false;
	end

	local hour, min, sec = Time2HourMinSec(curTime);
	if (hour == 0 or hour >= 9) and min < 60 then
		return true;
	else
    print("killboss: real time judge")
		return false;
	end
end

--请求boss信息
function StarKillBossMgr:RequestBossData(sceneid)
	local msg = {};
	msg.sceneid = tonumber(sceneid);
	--LuaMainScene:ClearMainSceneBoss();
	killBossMainScene.bossList = {}
	self.cityBosses = {};
	self.disAppearBossIds = {};
	isKillCityBoss = false;
	killBossId = -1;
	print("RequestBossData, sceneId:"..sceneid);
	print("Request boss data:"..tostring(msg));
	Network:Send(NetworkCmdType.req_city_boss_info_t, msg);
end

function StarKillBossMgr:IsAllBossKilled(sceneid)
	local sceneBossNum = cityBossNum[tostring(sceneid)];
	if sceneBossNum == 0 then
		return true;
	else
		return false;
	end
end

function StarKillBossMgr:ResetBossNum()
	cityBossNum = {}
end

--请求杀boss
function StarKillBossMgr:RequestKillBoss()

	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.invasion then
		--local contents = {};
		--table.insert(contents, {cType = MessageContentType.Text; text = LANG_killBoss_5});
		--table.insert(contents, {cType = MessageContentType.Text; text = tostring(FunctionOpenLevel.invasion), color = Configuration.RedColor});
		--table.insert(contents, {cType = MessageContentType.Text; text = LANG_killBoss_6});
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_killBoss_7..FunctionOpenLevel.invasion..LANG_killBoss_8);
		return ;
	end

	if self:IsCurrentTimeKillBoss() == false then
		self:ResetBossNum()
		return
	end

	if isKillCityBoss == true then
		print ("You are killing a boss now");
	--	return
	end

	local foundBoss = false;
	for curBossId, boss in pairs(self.cityBosses) do
		if curBossId == killBossId then
			foundBoss = true;
		end
	end

	if foundBoss == false then
    print("killboss: boss not found!")
		return;
	end

	if killCount >= totalKillCount or #self.disAppearBossIds >= 5 then
		for k, disBossId in pairs(self.disAppearBossIds) do
			print("boss"..disBossId.."   "..killBossId);
			if disBossId == killBossId then
				return
			end
		end

		if killCount >= totalKillCount then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_killBoss_1);
		end
		return
	end

	local bossName = "boss";

	local curBoss = killBossMainScene.bossList[killBossId];
	if curBoss == nil or curBoss.uiHead == nil then
		return
	end


	for k, disBossId in pairs(self.disAppearBossIds) do
		print("boss"..disBossId.."   "..killBossId);
		if disBossId == killBossId then
			return
		end
	end

	bossName = curBoss.uiHead.uiName.Text;

	local leftKillCount = totalKillCount - killCount;
	--local boxMsg = LANG_killBoss_2..bossName..LANG_killBoss_3..leftKillCount..LANG_killBoss_4;
	local okDelegate = Delegate.new(StarKillBossMgr, StarKillBossMgr.DoRequestKillBoss, 0);

	local contents = {};
	table.insert(contents, {cType = MessageContentType.Text; text = LANG_killBoss_2});
	table.insert(contents, {cType = MessageContentType.Text; text = bossName, color = QualityColor[curBoss.bossRate]});
	table.insert(contents, {cType = MessageContentType.Text; text = LANG_killBoss_3});
	--table.insert(contents, {cType = MessageContentType.Text; text = tostring(leftKillCount), color = Configuration.GreenColor});
	table.insert(contents, {cType = MessageContentType.Text; text = tostring(leftKillCount..LANG_killBoss_4)});

	MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate);

	--self:testBossMsg();
end

function StarKillBossMgr:DoRequestKillBoss()
	self:killBossSound()
	local msg = {};
	msg.bossid = killBossId;
	isKillCityBoss = true;
	print("RequestKillBoss, bossId:"..killBossId);
	Network:Send(NetworkCmdType.req_begin_fight_city_boss, msg);
end
function StarKillBossMgr:killBossSound()
	local team = MutipleTeam:getTeam(MutipleTeam:getDefault())
	--  战斗时从队伍中随机选一个英雄播放音效
	local len = 5
	for i=5,1, -1 do
		if team[i] == -1 then
			len = 5 - i
			break
		end
	end
	if len == 0 then
	else
		local random = math.random(1,len)
		local pid = team[6 - random]
		local role = ActorManager:GetRole(pid)   --  获取英雄信息
		local naviInfo
		if role.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
			naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid + 10000));
		else
			naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid));
		end
		--  获取声音
		if naviInfo then
			local path = random % (#naviInfo['soundlist']) + 1
			local soundPath = naviInfo['soundlist'][path]
			SoundManager:PlayVoice( tostring(soundPath) )
		end
	end
end
--杀星战斗结束时的回调函数
function StarKillBossMgr:OnInvasionFightCallBack(result)
	local msg = {};
	msg.bossid = killBossId;
	if (result == Victory.right) then
		msg.win = false;
	else
		msg.win = true;
		killCount = killCount + 1;
	end

	Network:Send(NetworkCmdType.req_fight_city_boss, msg);
end

--收到杀boss的消息反馈
function StarKillBossMgr:GotKillBossInfoRes(msg)
	print("GotKillBossInfoRes: "..tostring(msg));
end

function StarKillBossMgr:ClearSceneBoss(bossids)

	for k, bossId in pairs(bossids) do
		for curBossId, boss in pairs(self.cityBosses) do
			if bossId == curBossId then
				--table.remove(self.cityBosses, bossKey);
				local found = false;
				for _k, v in pairs(self.disAppearBossIds) do
					if v == bossId then
						found = true;
					end
				end
				if found == false then
					table.insert(self.disAppearBossIds, bossId);
				end
			end
		end

	end

	--if #self.disAppearBossIds >= #self.cityBosses then
	--	PromotionPanel:HideKillBossBtn();
	--end

	killBossMainScene:ClearSceneBoss(bossids);
end

function StarKillBossMgr:UpdateBossStatus(bossids, state)
	killBossMainScene:UpdateBossStatus(bossids, state);
end

--更新boss状态
function StarKillBossMgr:onUpdateBossStatus(msg)
	local bossesids = msg.bossids;
	local sceneid = msg.sceneid;
	local state = msg.state;    --0:无特殊状态,1:在战斗中,2:消失,3:出生

	if killBossMainScene == nil then
		return;
	end

	if sceneid == tonumber(killBossMainScene.resID) then
		if state == 3 then
			self:RemoveAllCityBoss()
			self:RequestBossData(sceneid)
		elseif state == 2 then
			self:ClearSceneBoss(msg.bossids)
		elseif state == 1 or state == 0 then
			self:UpdateBossStatus(bossesids, state)
		end
	end
end

--[[--发送杀boss消息
function StarKillBossMgr:RequestKillBossInfo(bossid, isWin)
	local msg = {};
	msg.bossid = bossid;
	msg.win = isWin;
	print("RequestKillBossInfo, bossId:"..bossid..", isWin:"..tostring(isWin));
	print("Request kill boss data:"..tostring(msg));
	Network:Send(NetworkCmdType.req_fight_city_boss_t, msg);
end
--]]
--获取boss等级
function StarKillBossMgr:GetBossResidAndLevel(bossid)
	for curId,boss in pairs(self.cityBosses) do
		if bossid == boss.id then
			return boss.resid, boss.level;
		end
	end

	return nil;
end

function StarKillBossMgr:GetBossId()
	return killBossId;
end

--设置杀星bossID
function StarKillBossMgr:SetKillBossId(bossId)
	killBossId = bossId;
end

function StarKillBossMgr:ResetKillBossData()
	isKillCityBoss = false;
	killBossId = -1;
end

--杀星结束
function StarKillBossMgr:OnKillBossFinished()
	isKillCityBoss = false;
	killBossId = -1;

--[[	local msg = {}
	msg.bossids = {1, 2};
	msg.sceneid = 1002;
	msg.state = 1;

	StarKillBossMgr:onUpdateBossStatus(msg)--]]
end

function StarKillBossMgr:OnSetKillBossReward(reward)
	killBossReward = reward;
end

function StarKillBossMgr:OnGetKillBossReward()
	return killBossReward;
end

function StarKillBossMgr:OnSetTargetPos(pos)
	posx = pos.x;
	posy = pos.y;
end

function StarKillBossMgr:IsTheSameTarget(pos)
	if posx == pos.x and pos.y == pos.y then
		return true;
	else
		return false;
	end
end

function StarKillBossMgr:testBossMsg()
	local msg = {}
	msg.bossids = {1, 2, 3, 4};
 	msg.sceneid = 1002;
	msg.state = 3;
	StarKillBossMgr:onUpdateBossStatus(msg);
end
