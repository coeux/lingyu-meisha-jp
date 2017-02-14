S201_magic_H015_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S201_magic_H015_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S201_magic_H015_attack.info_pool[effectScript.ID].Attacker)
        
		S201_magic_H015_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01501")
		PreLoadSound("stalk_01501")
		PreLoadSound("skill_01502")
		PreLoadAvatar("S200_1")
		PreLoadAvatar("S200")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "b" )
		effectScript:RegisterEvent( 20, "fhfgj" )
		effectScript:RegisterEvent( 23, "fdsafgg" )
		effectScript:RegisterEvent( 26, "fasfsdf" )
		effectScript:RegisterEvent( 27, "s" )
		effectScript:RegisterEvent( 28, "d" )
	end,

	b = function( effectScript )
		SetAnimation(S201_magic_H015_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	fhfgj = function( effectScript )
			PlaySound("skill_01501")
		PlaySound("stalk_01501")
	end,

	fdsafgg = function( effectScript )
			PlaySound("skill_01502")
	end,

	fasfsdf = function( effectScript )
		AttachAvatarPosEffect(false, S201_magic_H015_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(170, 10), 1.2, 100, "S200_1")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S201_magic_H015_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, 100, "S200")
	end,

	d = function( effectScript )
			DamageEffect(S201_magic_H015_attack.info_pool[effectScript.ID].Attacker, S201_magic_H015_attack.info_pool[effectScript.ID].Targeter, S201_magic_H015_attack.info_pool[effectScript.ID].AttackType, S201_magic_H015_attack.info_pool[effectScript.ID].AttackDataList, S201_magic_H015_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
