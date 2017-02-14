M009_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M009_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M009_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M009_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("M009_pugong")
		PreLoadAvatar("M009_pugongbeiji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 23, "saffffdfg" )
		effectScript:RegisterEvent( 27, "sfdsg" )
		effectScript:RegisterEvent( 28, "dd" )
	end,

	a = function( effectScript )
		SetAnimation(M009_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	saffffdfg = function( effectScript )
		AttachAvatarPosEffect(false, M009_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 50), 1, 100, "M009_pugong")
	end,

	sfdsg = function( effectScript )
		AttachAvatarPosEffect(false, M009_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "M009_pugongbeiji")
	end,

	dd = function( effectScript )
			DamageEffect(M009_normal_attack.info_pool[effectScript.ID].Attacker, M009_normal_attack.info_pool[effectScript.ID].Targeter, M009_normal_attack.info_pool[effectScript.ID].AttackType, M009_normal_attack.info_pool[effectScript.ID].AttackDataList, M009_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
