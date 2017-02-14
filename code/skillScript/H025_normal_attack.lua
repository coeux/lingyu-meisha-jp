H025_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H025_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H025_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H025_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H025_pugong_1")
		PreLoadAvatar("H025_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 17, "cdgfdh" )
		effectScript:RegisterEvent( 27, "fdsgh" )
		effectScript:RegisterEvent( 29, "ss" )
	end,

	a = function( effectScript )
		SetAnimation(H025_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	cdgfdh = function( effectScript )
		AttachAvatarPosEffect(false, H025_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 20), 1, 100, "H025_pugong_1")
	end,

	fdsgh = function( effectScript )
		AttachAvatarPosEffect(false, H025_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1.5, 100, "H025_pugong_2")
	end,

	ss = function( effectScript )
			DamageEffect(H025_normal_attack.info_pool[effectScript.ID].Attacker, H025_normal_attack.info_pool[effectScript.ID].Targeter, H025_normal_attack.info_pool[effectScript.ID].AttackType, H025_normal_attack.info_pool[effectScript.ID].AttackDataList, H025_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
