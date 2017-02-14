S87_magic_P102_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S87_magic_P102_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S87_magic_P102_attack.info_pool[effectScript.ID].Attacker)
        
		S87_magic_P102_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s01023")
		PreLoadSound("stalk_010201")
		PreLoadAvatar("S432_2")
		PreLoadAvatar("S432_1")
		PreLoadAvatar("S432_4")
		PreLoadAvatar("S432_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sSdsf" )
		effectScript:RegisterEvent( 25, "safdg" )
		effectScript:RegisterEvent( 39, "gfdgfh" )
		effectScript:RegisterEvent( 46, "ghjk" )
		effectScript:RegisterEvent( 50, "dsfdg" )
		effectScript:RegisterEvent( 53, "fggh" )
		effectScript:RegisterEvent( 58, "gffj" )
	end,

	sSdsf = function( effectScript )
		SetAnimation(S87_magic_P102_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s01023")
		PlaySound("stalk_010201")
	end,

	safdg = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 75), 1.5, 100, "S432_2")
	end,

	gfdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S432_1")
	end,

	ghjk = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 80), 1, 100, "S432_4")
	end,

	dsfdg = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P102_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.5, 100, "S432_3")
	end,

	fggh = function( effectScript )
			DamageEffect(S87_magic_P102_attack.info_pool[effectScript.ID].Attacker, S87_magic_P102_attack.info_pool[effectScript.ID].Targeter, S87_magic_P102_attack.info_pool[effectScript.ID].AttackType, S87_magic_P102_attack.info_pool[effectScript.ID].AttackDataList, S87_magic_P102_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gffj = function( effectScript )
			DamageEffect(S87_magic_P102_attack.info_pool[effectScript.ID].Attacker, S87_magic_P102_attack.info_pool[effectScript.ID].Targeter, S87_magic_P102_attack.info_pool[effectScript.ID].AttackType, S87_magic_P102_attack.info_pool[effectScript.ID].AttackDataList, S87_magic_P102_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
