H108_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H108_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H108_normal_attack.info_pool[effectScript.ID].Attacker)
		H108_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow05")
		PreLoadSound("minifire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "q" )
		effectScript:RegisterEvent( 19, "d" )
		effectScript:RegisterEvent( 20, "dgf" )
		effectScript:RegisterEvent( 22, "f" )
	end,

	q = function( effectScript )
		SetAnimation(H108_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
		H108_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H108_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(60, 80), 3, 800, 300, 0.8, H108_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(-45, 0), "arrow05", effectScript)
		PlaySound("minifire")
	end,

	dgf = function( effectScript )
		DetachEffect(H108_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

	f = function( effectScript )
			DamageEffect(H108_normal_attack.info_pool[effectScript.ID].Attacker, H108_normal_attack.info_pool[effectScript.ID].Targeter, H108_normal_attack.info_pool[effectScript.ID].AttackType, H108_normal_attack.info_pool[effectScript.ID].AttackDataList, H108_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
