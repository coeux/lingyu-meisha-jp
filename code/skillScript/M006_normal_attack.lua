M006_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M006_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M006_normal_attack.info_pool[effectScript.ID].Attacker)
       	if M006_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M006_normal_attack.info_pool[effectScript.ID].Effect1);M006_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		M006_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("luobo")
		PreLoadAvatar("luoboshouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fe" )
		effectScript:RegisterEvent( 27, "e" )
		effectScript:RegisterEvent( 28, "c" )
		effectScript:RegisterEvent( 29, "dd" )
		effectScript:RegisterEvent( 30, "es" )
	end,

	fe = function( effectScript )
		SetAnimation(M006_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	e = function( effectScript )
		M006_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M006_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(20, 100), 2, 600, 300, 1, M006_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, -20), "luobo", effectScript)
	end,

	c = function( effectScript )
		if M006_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M006_normal_attack.info_pool[effectScript.ID].Effect1);M006_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, M006_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "luoboshouji")
	end,

	es = function( effectScript )
			DamageEffect(M006_normal_attack.info_pool[effectScript.ID].Attacker, M006_normal_attack.info_pool[effectScript.ID].Targeter, M006_normal_attack.info_pool[effectScript.ID].AttackType, M006_normal_attack.info_pool[effectScript.ID].AttackDataList, M006_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
