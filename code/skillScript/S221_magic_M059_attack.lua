S221_magic_M059_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S221_magic_M059_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S221_magic_M059_attack.info_pool[effectScript.ID].Attacker)
		S221_magic_M059_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S221_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "A" )
		effectScript:RegisterEvent( 19, "AS" )
		effectScript:RegisterEvent( 22, "s" )
	end,

	A = function( effectScript )
		SetAnimation(S221_magic_M059_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	AS = function( effectScript )
		AttachAvatarPosEffect(false, S221_magic_M059_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 1, 100, "S221_1")
		DamageEffect(S221_magic_M059_attack.info_pool[effectScript.ID].Attacker, S221_magic_M059_attack.info_pool[effectScript.ID].Targeter, S221_magic_M059_attack.info_pool[effectScript.ID].AttackType, S221_magic_M059_attack.info_pool[effectScript.ID].AttackDataList, S221_magic_M059_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	s = function( effectScript )
		CameraShake()
	end,

}
