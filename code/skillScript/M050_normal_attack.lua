M050_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M050_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M050_normal_attack.info_pool[effectScript.ID].Attacker)
		M050_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("minifire")
		PreLoadAvatar("arrow05")
		PreLoadAvatar("hit_42")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 14, "df" )
		effectScript:RegisterEvent( 19, "s" )
		effectScript:RegisterEvent( 20, "f" )
		effectScript:RegisterEvent( 27, "w" )
		effectScript:RegisterEvent( 28, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M050_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("minifire")
	end,

	s = function( effectScript )
		M050_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M050_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(0, 70), 3, 800, 300, 1, M050_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "arrow05", effectScript)
	end,

	f = function( effectScript )
		DetachEffect(M050_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

	w = function( effectScript )
		AttachAvatarPosEffect(false, M050_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "hit_42")
	end,

	d = function( effectScript )
			DamageEffect(M050_normal_attack.info_pool[effectScript.ID].Attacker, M050_normal_attack.info_pool[effectScript.ID].Targeter, M050_normal_attack.info_pool[effectScript.ID].AttackType, M050_normal_attack.info_pool[effectScript.ID].AttackDataList, M050_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
