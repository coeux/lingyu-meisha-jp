H014_auto526_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H014_auto526_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H014_auto526_attack.info_pool[effectScript.ID].Attacker)
        
		H014_auto526_attack.info_pool[effectScript.ID] = nil
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
		effectScript:RegisterEvent( 2, "dfgf" )
		effectScript:RegisterEvent( 26, "dfgfdh" )
		effectScript:RegisterEvent( 28, "a1" )
		effectScript:RegisterEvent( 32, "aa" )
		effectScript:RegisterEvent( 36, "asdf" )
		effectScript:RegisterEvent( 40, "saf" )
	end,

	aaa = function( effectScript )
		SetAnimation(H014_auto526_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_01401")
	end,

	dfgf = function( effectScript )
			PlaySound("skill_01401")
	end,

	dfgfdh = function( effectScript )
			PlaySound("skill_01404")
		PlaySound("atalk_01401")
	end,

	a1 = function( effectScript )
		AttachAvatarPosEffect(false, H014_auto526_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, 80), 3, 100, "S144")
	end,

	aa = function( effectScript )
			DamageEffect(H014_auto526_attack.info_pool[effectScript.ID].Attacker, H014_auto526_attack.info_pool[effectScript.ID].Targeter, H014_auto526_attack.info_pool[effectScript.ID].AttackType, H014_auto526_attack.info_pool[effectScript.ID].AttackDataList, H014_auto526_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	asdf = function( effectScript )
			DamageEffect(H014_auto526_attack.info_pool[effectScript.ID].Attacker, H014_auto526_attack.info_pool[effectScript.ID].Targeter, H014_auto526_attack.info_pool[effectScript.ID].AttackType, H014_auto526_attack.info_pool[effectScript.ID].AttackDataList, H014_auto526_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	saf = function( effectScript )
			DamageEffect(H014_auto526_attack.info_pool[effectScript.ID].Attacker, H014_auto526_attack.info_pool[effectScript.ID].Targeter, H014_auto526_attack.info_pool[effectScript.ID].AttackType, H014_auto526_attack.info_pool[effectScript.ID].AttackDataList, H014_auto526_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
