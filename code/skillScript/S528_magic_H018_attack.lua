S528_magic_H018_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S528_magic_H018_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0, Effect2 = 0, Effect3 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S528_magic_H018_attack.info_pool[effectScript.ID].Attacker)
       	if S528_magic_H018_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Effect1);S528_magic_H018_attack.info_pool[effectScript.ID].Effect1 = nil; end
	if S528_magic_H018_attack.info_pool[effectScript.ID].Effect2 then DetachEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Effect2);S528_magic_H018_attack.info_pool[effectScript.ID].Effect2 = nil; end
	if S528_magic_H018_attack.info_pool[effectScript.ID].Effect3 then DetachEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Effect3);S528_magic_H018_attack.info_pool[effectScript.ID].Effect3 = nil; end
	if S528_magic_H018_attack.info_pool[effectScript.ID].Effect4 then DetachEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Effect4);S528_magic_H018_attack.info_pool[effectScript.ID].Effect4 = nil; end
	if S528_magic_H018_attack.info_pool[effectScript.ID].Effect5 then DetachEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Effect5);S528_magic_H018_attack.info_pool[effectScript.ID].Effect5 = nil; end
 
		S528_magic_H018_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01806")
		PreLoadSound("stalk_01801")
		PreLoadAvatar("S250_shifang")
		PreLoadAvatar("S250dandao")
		PreLoadAvatar("S250shouji")
		PreLoadAvatar("S250dandao")
		PreLoadAvatar("S250shouji")
		PreLoadAvatar("S250dandao")
		PreLoadAvatar("S250shouji")
		PreLoadAvatar("S250dandao")
		PreLoadAvatar("S250shouji")
		PreLoadAvatar("S250dandao")
		PreLoadAvatar("S250shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 20, "s" )
		effectScript:RegisterEvent( 23, "adad" )
		effectScript:RegisterEvent( 24, "ad" )
		effectScript:RegisterEvent( 25, "sadwd" )
		effectScript:RegisterEvent( 26, "h" )
		effectScript:RegisterEvent( 28, "dasf" )
		effectScript:RegisterEvent( 29, "shrgsdg" )
		effectScript:RegisterEvent( 30, "safvcxv" )
		effectScript:RegisterEvent( 31, "awff" )
		effectScript:RegisterEvent( 33, "affdg" )
		effectScript:RegisterEvent( 34, "bbbb" )
		effectScript:RegisterEvent( 35, "afgv" )
		effectScript:RegisterEvent( 36, "awdaf" )
		effectScript:RegisterEvent( 38, "dsgfhg" )
		effectScript:RegisterEvent( 39, "gdfhgj" )
		effectScript:RegisterEvent( 40, "fdhgj" )
		effectScript:RegisterEvent( 41, "gfjhgjhk" )
		effectScript:RegisterEvent( 43, "gfjhgfghg" )
		effectScript:RegisterEvent( 44, "gfjhgf" )
		effectScript:RegisterEvent( 45, "gfjghdhg" )
		effectScript:RegisterEvent( 46, "gdhjhk" )
	end,

	d = function( effectScript )
		SetAnimation(S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_01806")
		PlaySound("stalk_01801")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 3, 100, "S250_shifang")
	end,

	adad = function( effectScript )
		S528_magic_H018_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, Vector2(250, 60), 3, 1200, 300, 1, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S250dandao", effectScript)
	end,

	ad = function( effectScript )
		if S528_magic_H018_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Effect1);S528_magic_H018_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	sadwd = function( effectScript )
		AttachAvatarPosEffect(false, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 3, 100, "S250shouji")
	end,

	h = function( effectScript )
			DamageEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, S528_magic_H018_attack.info_pool[effectScript.ID].AttackType, S528_magic_H018_attack.info_pool[effectScript.ID].AttackDataList, S528_magic_H018_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dasf = function( effectScript )
		S528_magic_H018_attack.info_pool[effectScript.ID].Effect2 = AttachTraceEffect( S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, Vector2(250, 60), 3, 1200, 300, 1, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S250dandao", effectScript)
	end,

	shrgsdg = function( effectScript )
		if S528_magic_H018_attack.info_pool[effectScript.ID].Effect2 then DetachEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Effect2);S528_magic_H018_attack.info_pool[effectScript.ID].Effect2 = nil; end
	end,

	safvcxv = function( effectScript )
		AttachAvatarPosEffect(false, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 3, 100, "S250shouji")
	end,

	awff = function( effectScript )
			DamageEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, S528_magic_H018_attack.info_pool[effectScript.ID].AttackType, S528_magic_H018_attack.info_pool[effectScript.ID].AttackDataList, S528_magic_H018_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	affdg = function( effectScript )
		S528_magic_H018_attack.info_pool[effectScript.ID].Effect3 = AttachTraceEffect( S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, Vector2(150, 60), 3, 1200, 300, 1, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S250dandao", effectScript)
	end,

	bbbb = function( effectScript )
		if S528_magic_H018_attack.info_pool[effectScript.ID].Effect3 then DetachEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Effect3);S528_magic_H018_attack.info_pool[effectScript.ID].Effect3 = nil; end
	end,

	afgv = function( effectScript )
		AttachAvatarPosEffect(false, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 3, 100, "S250shouji")
	end,

	awdaf = function( effectScript )
			DamageEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, S528_magic_H018_attack.info_pool[effectScript.ID].AttackType, S528_magic_H018_attack.info_pool[effectScript.ID].AttackDataList, S528_magic_H018_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsgfhg = function( effectScript )
		S528_magic_H018_attack.info_pool[effectScript.ID].Effect4 = AttachTraceEffect( S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, Vector2(150, 60), 3, 1200, 300, 1, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S250dandao", effectScript)
	end,

	gdfhgj = function( effectScript )
		if S528_magic_H018_attack.info_pool[effectScript.ID].Effect4 then DetachEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Effect4);S528_magic_H018_attack.info_pool[effectScript.ID].Effect4 = nil; end
	end,

	fdhgj = function( effectScript )
		AttachAvatarPosEffect(false, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 3, 100, "S250shouji")
	end,

	gfjhgjhk = function( effectScript )
			DamageEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, S528_magic_H018_attack.info_pool[effectScript.ID].AttackType, S528_magic_H018_attack.info_pool[effectScript.ID].AttackDataList, S528_magic_H018_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gfjhgfghg = function( effectScript )
		S528_magic_H018_attack.info_pool[effectScript.ID].Effect5 = AttachTraceEffect( S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, Vector2(150, 60), 3, 1200, 300, 1, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S250dandao", effectScript)
	end,

	gfjhgf = function( effectScript )
		if S528_magic_H018_attack.info_pool[effectScript.ID].Effect5 then DetachEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Effect5);S528_magic_H018_attack.info_pool[effectScript.ID].Effect5 = nil; end
	end,

	gfjghdhg = function( effectScript )
		AttachAvatarPosEffect(false, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 3, 100, "S250shouji")
	end,

	gdhjhk = function( effectScript )
			DamageEffect(S528_magic_H018_attack.info_pool[effectScript.ID].Attacker, S528_magic_H018_attack.info_pool[effectScript.ID].Targeter, S528_magic_H018_attack.info_pool[effectScript.ID].AttackType, S528_magic_H018_attack.info_pool[effectScript.ID].AttackDataList, S528_magic_H018_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
