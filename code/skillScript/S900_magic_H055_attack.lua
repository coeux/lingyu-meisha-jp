S900_magic_H055_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S900_magic_H055_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S900_magic_H055_attack.info_pool[effectScript.ID].Attacker)
        
		S900_magic_H055_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H055_1_1")
		PreLoadSound("skill_05504")
		PreLoadAvatar("H055_1_1")
		PreLoadSound("stalk_05501")
		PreLoadAvatar("H055_5_1")
		PreLoadSound("skill_05502")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "db" )
		effectScript:RegisterEvent( 17, "inh" )
		effectScript:RegisterEvent( 31, "mj" )
		effectScript:RegisterEvent( 51, "dv" )
		effectScript:RegisterEvent( 62, "dfg" )
		effectScript:RegisterEvent( 65, "cdvb" )
	end,

	db = function( effectScript )
		SetAnimation(S900_magic_H055_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	inh = function( effectScript )
		AttachAvatarPosEffect(false, S900_magic_H055_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H055_1_1")
		PlaySound("skill_05504")
	end,

	mj = function( effectScript )
		AttachAvatarPosEffect(false, S900_magic_H055_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H055_1_1")
	end,

	dv = function( effectScript )
		SetAnimation(S900_magic_H055_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_05501")
	end,

	dfg = function( effectScript )
		AttachAvatarPosEffect(false, S900_magic_H055_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "H055_5_1")
		PlaySound("skill_05502")
	end,

	cdvb = function( effectScript )
			DamageEffect(S900_magic_H055_attack.info_pool[effectScript.ID].Attacker, S900_magic_H055_attack.info_pool[effectScript.ID].Targeter, S900_magic_H055_attack.info_pool[effectScript.ID].AttackType, S900_magic_H055_attack.info_pool[effectScript.ID].AttackDataList, S900_magic_H055_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
