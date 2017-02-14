H032_auto405_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H032_auto405_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H032_auto405_attack.info_pool[effectScript.ID].Attacker)
        
		H032_auto405_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("")
		PreLoadAvatar("S442_1")
		PreLoadSound("skill_03204")
		PreLoadAvatar("S442_9")
		PreLoadAvatar("H032_jineng")
		PreLoadSound("skill_03203")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsgdh" )
		effectScript:RegisterEvent( 5, "fdgfh" )
		effectScript:RegisterEvent( 21, "dgh" )
		effectScript:RegisterEvent( 24, "fghj" )
		effectScript:RegisterEvent( 26, "dgfh" )
	end,

	dsgdh = function( effectScript )
		SetAnimation(H032_auto405_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("")
	end,

	fdgfh = function( effectScript )
		AttachAvatarPosEffect(false, H032_auto405_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 165), 0.7, -100, "S442_1")
		PlaySound("skill_03204")
	end,

	dgh = function( effectScript )
		AttachAvatarPosEffect(false, H032_auto405_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 100), 1.8, 100, "S442_9")
	end,

	fghj = function( effectScript )
		AttachAvatarPosEffect(false, H032_auto405_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "H032_jineng")
		PlaySound("skill_03203")
	end,

	dgfh = function( effectScript )
			DamageEffect(H032_auto405_attack.info_pool[effectScript.ID].Attacker, H032_auto405_attack.info_pool[effectScript.ID].Targeter, H032_auto405_attack.info_pool[effectScript.ID].AttackType, H032_auto405_attack.info_pool[effectScript.ID].AttackDataList, H032_auto405_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
