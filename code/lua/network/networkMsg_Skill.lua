--networkMsg_Skill.lua

--======================================================================
--技能

NetworkMsg_Skill =
	{
	};


--技能升级
function NetworkMsg_Skill:onUpLevel( msg )
	local role = ActorManager:GetRole(msg.pid);
	
	for _,skill in ipairs(role.skls) do
		if skill.skid == msg.skid then
			skill.level = skill.level + msg.num;
			break;
		end
	end	
	SkillStrPanel:SkillUpgradeSound(role.resid)
	SkillStrPanel:RefreshSkill();
	SkillStrPanel:UpdateInfo();
	--  更新战斗力
	uiSystem:UpdateDataBind()
	--PlayEffect('sec_output/', Rect(0, 0, 80, 0), 'sec');
end

--技能升阶
function NetworkMsg_Skill:onAdvanceLevel( msg )
	local role = ActorManager:GetRole(msg.pid);
	
	for _,skill in ipairs(role.skls) do
		if skill.skid == msg.skid then
			skill.resid = msg.skill.resid;
			break;
		end
	end
	SkillStrPanel:SkillUpgradeSound(role.resid)
	SkillStrPanel:RefreshSkill();
	SkillStrPanel:UpdateAdvInfo();
	SkillStrPanel:success()
	uiSystem:UpdateDataBind()

	--判断是否有技能能升阶,更新家按钮红点
	SkillStrPanel:IsSkillCanAdv()
end

