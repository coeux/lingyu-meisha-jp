H062_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H062_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H062_normal_attack.info_pool[effectScript.ID].Attacker)
		H062_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow05")
		PreLoadSound("minifire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "b" )
		effectScript:RegisterEvent( 11, "bs" )
	end,

	a = function( effectScript )
		SetAnimation(H062_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
		H062_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H062_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(80, 75), 3, 800, 300, 1, H062_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow05", effectScript)
		PlaySound("minifire")
	end,

	bs = function( effectScript )
		DetachEffect(H062_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H062_normal_attack.info_pool[effectScript.ID].Attacker, H062_normal_attack.info_pool[effectScript.ID].Targeter, H062_normal_attack.info_pool[effectScript.ID].AttackType, H062_normal_attack.info_pool[effectScript.ID].AttackDataList, H062_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
