H038_auto734_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H038_auto734_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H038_auto734_attack.info_pool[effectScript.ID].Attacker)
        
		H038_auto734_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S730_1")
		PreLoadSound("skill_03802")
		PreLoadSound("atalk_03801")
		PreLoadAvatar("S732_3")
		PreLoadSound("skill_03803")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgfdhgfj" )
		effectScript:RegisterEvent( 5, "dsgdfhjh" )
		effectScript:RegisterEvent( 17, "fdghfjjj" )
		effectScript:RegisterEvent( 18, "dsfdgh" )
	end,

	dgfdhgfj = function( effectScript )
		SetAnimation(H038_auto734_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsgdfhjh = function( effectScript )
		AttachAvatarPosEffect(false, H038_auto734_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 10), 1, 100, "S730_1")
		PlaySound("skill_03802")
		PlaySound("atalk_03801")
	end,

	fdghfjjj = function( effectScript )
		AttachAvatarPosEffect(false, H038_auto734_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S732_3")
		PlaySound("skill_03803")
	end,

	dsfdgh = function( effectScript )
			DamageEffect(H038_auto734_attack.info_pool[effectScript.ID].Attacker, H038_auto734_attack.info_pool[effectScript.ID].Targeter, H038_auto734_attack.info_pool[effectScript.ID].AttackType, H038_auto734_attack.info_pool[effectScript.ID].AttackDataList, H038_auto734_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
