H098_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H098_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H098_normal_attack.info_pool[effectScript.ID].Attacker)
		H098_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow03")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 19, "sd" )
		effectScript:RegisterEvent( 20, "ss" )
	end,

	a = function( effectScript )
		SetAnimation(H098_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sd = function( effectScript )
		H098_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H098_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(30, 105), 3, 800, 300, 1, H098_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow03", effectScript)
	end,

	ss = function( effectScript )
			DamageEffect(H098_normal_attack.info_pool[effectScript.ID].Attacker, H098_normal_attack.info_pool[effectScript.ID].Targeter, H098_normal_attack.info_pool[effectScript.ID].AttackType, H098_normal_attack.info_pool[effectScript.ID].AttackDataList, H098_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	DetachEffect(H098_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

}
