S524_magic_M004_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S524_magic_M004_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S524_magic_M004_attack.info_pool[effectScript.ID].Attacker)
       	if S524_magic_M004_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S524_magic_M004_attack.info_pool[effectScript.ID].Effect1);S524_magic_M004_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		S524_magic_M004_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("qiu")
		PreLoadAvatar("Zshouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 26, "e" )
		effectScript:RegisterEvent( 27, "f" )
		effectScript:RegisterEvent( 28, "r" )
		effectScript:RegisterEvent( 29, "shanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(S524_magic_M004_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	e = function( effectScript )
		S524_magic_M004_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S524_magic_M004_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 50), 2, 800, 300, 0.5, S524_magic_M004_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "qiu", effectScript)
	end,

	f = function( effectScript )
		if S524_magic_M004_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S524_magic_M004_attack.info_pool[effectScript.ID].Effect1);S524_magic_M004_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	r = function( effectScript )
		AttachAvatarPosEffect(false, S524_magic_M004_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.5, 100, "Zshouji")
	end,

	shanghai = function( effectScript )
			DamageEffect(S524_magic_M004_attack.info_pool[effectScript.ID].Attacker, S524_magic_M004_attack.info_pool[effectScript.ID].Targeter, S524_magic_M004_attack.info_pool[effectScript.ID].AttackType, S524_magic_M004_attack.info_pool[effectScript.ID].AttackDataList, S524_magic_M004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
