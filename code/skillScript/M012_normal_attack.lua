M012_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M012_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M012_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M012_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("M012_pugong_1")
		PreLoadAvatar("M012_pugong_2")
		PreLoadAvatar("M012_pugong_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfg" )
		effectScript:RegisterEvent( 20, "sfdg" )
		effectScript:RegisterEvent( 21, "sdfdh" )
		effectScript:RegisterEvent( 25, "sfdgfh" )
		effectScript:RegisterEvent( 27, "fdsgh" )
	end,

	sfg = function( effectScript )
		SetAnimation(M012_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, M012_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(25, 10), 1.5, 100, "M012_pugong_1")
	end,

	sdfdh = function( effectScript )
		AttachAvatarPosEffect(false, M012_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 0.8, 100, "M012_pugong_2")
	end,

	sfdgfh = function( effectScript )
		AttachAvatarPosEffect(false, M012_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -2, 100, "M012_pugong_3")
	end,

	fdsgh = function( effectScript )
			DamageEffect(M012_normal_attack.info_pool[effectScript.ID].Attacker, M012_normal_attack.info_pool[effectScript.ID].Targeter, M012_normal_attack.info_pool[effectScript.ID].AttackType, M012_normal_attack.info_pool[effectScript.ID].AttackDataList, M012_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
