M048_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M048_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0, Effect2 = 0, Effect3 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M048_normal_attack.info_pool[effectScript.ID].Attacker)
		M048_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("minifire")
		PreLoadSound("minifire")
		PreLoadAvatar("arrow05")
		PreLoadAvatar("arrow05")
		PreLoadAvatar("arrow05")
		PreLoadAvatar("hit_42")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 7, "df" )
		effectScript:RegisterEvent( 8, "dfff" )
		effectScript:RegisterEvent( 15, "w" )
		effectScript:RegisterEvent( 16, "wr" )
		effectScript:RegisterEvent( 17, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M048_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("minifire")
	end,

	dfff = function( effectScript )
			PlaySound("minifire")
	end,

	w = function( effectScript )
		M048_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M048_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(50, 80), 2, 800, 300, 1, M048_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "arrow05", effectScript)
	M048_normal_attack.info_pool[effectScript.ID].Effect2 = AttachTraceEffect( M048_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(0, 120), 2, 800, 300, 0.5, M048_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), "arrow05", effectScript)
	M048_normal_attack.info_pool[effectScript.ID].Effect3 = AttachTraceEffect( M048_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(0, 50), 2, 800, 300, 0.5, M048_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.right_up_leg, Vector2(0, 0), "arrow05", effectScript)
	end,

	wr = function( effectScript )
		DetachEffect(M048_normal_attack.info_pool[effectScript.ID].Effect1)
	DetachEffect(M048_normal_attack.info_pool[effectScript.ID].Effect2)
	DetachEffect(M048_normal_attack.info_pool[effectScript.ID].Effect3)
	end,

	d = function( effectScript )
			DamageEffect(M048_normal_attack.info_pool[effectScript.ID].Attacker, M048_normal_attack.info_pool[effectScript.ID].Targeter, M048_normal_attack.info_pool[effectScript.ID].AttackType, M048_normal_attack.info_pool[effectScript.ID].AttackDataList, M048_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	AttachAvatarPosEffect(false, M048_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "hit_42")
	end,

}
