S402_magic_M083_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S402_magic_M083_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S402_magic_M083_attack.info_pool[effectScript.ID].Attacker)
		S402_magic_M083_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S402_1")
		PreLoadSound("lianyukuanglei")
		PreLoadAvatar("S402_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "A" )
		effectScript:RegisterEvent( 18, "S" )
		effectScript:RegisterEvent( 22, "D" )
		effectScript:RegisterEvent( 24, "F" )
	end,

	A = function( effectScript )
		SetAnimation(S402_magic_M083_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	S = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_M083_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S402_1")
		PlaySound("lianyukuanglei")
	end,

	D = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_M083_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S402_3")
	CameraShake()
	end,

	F = function( effectScript )
			DamageEffect(S402_magic_M083_attack.info_pool[effectScript.ID].Attacker, S402_magic_M083_attack.info_pool[effectScript.ID].Targeter, S402_magic_M083_attack.info_pool[effectScript.ID].AttackType, S402_magic_M083_attack.info_pool[effectScript.ID].AttackDataList, S402_magic_M083_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
