H011_auto324_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H011_auto324_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0, Effect2 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H011_auto324_attack.info_pool[effectScript.ID].Attacker)
		H011_auto324_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("shifang")
		PreLoadAvatar("S320dandao")
		PreLoadAvatar("S320shouji")
		PreLoadAvatar("shifang")
		PreLoadAvatar("S320dandao")
		PreLoadAvatar("S320shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 30, "s" )
		effectScript:RegisterEvent( 35, "afafaf" )
		effectScript:RegisterEvent( 36, "cszc" )
		effectScript:RegisterEvent( 37, "sfsgsdg" )
		effectScript:RegisterEvent( 38, "afsafg" )
		effectScript:RegisterEvent( 51, "e" )
		effectScript:RegisterEvent( 57, "affds" )
		effectScript:RegisterEvent( 58, "afcf" )
		effectScript:RegisterEvent( 59, "adaff" )
		effectScript:RegisterEvent( 60, "j" )
	end,

	d = function( effectScript )
		SetAnimation(H011_auto324_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, H011_auto324_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 3, 100, "shifang")
	end,

	afafaf = function( effectScript )
		H011_auto324_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H011_auto324_attack.info_pool[effectScript.ID].Attacker, Vector2(150, 75), 3, 800, 300, 1, H011_auto324_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S320dandao", effectScript)
	end,

	cszc = function( effectScript )
		AttachAvatarPosEffect(false, H011_auto324_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S320shouji")
	end,

	sfsgsdg = function( effectScript )
			DamageEffect(H011_auto324_attack.info_pool[effectScript.ID].Attacker, H011_auto324_attack.info_pool[effectScript.ID].Targeter, H011_auto324_attack.info_pool[effectScript.ID].AttackType, H011_auto324_attack.info_pool[effectScript.ID].AttackDataList, H011_auto324_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	afsafg = function( effectScript )
		DetachEffect(H011_auto324_attack.info_pool[effectScript.ID].Effect1)
	end,

	e = function( effectScript )
		AttachAvatarPosEffect(false, H011_auto324_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 2, 100, "shifang")
	end,

	affds = function( effectScript )
		H011_auto324_attack.info_pool[effectScript.ID].Effect2 = AttachTraceEffect( H011_auto324_attack.info_pool[effectScript.ID].Attacker, Vector2(150, 75), 3, 800, 300, 1, H011_auto324_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S320dandao", effectScript)
	end,

	afcf = function( effectScript )
		AttachAvatarPosEffect(false, H011_auto324_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S320shouji")
	end,

	adaff = function( effectScript )
		DetachEffect(H011_auto324_attack.info_pool[effectScript.ID].Effect2)
	end,

	j = function( effectScript )
			DamageEffect(H011_auto324_attack.info_pool[effectScript.ID].Attacker, H011_auto324_attack.info_pool[effectScript.ID].Targeter, H011_auto324_attack.info_pool[effectScript.ID].AttackType, H011_auto324_attack.info_pool[effectScript.ID].AttackDataList, H011_auto324_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
