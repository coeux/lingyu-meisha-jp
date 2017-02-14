S436_magic_P101_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S436_magic_P101_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S436_magic_P101_attack.info_pool[effectScript.ID].Attacker)
        
		S436_magic_P101_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s010111")
		PreLoadSound("atalk_010101")
		PreLoadAvatar("S420_2")
		PreLoadAvatar("S420_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfsdg" )
		effectScript:RegisterEvent( 18, "sfdg" )
		effectScript:RegisterEvent( 35, "ddddgf" )
		effectScript:RegisterEvent( 36, "dsgfdh" )
	end,

	dsfsdg = function( effectScript )
		SetAnimation(S436_magic_P101_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s010111")
		PlaySound("atalk_010101")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, S436_magic_P101_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-90, 110), 1.5, 100, "S420_2")
	end,

	ddddgf = function( effectScript )
		AttachAvatarPosEffect(false, S436_magic_P101_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.2, 100, "S420_1")
	end,

	dsgfdh = function( effectScript )
			DamageEffect(S436_magic_P101_attack.info_pool[effectScript.ID].Attacker, S436_magic_P101_attack.info_pool[effectScript.ID].Targeter, S436_magic_P101_attack.info_pool[effectScript.ID].AttackType, S436_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S436_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
