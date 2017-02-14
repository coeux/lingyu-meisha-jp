--effectEditor.lua

--========================================================================
--特效编辑器类

EffectEditor = 
	{
		attackerID		= nil;
		targeterID		= {};
		targetNum		= 1;
	};
	
	
local scene;
local desktop;

--初始化
function EffectEditor:Initialize()

	--========================================================================
	--创建战斗场景
	scene = SceneManager:LoadFightScene('2002');
	SceneManager:SetActiveScene(scene);
	
	--设置空桌面
	desktop = uiSystem:CreateControl('Desktop');
	uiSystem:AddDesktop(desktop);
	uiSystem:SwitchToDesktop(desktop);
	SetDesktopSize(desktop);
	
	uiSystem:LoadResource('godsSenki');
	
	--========================================================================
	--初始化角色
	
	EffectEditor:loadAttacker();
	EffectEditor:loadTargeter(self.targetNum);
	
	
	--========================================================================
	--战斗初始化
	
	--初始化伤害显示缓存
	DamageLabelManager:Initialize();
	
end

--加载攻击者
function EffectEditor:loadAttacker()
	
	--攻击者
	--local attacker = ActorManager:CreatePFighter('1001');		--女战士
	local attacker = ActorManager:CreatePFighter('1003');		--黑骑士
	
	
	attacker:SetAnimation(AnimationType.f_idle);

	SceneManager:GetActiveScene():AddSceneNode(attacker);

	attacker:SetPosition( Vector3(-appFramework.ScreenWidth * 0.25, 0, 0) );
	self.attackerID = attacker:GetID();
	
end

--加载受击者
function EffectEditor:loadTargeter( num )

	local targeterPos = 
		{
			Vector3(appFramework.ScreenWidth * 0, -50, 0);
			Vector3(appFramework.ScreenWidth * 0.25, 50, 0);
			Vector3(appFramework.ScreenWidth * 0.25, -50, 0);
		};
		
	--受击者设置
	for i = 1, num do
		
		--受击者
		local targeter = ActorManager:CreateMFighter('M021',{level = 1; actorType = ActorType.monster});
		targeter:SetAnimation(AnimationType.f_idle);
		targeter:SetDirection(DirectionType.faceleft);
		
		SceneManager:GetActiveScene():AddSceneNode(targeter);
		targeter:SetPosition( targeterPos[i] );
		targeter.m_hp = 10000000;
		
		table.insert( self.targeterID, targeter:GetID() );

	end
	
end

--更新
function EffectEditor:Update( elapse )

	FightManager.state = FightState.fightState;
	FightManager.isOver = false;
	ActorManager:Update(elapse);
	EffectManager:Update(elapse);
	FightManager:Update(elapse);	

end

--执行脚本
function EffectEditor:RunScript( effectName )

	local effectScript = effectScriptManager:CreateEffectScript(effectName);
	effectScript:SetArgs( 'Attacker', self.attackerID );
	effectScript:SetArgs( 'Targeter', self.targeterID );
	effectScript:SetArgs( 'DamageType', AttackType.skill );
	effectScript:SetArgs( 'DamageData', 100 );
	effectScript:TakeOff();
	
end
