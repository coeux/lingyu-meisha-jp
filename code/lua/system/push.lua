--push.lua

--========================================================================
-- 推送类

Push =
	{
	};

--变量

--推送配置地址
--local urlAddress			= 'http://god.123u.com/push/91/push.json'; 

local SystemDisplayId = 1;

--12点
local PisaPushAmTime = 12*3600;
--18点
local PisaPushPmTime = 18*3600;
--24小时
local OneDay = 24*3600;

local InvalidDate = -1; 		--无效时间

--注册推送
function Push:RegisterPush()
	
	--取消该应用的注册通知
	appFramework:CancelAllLocalNotifications();
	
	self:registerPowerPush();
end	

--注册体力满或领体力推送
function Push:registerPowerPush()
	for index = 0, 2 do
		self:registerOnePush(index);
	end
end

--注册一个推送
function Push:registerOnePush(index)
	local data = resTableManager:GetRowValue(ResTable.powerpush, tostring(index));
	local push = {};
	push.pushid = index;
	push.displayid = SystemDisplayId;
	push.date = self:getPushDateById(push.pushid);
	push.info = data['info'];
	push.title = data['name'];
	--注册推送通知
	if InvalidDate ~= push.date and ((index == 0 and SystemPanel.pisaPushAmFlag) or (index == 1 and SystemPanel.pisaPushPmFlag) or (index == 2 and SystemPanel.energyFullPushFlag)) then
		appFramework:ScheduleLocalNotification(cjson.encode(push));
	end
end

--注册体力满推送
function Push:registerEnergyFullPush()
	self:registerOnePush(2);
end

function Push:getPushDateById(id)
	local date = 0;
	--12点领取体力
	if 0 == id then
		date = self:getSecondTo12();
	--18点领取体力
	elseif 1 == id then
		date = self:getSecondTo18();	
	--体力回复满通知
	else
		date = self:getSecondToFullEnergy();	
	end
	return date;
end

--到下一次12点的秒数
function Push:getSecondTo12()
	if LuaTimerManager:GetCurrentTime() < PisaPushAmTime then
		date = PisaPushAmTime - LuaTimerManager:GetCurrentTime();
	else
		date = PisaPushAmTime - LuaTimerManager:GetCurrentTime() + OneDay;
	end
	return date;
end

--到下一次18点的秒数
function Push:getSecondTo18()
	if LuaTimerManager:GetCurrentTime() < PisaPushPmTime then
		date = PisaPushPmTime - LuaTimerManager:GetCurrentTime();
	else
		date = PisaPushPmTime - LuaTimerManager:GetCurrentTime() + OneDay;
	end
	return date;
end

--到下一次体力满的秒数，整5分钟时恢复一点
function Push:getSecondToFullEnergy()
	if ActorManager.user_data.power >= Configuration.MaxPower then
		return InvalidDate;
	else
		local hour, min, sec = Time2HourMinSec( LuaTimerManager:GetCurrentTime() );
		local newMin = math.ceil((min + 1)/5) * 5;
		local time = 0;
		--下一个整5分钟的秒数
		time = time + hour*3600 + newMin*60 - LuaTimerManager:GetCurrentTime();
		--没五分钟恢复一点体力
		time = time + (Configuration.MaxPower - ActorManager.user_data.power) * 60 * 5;
		return time;
	end
end

