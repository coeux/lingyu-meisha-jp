S91_magic_H011_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S91_magic_H011_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S91_magic_H011_attack.info_pool[effectScript.ID].Attacker)
        
		S91_magic_H011_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01101")
		PreLoadSound("skill_01102")
		PreLoadAvatar("S252_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 12, "dsgdfhg" )
		effectScript:RegisterEvent( 15, "ewfef" )
		effectScript:RegisterEvent( 22, "z" )
		effectScript:RegisterEvent( 24, "c" )
		effectScript:RegisterEvent( 27, "t" )
		effectScript:RegisterEvent( 29, "v" )
	end,

	a = function( effectScript )
		SetAnimation(S91_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_01101")
	end,

	dsgdfhg = function( effectScript )
			PlaySound("skill_01102")
	end,

	ewfef = function( effectScript )
		AttachAvatarPosEffect(false, S91_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 100), 2.5, 100, "S252_1")
	end,

	z = function( effectScript )
		CameraShake()
	end,

	c = function( effectScript )
			DamageEffect(S91_magic_H011_attack.info_pool[effectScript.ID].Attacker, S91_magic_H011_attack.info_pool[effectScript.ID].Targeter, S91_magic_H011_attack.info_pool[effectScript.ID].AttackType, S91_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S91_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	t = function( effectScript )
			DamageEffect(S91_magic_H011_attack.info_pool[effectScript.ID].Attacker, S91_magic_H011_attack.info_pool[effectScript.ID].Targeter, S91_magic_H011_attack.info_pool[effectScript.ID].AttackType, S91_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S91_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	v = function( effectScript )
			DamageEffect(S91_magic_H011_attack.info_pool[effectScript.ID].Attacker, S91_magic_H011_attack.info_pool[effectScript.ID].Targeter, S91_magic_H011_attack.info_pool[effectScript.ID].AttackType, S91_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S91_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
