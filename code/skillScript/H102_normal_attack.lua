H102_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H102_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H102_normal_attack.info_pool[effectScript.ID].Attacker)
		H102_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow01")
		PreLoadSound("bow")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "as" )
		effectScript:RegisterEvent( 17, "sd" )
	end,

	a = function( effectScript )
		SetAnimation(H102_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	as = function( effectScript )
		H102_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H102_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(50, 85), 3, 1200, 300, 0.7, H102_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow01", effectScript)
		PlaySound("bow")
	end,

	sd = function( effectScript )
		DetachEffect(H102_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H102_normal_attack.info_pool[effectScript.ID].Attacker, H102_normal_attack.info_pool[effectScript.ID].Targeter, H102_normal_attack.info_pool[effectScript.ID].AttackType, H102_normal_attack.info_pool[effectScript.ID].AttackDataList, H102_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
