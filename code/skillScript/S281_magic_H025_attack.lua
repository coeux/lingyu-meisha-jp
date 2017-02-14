S281_magic_H025_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S281_magic_H025_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S281_magic_H025_attack.info_pool[effectScript.ID].Attacker)
        
		S281_magic_H025_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S400_1")
		PreLoadAvatar("S350_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sadsfg" )
		effectScript:RegisterEvent( 19, "dsfcdg" )
		effectScript:RegisterEvent( 44, "afdg" )
		effectScript:RegisterEvent( 45, "gfhj" )
		effectScript:RegisterEvent( 48, "safdg" )
	end,

	sadsfg = function( effectScript )
		SetAnimation(S281_magic_H025_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfcdg = function( effectScript )
		AttachAvatarPosEffect(false, S281_magic_H025_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 50), 1, 100, "S400_1")
	end,

	afdg = function( effectScript )
		CameraShake()
	end,

	gfhj = function( effectScript )
		AttachAvatarPosEffect(false, S281_magic_H025_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.3, 100, "S350_2")
	end,

	safdg = function( effectScript )
			DamageEffect(S281_magic_H025_attack.info_pool[effectScript.ID].Attacker, S281_magic_H025_attack.info_pool[effectScript.ID].Targeter, S281_magic_H025_attack.info_pool[effectScript.ID].AttackType, S281_magic_H025_attack.info_pool[effectScript.ID].AttackDataList, S281_magic_H025_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
