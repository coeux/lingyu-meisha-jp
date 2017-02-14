M104_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M104_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M104_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M104_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("M104_pugong_3")
		PreLoadAvatar("M104_pugong_1")
		PreLoadAvatar("M104_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 21, "fdgh" )
		effectScript:RegisterEvent( 22, "arwqr" )
		effectScript:RegisterEvent( 27, "sfdg" )
		effectScript:RegisterEvent( 29, "sfdsgf" )
	end,

	a = function( effectScript )
		SetAnimation(M104_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	fdgh = function( effectScript )
		AttachAvatarPosEffect(false, M104_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 1, 100, "M104_pugong_3")
	end,

	arwqr = function( effectScript )
		AttachAvatarPosEffect(false, M104_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 1, -100, "M104_pugong_1")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, M104_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "M104_pugong_2")
	end,

	sfdsgf = function( effectScript )
			DamageEffect(M104_normal_attack.info_pool[effectScript.ID].Attacker, M104_normal_attack.info_pool[effectScript.ID].Targeter, M104_normal_attack.info_pool[effectScript.ID].AttackType, M104_normal_attack.info_pool[effectScript.ID].AttackDataList, M104_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
