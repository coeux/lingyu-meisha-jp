--fightAchievement.lua
--=================================================================
--战斗成就类

FightAchievementClass = class();


--==判断成就是否达成的函数
local function checkHp(requireHpPercnt)
	local currentHPPercnt = FightManager:getFinalHpPercent();
	return ((currentHPPercnt*100) >= requireHpPercnt);
end

local function cardDoentUse(requireCardType)
	local func = function(role_resid) 
		local team = MutipleTeam:getCurrentTeam();
		local isInTeam = false;
		for i=1, 5 do
			if team[i] > 0 then
				if tonumber(ActorManager:GetRole(team[i]).resid) == tonumber(role_resid) then
					isInTeam = true;
					break;
				end
			end
		end
		return (not isInTeam);
	end
	return func(requireCardType);
end

local function cardDoUse(requireCardType)
	local func = function(role_resid) 
		local team = MutipleTeam:getCurrentTeam();
		local isInTeam = false;
		for i=1, 5 do
			if team[i] > 0 then
				if tonumber(ActorManager:GetRole(team[i]).resid) == tonumber(role_resid) then
					isInTeam = true;
					break;
				end
			end
		end
		return isInTeam;
	end
	return func(requireCardType);
end

local function timeLimit(requireTime)
	local useTime = FightUIManager:getTimeGone();
	return useTime <= requireTime;
end

local function timeMonster(monsterID, requireTime)
	local func = function(monsterid, time)
		if FightManager:findDeadTime(monsterid) <= time then
			return true;
		end
		return false;
	end
	return func(monsterID, requireTime);
end

local function comboNeed(requireCombo)
	local comboMax = FightComboQueue:getMaxCombo();
	return comboMax >= requireCombo;
end

local function nodeath()
	if FightManager:getDeadNum() == 0 then
		return true;
	end
	return false;
end

local AchievementFuncList =
	{
		[AchievementType.HpPercent]			= checkHp;
		[AchievementType.CardDoentUse]		= cardDoentUse;
		[AchievementType.CardUse]			= cardDoUse;
		[AchievementType.TimeLimit]			= timeLimit;
		[AchievementType.TimeMonster]		= timeMonster;
		[AchievementType.ComboNeed]			= comboNeed;
		[AchievementType.Nodeath]			= nodeath
	}	

local hpV = function(res, value)
	local str = string.gsub(res, "a1", tostring(value[1]));
	return str;
end

local cardNUV = function(res, value)
	local name = resTableManager:GetValue(ResTable.actor, tostring(value[1]), 'name')
	local str = string.gsub(res, "a1", name);
	return str;
end

local cardUV = function(res, value)
	local name = resTableManager:GetValue(ResTable.actor, tostring(value[1]), 'name')
	local str = string.gsub(res, "a1", name);
	return str;
end

local timeLV = function(res, value)
	local str = string.gsub(res, "a1", tostring(value[1]));
	return str;
end

local timeMV = function(res, value)
	local name = resTableManager:GetValue(ResTable.monster, tostring(value[1]), 'name')
	local str = string.gsub(res, "a2", tostring(name));
	str = string.gsub(str, "a1", tostring(value[2]));
	return str;	
end

local comboV = function(res, value)
	local str = string.gsub(res, "a1", tostring(value[1]));
	return str;
end

local getAValue = 
	{
		[AchievementType.HpPercent]			= hpV;
		[AchievementType.CardDoentUse]		= cardNUV;
		[AchievementType.CardUse]			= cardUV;
		[AchievementType.TimeLimit]			= timeLV;
		[AchievementType.TimeMonster]		= timeMV;
		[AchievementType.ComboNeed]			= comboV;		
	}

local change16to2 = function(num16)
	local num16list = {
		['0'] = '0000';
		['1'] = '0001';
		['2'] = '0010';
		['3'] = '0011';
		['4'] = '0100';
		['5'] = '0101';
		['6'] = '0110';
		['7'] = '0111';
		['8'] = '1000';
		['9'] = '1001';
		['a'] = '1010';
		['b'] = '1011';
		['c'] = '1100';
		['d'] = '1101';
		['e'] = '1110';  
		['f'] = '1111';
	}
	if not num16list[num16] then return '0000'; end
	return num16list[num16];
end

--构造函数
function FightAchievementClass:constructor(barriersID)
	local achievementDataList	= resTableManager:GetValue(ResTable.barriers, tostring(barriersID), 'achievement');
	self.achievementList = {}
	if barriersID > 5000 or barriersID < 600 then
		return;
	end
		
	local barrier = (barriersID - 1000 >= 1) and (barriersID - 1000) or 1;
	local aFinishSting = string.sub(ActorManager.user_data.round.stars, barrier, barrier);
	self.achievementString = change16to2(aFinishSting);
	for i=1,3 do
		local achievementID = achievementDataList[i]
		if achievementID ~= nil then
			local achievement = resTableManager:GetRowValue(ResTable.achievement, tostring(achievementID));
			local aType = achievement['achievement_type'];
			local aValue = achievement['achievement_value'];
			local aName = resTableManager:GetValue(ResTable.achievement_name, tostring(aType), 'achievement_name');
			local aDes = resTableManager:GetValue(ResTable.achievement_name, tostring(aType), 'achievement_description');

			local achievementItem = {};			
			achievementItem.type = aType;
			achievementItem.name = aName;
			if aType == AchievementType.CardUse then
				achievementItem.des = LANG_Achievement_1;
			else
				achievementItem.des = getAValue[aType](aDes,aValue);
			end
			achievementItem.value = aValue;
			achievementItem.isComplete = (string.sub(self.achievementString, i, i) == '1') and true or false;
			achievementItem.CompleteFun = AchievementFuncList[tonumber(aType)];
			achievementItem.dealHead = function(headControl)
				if aType == AchievementType.CardUse then
					headControl.Visibility = Visibility.Visible;
					--if ActorManager:IsHavePartner(aValue[1]) then
						headControl.Image = GetPicture('navi/' .. resTableManager:GetValue(ResTable.navi_main, tostring(aValue[1]), 'role_path_icon') .. '.ccz');
						--headControl:GetLogicChild('nohaveLabel').Text = ' '
						--headControl:GetLogicChild('nohaveLabel').Visibility = Visibility.Hidden
					--else
						--headControl.Image = nil
						--headControl:GetLogicChild('nohaveLabel').Text = LANG_Achievement
						headControl:GetLogicChild('nohaveLabel').Visibility = Visibility.Hidden
					--end
					self:setUC(aValue[1]);
				else
					headControl.Visibility = Visibility.Hidden;
				end
			end
			self.achievementList[i] = achievementItem;
		end
	end

	local achievementItem = {};
	local aType = AchievementType.Nodeath;
	local aValue = {0};
	local aName = resTableManager:GetValue(ResTable.achievement_name, tostring(aType), 'achievement_name');
	local aDes = resTableManager:GetValue(ResTable.achievement_name, tostring(aType), 'achievement_description');

	achievementItem.type = aType;
	achievementItem.name = aName;
	achievementItem.des = aDes;
	achievementItem.value = aValue;
	achievementItem.isComplete = (string.sub(self.achievementString, 4, 4) == '1') and true or false;
	achievementItem.CompleteFun = AchievementFuncList[tonumber(aType)];
	achievementItem.dealHead = function(headControl)
		headControl.Visibility = Visibility.Hidden;
	end
	self.achievementList[4] = achievementItem;
end

function FightAchievementClass:Destory()
	self.achievementList = {}
end

function FightAchievementClass:getAchievementList()
	return self.achievementList;
end

function FightAchievementClass:getCompleteString()
	local res = '';
	for i=1,4 do
		if self.achievementList[i].CompleteFun(unpack(self.achievementList[i].value)) then
			res = res .. '1';
		else
			res = res .. '0';
		end
	end
	
	return res;
end

function FightAchievementClass:getCompleteRes()
	local res = 0;
	for i=1, 4 do
		local cNum = 0;
		if self.achievementList[i].isComplete then
			cNum = 1;
		elseif self.achievementList[i].CompleteFun(unpack(self.achievementList[i].value)) then
			cNum = 1;
			self.achievementList[i].isComplete = true;
		else
			cNum = 0;
		end
		res = res + cNum * math.pow(2,4-i);
	end
	return string.format("%x",res);
end

function FightAchievementClass:getRankString(barriersID)
	local rankString;
	local barrierID = (barriersID - 1000 >= 1) and (barriersID - 1000) or 1;
	local aFinishString = string.sub(ActorManager.user_data.round.stars, barrierID, barrierID);
	local aRes = change16to2(aFinishString);
	rankString = string.sub(aRes, 4, 4);
	return rankString;
end

function FightAchievementClass:getAchievementString(barriersID)
	local aString;
	local barrierID = (barriersID - 1000 >= 1) and (barriersID - 1000) or 1;
	local aFinishString = string.sub(ActorManager.user_data.round.stars, barrierID, barrierID);
	local aRes = change16to2(aFinishString);
	aString = string.sub(aRes, 1, 3); 
	return aString;	
end

function FightAchievementClass:getStarNum(barriersID)
	local num=0;
	local barrierID = (barriersID - 1000 >= 1) and (barriersID - 1000) or 1;
	local aFinishString = string.sub(ActorManager.user_data.round.stars, barrierID, barrierID);
	local aRes = change16to2(aFinishString);
	for i=1, 4 do
		num = num + tonumber(string.sub(aRes,i,i));
	end
	return num;
end

function FightAchievementClass:clearUC()
	self.ucList = {};
end

function FightAchievementClass:setUC(resid)
	self.ucList[resid] = true;
end

function FightAchievementClass:check(resid)
	if self.ucList[resid] then
		return true;
	end
	return false;
end

function FightAchievementClass:getAllStarsNum()
	local str = ActorManager.user_data.round.stars
	local totalStarsNum = 0;
	local index = 1;
	while true do
		local indexChar = string.sub(str, index, index);
		if indexChar and indexChar > '0' then
			local aRes = change16to2(indexChar);
			local num = 0;
			for i=1, 4 do
				num = num + tonumber(string.sub(aRes,i,i));
			end
			totalStarsNum = totalStarsNum + num;
			index = index + 1;
		else
			break;
		end
	end

	return totalStarsNum;
end