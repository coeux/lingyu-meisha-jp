S863_magic_H051_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S863_magic_H051_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S863_magic_H051_attack.info_pool[effectScript.ID].Attacker)
        
		S863_magic_H051_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_05102")
		PreLoadAvatar("H051_1_1")
		PreLoadAvatar("H051_4_1")
		PreLoadSound("stalk_05101")
		PreLoadAvatar("H051_4_2")
		PreLoadSound("skill_05101")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfvb" )
		effectScript:RegisterEvent( 8, "scd" )
		effectScript:RegisterEvent( 41, "tghj" )
		effectScript:RegisterEvent( 64, "fvv" )
		effectScript:RegisterEvent( 65, "sc" )
	end,

	dsfvb = function( effectScript )
		SetAnimation(S863_magic_H051_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_05102")
	end,

	scd = function( effectScript )
		AttachAvatarPosEffect(false, S863_magic_H051_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-45, 83), 1, 100, "H051_1_1")
	end,

	tghj = function( effectScript )
		SetAnimation(S863_magic_H051_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	AttachAvatarPosEffect(false, S863_magic_H051_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-50, 83), 1, 100, "H051_4_1")
		PlaySound("stalk_05101")
	end,

	fvv = function( effectScript )
		AttachAvatarPosEffect(false, S863_magic_H051_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -40), 1.6, 100, "H051_4_2")
		PlaySound("skill_05101")
	end,

	sc = function( effectScript )
			DamageEffect(S863_magic_H051_attack.info_pool[effectScript.ID].Attacker, S863_magic_H051_attack.info_pool[effectScript.ID].Targeter, S863_magic_H051_attack.info_pool[effectScript.ID].AttackType, S863_magic_H051_attack.info_pool[effectScript.ID].AttackDataList, S863_magic_H051_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
