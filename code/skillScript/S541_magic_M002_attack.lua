S541_magic_M002_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S541_magic_M002_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S541_magic_M002_attack.info_pool[effectScript.ID].Attacker)
       	if S541_magic_M002_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S541_magic_M002_attack.info_pool[effectScript.ID].Effect1);S541_magic_M002_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		S541_magic_M002_attack.info_pool[effectScript.ID] = nil
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
		SetAnimation(S541_magic_M002_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	e = function( effectScript )
		S541_magic_M002_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S541_magic_M002_attack.info_pool[effectScript.ID].Attacker, Vector2(-50, 0), 1, 600, 500, 1.5, S541_magic_M002_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, -20), "pingzi", effectScript)
	end,

	r = function( effectScript )
		if S541_magic_M002_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S541_magic_M002_attack.info_pool[effectScript.ID].Effect1);S541_magic_M002_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, S541_magic_M002_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 90), 2, 100, "Zshouji")
	end,

	vf = function( effectScript )
			DamageEffect(S541_magic_M002_attack.info_pool[effectScript.ID].Attacker, S541_magic_M002_attack.info_pool[effectScript.ID].Targeter, S541_magic_M002_attack.info_pool[effectScript.ID].AttackType, S541_magic_M002_attack.info_pool[effectScript.ID].AttackDataList, S541_magic_M002_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
