
--========================================================================
--诸神战记类

GodsSenki =
	{
	};


--初始化
function GodsSenki:Init()

end

--销毁
function GodsSenki:Destroy()

end

--进入
function GodsSenki:onEnter()
	
end

--离开
function GodsSenki:onLeave()
end

--更新
function GodsSenki:Update( Elapse )

	FightManager:Update(Elapse);
	FightShowSkillManager:Update(Elapse);		--技能展示更新
	ActorManager:Update(Elapse);
	EffectManager:Update(Elapse);
    effectScriptManager:Update(Elapse)

end
