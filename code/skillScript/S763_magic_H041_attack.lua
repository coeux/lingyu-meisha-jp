S763_magic_H041_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S763_magic_H041_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S763_magic_H041_attack.info_pool[effectScript.ID].Attacker)
        
		S763_magic_H041_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S762_1")
		PreLoadSound("skill_04104")
		PreLoadSound("skill_04105")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgdhj" )
		effectScript:RegisterEvent( 16, "dgfdhj" )
		effectScript:RegisterEvent( 47, "dfgfjj" )
	end,

	dfgdhj = function( effectScript )
		SetAnimation(S763_magic_H041_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dgfdhj = function( effectScript )
		AttachAvatarPosEffect(false, S763_magic_H041_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(60, 50), 1.5, 100, "S762_1")
		PlaySound("skill_04104")
	end,

	dfgfjj = function( effectScript )
			DamageEffect(S763_magic_H041_attack.info_pool[effectScript.ID].Attacker, S763_magic_H041_attack.info_pool[effectScript.ID].Targeter, S763_magic_H041_attack.info_pool[effectScript.ID].AttackType, S763_magic_H041_attack.info_pool[effectScript.ID].AttackDataList, S763_magic_H041_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("skill_04105")
	end,

}
