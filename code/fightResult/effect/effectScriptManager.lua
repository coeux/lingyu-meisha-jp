--=================================================================
--特效脚本管理类
effectScriptManager = 
	{
		elapse 				= 0;				--累积时间
		currentFrame 		= 0;				--当前时间
		canUseEffectID 		= 0;				--可以使用的特效ID
		effectList			= {};				--特效列表(技能脚本)
		effectTableList		= {};				--技能特效数组
		invalidEffectList	= {};				--无效的特效列表
	}

--初始化
function effectScriptManager:Init()
	self.elapse 			= 0;
	self.currentFrame 		= 0;
	self.canUseEffectID 	= 0;
	self.effectList			= {};
	self.invalidEffectList	= {};
end

--销毁
function effectScriptManager:Destroy()
	self.effectList			= {};
end

--更新
function effectScriptManager:Update(Elapse)
	self.elapse = self.elapse + Elapse;
	
	local frameNum = math.floor(self.elapse * GlobalData.FPS);
	frameNum = frameNum - self.currentFrame;
	if 0 == frameNum then
		return ;
	end
	self.currentFrame = self.currentFrame + frameNum;
	
	--删除无效特效
	for _,effectScriptID in ipairs(self.invalidEffectList) do
		local effectScript = self.effectList[effectScriptID];
		if effectScript ~= nil then
			effectScript:Destroy();
			self:RemoveEffectScript(self.effectList[effectScriptID]);
			self.effectList[effectScriptID] = nil;
		end	
	end
	self.invalidEffectList = {};	
	
	--更新脚本
	for _,effectScript in pairs(self.effectList) do	
		effectScript:Update(frameNum);
	end

end

--创建脚本
function effectScriptManager:CreateEffectScript(name)
	self.canUseEffectID = self.canUseEffectID + 1;
	local effectScript = EffectScript.new(self.canUseEffectID, name);
	
	self.effectList[effectScript:GetID()] = effectScript;	
	table.insert(self.effectTableList, effectScript);
	
	return effectScript;
end

--删除脚本
function effectScriptManager:RemoveEffectScript(effectScript)
	local index = 1;
	while true do
		if self.effectTableList[index] == effectScript then
			table.remove(self.effectTableList, index);
			break;
		end
		index = index + 1;
	end
end

--获得脚本
function effectScriptManager:GetEffectScript(id)
	return self.effectList[id];
end

--暂停所有脚本
function effectScriptManager:PauseAllEffectScript()
	for _,effectScript in pairs(self.effectList) do	
		effectScript:Pause();
	end
end

--恢复所有技能脚本
function effectScriptManager:ResumeAllEffectScript()
	for _,effectScript in pairs(self.effectList) do	
		effectScript:Resume();
	end
end

--删除脚本
function effectScriptManager:DestroyEffectScript(effectScript)
	table.insert(self.invalidEffectList, effectScript:GetID());
end

function effectScriptManager:DestroyEffectScriptWithID(id)
	table.insert(self.invalidEffectList, id);
end

--删除所有脚本
function effectScriptManager:DestroyAllEffectScript()
	self.effectList = {};
end

--执行所有脚本
function effectScriptManager:TakeOff()
	for _,effectScript in ipairs(self.effectList) do
		effectScript:TakeOff();
	end
end
