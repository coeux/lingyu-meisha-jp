S360_magic_H010_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S360_magic_H010_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S360_magic_H010_attack.info_pool[effectScript.ID].Attacker)
        
		S360_magic_H010_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0112")
		PreLoadAvatar("JJyinchang")
		PreLoadAvatar("S252_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "b" )
		effectScript:RegisterEvent( 19, "wer" )
		effectScript:RegisterEvent( 29, "a" )
		effectScript:RegisterEvent( 45, "ewfef" )
		effectScript:RegisterEvent( 52, "c" )
		effectScript:RegisterEvent( 53, "z" )
		effectScript:RegisterEvent( 55, "t" )
		effectScript:RegisterEvent( 58, "v" )
	end,

	b = function( effectScript )
		SetAnimation(S360_magic_H010_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s0112")
	end,

	wer = function( effectScript )
		AttachAvatarPosEffect(false, S360_magic_H010_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-50, 50), 2.5, 100, "JJyinchang")
	end,

	a = function( effectScript )
		SetAnimation(S360_magic_H010_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	ewfef = function( effectScript )
		AttachAvatarPosEffect(false, S360_magic_H010_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 5, 100, "S252_1")
	end,

	c = function( effectScript )
			DamageEffect(S360_magic_H010_attack.info_pool[effectScript.ID].Attacker, S360_magic_H010_attack.info_pool[effectScript.ID].Targeter, S360_magic_H010_attack.info_pool[effectScript.ID].AttackType, S360_magic_H010_attack.info_pool[effectScript.ID].AttackDataList, S360_magic_H010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	z = function( effectScript )
		CameraShake()
	end,

	t = function( effectScript )
			DamageEffect(S360_magic_H010_attack.info_pool[effectScript.ID].Attacker, S360_magic_H010_attack.info_pool[effectScript.ID].Targeter, S360_magic_H010_attack.info_pool[effectScript.ID].AttackType, S360_magic_H010_attack.info_pool[effectScript.ID].AttackDataList, S360_magic_H010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	v = function( effectScript )
			DamageEffect(S360_magic_H010_attack.info_pool[effectScript.ID].Attacker, S360_magic_H010_attack.info_pool[effectScript.ID].Targeter, S360_magic_H010_attack.info_pool[effectScript.ID].AttackType, S360_magic_H010_attack.info_pool[effectScript.ID].AttackDataList, S360_magic_H010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
