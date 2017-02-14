M041_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M041_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M041_normal_attack.info_pool[effectScript.ID].Attacker)
		M041_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("minifire")
		PreLoadAvatar("arrow05")
		PreLoadAvatar("hit_42")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 9, "df" )
		effectScript:RegisterEvent( 11, "af" )
		effectScript:RegisterEvent( 12, "afs" )
		effectScript:RegisterEvent( 13, "f" )
		effectScript:RegisterEvent( 14, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M041_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("minifire")
	end,

	af = function( effectScript )
		M041_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M041_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(20, 80), 2, 800, 300, 1, M041_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "arrow05", effectScript)
	end,

	afs = function( effectScript )
		DetachEffect(M041_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

	f = function( effectScript )
		AttachAvatarPosEffect(false, M041_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "hit_42")
	end,

	d = function( effectScript )
			DamageEffect(M041_normal_attack.info_pool[effectScript.ID].Attacker, M041_normal_attack.info_pool[effectScript.ID].Targeter, M041_normal_attack.info_pool[effectScript.ID].AttackType, M041_normal_attack.info_pool[effectScript.ID].AttackDataList, M041_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
