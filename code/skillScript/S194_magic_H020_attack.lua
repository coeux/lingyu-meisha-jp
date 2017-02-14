S194_magic_H020_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S194_magic_H020_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S194_magic_H020_attack.info_pool[effectScript.ID].Attacker)
        
		S194_magic_H020_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0201")
		PreLoadAvatar("S192_1")
		PreLoadAvatar("S192_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 11, "dsfrf" )
		effectScript:RegisterEvent( 43, "aaaa" )
		effectScript:RegisterEvent( 44, "asff" )
		effectScript:RegisterEvent( 45, "aaa" )
	end,

	aa = function( effectScript )
		SetAnimation(S194_magic_H020_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s0201")
	end,

	dsfrf = function( effectScript )
		AttachAvatarPosEffect(false, S194_magic_H020_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -25), 2.2, -100, "S192_1")
	end,

	aaaa = function( effectScript )
			DamageEffect(S194_magic_H020_attack.info_pool[effectScript.ID].Attacker, S194_magic_H020_attack.info_pool[effectScript.ID].Targeter, S194_magic_H020_attack.info_pool[effectScript.ID].AttackType, S194_magic_H020_attack.info_pool[effectScript.ID].AttackDataList, S194_magic_H020_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	asff = function( effectScript )
		AttachAvatarPosEffect(false, S194_magic_H020_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S192_2")
	end,

	aaa = function( effectScript )
		CameraShake()
	end,

}
