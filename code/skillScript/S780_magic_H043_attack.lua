S780_magic_H043_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S780_magic_H043_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S780_magic_H043_attack.info_pool[effectScript.ID].Attacker)
        
		S780_magic_H043_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H043_xuli_1")
		PreLoadAvatar("H043_xuli_2")
		PreLoadSound("skill_04304")
		PreLoadSound("stalk_04301")
		PreLoadAvatar("S780_2")
		PreLoadSound("skill_04303")
		PreLoadAvatar("S780_1")
		PreLoadSound("skill_04303")
		PreLoadSound("skill_04303")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgdfhfjh" )
		effectScript:RegisterEvent( 14, "fdsfdhg" )
		effectScript:RegisterEvent( 45, "dfdghh" )
		effectScript:RegisterEvent( 67, "dsfdgfhhj" )
		effectScript:RegisterEvent( 70, "fgfhgjj" )
		effectScript:RegisterEvent( 72, "dfdhgj" )
	end,

	dgdfhfjh = function( effectScript )
		SetAnimation(S780_magic_H043_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	fdsfdhg = function( effectScript )
		AttachAvatarPosEffect(false, S780_magic_H043_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H043_xuli_1")
	AttachAvatarPosEffect(false, S780_magic_H043_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, -100, "H043_xuli_2")
		PlaySound("skill_04304")
		PlaySound("stalk_04301")
	end,

	dfdghh = function( effectScript )
		SetAnimation(S780_magic_H043_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdgfhhj = function( effectScript )
		AttachAvatarPosEffect(false, S780_magic_H043_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(130, 130), 2, 100, "S780_2")
		PlaySound("skill_04303")
	end,

	fgfhgjj = function( effectScript )
		AttachAvatarPosEffect(false, S780_magic_H043_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 70), 2, 100, "S780_1")
		PlaySound("skill_04303")
	end,

	dfdhgj = function( effectScript )
			DamageEffect(S780_magic_H043_attack.info_pool[effectScript.ID].Attacker, S780_magic_H043_attack.info_pool[effectScript.ID].Targeter, S780_magic_H043_attack.info_pool[effectScript.ID].AttackType, S780_magic_H043_attack.info_pool[effectScript.ID].AttackDataList, S780_magic_H043_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("skill_04303")
	end,

}
