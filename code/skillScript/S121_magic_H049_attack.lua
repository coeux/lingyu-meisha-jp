S121_magic_H049_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S121_magic_H049_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S121_magic_H049_attack.info_pool[effectScript.ID].Attacker)
		S121_magic_H049_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S121")
		PreLoadSound("shenshengchongji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 22, "b" )
		effectScript:RegisterEvent( 24, "c" )
		effectScript:RegisterEvent( 26, "e" )
	end,

	a = function( effectScript )
		SetAnimation(S121_magic_H049_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S121_magic_H049_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S121")
	CameraShake()
		PlaySound("shenshengchongji")
	end,

	c = function( effectScript )
			DamageEffect(S121_magic_H049_attack.info_pool[effectScript.ID].Attacker, S121_magic_H049_attack.info_pool[effectScript.ID].Targeter, S121_magic_H049_attack.info_pool[effectScript.ID].AttackType, S121_magic_H049_attack.info_pool[effectScript.ID].AttackDataList, S121_magic_H049_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	e = function( effectScript )
		CameraShake()
	end,

}
