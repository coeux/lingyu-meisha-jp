M028_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M028_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0, Effect3 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M028_normal_attack.info_pool[effectScript.ID].Attacker)
		M028_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roar")
		PreLoadSound("minifire")
		PreLoadSound("minifire")
		PreLoadAvatar("arrow05")
		PreLoadAvatar("arrow05")
		PreLoadAvatar("hit_42")
		PreLoadAvatar("hit_42")
		PreLoadAvatar("hit_42")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfsdgsd" )
		effectScript:RegisterEvent( 7, "dafda" )
		effectScript:RegisterEvent( 10, "dafadsf" )
		effectScript:RegisterEvent( 12, "xcbsdgdf" )
		effectScript:RegisterEvent( 13, "sgvd" )
		effectScript:RegisterEvent( 14, "dsfe" )
		effectScript:RegisterEvent( 17, "dsfsf" )
		effectScript:RegisterEvent( 18, "d" )
	end,

	dfsdgsd = function( effectScript )
		SetAnimation(M028_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("roar")
	end,

	dafda = function( effectScript )
			PlaySound("minifire")
	end,

	dafadsf = function( effectScript )
			PlaySound("minifire")
	end,

	xcbsdgdf = function( effectScript )
		M028_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M028_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(80, 210), 2, 1200, 300, 1, M028_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(40, 20), "arrow05", effectScript)
	M028_normal_attack.info_pool[effectScript.ID].Effect3 = AttachTraceEffect( M028_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(80, 210), 2, 600, 300, 1, M028_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(30, 0), "arrow05", effectScript)
	end,

	sgvd = function( effectScript )
		DetachEffect(M028_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

	dsfe = function( effectScript )
		AttachAvatarPosEffect(false, M028_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.3, 100, "hit_42")
	AttachAvatarPosEffect(false, M028_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(30, 0), 1, 100, "hit_42")
	end,

	dsfsf = function( effectScript )
			DamageEffect(M028_normal_attack.info_pool[effectScript.ID].Attacker, M028_normal_attack.info_pool[effectScript.ID].Targeter, M028_normal_attack.info_pool[effectScript.ID].AttackType, M028_normal_attack.info_pool[effectScript.ID].AttackDataList, M028_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	DetachEffect(M028_normal_attack.info_pool[effectScript.ID].Effect3)
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, M028_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1, 100, "hit_42")
	end,

}
