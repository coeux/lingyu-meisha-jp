S480_magic_H031_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S480_magic_H031_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S480_magic_H031_attack.info_pool[effectScript.ID].Attacker)
        
		S480_magic_H031_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0313")
		PreLoadSound("s0314")
		PreLoadAvatar("S480_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsf" )
		effectScript:RegisterEvent( 17, "dsfdh" )
		effectScript:RegisterEvent( 41, "sfd" )
	end,

	dsf = function( effectScript )
		SetAnimation(S480_magic_H031_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s0313")
		PlaySound("s0314")
	end,

	dsfdh = function( effectScript )
		AttachAvatarPosEffect(false, S480_magic_H031_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 70), 1.2, 100, "S480_1")
	end,

	sfd = function( effectScript )
			DamageEffect(S480_magic_H031_attack.info_pool[effectScript.ID].Attacker, S480_magic_H031_attack.info_pool[effectScript.ID].Targeter, S480_magic_H031_attack.info_pool[effectScript.ID].AttackType, S480_magic_H031_attack.info_pool[effectScript.ID].AttackDataList, S480_magic_H031_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
