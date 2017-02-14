S620_magic_M012_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S620_magic_M012_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S620_magic_M012_attack.info_pool[effectScript.ID].Attacker)
        
		S620_magic_M012_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S620_1")
		PreLoadAvatar("S620_2")
		PreLoadAvatar("S620_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsf" )
		effectScript:RegisterEvent( 18, "dsfdg" )
		effectScript:RegisterEvent( 45, "dsfg" )
		effectScript:RegisterEvent( 48, "dfgfh" )
		effectScript:RegisterEvent( 51, "dsfgfdh" )
	end,

	dsf = function( effectScript )
		SetAnimation(S620_magic_M012_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdg = function( effectScript )
		AttachAvatarPosEffect(false, S620_magic_M012_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 130), 1.5, 100, "S620_1")
	end,

	dsfg = function( effectScript )
		AttachAvatarPosEffect(false, S620_magic_M012_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 40), 2, 100, "S620_2")
	end,

	dfgfh = function( effectScript )
		AttachAvatarPosEffect(false, S620_magic_M012_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S620_3")
	end,

	dsfgfdh = function( effectScript )
			DamageEffect(S620_magic_M012_attack.info_pool[effectScript.ID].Attacker, S620_magic_M012_attack.info_pool[effectScript.ID].Targeter, S620_magic_M012_attack.info_pool[effectScript.ID].AttackType, S620_magic_M012_attack.info_pool[effectScript.ID].AttackDataList, S620_magic_M012_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
