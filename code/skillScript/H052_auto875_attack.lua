H052_auto875_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H052_auto875_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H052_auto875_attack.info_pool[effectScript.ID].Attacker)
        
		H052_auto875_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05201")
		PreLoadAvatar("H052_3_2")
		PreLoadAvatar("H052_3_1")
		PreLoadSound("skill_05201")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "atgyh" )
		effectScript:RegisterEvent( 18, "drftgy" )
		effectScript:RegisterEvent( 20, "fgh" )
	end,

	atgyh = function( effectScript )
		SetAnimation(H052_auto875_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_05201")
	end,

	drftgy = function( effectScript )
		AttachAvatarPosEffect(false, H052_auto875_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(55, 13), 0.9, 100, "H052_3_2")
	AttachAvatarPosEffect(false, H052_auto875_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H052_3_1")
		PlaySound("skill_05201")
	end,

	fgh = function( effectScript )
			DamageEffect(H052_auto875_attack.info_pool[effectScript.ID].Attacker, H052_auto875_attack.info_pool[effectScript.ID].Targeter, H052_auto875_attack.info_pool[effectScript.ID].AttackType, H052_auto875_attack.info_pool[effectScript.ID].AttackDataList, H052_auto875_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
