H009_auto328_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H009_auto328_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0, Effect2 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H009_auto328_attack.info_pool[effectScript.ID].Attacker)
       	if H009_auto328_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H009_auto328_attack.info_pool[effectScript.ID].Effect1);H009_auto328_attack.info_pool[effectScript.ID].Effect1 = nil; end
	if H009_auto328_attack.info_pool[effectScript.ID].Effect2 then DetachEffect(H009_auto328_attack.info_pool[effectScript.ID].Effect2);H009_auto328_attack.info_pool[effectScript.ID].Effect2 = nil; end
 
		H009_auto328_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0114")
		PreLoadAvatar("shifang")
		PreLoadAvatar("S250dandao")
		PreLoadAvatar("S250shouji")
		PreLoadAvatar("shifang")
		PreLoadAvatar("S250dandao")
		PreLoadAvatar("S250shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 30, "s" )
		effectScript:RegisterEvent( 35, "afafaf" )
		effectScript:RegisterEvent( 36, "afsafg" )
		effectScript:RegisterEvent( 37, "cszc" )
		effectScript:RegisterEvent( 38, "sfsgsdg" )
		effectScript:RegisterEvent( 53, "e" )
		effectScript:RegisterEvent( 57, "affds" )
		effectScript:RegisterEvent( 58, "adaff" )
		effectScript:RegisterEvent( 59, "afcf" )
		effectScript:RegisterEvent( 60, "j" )
	end,

	d = function( effectScript )
		SetAnimation(H009_auto328_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s0114")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, H009_auto328_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 3, 100, "shifang")
	end,

	afafaf = function( effectScript )
		H009_auto328_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H009_auto328_attack.info_pool[effectScript.ID].Attacker, Vector2(250, 60), 3, 1000, 300, 1, H009_auto328_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S250dandao", effectScript)
	end,

	afsafg = function( effectScript )
		if H009_auto328_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H009_auto328_attack.info_pool[effectScript.ID].Effect1);H009_auto328_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	cszc = function( effectScript )
		AttachAvatarPosEffect(false, H009_auto328_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 3, 100, "S250shouji")
	end,

	sfsgsdg = function( effectScript )
			DamageEffect(H009_auto328_attack.info_pool[effectScript.ID].Attacker, H009_auto328_attack.info_pool[effectScript.ID].Targeter, H009_auto328_attack.info_pool[effectScript.ID].AttackType, H009_auto328_attack.info_pool[effectScript.ID].AttackDataList, H009_auto328_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	e = function( effectScript )
		AttachAvatarPosEffect(false, H009_auto328_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 2, 100, "shifang")
	end,

	affds = function( effectScript )
		H009_auto328_attack.info_pool[effectScript.ID].Effect2 = AttachTraceEffect( H009_auto328_attack.info_pool[effectScript.ID].Attacker, Vector2(250, 60), 3, 1000, 300, 1, H009_auto328_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S250dandao", effectScript)
	end,

	adaff = function( effectScript )
		if H009_auto328_attack.info_pool[effectScript.ID].Effect2 then DetachEffect(H009_auto328_attack.info_pool[effectScript.ID].Effect2);H009_auto328_attack.info_pool[effectScript.ID].Effect2 = nil; end
	end,

	afcf = function( effectScript )
		AttachAvatarPosEffect(false, H009_auto328_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 3, 100, "S250shouji")
	end,

	j = function( effectScript )
			DamageEffect(H009_auto328_attack.info_pool[effectScript.ID].Attacker, H009_auto328_attack.info_pool[effectScript.ID].Targeter, H009_auto328_attack.info_pool[effectScript.ID].AttackType, H009_auto328_attack.info_pool[effectScript.ID].AttackDataList, H009_auto328_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
