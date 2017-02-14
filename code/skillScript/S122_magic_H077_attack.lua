S122_magic_H077_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S122_magic_H077_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S122_magic_H077_attack.info_pool[effectScript.ID].Attacker)
		S122_magic_H077_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S122")
		PreLoadSound("zhushenhuanghun")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ddhfg" )
		effectScript:RegisterEvent( 15, "nfg" )
		effectScript:RegisterEvent( 26, "vcndh" )
		effectScript:RegisterEvent( 35, "vbnd" )
	end,

	ddhfg = function( effectScript )
		SetAnimation(S122_magic_H077_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	nfg = function( effectScript )
		AttachAvatarPosEffect(false, S122_magic_H077_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S122")
	end,

	vcndh = function( effectScript )
			DamageEffect(S122_magic_H077_attack.info_pool[effectScript.ID].Attacker, S122_magic_H077_attack.info_pool[effectScript.ID].Targeter, S122_magic_H077_attack.info_pool[effectScript.ID].AttackType, S122_magic_H077_attack.info_pool[effectScript.ID].AttackDataList, S122_magic_H077_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
		PlaySound("zhushenhuanghun")
	end,

	vbnd = function( effectScript )
		CameraShake()
	end,

}
