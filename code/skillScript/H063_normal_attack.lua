H063_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H063_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H063_normal_attack.info_pool[effectScript.ID].Attacker)
		H063_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow05")
		PreLoadSound("minifire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 17, "b" )
		effectScript:RegisterEvent( 18, "c" )
	end,

	a = function( effectScript )
		SetAnimation(H063_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
		H063_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H063_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(65, 90), 3, 800, 300, 1, H063_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow05", effectScript)
		PlaySound("minifire")
	end,

	c = function( effectScript )
		DetachEffect(H063_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H063_normal_attack.info_pool[effectScript.ID].Attacker, H063_normal_attack.info_pool[effectScript.ID].Targeter, H063_normal_attack.info_pool[effectScript.ID].AttackType, H063_normal_attack.info_pool[effectScript.ID].AttackDataList, H063_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
