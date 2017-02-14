S322_magic_H090_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S322_magic_H090_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S322_magic_H090_attack.info_pool[effectScript.ID].Attacker)
		S322_magic_H090_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadAvatar("S322")
		PreLoadSound("jiuxinglingri")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 27, "d" )
		effectScript:RegisterEvent( 31, "f" )
		effectScript:RegisterEvent( 34, "axczc" )
	end,

	a = function( effectScript )
		SetAnimation(S322_magic_H090_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("odin")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S322_magic_H090_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S322")
	CameraShake()
		PlaySound("jiuxinglingri")
	end,

	f = function( effectScript )
			DamageEffect(S322_magic_H090_attack.info_pool[effectScript.ID].Attacker, S322_magic_H090_attack.info_pool[effectScript.ID].Targeter, S322_magic_H090_attack.info_pool[effectScript.ID].AttackType, S322_magic_H090_attack.info_pool[effectScript.ID].AttackDataList, S322_magic_H090_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	axczc = function( effectScript )
		CameraShake()
	end,

}
