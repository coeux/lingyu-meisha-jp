S592_magic_H014_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S592_magic_H014_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S592_magic_H014_attack.info_pool[effectScript.ID].Attacker)
        
		S592_magic_H014_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01401")
		PreLoadSound("skill_01401")
		PreLoadSound("skill_01404")
		PreLoadSound("atalk_01401")
		PreLoadAvatar("S144")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aaa" )
		effectScript:RegisterEvent( 5, "dgfdg" )
		effectScript:RegisterEvent( 25, "dfgdfgh" )
		effectScript:RegisterEvent( 28, "a1" )
		effectScript:RegisterEvent( 32, "aa" )
		effectScript:RegisterEvent( 36, "asdf" )
		effectScript:RegisterEvent( 40, "saf" )
	end,

	aaa = function( effectScript )
		SetAnimation(S592_magic_H014_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_01401")
	end,

	dgfdg = function( effectScript )
			PlaySound("skill_01401")
	end,

	dfgdfgh = function( effectScript )
			PlaySound("skill_01404")
		PlaySound("atalk_01401")
	end,

	a1 = function( effectScript )
		AttachAvatarPosEffect(false, S592_magic_H014_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, 80), 3, 100, "S144")
	end,

	aa = function( effectScript )
			DamageEffect(S592_magic_H014_attack.info_pool[effectScript.ID].Attacker, S592_magic_H014_attack.info_pool[effectScript.ID].Targeter, S592_magic_H014_attack.info_pool[effectScript.ID].AttackType, S592_magic_H014_attack.info_pool[effectScript.ID].AttackDataList, S592_magic_H014_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	asdf = function( effectScript )
			DamageEffect(S592_magic_H014_attack.info_pool[effectScript.ID].Attacker, S592_magic_H014_attack.info_pool[effectScript.ID].Targeter, S592_magic_H014_attack.info_pool[effectScript.ID].AttackType, S592_magic_H014_attack.info_pool[effectScript.ID].AttackDataList, S592_magic_H014_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	saf = function( effectScript )
			DamageEffect(S592_magic_H014_attack.info_pool[effectScript.ID].Attacker, S592_magic_H014_attack.info_pool[effectScript.ID].Targeter, S592_magic_H014_attack.info_pool[effectScript.ID].AttackType, S592_magic_H014_attack.info_pool[effectScript.ID].AttackDataList, S592_magic_H014_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
