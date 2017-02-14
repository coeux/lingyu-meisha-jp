M001_auto581_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M001_auto581_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M001_auto581_attack.info_pool[effectScript.ID].Attacker)
        
		M001_auto581_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S202_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfd" )
		effectScript:RegisterEvent( 27, "fdsgfdg" )
		effectScript:RegisterEvent( 30, "fg" )
	end,

	sfd = function( effectScript )
		SetAnimation(M001_auto581_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	fdsgfdg = function( effectScript )
		AttachAvatarPosEffect(false, M001_auto581_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -2, 100, "S202_1")
	end,

	fg = function( effectScript )
			DamageEffect(M001_auto581_attack.info_pool[effectScript.ID].Attacker, M001_auto581_attack.info_pool[effectScript.ID].Targeter, M001_auto581_attack.info_pool[effectScript.ID].AttackType, M001_auto581_attack.info_pool[effectScript.ID].AttackDataList, M001_auto581_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
