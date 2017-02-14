S221_magic_M020_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S221_magic_M020_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S221_magic_M020_attack.info_pool[effectScript.ID].Attacker)
		S221_magic_M020_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("monster")
		PreLoadAvatar("S221_1")
		PreLoadSound("leitingyiji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 40, "d" )
		effectScript:RegisterEvent( 42, "x" )
	end,

	a = function( effectScript )
		SetAnimation(S221_magic_M020_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("monster")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S221_magic_M020_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 10), 1, 100, "S221_1")
		PlaySound("leitingyiji")
	end,

	x = function( effectScript )
		CameraShake()
		DamageEffect(S221_magic_M020_attack.info_pool[effectScript.ID].Attacker, S221_magic_M020_attack.info_pool[effectScript.ID].Targeter, S221_magic_M020_attack.info_pool[effectScript.ID].AttackType, S221_magic_M020_attack.info_pool[effectScript.ID].AttackDataList, S221_magic_M020_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
