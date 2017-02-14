S584_magic_H011_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S584_magic_H011_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S584_magic_H011_attack.info_pool[effectScript.ID].Attacker)
        
		S584_magic_H011_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01101")
		PreLoadSound("skill_01102")
		PreLoadAvatar("S252_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 12, "sdfdsh" )
		effectScript:RegisterEvent( 15, "ewfef" )
		effectScript:RegisterEvent( 25, "c" )
		effectScript:RegisterEvent( 28, "z" )
		effectScript:RegisterEvent( 30, "t" )
		effectScript:RegisterEvent( 32, "v" )
	end,

	a = function( effectScript )
		SetAnimation(S584_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_01101")
	end,

	sdfdsh = function( effectScript )
			PlaySound("skill_01102")
	end,

	ewfef = function( effectScript )
		AttachAvatarPosEffect(false, S584_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 2.5, 100, "S252_1")
	end,

	c = function( effectScript )
			DamageEffect(S584_magic_H011_attack.info_pool[effectScript.ID].Attacker, S584_magic_H011_attack.info_pool[effectScript.ID].Targeter, S584_magic_H011_attack.info_pool[effectScript.ID].AttackType, S584_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S584_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	z = function( effectScript )
		CameraShake()
	end,

	t = function( effectScript )
			DamageEffect(S584_magic_H011_attack.info_pool[effectScript.ID].Attacker, S584_magic_H011_attack.info_pool[effectScript.ID].Targeter, S584_magic_H011_attack.info_pool[effectScript.ID].AttackType, S584_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S584_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	v = function( effectScript )
			DamageEffect(S584_magic_H011_attack.info_pool[effectScript.ID].Attacker, S584_magic_H011_attack.info_pool[effectScript.ID].Targeter, S584_magic_H011_attack.info_pool[effectScript.ID].AttackType, S584_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S584_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
