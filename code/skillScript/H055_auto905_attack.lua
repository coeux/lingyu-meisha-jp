H055_auto905_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H055_auto905_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H055_auto905_attack.info_pool[effectScript.ID].Attacker)
        
		H055_auto905_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05501")
		PreLoadSound("skill_05503")
		PreLoadAvatar("H055_4_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "va" )
		effectScript:RegisterEvent( 12, "df" )
		effectScript:RegisterEvent( 14, "mpo" )
	end,

	va = function( effectScript )
		SetAnimation(H055_auto905_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_05501")
		PlaySound("skill_05503")
	end,

	df = function( effectScript )
		AttachAvatarPosEffect(false, H055_auto905_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-10, -10), 1.1, 100, "H055_4_1")
	end,

	mpo = function( effectScript )
			DamageEffect(H055_auto905_attack.info_pool[effectScript.ID].Attacker, H055_auto905_attack.info_pool[effectScript.ID].Targeter, H055_auto905_attack.info_pool[effectScript.ID].AttackType, H055_auto905_attack.info_pool[effectScript.ID].AttackDataList, H055_auto905_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
