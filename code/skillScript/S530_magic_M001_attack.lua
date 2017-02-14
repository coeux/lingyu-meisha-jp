S530_magic_M001_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S530_magic_M001_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S530_magic_M001_attack.info_pool[effectScript.ID].Attacker)
        
		S530_magic_M001_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S202")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfd" )
		effectScript:RegisterEvent( 27, "fdsgfdg" )
		effectScript:RegisterEvent( 30, "wre" )
	end,

	sfd = function( effectScript )
		SetAnimation(S530_magic_M001_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	fdsgfdg = function( effectScript )
		AttachAvatarPosEffect(false, S530_magic_M001_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S202")
	end,

	wre = function( effectScript )
			DamageEffect(S530_magic_M001_attack.info_pool[effectScript.ID].Attacker, S530_magic_M001_attack.info_pool[effectScript.ID].Targeter, S530_magic_M001_attack.info_pool[effectScript.ID].AttackType, S530_magic_M001_attack.info_pool[effectScript.ID].AttackDataList, S530_magic_M001_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
