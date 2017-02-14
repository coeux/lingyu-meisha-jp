S320_magic_H011_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S320_magic_H011_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0, Effect2 = 0, Effect3 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S320_magic_H011_attack.info_pool[effectScript.ID].Attacker)
		S320_magic_H011_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("JJyinchang")
		PreLoadAvatar("shifang")
		PreLoadAvatar("S320dandao")
		PreLoadAvatar("S320shouji")
		PreLoadAvatar("shifang")
		PreLoadAvatar("S320dandao")
		PreLoadAvatar("S320shouji")
		PreLoadAvatar("S320dandao")
		PreLoadAvatar("S320shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 29, "d" )
		effectScript:RegisterEvent( 59, "s" )
		effectScript:RegisterEvent( 67, "adad" )
		effectScript:RegisterEvent( 68, "sadwd" )
		effectScript:RegisterEvent( 69, "ad" )
		effectScript:RegisterEvent( 70, "h" )
		effectScript:RegisterEvent( 77, "e" )
		effectScript:RegisterEvent( 84, "dasf" )
		effectScript:RegisterEvent( 85, "safvcxv" )
		effectScript:RegisterEvent( 86, "shrgsdg" )
		effectScript:RegisterEvent( 87, "awff" )
		effectScript:RegisterEvent( 91, "affdg" )
		effectScript:RegisterEvent( 92, "afgv" )
		effectScript:RegisterEvent( 93, "bbbb" )
		effectScript:RegisterEvent( 94, "awdaf" )
	end,

	a = function( effectScript )
		SetAnimation(S320_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	AttachAvatarPosEffect(false, S320_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-30, 50), 2, 100, "JJyinchang")
	end,

	d = function( effectScript )
		SetAnimation(S320_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S320_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 80), 3, 100, "shifang")
	end,

	adad = function( effectScript )
		S320_magic_H011_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S320_magic_H011_attack.info_pool[effectScript.ID].Attacker, Vector2(150, 75), 3, 800, 300, 1, S320_magic_H011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S320dandao", effectScript)
	end,

	sadwd = function( effectScript )
		AttachAvatarPosEffect(false, S320_magic_H011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.5, 100, "S320shouji")
	end,

	ad = function( effectScript )
		DetachEffect(S320_magic_H011_attack.info_pool[effectScript.ID].Effect1)
	end,

	h = function( effectScript )
			DamageEffect(S320_magic_H011_attack.info_pool[effectScript.ID].Attacker, S320_magic_H011_attack.info_pool[effectScript.ID].Targeter, S320_magic_H011_attack.info_pool[effectScript.ID].AttackType, S320_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S320_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	e = function( effectScript )
		AttachAvatarPosEffect(false, S320_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 2, 100, "shifang")
	end,

	dasf = function( effectScript )
		S320_magic_H011_attack.info_pool[effectScript.ID].Effect2 = AttachTraceEffect( S320_magic_H011_attack.info_pool[effectScript.ID].Attacker, Vector2(150, 75), 3, 800, 300, 1, S320_magic_H011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S320dandao", effectScript)
	end,

	safvcxv = function( effectScript )
		AttachAvatarPosEffect(false, S320_magic_H011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S320shouji")
	end,

	shrgsdg = function( effectScript )
		DetachEffect(S320_magic_H011_attack.info_pool[effectScript.ID].Effect2)
	end,

	awff = function( effectScript )
			DamageEffect(S320_magic_H011_attack.info_pool[effectScript.ID].Attacker, S320_magic_H011_attack.info_pool[effectScript.ID].Targeter, S320_magic_H011_attack.info_pool[effectScript.ID].AttackType, S320_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S320_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	affdg = function( effectScript )
		S320_magic_H011_attack.info_pool[effectScript.ID].Effect3 = AttachTraceEffect( S320_magic_H011_attack.info_pool[effectScript.ID].Attacker, Vector2(150, 75), 3, 800, 300, 1, S320_magic_H011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S320dandao", effectScript)
	end,

	afgv = function( effectScript )
		AttachAvatarPosEffect(false, S320_magic_H011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S320shouji")
	end,

	bbbb = function( effectScript )
		DetachEffect(S320_magic_H011_attack.info_pool[effectScript.ID].Effect3)
	end,

	awdaf = function( effectScript )
			DamageEffect(S320_magic_H011_attack.info_pool[effectScript.ID].Attacker, S320_magic_H011_attack.info_pool[effectScript.ID].Targeter, S320_magic_H011_attack.info_pool[effectScript.ID].AttackType, S320_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S320_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
