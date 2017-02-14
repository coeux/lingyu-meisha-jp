H111_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H111_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H111_normal_attack.info_pool[effectScript.ID].Attacker)
		H111_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("bow")
		PreLoadAvatar("arrow01")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "asd" )
		effectScript:RegisterEvent( 15, "sddd" )
		effectScript:RegisterEvent( 16, "ffgg" )
	end,

	asd = function( effectScript )
		SetAnimation(H111_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sddd = function( effectScript )
			PlaySound("bow")
	H111_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H111_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(40, 95), 1, 800, 200, 1, H111_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow01", effectScript)
	end,

	ffgg = function( effectScript )
		DetachEffect(H111_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H111_normal_attack.info_pool[effectScript.ID].Attacker, H111_normal_attack.info_pool[effectScript.ID].Targeter, H111_normal_attack.info_pool[effectScript.ID].AttackType, H111_normal_attack.info_pool[effectScript.ID].AttackDataList, H111_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
