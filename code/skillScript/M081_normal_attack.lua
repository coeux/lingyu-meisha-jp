M081_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M081_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M081_normal_attack.info_pool[effectScript.ID].Attacker)
		M081_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow05")
		PreLoadSound("minifire")
		PreLoadAvatar("hit_42")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "s" )
		effectScript:RegisterEvent( 16, "d" )
		effectScript:RegisterEvent( 17, "f" )
	end,

	a = function( effectScript )
		SetAnimation(M081_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	s = function( effectScript )
		M081_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M081_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(50, 100), 3, 800, 300, 1, M081_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow05", effectScript)
		PlaySound("minifire")
	end,

	d = function( effectScript )
		DetachEffect(M081_normal_attack.info_pool[effectScript.ID].Effect1)
	AttachAvatarPosEffect(false, M081_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-50, 60), 1, 100, "hit_42")
	end,

	f = function( effectScript )
			DamageEffect(M081_normal_attack.info_pool[effectScript.ID].Attacker, M081_normal_attack.info_pool[effectScript.ID].Targeter, M081_normal_attack.info_pool[effectScript.ID].AttackType, M081_normal_attack.info_pool[effectScript.ID].AttackDataList, M081_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
