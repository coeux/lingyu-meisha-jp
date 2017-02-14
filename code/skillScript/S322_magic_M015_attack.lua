S322_magic_M015_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S322_magic_M015_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S322_magic_M015_attack.info_pool[effectScript.ID].Attacker)
		S322_magic_M015_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S322")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "A" )
		effectScript:RegisterEvent( 15, "AA" )
		effectScript:RegisterEvent( 19, "AAS" )
		effectScript:RegisterEvent( 25, "ASDD" )
	end,

	A = function( effectScript )
		SetAnimation(S322_magic_M015_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	AA = function( effectScript )
		AttachAvatarPosEffect(false, S322_magic_M015_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S322")
	end,

	AAS = function( effectScript )
			DamageEffect(S322_magic_M015_attack.info_pool[effectScript.ID].Attacker, S322_magic_M015_attack.info_pool[effectScript.ID].Targeter, S322_magic_M015_attack.info_pool[effectScript.ID].AttackType, S322_magic_M015_attack.info_pool[effectScript.ID].AttackDataList, S322_magic_M015_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	ASDD = function( effectScript )
		end,

}
