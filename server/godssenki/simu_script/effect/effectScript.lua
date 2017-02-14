--=================================================================================
--特效脚本类
EffectScript = class();

function EffectScript:constructor(id, name)
	--状态相关
	self.ID = id;
	self.m_name = name;
	self.m_runningState = true;
	
	--脚本
	self.m_effect = _G[name];
	self.m_effect.init(self);
	
	--事件相关
	self.m_eventInfoList = {};
	self.m_curEventInfo = 1;
	self.m_curFrameNum = 0;
end

--销毁
function EffectScript:Destroy()
	self.m_effect.clean(self);
end

--更新
function EffectScript:Update(deltaFrameNum)
	if (not self.m_runningState) then
		return ;
	end
	
	self.m_curFrameNum = self.m_curFrameNum + deltaFrameNum;
	
	while true do
		if (self.m_curEventInfo > #(self.m_eventInfoList)) then
			effectScriptManager:DestroyEffectScript(self.ID);
			break;
		end	
		
		if (self.m_curFrameNum < self.m_eventInfoList[self.m_curEventInfo].time) then	
			break;		--时间未到	
		end

		self.m_effect[self.m_eventInfoList[self.m_curEventInfo].func](self)		--执行事件函数
		self.m_curEventInfo = self.m_curEventInfo + 1;
	end
end

--获取id
function EffectScript:GetID()
	return self.ID;
end

--名字
function EffectScript:GetName()
	return self.m_name;
end

--注册事件
function EffectScript:RegisterEvent(time, callbackFunc)
	local info = {time = time, func = callbackFunc};
	local length = #(self.m_eventInfoList);
	local index = 1;

	while ( (index <= length) and (info.time > self.m_eventInfoList[index].time) ) do	
		index = index + 1;			
	end

	table.insert(self.m_eventInfoList, index, info);
end

--执行脚本
function EffectScript:TakeOff()
	self.m_effect.run(self);
end

--暂停
function EffectScript:Pause()
	self.m_runningState = false;
end

--继续
function EffectScript:ContinueNext()
	if (self.m_curEventInfo > #(self.m_eventInfoList)) then
		--删除脚本
		effectScriptManager:DestroyEffectScript(self.ID);
		return ;
	end
	self.m_runningState = true;
end

--设置参数
function EffectScript:SetArgs(name, value)
	self.m_effect.info_pool[self.ID][name] = value;
end
