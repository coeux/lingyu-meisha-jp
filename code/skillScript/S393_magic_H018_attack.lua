S393_magic_H018_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S393_magic_H018_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S393_magic_H018_attack.info_pool[effectScript.ID].Attacker)
        
		S393_magic_H018_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01801")
		PreLoadSound("skill_01804")
		PreLoadAvatar("S392_3")
		PreLoadSound("skill_01801")
		PreLoadAvatar("S392_2")
		PreLoadSound("skill_01801")
		PreLoadSound("skill_01805")
		PreLoadAvatar("S392_3")
		PreLoadAvatar("S392_1")
		PreLoadSound("skill_01805")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 19, "dgdf" )
		effectScript:RegisterEvent( 23, "fghgjk" )
		effectScript:RegisterEvent( 28, "sfdh" )
		effectScript:RegisterEvent( 32, "affds" )
		effectScript:RegisterEvent( 33, "fdh" )
		effectScript:RegisterEvent( 37, "dsfgdh" )
		effectScript:RegisterEvent( 38, "fdgfjh" )
		effectScript:RegisterEvent( 39, "s" )
		effectScript:RegisterEvent( 40, "dsg" )
		effectScript:RegisterEvent( 41, "adaff" )
		effectScript:RegisterEvent( 44, "dsgdh" )
		effectScript:RegisterEvent( 47, "afcf" )
	end,

	d = function( effectScript )
		SetAnimation(S393_magic_H018_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_01801")
	end,

	dgdf = function( effectScript )
			PlaySound("skill_01804")
	end,

	fghgjk = function( effectScript )
		AttachAvatarPosEffect(false, S393_magic_H018_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S392_3")
	end,

	sfdh = function( effectScript )
			PlaySound("skill_01801")
	end,

	affds = function( effectScript )
		AttachAvatarPosEffect(false, S393_magic_H018_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 2.5, 100, "S392_2")
	end,

	fdh = function( effectScript )
			PlaySound("skill_01801")
	end,

	dsfgdh = function( effectScript )
			PlaySound("skill_01805")
	end,

	fdgfjh = function( effectScript )
		AttachAvatarPosEffect(false, S393_magic_H018_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S392_3")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S393_magic_H018_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S392_1")
	end,

	dsg = function( effectScript )
	end,

	adaff = function( effectScript )
			DamageEffect(S393_magic_H018_attack.info_pool[effectScript.ID].Attacker, S393_magic_H018_attack.info_pool[effectScript.ID].Targeter, S393_magic_H018_attack.info_pool[effectScript.ID].AttackType, S393_magic_H018_attack.info_pool[effectScript.ID].AttackDataList, S393_magic_H018_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsgdh = function( effectScript )
			PlaySound("skill_01805")
	end,

	afcf = function( effectScript )
			DamageEffect(S393_magic_H018_attack.info_pool[effectScript.ID].Attacker, S393_magic_H018_attack.info_pool[effectScript.ID].Targeter, S393_magic_H018_attack.info_pool[effectScript.ID].AttackType, S393_magic_H018_attack.info_pool[effectScript.ID].AttackDataList, S393_magic_H018_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
