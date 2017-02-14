M031_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M031_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M031_normal_attack.info_pool[effectScript.ID].Attacker)
		M031_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("M031_1")
		PreLoadSound("fire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 17, "b" )
		effectScript:RegisterEvent( 21, "c" )
	end,

	a = function( effectScript )
		SetAnimation(M031_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, M031_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "M031_1")
	end,

	c = function( effectScript )
			DamageEffect(M031_normal_attack.info_pool[effectScript.ID].Attacker, M031_normal_attack.info_pool[effectScript.ID].Targeter, M031_normal_attack.info_pool[effectScript.ID].AttackType, M031_normal_attack.info_pool[effectScript.ID].AttackDataList, M031_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("fire")
	end,

}
