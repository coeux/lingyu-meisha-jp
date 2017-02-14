M032_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M032_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M032_normal_attack.info_pool[effectScript.ID].Attacker)
		M032_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("M033_1")
		PreLoadSound("fire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 17, "b" )
		effectScript:RegisterEvent( 19, "v" )
	end,

	a = function( effectScript )
		SetAnimation(M032_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, M032_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "M033_1")
	end,

	v = function( effectScript )
			DamageEffect(M032_normal_attack.info_pool[effectScript.ID].Attacker, M032_normal_attack.info_pool[effectScript.ID].Targeter, M032_normal_attack.info_pool[effectScript.ID].AttackType, M032_normal_attack.info_pool[effectScript.ID].AttackDataList, M032_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("fire")
	end,

}
