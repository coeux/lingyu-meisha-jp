P03_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P03_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P03_normal_attack.info_pool[effectScript.ID].Attacker)
		P03_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow01")
		PreLoadSound("bow")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 11, "b" )
		effectScript:RegisterEvent( 12, "c" )
	end,

	a = function( effectScript )
		SetAnimation(P03_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
		P03_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( P03_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(40, 85), 3, 1200, 300, 1, P03_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-40, 0), "arrow01", effectScript)
		PlaySound("bow")
	end,

	c = function( effectScript )
		DetachEffect(P03_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(P03_normal_attack.info_pool[effectScript.ID].Attacker, P03_normal_attack.info_pool[effectScript.ID].Targeter, P03_normal_attack.info_pool[effectScript.ID].AttackType, P03_normal_attack.info_pool[effectScript.ID].AttackDataList, P03_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
