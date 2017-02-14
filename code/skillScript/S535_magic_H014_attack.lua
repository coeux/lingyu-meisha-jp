S535_magic_H014_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S535_magic_H014_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S535_magic_H014_attack.info_pool[effectScript.ID].Attacker)
        
		S535_magic_H014_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01401")
		PreLoadSound("skill_01402")
		PreLoadSound("skill_01401")
		PreLoadSound("skill_01404")
		PreLoadSound("atalk_01401")
		PreLoadAvatar("S144")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 6, "sfgdh" )
		effectScript:RegisterEvent( 19, "fdshg" )
		effectScript:RegisterEvent( 25, "aaa" )
		effectScript:RegisterEvent( 50, "dgdfh" )
		effectScript:RegisterEvent( 53, "a1" )
		effectScript:RegisterEvent( 58, "aa" )
		effectScript:RegisterEvent( 62, "g" )
		effectScript:RegisterEvent( 67, "e" )
	end,

	a = function( effectScript )
		SetAnimation(S535_magic_H014_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_01401")
	end,

	sfgdh = function( effectScript )
			PlaySound("skill_01402")
	end,

	fdshg = function( effectScript )
			PlaySound("skill_01401")
	end,

	aaa = function( effectScript )
		SetAnimation(S535_magic_H014_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dgdfh = function( effectScript )
			PlaySound("skill_01404")
		PlaySound("atalk_01401")
	end,

	a1 = function( effectScript )
		AttachAvatarPosEffect(false, S535_magic_H014_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(230, 90), 3, 100, "S144")
	end,

	aa = function( effectScript )
			DamageEffect(S535_magic_H014_attack.info_pool[effectScript.ID].Attacker, S535_magic_H014_attack.info_pool[effectScript.ID].Targeter, S535_magic_H014_attack.info_pool[effectScript.ID].AttackType, S535_magic_H014_attack.info_pool[effectScript.ID].AttackDataList, S535_magic_H014_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	g = function( effectScript )
			DamageEffect(S535_magic_H014_attack.info_pool[effectScript.ID].Attacker, S535_magic_H014_attack.info_pool[effectScript.ID].Targeter, S535_magic_H014_attack.info_pool[effectScript.ID].AttackType, S535_magic_H014_attack.info_pool[effectScript.ID].AttackDataList, S535_magic_H014_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	e = function( effectScript )
			DamageEffect(S535_magic_H014_attack.info_pool[effectScript.ID].Attacker, S535_magic_H014_attack.info_pool[effectScript.ID].Targeter, S535_magic_H014_attack.info_pool[effectScript.ID].AttackType, S535_magic_H014_attack.info_pool[effectScript.ID].AttackDataList, S535_magic_H014_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
