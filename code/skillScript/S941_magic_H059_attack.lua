S941_magic_H059_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S941_magic_H059_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S941_magic_H059_attack.info_pool[effectScript.ID].Attacker)
        
		S941_magic_H059_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05901")
		PreLoadSound("skill_05901")
		PreLoadAvatar("H059_1_1")
		PreLoadAvatar("H059_3_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fjeag" )
		effectScript:RegisterEvent( 12, "dh" )
		effectScript:RegisterEvent( 34, "gfe" )
		effectScript:RegisterEvent( 53, "ikgt" )
		effectScript:RegisterEvent( 55, "ieh" )
	end,

	fjeag = function( effectScript )
		SetAnimation(S941_magic_H059_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_05901")
		PlaySound("skill_05901")
	end,

	dh = function( effectScript )
		AttachAvatarPosEffect(false, S941_magic_H059_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(45, 145), 1.5, 100, "H059_1_1")
	end,

	gfe = function( effectScript )
		SetAnimation(S941_magic_H059_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	ikgt = function( effectScript )
		AttachAvatarPosEffect(false, S941_magic_H059_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 1.4, 100, "H059_3_1")
	end,

	ieh = function( effectScript )
			DamageEffect(S941_magic_H059_attack.info_pool[effectScript.ID].Attacker, S941_magic_H059_attack.info_pool[effectScript.ID].Targeter, S941_magic_H059_attack.info_pool[effectScript.ID].AttackType, S941_magic_H059_attack.info_pool[effectScript.ID].AttackDataList, S941_magic_H059_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
