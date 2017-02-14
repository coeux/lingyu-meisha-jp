H005_auto184_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H005_auto184_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H005_auto184_attack.info_pool[effectScript.ID].Attacker)
        
		H005_auto184_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_0501")
		PreLoadSound("stalk_0501")
		PreLoadAvatar("S180_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 15, "sfdsfs" )
		effectScript:RegisterEvent( 33, "aaa" )
	end,

	aa = function( effectScript )
		SetAnimation(H005_auto184_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("skill_0501")
		PlaySound("stalk_0501")
	end,

	sfdsfs = function( effectScript )
		AttachAvatarPosEffect(false, H005_auto184_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 4, 100, "S180_1")
	end,

	aaa = function( effectScript )
			DamageEffect(H005_auto184_attack.info_pool[effectScript.ID].Attacker, H005_auto184_attack.info_pool[effectScript.ID].Targeter, H005_auto184_attack.info_pool[effectScript.ID].AttackType, H005_auto184_attack.info_pool[effectScript.ID].AttackDataList, H005_auto184_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
