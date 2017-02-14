H065_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H065_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H065_normal_attack.info_pool[effectScript.ID].Attacker)
		H065_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("spear")
		PreLoadAvatar("arrow04")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 17, "sdf" )
		effectScript:RegisterEvent( 20, "b" )
		effectScript:RegisterEvent( 21, "c" )
	end,

	a = function( effectScript )
		SetAnimation(H065_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sdf = function( effectScript )
			PlaySound("spear")
	end,

	b = function( effectScript )
		H065_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H065_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(80, 140), 1, 800, 10, 0.75, H065_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, -20), "arrow04", effectScript)
	end,

	c = function( effectScript )
		DetachEffect(H065_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H065_normal_attack.info_pool[effectScript.ID].Attacker, H065_normal_attack.info_pool[effectScript.ID].Targeter, H065_normal_attack.info_pool[effectScript.ID].AttackType, H065_normal_attack.info_pool[effectScript.ID].AttackDataList, H065_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
