S437_magic_P102_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S437_magic_P102_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S437_magic_P102_attack.info_pool[effectScript.ID].Attacker)
        
		S437_magic_P102_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S432_2")
		PreLoadAvatar("S432_1")
		PreLoadAvatar("S432_4")
		PreLoadAvatar("S432_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sSdsf" )
		effectScript:RegisterEvent( 27, "safdg" )
		effectScript:RegisterEvent( 39, "gfdgfh" )
		effectScript:RegisterEvent( 46, "ghjk" )
		effectScript:RegisterEvent( 50, "dsfdg" )
		effectScript:RegisterEvent( 53, "fggh" )
		effectScript:RegisterEvent( 58, "gffj" )
	end,

	sSdsf = function( effectScript )
		SetAnimation(S437_magic_P102_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	safdg = function( effectScript )
		AttachAvatarPosEffect(false, S437_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 85), 1.5, 100, "S432_2")
	end,

	gfdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S437_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S432_1")
	end,

	ghjk = function( effectScript )
		AttachAvatarPosEffect(false, S437_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 80), 1, 100, "S432_4")
	end,

	dsfdg = function( effectScript )
		AttachAvatarPosEffect(false, S437_magic_P102_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(150, 0), -2, 100, "S432_3")
	end,

	fggh = function( effectScript )
			DamageEffect(S437_magic_P102_attack.info_pool[effectScript.ID].Attacker, S437_magic_P102_attack.info_pool[effectScript.ID].Targeter, S437_magic_P102_attack.info_pool[effectScript.ID].AttackType, S437_magic_P102_attack.info_pool[effectScript.ID].AttackDataList, S437_magic_P102_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gffj = function( effectScript )
			DamageEffect(S437_magic_P102_attack.info_pool[effectScript.ID].Attacker, S437_magic_P102_attack.info_pool[effectScript.ID].Targeter, S437_magic_P102_attack.info_pool[effectScript.ID].AttackType, S437_magic_P102_attack.info_pool[effectScript.ID].AttackDataList, S437_magic_P102_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
