S539_magic_H007_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S539_magic_H007_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S539_magic_H007_attack.info_pool[effectScript.ID].Attacker)
        
		S539_magic_H007_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_0701")
		PreLoadAvatar("S130_1")
		PreLoadAvatar("S130_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ff" )
		effectScript:RegisterEvent( 6, "dsfgdsh" )
		effectScript:RegisterEvent( 15, "adaf" )
		effectScript:RegisterEvent( 31, "fdsfdsf" )
		effectScript:RegisterEvent( 34, "sdfh" )
		effectScript:RegisterEvent( 36, "gvdfhg" )
		effectScript:RegisterEvent( 39, "dsadsa" )
	end,

	ff = function( effectScript )
		SetAnimation(S539_magic_H007_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("atalk_0701")
	end,

	dsfgdsh = function( effectScript )
	end,

	adaf = function( effectScript )
		AttachAvatarPosEffect(false, S539_magic_H007_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 120), 2, 100, "S130_1")
	end,

	fdsfdsf = function( effectScript )
		AttachAvatarPosEffect(false, S539_magic_H007_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, -20), 2.5, 100, "S130_3")
	end,

	sdfh = function( effectScript )
		end,

	gvdfhg = function( effectScript )
	end,

	dsadsa = function( effectScript )
			DamageEffect(S539_magic_H007_attack.info_pool[effectScript.ID].Attacker, S539_magic_H007_attack.info_pool[effectScript.ID].Targeter, S539_magic_H007_attack.info_pool[effectScript.ID].AttackType, S539_magic_H007_attack.info_pool[effectScript.ID].AttackDataList, S539_magic_H007_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
