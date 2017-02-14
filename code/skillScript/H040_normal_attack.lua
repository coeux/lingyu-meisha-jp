H040_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H040_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H040_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H040_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H040_pugong_1")
		PreLoadAvatar("S492_3")
		PreLoadSound("attack_04001")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 20, "quchu" )
		effectScript:RegisterEvent( 25, "zhuizhong" )
		effectScript:RegisterEvent( 26, "xianshi" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H040_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	quchu = function( effectScript )
		end,

	zhuizhong = function( effectScript )
		AttachAvatarPosEffect(false, H040_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 1.8, 100, "H040_pugong_1")
	AttachAvatarPosEffect(false, H040_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 1.2, -100, "S492_3")
		PlaySound("attack_04001")
	end,

	xianshi = function( effectScript )
			DamageEffect(H040_normal_attack.info_pool[effectScript.ID].Attacker, H040_normal_attack.info_pool[effectScript.ID].Targeter, H040_normal_attack.info_pool[effectScript.ID].AttackType, H040_normal_attack.info_pool[effectScript.ID].AttackDataList, H040_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
