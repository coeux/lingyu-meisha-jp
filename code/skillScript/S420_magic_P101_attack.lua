S420_magic_P101_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S420_magic_P101_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S420_magic_P101_attack.info_pool[effectScript.ID].Attacker)
        
		S420_magic_P101_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
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
		SetAnimation(S420_magic_P101_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, S420_magic_P101_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-90, 110), 1.5, 100, "S420_2")
	end,

	ddddgf = function( effectScript )
		AttachAvatarPosEffect(false, S420_magic_P101_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.2, 100, "S420_1")
	end,

	dsgfdh = function( effectScript )
			DamageEffect(S420_magic_P101_attack.info_pool[effectScript.ID].Attacker, S420_magic_P101_attack.info_pool[effectScript.ID].Targeter, S420_magic_P101_attack.info_pool[effectScript.ID].AttackType, S420_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S420_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
