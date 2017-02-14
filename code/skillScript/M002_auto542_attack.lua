M002_auto542_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M002_auto542_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M002_auto542_attack.info_pool[effectScript.ID].Attacker)
       	if M002_auto542_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M002_auto542_attack.info_pool[effectScript.ID].Effect1);M002_auto542_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		M002_auto542_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("pingzi")
		PreLoadAvatar("Zshouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sf" )
		effectScript:RegisterEvent( 17, "e" )
		effectScript:RegisterEvent( 18, "r" )
		effectScript:RegisterEvent( 19, "dd" )
		effectScript:RegisterEvent( 20, "vf" )
	end,

	sf = function( effectScript )
		SetAnimation(M002_auto542_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	e = function( effectScript )
		M002_auto542_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M002_auto542_attack.info_pool[effectScript.ID].Attacker, Vector2(-30, 0), 1, 500, 500, 1.5, M002_auto542_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, -20), "pingzi", effectScript)
	end,

	r = function( effectScript )
		if M002_auto542_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M002_auto542_attack.info_pool[effectScript.ID].Effect1);M002_auto542_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, M002_auto542_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 90), 2, 100, "Zshouji")
	end,

	vf = function( effectScript )
			DamageEffect(M002_auto542_attack.info_pool[effectScript.ID].Attacker, M002_auto542_attack.info_pool[effectScript.ID].Targeter, M002_auto542_attack.info_pool[effectScript.ID].AttackType, M002_auto542_attack.info_pool[effectScript.ID].AttackDataList, M002_auto542_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
