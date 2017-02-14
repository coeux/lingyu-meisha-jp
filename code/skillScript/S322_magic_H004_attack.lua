S322_magic_H004_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S322_magic_H004_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S322_magic_H004_attack.info_pool[effectScript.ID].Attacker)
		S322_magic_H004_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S322")
		PreLoadSound("jiuxinglingri")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asd" )
		effectScript:RegisterEvent( 36, "vv" )
		effectScript:RegisterEvent( 43, "aaaa" )
	end,

	asd = function( effectScript )
		SetAnimation(S322_magic_H004_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	vv = function( effectScript )
		AttachAvatarPosEffect(false, S322_magic_H004_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S322")
		PlaySound("jiuxinglingri")
	end,

	aaaa = function( effectScript )
			DamageEffect(S322_magic_H004_attack.info_pool[effectScript.ID].Attacker, S322_magic_H004_attack.info_pool[effectScript.ID].Targeter, S322_magic_H004_attack.info_pool[effectScript.ID].AttackType, S322_magic_H004_attack.info_pool[effectScript.ID].AttackDataList, S322_magic_H004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
