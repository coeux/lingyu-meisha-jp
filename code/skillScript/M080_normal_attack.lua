M080_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M080_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M080_normal_attack.info_pool[effectScript.ID].Attacker)
		M080_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow08")
		PreLoadSound("iceball")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 18, "s" )
		effectScript:RegisterEvent( 19, "d" )
		effectScript:RegisterEvent( 20, "f" )
	end,

	a = function( effectScript )
		SetAnimation(M080_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	s = function( effectScript )
		M080_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M080_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(50, 95), 3, 800, 300, 1, M080_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow08", effectScript)
		PlaySound("iceball")
	end,

	d = function( effectScript )
		DetachEffect(M080_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

	f = function( effectScript )
			DamageEffect(M080_normal_attack.info_pool[effectScript.ID].Attacker, M080_normal_attack.info_pool[effectScript.ID].Targeter, M080_normal_attack.info_pool[effectScript.ID].AttackType, M080_normal_attack.info_pool[effectScript.ID].AttackDataList, M080_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
