H014_auto143_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H014_auto143_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H014_auto143_attack.info_pool[effectScript.ID].Attacker)
        
		H014_auto143_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01401")
		PreLoadSound("skill_01401")
		PreLoadSound("skill_01402")
		PreLoadAvatar("S140")
		PreLoadSound("atalk_01401")
		PreLoadSound("skill_01403")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aaa" )
		effectScript:RegisterEvent( 2, "dfdh" )
		effectScript:RegisterEvent( 10, "dsgfdh" )
		effectScript:RegisterEvent( 17, "a1" )
		effectScript:RegisterEvent( 21, "dgdfh" )
		effectScript:RegisterEvent( 25, "aa" )
	end,

	aaa = function( effectScript )
		SetAnimation(H014_auto143_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_01401")
	end,

	dfdh = function( effectScript )
			PlaySound("skill_01401")
	end,

	dsgfdh = function( effectScript )
			PlaySound("skill_01402")
	end,

	a1 = function( effectScript )
		AttachAvatarPosEffect(false, H014_auto143_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 30), 3.5, 100, "S140")
		PlaySound("atalk_01401")
	end,

	dgdfh = function( effectScript )
			PlaySound("skill_01403")
	end,

	aa = function( effectScript )
			DamageEffect(H014_auto143_attack.info_pool[effectScript.ID].Attacker, H014_auto143_attack.info_pool[effectScript.ID].Targeter, H014_auto143_attack.info_pool[effectScript.ID].AttackType, H014_auto143_attack.info_pool[effectScript.ID].AttackDataList, H014_auto143_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}