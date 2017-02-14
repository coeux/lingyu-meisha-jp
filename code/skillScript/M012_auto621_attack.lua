M012_auto621_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M012_auto621_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M012_auto621_attack.info_pool[effectScript.ID].Attacker)
        
		M012_auto621_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("s621_1")
		PreLoadAvatar("s621_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdg" )
		effectScript:RegisterEvent( 27, "dsgg" )
		effectScript:RegisterEvent( 38, "dsgh" )
		effectScript:RegisterEvent( 40, "sdfdg" )
	end,

	fdg = function( effectScript )
		SetAnimation(M012_auto621_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dsgg = function( effectScript )
		AttachAvatarPosEffect(false, M012_auto621_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 1.3, 100, "s621_1")
	end,

	dsgh = function( effectScript )
		AttachAvatarPosEffect(false, M012_auto621_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2.5, 100, "s621_2")
	end,

	sdfdg = function( effectScript )
			DamageEffect(M012_auto621_attack.info_pool[effectScript.ID].Attacker, M012_auto621_attack.info_pool[effectScript.ID].Targeter, M012_auto621_attack.info_pool[effectScript.ID].AttackType, M012_auto621_attack.info_pool[effectScript.ID].AttackDataList, M012_auto621_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
