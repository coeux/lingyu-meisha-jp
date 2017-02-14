H064_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H064_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H064_normal_attack.info_pool[effectScript.ID].Attacker)
		H064_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow05")
		PreLoadSound("minifire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 14, "b" )
		effectScript:RegisterEvent( 15, "c" )
	end,

	a = function( effectScript )
		SetAnimation(H064_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
		H064_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H064_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(40, 80), 3, 800, 300, 1, H064_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow05", effectScript)
		PlaySound("minifire")
	end,

	c = function( effectScript )
		DetachEffect(H064_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H064_normal_attack.info_pool[effectScript.ID].Attacker, H064_normal_attack.info_pool[effectScript.ID].Targeter, H064_normal_attack.info_pool[effectScript.ID].AttackType, H064_normal_attack.info_pool[effectScript.ID].AttackDataList, H064_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
