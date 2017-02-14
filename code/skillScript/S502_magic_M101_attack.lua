S502_magic_M101_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S502_magic_M101_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S502_magic_M101_attack.info_pool[effectScript.ID].Attacker)
        
		S502_magic_M101_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("gs0082")
		PreLoadSound("g0082")
		PreLoadAvatar("S502_yinbo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfd" )
		effectScript:RegisterEvent( 23, "dsfd" )
		effectScript:RegisterEvent( 32, "sads" )
	end,

	sfd = function( effectScript )
		SetAnimation(S502_magic_M101_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("gs0082")
		PlaySound("g0082")
	end,

	dsfd = function( effectScript )
		AttachAvatarPosEffect(false, S502_magic_M101_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 200), 2.3, 100, "S502_yinbo")
	end,

	sads = function( effectScript )
			DamageEffect(S502_magic_M101_attack.info_pool[effectScript.ID].Attacker, S502_magic_M101_attack.info_pool[effectScript.ID].Targeter, S502_magic_M101_attack.info_pool[effectScript.ID].AttackType, S502_magic_M101_attack.info_pool[effectScript.ID].AttackDataList, S502_magic_M101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
