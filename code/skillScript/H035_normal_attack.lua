H035_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H035_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H035_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H035_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("attack_03501")
		PreLoadAvatar("H035_pugong_1")
		PreLoadAvatar("H035_pugong_2")
		PreLoadSound("attack_03502")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 14, "dsfdgh" )
		effectScript:RegisterEvent( 17, "sfg" )
		effectScript:RegisterEvent( 18, "xianshishanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H035_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("attack_03501")
	end,

	dsfdgh = function( effectScript )
		AttachAvatarPosEffect(false, H035_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 40), 1, 100, "H035_pugong_1")
	end,

	sfg = function( effectScript )
		AttachAvatarPosEffect(false, H035_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 60), 2, 100, "H035_pugong_2")
		PlaySound("attack_03502")
	end,

	xianshishanghai = function( effectScript )
			DamageEffect(H035_normal_attack.info_pool[effectScript.ID].Attacker, H035_normal_attack.info_pool[effectScript.ID].Targeter, H035_normal_attack.info_pool[effectScript.ID].AttackType, H035_normal_attack.info_pool[effectScript.ID].AttackDataList, H035_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
