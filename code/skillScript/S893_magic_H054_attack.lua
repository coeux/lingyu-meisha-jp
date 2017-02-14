S893_magic_H054_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S893_magic_H054_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S893_magic_H054_attack.info_pool[effectScript.ID].Attacker)
        
		S893_magic_H054_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05401")
		PreLoadAvatar("H054_1")
		PreLoadSound("skill_05403")
		PreLoadAvatar("H054_4_2")
		PreLoadSound("skill_05404")
		PreLoadSound("skill_05405")
		PreLoadAvatar("H054_4_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "jhk" )
		effectScript:RegisterEvent( 10, "cvbn" )
		effectScript:RegisterEvent( 34, "kol" )
		effectScript:RegisterEvent( 43, "xcvb" )
		effectScript:RegisterEvent( 44, "jh" )
		effectScript:RegisterEvent( 50, "vgb" )
	end,

	jhk = function( effectScript )
		SetAnimation(S893_magic_H054_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_05401")
	end,

	cvbn = function( effectScript )
		AttachAvatarPosEffect(false, S893_magic_H054_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-15, -10), 1.1, 100, "H054_1")
		PlaySound("skill_05403")
	end,

	kol = function( effectScript )
		SetAnimation(S893_magic_H054_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	xcvb = function( effectScript )
		AttachAvatarPosEffect(false, S893_magic_H054_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(20, -50), 1.65, 100, "H054_4_2")
		PlaySound("skill_05404")
		PlaySound("skill_05405")
	end,

	jh = function( effectScript )
		AttachAvatarPosEffect(false, S893_magic_H054_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-120, 160), 1, 100, "H054_4_1")
	end,

	vgb = function( effectScript )
			DamageEffect(S893_magic_H054_attack.info_pool[effectScript.ID].Attacker, S893_magic_H054_attack.info_pool[effectScript.ID].Targeter, S893_magic_H054_attack.info_pool[effectScript.ID].AttackType, S893_magic_H054_attack.info_pool[effectScript.ID].AttackDataList, S893_magic_H054_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
