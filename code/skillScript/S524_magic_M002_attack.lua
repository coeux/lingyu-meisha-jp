S524_magic_M002_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S524_magic_M002_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S524_magic_M002_attack.info_pool[effectScript.ID].Attacker)
       	if S524_magic_M002_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S524_magic_M002_attack.info_pool[effectScript.ID].Effect1);S524_magic_M002_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		S524_magic_M002_attack.info_pool[effectScript.ID] = nil
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
		SetAnimation(S524_magic_M002_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	e = function( effectScript )
		S524_magic_M002_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S524_magic_M002_attack.info_pool[effectScript.ID].Attacker, Vector2(-30, 0), 1, 500, 500, 1.5, S524_magic_M002_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, -20), "pingzi", effectScript)
	end,

	r = function( effectScript )
		if S524_magic_M002_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S524_magic_M002_attack.info_pool[effectScript.ID].Effect1);S524_magic_M002_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, S524_magic_M002_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 90), 2, 100, "Zshouji")
	end,

	vf = function( effectScript )
			DamageEffect(S524_magic_M002_attack.info_pool[effectScript.ID].Attacker, S524_magic_M002_attack.info_pool[effectScript.ID].Targeter, S524_magic_M002_attack.info_pool[effectScript.ID].AttackType, S524_magic_M002_attack.info_pool[effectScript.ID].AttackDataList, S524_magic_M002_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
