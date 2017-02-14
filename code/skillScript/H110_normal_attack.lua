H110_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H110_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H110_normal_attack.info_pool[effectScript.ID].Attacker)
		H110_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow01")
		PreLoadSound("bow")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 8, "s" )
		effectScript:RegisterEvent( 9, "f" )
		effectScript:RegisterEvent( 11, "d" )
	end,

	a = function( effectScript )
		SetAnimation(H110_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	s = function( effectScript )
		H110_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H110_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(20, 78), 3, 800, 300, 0.9, H110_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), "arrow01", effectScript)
		PlaySound("bow")
	end,

	f = function( effectScript )
		DetachEffect(H110_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

	d = function( effectScript )
			DamageEffect(H110_normal_attack.info_pool[effectScript.ID].Attacker, H110_normal_attack.info_pool[effectScript.ID].Targeter, H110_normal_attack.info_pool[effectScript.ID].AttackType, H110_normal_attack.info_pool[effectScript.ID].AttackDataList, H110_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
