P04_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P04_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P04_normal_attack.info_pool[effectScript.ID].Attacker)
		P04_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow01")
		PreLoadSound("bow")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 23, "ww" )
		effectScript:RegisterEvent( 24, "mm" )
		effectScript:RegisterEvent( 25, "gg" )
	end,

	aa = function( effectScript )
		SetAnimation(P04_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	ww = function( effectScript )
		P04_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( P04_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(60, 75), 3, 800, 150, 1, P04_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow01", effectScript)
		PlaySound("bow")
	end,

	mm = function( effectScript )
		DetachEffect(P04_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

	gg = function( effectScript )
			DamageEffect(P04_normal_attack.info_pool[effectScript.ID].Attacker, P04_normal_attack.info_pool[effectScript.ID].Targeter, P04_normal_attack.info_pool[effectScript.ID].AttackType, P04_normal_attack.info_pool[effectScript.ID].AttackDataList, P04_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
