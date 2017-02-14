S883_magic_H053_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S883_magic_H053_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S883_magic_H053_attack.info_pool[effectScript.ID].Attacker)
        
		S883_magic_H053_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05301")
		PreLoadSound("skill_05303")
		PreLoadAvatar("H053_1")
		PreLoadSound("skill_05301")
		PreLoadAvatar("H053_4_1")
		PreLoadAvatar("H053_4_2")
		PreLoadAvatar("H053_4_2")
		PreLoadAvatar("H053_4_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sxfvgt" )
		effectScript:RegisterEvent( 7, "xdcfg" )
		effectScript:RegisterEvent( 37, "hjkl" )
		effectScript:RegisterEvent( 54, "dfgy" )
		effectScript:RegisterEvent( 56, "hjklcvb" )
		effectScript:RegisterEvent( 66, "uyhiu" )
		effectScript:RegisterEvent( 68, "mjmng" )
	end,

	sxfvgt = function( effectScript )
		SetAnimation(S883_magic_H053_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_05301")
		PlaySound("skill_05303")
	end,

	xdcfg = function( effectScript )
		AttachAvatarPosEffect(false, S883_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H053_1")
	end,

	hjkl = function( effectScript )
		SetAnimation(S883_magic_H053_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("skill_05301")
	end,

	dfgy = function( effectScript )
		AttachAvatarPosEffect(false, S883_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -15), 1.3, 100, "H053_4_1")
	end,

	hjklcvb = function( effectScript )
		AttachAvatarPosEffect(false, S883_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.25, 100, "H053_4_2")
	AttachAvatarPosEffect(false, S883_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -20), 1.3, 100, "H053_4_2")
	end,

	uyhiu = function( effectScript )
		AttachAvatarPosEffect(false, S883_magic_H053_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "H053_4_3")
	end,

	mjmng = function( effectScript )
			DamageEffect(S883_magic_H053_attack.info_pool[effectScript.ID].Attacker, S883_magic_H053_attack.info_pool[effectScript.ID].Targeter, S883_magic_H053_attack.info_pool[effectScript.ID].AttackType, S883_magic_H053_attack.info_pool[effectScript.ID].AttackDataList, S883_magic_H053_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
