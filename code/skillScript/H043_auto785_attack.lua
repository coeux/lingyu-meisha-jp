H043_auto785_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H043_auto785_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H043_auto785_attack.info_pool[effectScript.ID].Attacker)
        
		H043_auto785_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S780_2")
		PreLoadSound("skill_04303")
		PreLoadAvatar("S780_1")
		PreLoadSound("skill_04303")
		PreLoadSound("skill_04303")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfdghh" )
		effectScript:RegisterEvent( 26, "dsfdgfhhj" )
		effectScript:RegisterEvent( 32, "fgfhgjj" )
		effectScript:RegisterEvent( 35, "dfdhgj" )
	end,

	dfdghh = function( effectScript )
		SetAnimation(H043_auto785_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdgfhhj = function( effectScript )
		AttachAvatarPosEffect(false, H043_auto785_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(130, 130), 2, 100, "S780_2")
		PlaySound("skill_04303")
	end,

	fgfhgjj = function( effectScript )
		AttachAvatarPosEffect(false, H043_auto785_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 70), 2, 100, "S780_1")
		PlaySound("skill_04303")
	end,

	dfdhgj = function( effectScript )
			DamageEffect(H043_auto785_attack.info_pool[effectScript.ID].Attacker, H043_auto785_attack.info_pool[effectScript.ID].Targeter, H043_auto785_attack.info_pool[effectScript.ID].AttackType, H043_auto785_attack.info_pool[effectScript.ID].AttackDataList, H043_auto785_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("skill_04303")
	end,

}
