M004_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M004_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M004_normal_attack.info_pool[effectScript.ID].Attacker)
       	if M004_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M004_normal_attack.info_pool[effectScript.ID].Effect1);M004_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		M004_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("qiu")
		PreLoadAvatar("qiushouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 26, "e" )
		effectScript:RegisterEvent( 27, "r" )
		effectScript:RegisterEvent( 28, "f" )
		effectScript:RegisterEvent( 29, "shanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(M004_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	e = function( effectScript )
		M004_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M004_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 50), 2, 800, 300, 0.5, M004_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "qiu", effectScript)
	end,

	r = function( effectScript )
		AttachAvatarPosEffect(false, M004_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.5, 100, "qiushouji")
	end,

	f = function( effectScript )
		if M004_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M004_normal_attack.info_pool[effectScript.ID].Effect1);M004_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	shanghai = function( effectScript )
			DamageEffect(M004_normal_attack.info_pool[effectScript.ID].Attacker, M004_normal_attack.info_pool[effectScript.ID].Targeter, M004_normal_attack.info_pool[effectScript.ID].AttackType, M004_normal_attack.info_pool[effectScript.ID].AttackDataList, M004_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
