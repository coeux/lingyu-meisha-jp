H025_auto285_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H025_auto285_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H025_auto285_attack.info_pool[effectScript.ID].Attacker)
        
		H025_auto285_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S402_1")
		PreLoadAvatar("S402_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfbgfh" )
		effectScript:RegisterEvent( 28, "fdgfh" )
		effectScript:RegisterEvent( 45, "gbfhgj" )
		effectScript:RegisterEvent( 47, "sgfdh" )
	end,

	dfbgfh = function( effectScript )
		SetAnimation(H025_auto285_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fdgfh = function( effectScript )
		AttachAvatarPosEffect(false, H025_auto285_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S402_1")
	end,

	gbfhgj = function( effectScript )
		AttachAvatarPosEffect(false, H025_auto285_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S402_2")
	end,

	sgfdh = function( effectScript )
			DamageEffect(H025_auto285_attack.info_pool[effectScript.ID].Attacker, H025_auto285_attack.info_pool[effectScript.ID].Targeter, H025_auto285_attack.info_pool[effectScript.ID].AttackType, H025_auto285_attack.info_pool[effectScript.ID].AttackDataList, H025_auto285_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
