H109_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H109_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H109_normal_attack.info_pool[effectScript.ID].Attacker)
		H109_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("girlhit")
		PreLoadAvatar("P02_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "r" )
		effectScript:RegisterEvent( 5, "wfa" )
		effectScript:RegisterEvent( 10, "f" )
	end,

	r = function( effectScript )
		SetAnimation(H109_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("girlhit")
	end,

	wfa = function( effectScript )
		AttachAvatarPosEffect(false, H109_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "P02_1")
	end,

	f = function( effectScript )
			DamageEffect(H109_normal_attack.info_pool[effectScript.ID].Attacker, H109_normal_attack.info_pool[effectScript.ID].Targeter, H109_normal_attack.info_pool[effectScript.ID].AttackType, H109_normal_attack.info_pool[effectScript.ID].AttackDataList, H109_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
