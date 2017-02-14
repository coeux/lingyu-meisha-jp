S221_magic_M006_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S221_magic_M006_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S221_magic_M006_attack.info_pool[effectScript.ID].Attacker)
		S221_magic_M006_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("slime")
		PreLoadAvatar("M006_1")
		PreLoadAvatar("S221_1")
		PreLoadSound("leitingyiji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdfg" )
		effectScript:RegisterEvent( 31, "sdfa" )
		effectScript:RegisterEvent( 44, "vzxfa" )
		effectScript:RegisterEvent( 47, "svs" )
	end,

	sdfg = function( effectScript )
		SetAnimation(S221_magic_M006_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	sdfa = function( effectScript )
			PlaySound("slime")
	end,

	vzxfa = function( effectScript )
		AttachAvatarPosEffect(false, S221_magic_M006_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 1, 100, "M006_1")
	end,

	svs = function( effectScript )
		AttachAvatarPosEffect(false, S221_magic_M006_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S221_1")
		DamageEffect(S221_magic_M006_attack.info_pool[effectScript.ID].Attacker, S221_magic_M006_attack.info_pool[effectScript.ID].Targeter, S221_magic_M006_attack.info_pool[effectScript.ID].AttackType, S221_magic_M006_attack.info_pool[effectScript.ID].AttackDataList, S221_magic_M006_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
		PlaySound("leitingyiji")
	end,

}
