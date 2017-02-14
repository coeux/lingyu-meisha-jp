S694_magic_M010_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S694_magic_M010_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0, Effect2 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S694_magic_M010_attack.info_pool[effectScript.ID].Attacker)
       	if S694_magic_M010_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S694_magic_M010_attack.info_pool[effectScript.ID].Effect1);S694_magic_M010_attack.info_pool[effectScript.ID].Effect1 = nil; end
	if S694_magic_M010_attack.info_pool[effectScript.ID].Effect2 then DetachEffect(S694_magic_M010_attack.info_pool[effectScript.ID].Effect2);S694_magic_M010_attack.info_pool[effectScript.ID].Effect2 = nil; end
 
		S694_magic_M010_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S637_1")
		PreLoadAvatar("S637_4")
		PreLoadAvatar("S637_1")
		PreLoadAvatar("S637_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hjhkhjk" )
		effectScript:RegisterEvent( 35, "hgjk" )
		effectScript:RegisterEvent( 36, "sfdg" )
		effectScript:RegisterEvent( 37, "dsfgdg" )
		effectScript:RegisterEvent( 38, "sdfdsg" )
		effectScript:RegisterEvent( 67, "fgjhgj" )
		effectScript:RegisterEvent( 68, "sdfdg" )
		effectScript:RegisterEvent( 69, "fdhg" )
		effectScript:RegisterEvent( 70, "sfgh" )
	end,

	hjhkhjk = function( effectScript )
		SetAnimation(S694_magic_M010_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	hgjk = function( effectScript )
		S694_magic_M010_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S694_magic_M010_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 50), 2, 1200, 300, 1, S694_magic_M010_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S637_1", effectScript)
	end,

	sfdg = function( effectScript )
		if S694_magic_M010_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S694_magic_M010_attack.info_pool[effectScript.ID].Effect1);S694_magic_M010_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	dsfgdg = function( effectScript )
		AttachAvatarPosEffect(false, S694_magic_M010_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S637_4")
	end,

	sdfdsg = function( effectScript )
			DamageEffect(S694_magic_M010_attack.info_pool[effectScript.ID].Attacker, S694_magic_M010_attack.info_pool[effectScript.ID].Targeter, S694_magic_M010_attack.info_pool[effectScript.ID].AttackType, S694_magic_M010_attack.info_pool[effectScript.ID].AttackDataList, S694_magic_M010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fgjhgj = function( effectScript )
		S694_magic_M010_attack.info_pool[effectScript.ID].Effect2 = AttachTraceEffect( S694_magic_M010_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 50), 2, 1200, 300, 1, S694_magic_M010_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S637_1", effectScript)
	end,

	sdfdg = function( effectScript )
		if S694_magic_M010_attack.info_pool[effectScript.ID].Effect2 then DetachEffect(S694_magic_M010_attack.info_pool[effectScript.ID].Effect2);S694_magic_M010_attack.info_pool[effectScript.ID].Effect2 = nil; end
	end,

	fdhg = function( effectScript )
		AttachAvatarPosEffect(false, S694_magic_M010_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S637_4")
	end,

	sfgh = function( effectScript )
			DamageEffect(S694_magic_M010_attack.info_pool[effectScript.ID].Attacker, S694_magic_M010_attack.info_pool[effectScript.ID].Targeter, S694_magic_M010_attack.info_pool[effectScript.ID].AttackType, S694_magic_M010_attack.info_pool[effectScript.ID].AttackDataList, S694_magic_M010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
