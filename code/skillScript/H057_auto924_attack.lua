H057_auto924_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H057_auto924_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H057_auto924_attack.info_pool[effectScript.ID].Attacker)
        
		H057_auto924_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05701")
		PreLoadAvatar("H057_3_1")
		PreLoadSound("skill_05701")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "gh" )
		effectScript:RegisterEvent( 34, "fgy" )
		effectScript:RegisterEvent( 36, "ui" )
	end,

	gh = function( effectScript )
		SetAnimation(H057_auto924_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_05701")
	end,

	fgy = function( effectScript )
		AttachAvatarPosEffect(false, H057_auto924_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -20), 1.2, 100, "H057_3_1")
		PlaySound("skill_05701")
	end,

	ui = function( effectScript )
			DamageEffect(H057_auto924_attack.info_pool[effectScript.ID].Attacker, H057_auto924_attack.info_pool[effectScript.ID].Targeter, H057_auto924_attack.info_pool[effectScript.ID].AttackType, H057_auto924_attack.info_pool[effectScript.ID].AttackDataList, H057_auto924_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
