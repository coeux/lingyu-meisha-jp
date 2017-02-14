M027_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M027_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0, Effect3 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M027_normal_attack.info_pool[effectScript.ID].Attacker)
		M027_normal_attack.info_pool[effectScript.ID] = nil
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
		effectScript:RegisterEvent( 7, "sa" )
		effectScript:RegisterEvent( 9, "daf" )
		effectScript:RegisterEvent( 12, "xcbsdgdf" )
		effectScript:RegisterEvent( 13, "sgvd" )
		effectScript:RegisterEvent( 14, "dsfe" )
		effectScript:RegisterEvent( 17, "dsfsf" )
		effectScript:RegisterEvent( 18, "d" )
	end,

	dfsdgsd = function( effectScript )
		SetAnimation(M027_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("roar")
	end,

	sa = function( effectScript )
			PlaySound("minifire")
	end,

	daf = function( effectScript )
			PlaySound("minifire")
	end,

	xcbsdgdf = function( effectScript )
		M027_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M027_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(80, 210), 2, 1200, 300, 1, M027_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(40, 20), "arrow05", effectScript)
	M027_normal_attack.info_pool[effectScript.ID].Effect3 = AttachTraceEffect( M027_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(80, 210), 2, 600, 300, 1, M027_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(40, 0), "arrow05", effectScript)
	end,

	sgvd = function( effectScript )
		DetachEffect(M027_normal_attack.info_pool[effectScript.ID].Effect1)
	end,

	dsfe = function( effectScript )
		AttachAvatarPosEffect(false, M027_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.3, 100, "hit_42")
	AttachAvatarPosEffect(false, M027_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(30, 0), 1, 100, "hit_42")
	end,

	dsfsf = function( effectScript )
			DamageEffect(M027_normal_attack.info_pool[effectScript.ID].Attacker, M027_normal_attack.info_pool[effectScript.ID].Targeter, M027_normal_attack.info_pool[effectScript.ID].AttackType, M027_normal_attack.info_pool[effectScript.ID].AttackDataList, M027_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	DetachEffect(M027_normal_attack.info_pool[effectScript.ID].Effect3)
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, M027_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1, 100, "hit_42")
	end,

}
