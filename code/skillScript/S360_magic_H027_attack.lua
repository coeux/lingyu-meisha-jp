S360_magic_H027_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S360_magic_H027_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S360_magic_H027_attack.info_pool[effectScript.ID].Attacker)
        
		S360_magic_H027_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S360_1")
		PreLoadAvatar("S360_2")
		PreLoadAvatar("S360_3")
		PreLoadAvatar("S360_5")
		PreLoadAvatar("S360_4")
		PreLoadAvatar("S360_6")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsg" )
		effectScript:RegisterEvent( 39, "dsgfdh" )
		effectScript:RegisterEvent( 49, "dsfdhg" )
		effectScript:RegisterEvent( 56, "dsfh" )
		effectScript:RegisterEvent( 62, "dsgfdhfg" )
		effectScript:RegisterEvent( 89, "dsfgdh" )
		effectScript:RegisterEvent( 93, "sdfdg" )
		effectScript:RegisterEvent( 107, "sfsdg" )
		effectScript:RegisterEvent( 111, "gfjj" )
		effectScript:RegisterEvent( 113, "frg" )
	end,

	dsg = function( effectScript )
		SetAnimation(S360_magic_H027_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	dsgfdh = function( effectScript )
		SetAnimation(S360_magic_H027_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdhg = function( effectScript )
		AttachAvatarPosEffect(false, S360_magic_H027_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 72), 1, 100, "S360_1")
	end,

	dsfh = function( effectScript )
		AttachAvatarPosEffect(false, S360_magic_H027_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 50), 1.2, 100, "S360_2")
	end,

	dsgfdhfg = function( effectScript )
		AttachAvatarPosEffect(false, S360_magic_H027_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S360_3")
	end,

	dsfgdh = function( effectScript )
		AttachAvatarPosEffect(false, S360_magic_H027_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 100), 1, 100, "S360_5")
	end,

	sdfdg = function( effectScript )
		AttachAvatarPosEffect(false, S360_magic_H027_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 50), 1, 100, "S360_4")
	end,

	sfsdg = function( effectScript )
		end,

	gfjj = function( effectScript )
		AttachAvatarPosEffect(false, S360_magic_H027_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(350, 0), 1.2, 100, "S360_6")
	end,

	frg = function( effectScript )
			DamageEffect(S360_magic_H027_attack.info_pool[effectScript.ID].Attacker, S360_magic_H027_attack.info_pool[effectScript.ID].Targeter, S360_magic_H027_attack.info_pool[effectScript.ID].AttackType, S360_magic_H027_attack.info_pool[effectScript.ID].AttackDataList, S360_magic_H027_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
