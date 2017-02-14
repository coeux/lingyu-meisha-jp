S144_magic_H014_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S144_magic_H014_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S144_magic_H014_attack.info_pool[effectScript.ID].Attacker)
        
		S144_magic_H014_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01401")
		PreLoadSound("skill_01405")
		PreLoadSound("skill_01401")
		PreLoadSound("skill_01404")
		PreLoadSound("atalk_01401")
		PreLoadAvatar("S144")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 7, "dsfsdgh" )
		effectScript:RegisterEvent( 18, "dfgfh" )
		effectScript:RegisterEvent( 27, "dsfdsh" )
		effectScript:RegisterEvent( 40, "dsgdh" )
		effectScript:RegisterEvent( 45, "aaa" )
		effectScript:RegisterEvent( 69, "dfgdfh" )
		effectScript:RegisterEvent( 73, "a1" )
		effectScript:RegisterEvent( 78, "aa" )
		effectScript:RegisterEvent( 82, "g" )
		effectScript:RegisterEvent( 87, "e" )
	end,

	a = function( effectScript )
		SetAnimation(S144_magic_H014_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_01401")
	end,

	dsfsdgh = function( effectScript )
			PlaySound("skill_01405")
	end,

	dfgfh = function( effectScript )
		end,

	dsfdsh = function( effectScript )
		end,

	dsgdh = function( effectScript )
			PlaySound("skill_01401")
	end,

	aaa = function( effectScript )
		SetAnimation(S144_magic_H014_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dfgdfh = function( effectScript )
			PlaySound("skill_01404")
		PlaySound("atalk_01401")
	end,

	a1 = function( effectScript )
		AttachAvatarPosEffect(false, S144_magic_H014_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(230, 90), 3, 100, "S144")
	end,

	aa = function( effectScript )
			DamageEffect(S144_magic_H014_attack.info_pool[effectScript.ID].Attacker, S144_magic_H014_attack.info_pool[effectScript.ID].Targeter, S144_magic_H014_attack.info_pool[effectScript.ID].AttackType, S144_magic_H014_attack.info_pool[effectScript.ID].AttackDataList, S144_magic_H014_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	g = function( effectScript )
			DamageEffect(S144_magic_H014_attack.info_pool[effectScript.ID].Attacker, S144_magic_H014_attack.info_pool[effectScript.ID].Targeter, S144_magic_H014_attack.info_pool[effectScript.ID].AttackType, S144_magic_H014_attack.info_pool[effectScript.ID].AttackDataList, S144_magic_H014_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	e = function( effectScript )
			DamageEffect(S144_magic_H014_attack.info_pool[effectScript.ID].Attacker, S144_magic_H014_attack.info_pool[effectScript.ID].Targeter, S144_magic_H014_attack.info_pool[effectScript.ID].AttackType, S144_magic_H014_attack.info_pool[effectScript.ID].AttackDataList, S144_magic_H014_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
