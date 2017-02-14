M010_auto637_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M010_auto637_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0, Effect2 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M010_auto637_attack.info_pool[effectScript.ID].Attacker)
       	if M010_auto637_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M010_auto637_attack.info_pool[effectScript.ID].Effect1);M010_auto637_attack.info_pool[effectScript.ID].Effect1 = nil; end
	if M010_auto637_attack.info_pool[effectScript.ID].Effect2 then DetachEffect(M010_auto637_attack.info_pool[effectScript.ID].Effect2);M010_auto637_attack.info_pool[effectScript.ID].Effect2 = nil; end
 
		M010_auto637_attack.info_pool[effectScript.ID] = nil
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
		SetAnimation(M010_auto637_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	hgjk = function( effectScript )
		M010_auto637_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M010_auto637_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 50), 2, 1200, 300, 1, M010_auto637_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S637_1", effectScript)
	end,

	sfdg = function( effectScript )
		if M010_auto637_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M010_auto637_attack.info_pool[effectScript.ID].Effect1);M010_auto637_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	dsfgdg = function( effectScript )
		AttachAvatarPosEffect(false, M010_auto637_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S637_4")
	end,

	sdfdsg = function( effectScript )
			DamageEffect(M010_auto637_attack.info_pool[effectScript.ID].Attacker, M010_auto637_attack.info_pool[effectScript.ID].Targeter, M010_auto637_attack.info_pool[effectScript.ID].AttackType, M010_auto637_attack.info_pool[effectScript.ID].AttackDataList, M010_auto637_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fgjhgj = function( effectScript )
		M010_auto637_attack.info_pool[effectScript.ID].Effect2 = AttachTraceEffect( M010_auto637_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 50), 2, 1200, 300, 1, M010_auto637_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S637_1", effectScript)
	end,

	sdfdg = function( effectScript )
		if M010_auto637_attack.info_pool[effectScript.ID].Effect2 then DetachEffect(M010_auto637_attack.info_pool[effectScript.ID].Effect2);M010_auto637_attack.info_pool[effectScript.ID].Effect2 = nil; end
	end,

	fdhg = function( effectScript )
		AttachAvatarPosEffect(false, M010_auto637_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S637_4")
	end,

	sfgh = function( effectScript )
			DamageEffect(M010_auto637_attack.info_pool[effectScript.ID].Attacker, M010_auto637_attack.info_pool[effectScript.ID].Targeter, M010_auto637_attack.info_pool[effectScript.ID].AttackType, M010_auto637_attack.info_pool[effectScript.ID].AttackDataList, M010_auto637_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
