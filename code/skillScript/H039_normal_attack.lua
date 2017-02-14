H039_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H039_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H039_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H039_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H039_daoguang")
		PreLoadSound("attack_03901")
		PreLoadAvatar("H039_pugong_1")
		PreLoadAvatar("H036_pugong_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 21, "zhuizhong" )
		effectScript:RegisterEvent( 22, "quchu" )
		effectScript:RegisterEvent( 23, "sfsdgh" )
		effectScript:RegisterEvent( 24, "xianshi" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H039_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	zhuizhong = function( effectScript )
		AttachAvatarPosEffect(false, H039_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-40, 50), 1, 100, "H039_daoguang")
		PlaySound("attack_03901")
	end,

	quchu = function( effectScript )
		AttachAvatarPosEffect(false, H039_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H039_pugong_1")
	end,

	sfsdgh = function( effectScript )
		AttachAvatarPosEffect(false, H039_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1.8, 100, "H036_pugong_1")
	end,

	xianshi = function( effectScript )
			DamageEffect(H039_normal_attack.info_pool[effectScript.ID].Attacker, H039_normal_attack.info_pool[effectScript.ID].Targeter, H039_normal_attack.info_pool[effectScript.ID].AttackType, H039_normal_attack.info_pool[effectScript.ID].AttackDataList, H039_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
