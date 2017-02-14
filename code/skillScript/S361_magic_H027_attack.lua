S361_magic_H027_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S361_magic_H027_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S361_magic_H027_attack.info_pool[effectScript.ID].Attacker)
        
		S361_magic_H027_attack.info_pool[effectScript.ID] = nil
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
		effectScript:RegisterEvent( 35, "dsgfdh" )
		effectScript:RegisterEvent( 46, "dsfdhg" )
		effectScript:RegisterEvent( 52, "dsfh" )
		effectScript:RegisterEvent( 57, "dsgfdhfg" )
		effectScript:RegisterEvent( 86, "dsfgdh" )
		effectScript:RegisterEvent( 91, "sdfdg" )
		effectScript:RegisterEvent( 105, "gfjj" )
		effectScript:RegisterEvent( 108, "sadsg" )
	end,

	dsg = function( effectScript )
		SetAnimation(S361_magic_H027_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	dsgfdh = function( effectScript )
		SetAnimation(S361_magic_H027_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdhg = function( effectScript )
		AttachAvatarPosEffect(false, S361_magic_H027_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 72), 1, 100, "S360_1")
	end,

	dsfh = function( effectScript )
		AttachAvatarPosEffect(false, S361_magic_H027_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 50), 1.2, 100, "S360_2")
	end,

	dsgfdhfg = function( effectScript )
		AttachAvatarPosEffect(false, S361_magic_H027_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S360_3")
	end,

	dsfgdh = function( effectScript )
		AttachAvatarPosEffect(false, S361_magic_H027_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 100), 1, 100, "S360_5")
	end,

	sdfdg = function( effectScript )
		AttachAvatarPosEffect(false, S361_magic_H027_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 50), 1, 100, "S360_4")
	end,

	gfjj = function( effectScript )
		AttachAvatarPosEffect(false, S361_magic_H027_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(350, 0), 1.2, 100, "S360_6")
	end,

	sadsg = function( effectScript )
			DamageEffect(S361_magic_H027_attack.info_pool[effectScript.ID].Attacker, S361_magic_H027_attack.info_pool[effectScript.ID].Targeter, S361_magic_H027_attack.info_pool[effectScript.ID].AttackType, S361_magic_H027_attack.info_pool[effectScript.ID].AttackDataList, S361_magic_H027_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
