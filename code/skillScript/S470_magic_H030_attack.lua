S470_magic_H030_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S470_magic_H030_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S470_magic_H030_attack.info_pool[effectScript.ID].Attacker)
        
		S470_magic_H030_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_03001")
		PreLoadSound("s0304")
		PreLoadSound("s0303")
		PreLoadAvatar("H001_xuli")
		PreLoadAvatar("s621_2")
		PreLoadAvatar("s621_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsg" )
		effectScript:RegisterEvent( 11, "dsafdg" )
		effectScript:RegisterEvent( 23, "gfh" )
		effectScript:RegisterEvent( 27, "gfhfdh" )
		effectScript:RegisterEvent( 28, "fvdhg" )
	end,

	dsg = function( effectScript )
		SetAnimation(S470_magic_H030_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_03001")
		PlaySound("s0304")
		PlaySound("s0303")
	end,

	dsafdg = function( effectScript )
		AttachAvatarPosEffect(false, S470_magic_H030_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H001_xuli")
	end,

	gfh = function( effectScript )
		AttachAvatarPosEffect(false, S470_magic_H030_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-10, 0), 1.5, 100, "s621_2")
	end,

	gfhfdh = function( effectScript )
		AttachAvatarPosEffect(false, S470_magic_H030_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(10, 20), 1.8, 100, "s621_2")
	end,

	fvdhg = function( effectScript )
			DamageEffect(S470_magic_H030_attack.info_pool[effectScript.ID].Attacker, S470_magic_H030_attack.info_pool[effectScript.ID].Targeter, S470_magic_H030_attack.info_pool[effectScript.ID].AttackType, S470_magic_H030_attack.info_pool[effectScript.ID].AttackDataList, S470_magic_H030_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
