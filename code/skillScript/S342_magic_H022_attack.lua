S342_magic_H022_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S342_magic_H022_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S342_magic_H022_attack.info_pool[effectScript.ID].Attacker)
        
		S342_magic_H022_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S342_shifa")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asd" )
		effectScript:RegisterEvent( 31, "ad" )
		effectScript:RegisterEvent( 63, "sfdsgf" )
	end,

	asd = function( effectScript )
		SetAnimation(S342_magic_H022_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	ad = function( effectScript )
		AttachAvatarPosEffect(false, S342_magic_H022_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(75, 20), 1.2, 100, "S342_shifa")
	end,

	sfdsgf = function( effectScript )
			DamageEffect(S342_magic_H022_attack.info_pool[effectScript.ID].Attacker, S342_magic_H022_attack.info_pool[effectScript.ID].Targeter, S342_magic_H022_attack.info_pool[effectScript.ID].AttackType, S342_magic_H022_attack.info_pool[effectScript.ID].AttackDataList, S342_magic_H022_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
