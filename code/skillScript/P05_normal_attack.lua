P05_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P05_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P05_normal_attack.info_pool[effectScript.ID].Attacker)
		P05_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("minifire")
		PreLoadAvatar("arrow05")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 9, "as" )
		effectScript:RegisterEvent( 13, "b" )
		effectScript:RegisterEvent( 14, "sd" )
	end,

	a = function( effectScript )
		SetAnimation(P05_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	as = function( effectScript )
			PlaySound("minifire")
	end,

	b = function( effectScript )
		P05_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( P05_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(110, 75), 3, 800, 300, 1, P05_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-30, 0), "arrow05", effectScript)
	end,

	sd = function( effectScript )
		DetachEffect(P05_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(P05_normal_attack.info_pool[effectScript.ID].Attacker, P05_normal_attack.info_pool[effectScript.ID].Targeter, P05_normal_attack.info_pool[effectScript.ID].AttackType, P05_normal_attack.info_pool[effectScript.ID].AttackDataList, P05_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
